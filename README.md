# Cyclic-Lamp-FPGA

# Cyclic Lamp Controller: Moore FSM on FPGA

A 3-state Moore FSM in Verilog that cycles **RED → GREEN → YELLOW**, implemented on the Intel MAX 10 (DE10-Lite) FPGA board.

## Features
- Moore FSM with synchronous, active-high reset
- Parameterized hold time (`clk_freq`, `hold_sec`)
- Counter-based one-cycle enable tick, so the design stays in a **single 50 MHz clock domain** (no divided clock)
- Self-checking flow: simulated in Questa, constrained with SDC, verified on hardware

## State Diagram

<img width="1600" height="1234" alt="State_digram" src="https://github.com/user-attachments/assets/af4dd481-053e-4379-b73e-0830496022de" />


## Design Details
| Item | Value |
|---|---|
| FSM type | Moore |
| Outputs | `light[2:0]` = {RED, GREEN, YELLOW} |
| Board | Terasic DE10-Lite (MAX 10, 10M50DAF484C7G) |
| Clock | 50 MHz (`MAX10_CLK1_50`) |
| Tools | Quartus Prime Lite, Questa Intel FPGA Edition |

### Parameters
| Parameter | Default | Description |
|---|---|---|
| `clk_freq` | 50_000_000 | Board clock in Hz |
| `hold_sec` | 1 | Seconds each color is held |

The counter counts `clk_freq * hold_sec` cycles, then generates a one-cycle `tick` that advances the FSM.

## Pin Assignments
| Port | Pin | Board part |
|---|---|---|
| `clk` | PIN_P11 | 50 MHz clock |
| `rst` | PIN_C10 | SW0 |
| `light[2]` (RED) | PIN_A10 | LEDR2 |
| `light[1]` (GREEN) | PIN_A9 | LEDR1 |
| `light[0]` (YELLOW) | PIN_A8 | LEDR0 |

I/O standard: 3.3-V LVTTL

## Behavior on the Board
- **SW0 down:** LEDs cycle LEDR2 → LEDR1 → LEDR0, 1 second each
- **SW0 up:** reset, the lamp returns to RED and holds

## Simulation
The testbench overrides the parameters so each color lasts 10 clocks:

```verilog
cyclic_lamp #(.clk_freq(10), .hold_sec(1)) dut (.clk(clk), .rst(rst), .light(light));
```

Run in Questa:
```
vlog rtl/cyclic_lamp.v tb/tb_cyclic_lamp.v
vsim tb_cyclic_lamp
add wave -r *
run -all
```

Expected output: `100 → 010 → 001 → 100`, changing every 100 ns.

<img width="1881" height="285" alt="Waveform" src="https://github.com/user-attachments/assets/7652dae1-d6c2-4f06-955f-2625a0569010" />



## Timing Constraints
`cyclic_lamp.sdc` defines the 20 ns (50 MHz) clock and sets false paths on the slow switch and LED I/O.

## Repository Structure
```
├── rtl/            cyclic_lamp.v
├── tb/             tb_cyclic_lamp.v
├── constraints/    cyclic_lamp.sdc, cyclic_lamp.qsf
├── docs/           waveform.png, demo photo
└── README.md
```

## How to Run on Hardware
1. Open the project in Quartus Prime and compile
2. Tools → Programmer → USB-Blaster → load `cyclic_lamp.sof`
3. Flip SW0 down to run, up to reset

## What I Learned
- Why FPGAs measure time by counting clock cycles
- Clock-enable tick vs divided clock
- Writing SDC constraints and pin assignments
- Moving from simulation to real hardware

## Author
SEHAN K, ECE student | VLSI / RTL Design
