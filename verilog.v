`timescale 1ns / 1ps

module top_module(
    input  wire        clkr,
    input  wire        rxr,
    input  wire [4:0]  btnr,
    output wire        spr,
    output wire [7:0]  hr,
    output wire [7:0]  mr,
    output wire [4:0]  date,
    output wire [4:0]  month,
    output wire [7:0]  year,
    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        dp
);

    // ---------------- BUTTON EDGE DETECTION ----------------
    reg [4:0] btnr_prev;
    reg [4:0] btnr_sync;
    wire btn_time_edge;
    wire btn_date_edge;
    wire btn_stopwatch;
    wire btn_sw_reset;      // BTNR (Right) - Reset stopwatch
    wire btn_sw_startstop;  // BTND (Down) - Start/Stop stopwatch
    
    always @(posedge clkr) begin
        btnr_sync <= btnr;
        btnr_prev <= btnr_sync;
    end
    
    assign btn_time_edge = btnr_sync[0] && !btnr_prev[0];
    assign btn_date_edge = btnr_sync[1] && !btnr_prev[1];
    assign btn_stopwatch = btnr_sync[2];  // BTNL - Hold to show stopwatch
    assign btn_sw_reset = btnr_sync[3] && !btnr_prev[3];     // BTNR - Edge detect for reset
    assign btn_sw_startstop = btnr_sync[4] && !btnr_prev[4]; // BTND - Edge detect for start/stop

    // ---------------- UART TRANSMITTER ----------------
    reg tx_start;
    reg [7:0] tx_data;
    wire tx_busy;
    wire tx_out;
    
    uart_tx #(
        .BAUD_RATE(9600),
        .CLOCK_FREQ(100_000_000)
    ) uart_tx_inst (
        .clk(clkr),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx_out),
        .tx_busy(tx_busy)
    );
    
    assign spr = tx_out;

    // State machine to send button press notification
    reg [1:0] tx_state;
    localparam TX_IDLE = 0, TX_WAIT_BUSY = 1, TX_WAIT_DONE = 2;
    
    always @(posedge clkr) begin
        case(tx_state)
            TX_IDLE: begin
                tx_start <= 0;
                if (btn_time_edge) begin
                    tx_data <= 8'd0;
                    tx_start <= 1;
                    tx_state <= TX_WAIT_BUSY;
                end
                else if (btn_date_edge) begin
                    tx_data <= 8'd1;
                    tx_start <= 1;
                    tx_state <= TX_WAIT_BUSY;
                end
            end
            
            TX_WAIT_BUSY: begin
                tx_start <= 0;
                if (tx_busy) begin
                    tx_state <= TX_WAIT_DONE;
                end
            end
            
            TX_WAIT_DONE: begin
                if (!tx_busy) begin
                    tx_state <= TX_IDLE;
                end
            end
            
            default: tx_state <= TX_IDLE;
        endcase
    end

    // ---------------- UART RECEIVER FOR TIME/DATE DATA ----------------
    wire rx_ready;
    wire [7:0] rx_data;
    
    uart_rx #(
        .BAUD_RATE(9600),
        .CLOCK_FREQ(100_000_000)
    ) uart_rx_inst (
        .clk(clkr),
        .rx(rxr),
        .rx_ready(rx_ready),
        .rx_data(rx_data)
    );

    // ---------------- DATA RECEPTION AND LIVE CLOCK ----------------
    reg [2:0] rx_state;
    reg [1:0] byte_count;
    
    localparam RX_IDLE = 0, RX_TIME = 1, RX_DATE = 2;
    
    reg [7:0] hr_reg, mr_reg, sec_reg;
    reg [4:0] date_reg, month_reg;
    reg [7:0] year_reg;
    
    // Output to LEDs
    assign hr = hr_reg;
    assign mr = mr_reg;
    assign date = date_reg;
    assign month = month_reg;
    assign year = year_reg;
    
    // 1Hz clock generator for live time
    reg [27:0] clk_1hz_counter;
    reg clk_1hz_pulse;
    
    always @(posedge clkr) begin
        if (clk_1hz_counter == 100_000_000 - 1) begin
            clk_1hz_counter <= 0;
            clk_1hz_pulse <= 1;
        end else begin
            clk_1hz_counter <= clk_1hz_counter + 1;
            clk_1hz_pulse <= 0;
        end
    end
    
    // Combined reception and live clock update
    always @(posedge clkr) begin
        case(rx_state)
            RX_IDLE: begin
                byte_count <= 0;
                if (btn_time_edge) begin
                    rx_state <= RX_TIME;
                end
                else if (btn_date_edge) begin
                    rx_state <= RX_DATE;
                end
                // Live clock update when idle
                else if (clk_1hz_pulse) begin
                    if (sec_reg == 59) begin
                        sec_reg <= 0;
                        if (mr_reg == 59) begin
                            mr_reg <= 0;
                            if (hr_reg == 23) begin
                                hr_reg <= 0;
                            end else begin
                                hr_reg <= hr_reg + 1;
                            end
                        end else begin
                            mr_reg <= mr_reg + 1;
                        end
                    end else begin
                        sec_reg <= sec_reg + 1;
                    end
                end
            end
            
            RX_TIME: begin
                if (rx_ready) begin
                    case(byte_count)
                        2'd0: hr_reg <= rx_data;
                        2'd1: mr_reg <= rx_data;
                        2'd2: sec_reg <= rx_data;
                    endcase
                    
                    if (byte_count == 2'd2) begin
                        rx_state <= RX_IDLE;
                    end else begin
                        byte_count <= byte_count + 1;
                    end
                end
            end
            
            RX_DATE: begin
                if (rx_ready) begin
                    case(byte_count)
                        2'd0: date_reg <= rx_data[4:0];
                        2'd1: month_reg <= rx_data[4:0];
                        2'd2: year_reg <= rx_data;
                    endcase
                    
                    if (byte_count == 2'd2) begin
                        rx_state <= RX_IDLE;
                    end else begin
                        byte_count <= byte_count + 1;
                    end
                end
            end
            
            default: rx_state <= RX_IDLE;
        endcase
    end

    // ---------------- STOPWATCH MODULE ----------------
    wire [6:0] seg_sw;
    wire [3:0] an_sw;
    wire dp_sw;

    stopwatch_simple sw_inst (
        .CLK100MHZ(clkr),
        .btn_reset(btn_sw_reset),
        .btn_startstop(btn_sw_startstop),
        .seg(seg_sw),
        .an(an_sw),
        .dp(dp_sw)
    );

    // ---------------- 7-SEGMENT DISPLAY FOR TIME/DATE ----------------
    wire [6:0] seg_time;
    wire [3:0] an_time;
    wire dp_time;
    
    // Display mode: 0=time, 1=date
    reg display_mode;
    
    always @(posedge clkr) begin
        if (btn_time_edge) begin
            display_mode <= 0;  // Show time
        end else if (btn_date_edge) begin
            display_mode <= 1;  // Show date
        end
    end
    
    seven_seg_display display_inst (
        .clk(clkr),
        .hr(hr_reg),
        .mr(mr_reg),
        .date(date_reg),
        .month(month_reg),
        .mode(display_mode),
        .seg(seg_time),
        .an(an_time),
        .dp(dp_time)
    );

    // ---------------- DISPLAY MUX ----------------
    // Show stopwatch when BTNL pressed, otherwise show time/date
    assign seg = btn_stopwatch ? seg_sw : seg_time;
    assign an = btn_stopwatch ? an_sw : an_time;
    assign dp = btn_stopwatch ? dp_sw : dp_time;

endmodule

// ============================================================================
// 7-SEGMENT DISPLAY MODULE FOR TIME AND DATE
// ============================================================================
module seven_seg_display(
    input wire clk,
    input wire [7:0] hr,
    input wire [7:0] mr,
    input wire [4:0] date,
    input wire [4:0] month,
    input wire mode,  // 0=time, 1=date
    output reg [6:0] seg,
    output reg [3:0] an,
    output wire dp
);

    assign dp = 1'b1;  // Decimal point off
    
    // Convert binary to BCD
    wire [3:0] hr_tens = hr / 10;
    wire [3:0] hr_ones = hr % 10;
    wire [3:0] mr_tens = mr / 10;
    wire [3:0] mr_ones = mr % 10;
    wire [3:0] date_tens = date / 10;
    wire [3:0] date_ones = date % 10;
    wire [3:0] month_tens = month / 10;
    wire [3:0] month_ones = month % 10;
    
    // Multiplexing counter
    reg [1:0] digit_select;
    reg [16:0] refresh_counter;
    
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == 100000) begin
            refresh_counter <= 0;
            digit_select <= digit_select + 1;
        end
    end
    
    // Select digit to display
    reg [3:0] bcd_digit;
    
    always @(*) begin
        if (mode == 0) begin
            // Time mode: HH:MM
            case(digit_select)
                2'b00: begin an = 4'b1110; bcd_digit = mr_ones; end
                2'b01: begin an = 4'b1101; bcd_digit = mr_tens; end
                2'b10: begin an = 4'b1011; bcd_digit = hr_ones; end
                2'b11: begin an = 4'b0111; bcd_digit = hr_tens; end
            endcase
        end else begin
            // Date mode: DD:MM
            case(digit_select)
                2'b00: begin an = 4'b1110; bcd_digit = month_ones; end
                2'b01: begin an = 4'b1101; bcd_digit = month_tens; end
                2'b10: begin an = 4'b1011; bcd_digit = date_ones; end
                2'b11: begin an = 4'b0111; bcd_digit = date_tens; end
            endcase
        end
    end
    
    // BCD to 7-segment decoder (active low)
    always @(*) begin
        case(bcd_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule


// UART TRANSMITTER MODULE

module uart_tx #(
    parameter BAUD_RATE = 9600,
    parameter CLOCK_FREQ = 100_000_000
)(
    input wire clk,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);
    localparam integer CLK_PER_BIT = CLOCK_FREQ / BAUD_RATE;
    
    reg [15:0] clk_count;
    reg [3:0] bit_index;
    reg [7:0] tx_data_reg;
    reg [2:0] state;
    
    localparam IDLE = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT = 3'd3;
    
    initial begin
        tx = 1'b1;
        tx_busy = 1'b0;
        state = IDLE;
        clk_count = 0;
        bit_index = 0;
    end
    
    always @(posedge clk) begin
        case(state)
            IDLE: begin
                tx <= 1'b1;
                clk_count <= 0;
                bit_index <= 0;
                tx_busy <= 1'b0;
                
                if (tx_start) begin
                    tx_data_reg <= tx_data;
                    tx_busy <= 1'b1;
                    state <= START_BIT;
                end
            end
            
            START_BIT: begin
                tx <= 1'b0;
                if (clk_count < CLK_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    state <= DATA_BITS;
                end
            end
            
            DATA_BITS: begin
                tx <= tx_data_reg[bit_index];
                if (clk_count < CLK_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                    end else begin
                        bit_index <= 0;
                        state <= STOP_BIT;
                    end
                end
            end
            
            STOP_BIT: begin
                tx <= 1'b1;
                if (clk_count < CLK_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    state <= IDLE;
                end
            end
            
            default: state <= IDLE;
        endcase
    end
endmodule


// UART RECEIVER MODULE

module uart_rx #(
    parameter BAUD_RATE = 9600,
    parameter CLOCK_FREQ = 100_000_000
)(
    input wire clk,
    input wire rx,
    output reg rx_ready,
    output reg [7:0] rx_data
);
    localparam integer CLK_PER_BIT = CLOCK_FREQ / BAUD_RATE;
    
    reg [15:0] clk_count;
    reg [3:0] bit_index;
    reg [7:0] rx_data_reg;
    reg [2:0] state;
    reg rx_sync, rx_prev;
    
    localparam IDLE = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT = 3'd3;
    
    initial begin
        rx_ready = 1'b0;
        rx_data = 8'd0;
        state = IDLE;
        clk_count = 0;
        bit_index = 0;
    end
    
    always @(posedge clk) begin
        rx_sync <= rx;
        rx_prev <= rx_sync;
    end
    
    always @(posedge clk) begin
        rx_ready <= 1'b0;
        
        case(state)
            IDLE: begin
                clk_count <= 0;
                bit_index <= 0;
                
                if (rx_prev == 1'b1 && rx_sync == 1'b0) begin
                    state <= START_BIT;
                end
            end
            
            START_BIT: begin
                if (clk_count < (CLK_PER_BIT / 2) - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    if (rx_sync == 1'b0) begin
                        state <= DATA_BITS;
                    end else begin
                        state <= IDLE;
                    end
                end
            end
            
            DATA_BITS: begin
                if (clk_count < CLK_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    rx_data_reg[bit_index] <= rx_sync;
                    
                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                    end else begin
                        bit_index <= 0;
                        state <= STOP_BIT;
                    end
                end
            end
            
            STOP_BIT: begin
                if (clk_count < CLK_PER_BIT - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    rx_ready <= 1'b1;
                    rx_data <= rx_data_reg;
                    state <= IDLE;
                end
            end
            
            default: state <= IDLE;
        endcase
    end
endmodule


// STOPWATCH MODULE 

module stopwatch_simple(
    input  wire CLK100MHZ,
    input  wire btn_reset,      // Reset to 00:00
    input  wire btn_startstop,  // Toggle start/stop
    output reg  [6:0] seg,
    output reg  [3:0] an,
    output wire dp
);

    assign dp = 1'b1;  // Decimal point off
    
    // Stopwatch state: 0=stopped, 1=running
    reg running;
    
    // Toggle running state on button press
    always @(posedge CLK100MHZ) begin
        if (btn_reset) begin
            running <= 0;  // Stop when reset
        end else if (btn_startstop) begin
            running <= ~running;  // Toggle
        end
    end
    
    // 10Hz clock generator (100ms per tick for centiseconds)
    reg [26:0] cnt;
    reg tick_10hz;
    
    always @(posedge CLK100MHZ) begin
        if (cnt == 10_000_000 - 1) begin  // 100MHz / 10_000_000 = 10Hz
            cnt <= 0;
            tick_10hz <= 1;
        end else begin
            cnt <= cnt + 1;
            tick_10hz <= 0;
        end
    end
    
    // Stopwatch counters: MM:SS format
    reg [5:0] seconds;  // 0-59
    reg [5:0] minutes;  // 0-59
    reg [3:0] centisec; // 0-9 (tenths of second)
    
    always @(posedge CLK100MHZ) begin
        if (btn_reset) begin
            seconds <= 0;
            minutes <= 0;
            centisec <= 0;
        end else if (running && tick_10hz) begin
            if (centisec == 9) begin
                centisec <= 0;
                if (seconds == 59) begin
                    seconds <= 0;
                    if (minutes == 59) begin
                        minutes <= 0;
                    end else begin
                        minutes <= minutes + 1;
                    end
                end else begin
                    seconds <= seconds + 1;
                end
            end else begin
                centisec <= centisec + 1;
            end
        end
    end
    
    // Convert to BCD for display
    wire [3:0] s1 = seconds % 10;
    wire [3:0] s10 = seconds / 10;
    wire [3:0] m1 = minutes % 10;
    wire [3:0] m10 = minutes / 10;
    
    // Display multiplexing
    reg [1:0] sel;
    reg [16:0] refresh_cnt;
    
    always @(posedge CLK100MHZ) begin
        refresh_cnt <= refresh_cnt + 1;
        if (refresh_cnt == 100_000) begin
            refresh_cnt <= 0;
            sel <= sel + 1;
        end
    end
    
    // Select digit to display
    reg [3:0] digit;
    
    always @(*) begin
        case(sel)
            2'b00: begin an = 4'b1110; digit = s1; end   // Rightmost: seconds ones
            2'b01: begin an = 4'b1101; digit = s10; end  // seconds tens
            2'b10: begin an = 4'b1011; digit = m1; end   // minutes ones
            2'b11: begin an = 4'b0111; digit = m10; end  // Leftmost: minutes tens
        endcase
    end
    
    // BCD to 7-segment decoder (active low)
    always @(*) begin
        case(digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule
