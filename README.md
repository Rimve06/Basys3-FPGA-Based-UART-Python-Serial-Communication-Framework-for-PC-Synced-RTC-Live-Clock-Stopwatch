# Basys3 FPGA-Based UART Python Serial Communication Framework for PC-Synchronized RTC, Live Clock & Stopwatch

The system provides a user-friendly interface through physical push buttons on the FPGA board, allowing the user to select between three operational modes: Live Time, Live Date, and Live Stopwatch. Time and date are synchronized once from the PC, then maintained on FPGA, while the stopwatch runs fully in hardware.When the user presses a button to request Live Time or Live Date, the FPGA detects the button input and forwards a control signal to the Verilog control logic. The Verilog system decodes the button number and activates the corresponding functional module among the three available modules. Based on this selection, the FPGA initiates UART communication with the Python application running on the PC.The Python program receives the request, retrieves the current system time or date from the PC, and transmits this information back to the FPGA via serial communication. The FPGA then forwards the received data to the Verilog logic, where it is parsed, processed, and displayed on the on-board seven-segment display. After the initial synchronization, the Verilog logic internally maintains and increments the time or date values, enabling continuous real-time display without requiring further updates from the PC. This design minimizes communication overhead and demonstrates efficient partitioning of responsibilities between software and hardware.In contrast, the Stopwatch mode is implemented entirely within Verilog and operates independently of the PC. All timing, counting, and control logic are handled on the FPGA, showcasing a fully hardware-based real-time system.

---

# Features

- UART communication between Basys 3 FPGA and Python
- Real-time clock synchronized with PC
- Date synchronization from host computer
- FPGA maintains clock after initial synchronization
- Hardware-based stopwatch implementation
- Seven-segment display output
- LED binary display for debugging
- Push-button user interface
- Modular Verilog design
- Vivado compatible project

---

# System Overview

The project consists of two major parts:

- **FPGA (Verilog)**
- **PC Application (Python)**

The FPGA communicates with the Python application through UART.

When a user requests the current **time** or **date**, the FPGA sends a command to the PC. The Python application reads the current system time using the operating system and transmits it back over UART.

After receiving the data, the FPGA stores the values internally and continues updating the clock completely in hardware using its own timing logic. Therefore, communication with the PC occurs **only once per synchronization request**, minimizing serial traffic.

The stopwatch module is implemented entirely inside the FPGA and operates independently of the PC.

---

# System Architecture

```
                  +----------------------+
                  |      Push Buttons    |
                  +----------+-----------+
                             |
                             v
                  +----------------------+
                  |   Verilog Controller |
                  +----------+-----------+
                             |
                 UART Request|
                             v
                +------------------------+
                | UART Transmitter (FPGA)|
                +-----------+------------+
                            |
                     Serial Communication
                            |
                            v
                +------------------------+
                | Python Application     |
                | Reads PC Date & Time   |
                +-----------+------------+
                            |
                     UART Response
                            |
                            v
                +------------------------+
                | UART Receiver (FPGA)   |
                +-----------+------------+
                            |
                            v
        +-------------------------------------------+
        | Live Clock / Date Logic (Verilog)          |
        +-------------------------------------------+
                            |
                            v
                  Seven Segment Display

                 Stopwatch runs independently
                      inside the FPGA
```

---

# Hardware Used

- Basys 3 FPGA Development Board
- Xilinx Artix-7 FPGA
- USB-UART (FT2232HQ)
- 100 MHz On-board Clock

---

# Software Used

- Xilinx Vivado
- Python 3.x
- pySerial

Install Python dependency:

```bash
pip install pyserial
```

---



# Button Functions

| Button |  Label | Function |
|---------|-------|-------------------------------|
| **BTNC** | Center| Request current time from PC |
| **BTNU** | Up    | Request current date from PC |
| **BTNL** | Left  | Hold to display stopwatch |
| **BTNR** | Right |Reset stopwatch |
| **BTND** | Down  |Start/Stop stopwatch |

---

# Display

## Seven Segment Display

### Time Mode

```
HH:MM
```

Example:

```
14:35
```

---

### Date Mode

```
DD:MM
```

Example:

```
04:08
```

---

### Stopwatch

```
MM:SS
```

Example:

```
12:48
```

---

# LED Outputs

Binary outputs are provided for debugging.

| LEDs | Data |
|------|------|
| HR LEDs | Hours |
| MR LEDs | Minutes |
| DATE LEDs | Date |
| MONTH LEDs | Month |
| YEAR LEDs | Year |

---

# Communication Protocol

## FPGA → Python

| Byte | Meaning |
|------|---------|
| 0 | Request Time |
| 1 | Request Date |

---

## Python → FPGA

### Time Request

```
Hour
Minute
Second
```

Each value is transmitted as one byte.

Example:

```
14
35
52
```

---

### Date Request

```
Date
Month
Year
```

Example:

```
04
08
26
```

---

# Workflow

1. User presses a push button.
2. FPGA detects the button edge.
3. FPGA transmits a request through UART.
4. Python receives the request.
5. Python fetches the current PC time/date.
6. Python sends the requested values back.
7. FPGA receives the bytes.
8. FPGA stores the values.
9. FPGA continuously updates the clock internally.
10. Stopwatch operates independently without PC communication.

---

# UART Configuration

| Parameter | Value |
|-----------|-------|
| Baud Rate | 9600 |
| Data Bits | 8 |
| Stop Bits | 1 |
| Parity | None |

---

# Notes

- Time and date are synchronized **only when requested**.
- Once synchronized, the FPGA updates the clock independently.
- Stopwatch functionality is completely hardware-based.
- Date rollover (month/year progression) is not implemented automatically in the current version and requires re-synchronization from the PC if needed.
- The seven-segment display is multiplexed.
- LEDs display raw binary values for debugging.

---

# Constraint File

The provided **constraints.xdc** file is specifically written for the author's **Basys 3 FPGA board configuration**.

Pin mappings, clock assignments, and peripheral connections may differ on other FPGA boards.

If you are using another FPGA board, you must modify the constraint file according to your board's schematic and user manual.

---

# Future Improvements

- Automatic calendar update
- Leap year support
- RTC backup using external battery
- Alarm functionality
- Serial terminal interface
- User-settable clock without PC
- Millisecond stopwatch
- LCD/OLED support

---


# Author

**Tasmin Rubaiyat Rimve**

CSE Undergraduate

Khulna University of Engineering & Technology (KUET)

If you find this project useful, feel free to ⭐ the repository.
