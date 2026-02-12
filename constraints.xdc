## Clock Signal (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clkr]
set_property IOSTANDARD LVCMOS33 [get_ports clkr]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clkr]

## USB-UART Bridge (Serial Communication)
## RX (FPGA receives from PC) - corresponds to TXD from FT2232HQ
set_property PACKAGE_PIN B18 [get_ports rxr]
set_property IOSTANDARD LVCMOS33 [get_ports rxr]

## TX (FPGA transmits to PC) - corresponds to RXD to FT2232HQ
set_property PACKAGE_PIN A18 [get_ports spr]
set_property IOSTANDARD LVCMOS33 [get_ports spr]

## Push Buttons (Active High when pressed)
## BTNC (Center) - Request Time
set_property PACKAGE_PIN U18 [get_ports {btnr[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnr[0]}]

## BTNU (Up) - Request Date
set_property PACKAGE_PIN T18 [get_ports {btnr[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnr[1]}]

## BTNL (Left) - Show Stopwatch
set_property PACKAGE_PIN W19 [get_ports {btnr[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnr[2]}]

## BTNR (Right) - Stopwatch Reset
set_property PACKAGE_PIN T17 [get_ports {btnr[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnr[3]}]

## BTND (Down) - Stopwatch Start/Stop
set_property PACKAGE_PIN U17 [get_ports {btnr[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnr[4]}]

## LEDs for Hours (8 bits) - Binary Display
set_property PACKAGE_PIN U16 [get_ports {hr[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hr[0]}]
set_property PACKAGE_PIN E19 [get_ports {hr[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hr[1]}]
set_property PACKAGE_PIN U19 [get_ports {hr[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hr[2]}]
set_property PACKAGE_PIN V19 [get_ports {hr[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hr[3]}]
set_property PACKAGE_PIN W18 [get_ports {hr[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hr[4]}]
set_property PACKAGE_PIN U15 [get_ports {hr[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hr[5]}]
set_property PACKAGE_PIN U14 [get_ports {hr[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hr[6]}]
set_property PACKAGE_PIN V14 [get_ports {hr[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hr[7]}]

## LEDs for Minutes (8 bits) - Binary Display
set_property PACKAGE_PIN V13 [get_ports {mr[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mr[0]}]
set_property PACKAGE_PIN V3 [get_ports {mr[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mr[1]}]
set_property PACKAGE_PIN W3 [get_ports {mr[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mr[2]}]
set_property PACKAGE_PIN U3 [get_ports {mr[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mr[3]}]
set_property PACKAGE_PIN P3 [get_ports {mr[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mr[4]}]
set_property PACKAGE_PIN N3 [get_ports {mr[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mr[5]}]
set_property PACKAGE_PIN P1 [get_ports {mr[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mr[6]}]
set_property PACKAGE_PIN L1 [get_ports {mr[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mr[7]}]

## Additional LEDs for Date (5 bits) - Binary Display
set_property PACKAGE_PIN V17 [get_ports {date[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {date[0]}]
set_property PACKAGE_PIN V16 [get_ports {date[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {date[1]}]
set_property PACKAGE_PIN W16 [get_ports {date[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {date[2]}]
set_property PACKAGE_PIN W17 [get_ports {date[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {date[3]}]
set_property PACKAGE_PIN W15 [get_ports {date[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {date[4]}]

## Additional pins for Month (5 bits)
set_property PACKAGE_PIN V15 [get_ports {month[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {month[0]}]
set_property PACKAGE_PIN W14 [get_ports {month[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {month[1]}]
set_property PACKAGE_PIN W13 [get_ports {month[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {month[2]}]
set_property PACKAGE_PIN V2 [get_ports {month[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {month[3]}]
set_property PACKAGE_PIN T3 [get_ports {month[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {month[4]}]

## Additional pins for Year (8 bits)
set_property PACKAGE_PIN T2 [get_ports {year[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {year[0]}]
set_property PACKAGE_PIN R3 [get_ports {year[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {year[1]}]
set_property PACKAGE_PIN W2 [get_ports {year[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {year[2]}]
set_property PACKAGE_PIN U1 [get_ports {year[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {year[3]}]
set_property PACKAGE_PIN T1 [get_ports {year[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {year[4]}]
set_property PACKAGE_PIN R2 [get_ports {year[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {year[5]}]
set_property PACKAGE_PIN J1 [get_ports {year[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {year[6]}]
set_property PACKAGE_PIN L2 [get_ports {year[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {year[7]}]

## 7-Segment Display Segments (Active Low)
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

## 7-Segment Display Anodes (Active Low)
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

## Decimal Point (Active Low)
set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]

## Configuration and Bitstream Settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

## Timing Constraints
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rxr_IBUF]
