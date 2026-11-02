# FPGA Fundamentals

**Digital Logic Design, SystemVerilog, and FPGA Development**

An ongoing project exploring digital hardware design and computer architecture using SystemVerilog and AMD Vivado.

The goal is to develop a practical understanding of RTL design, simulation, verification, synthesis, and FPGA-based systems, progressing from fundamental digital components toward processor architecture and aerospace-oriented embedded hardware.

## Current Implementation: 4-Bit ALU

The first completed module is a synchronous, 4-bit Arithmetic Logic Unit (ALU) supporting 12 operations.

### Supported Operations

| Opcode | Operation | Description |
|---|---|---|
| `0000` | ADD | Addition |
| `0001` | SUB | Subtraction |
| `0010` | AND | Bitwise AND |
| `0011` | OR | Bitwise OR |
| `0100` | XOR | Bitwise XOR |
| `0101` | NOT | Bitwise inversion of A |
| `0110` | LSL | Logical shift left |
| `0111` | LSR | Logical shift right |
| `1000` | ASR | Arithmetic shift right |
| `1001` | EQ | Equality comparison |
| `1010` | LT | Unsigned less-than comparison |
| `1011` | MUL | Multiplication (lower 4 bits) |

Opcodes `1100`–`1111` are reserved.

### Hardware Architecture

The ALU accepts two 4-bit operands and a 4-bit operation selector.

**Inputs**
- `a[3:0]` — First operand
- `b[3:0]` — Second operand
- `op[3:0]` — Operation selector
- `clk` — Clock
- `rst` — Active-high synchronous reset

**Outputs**
- `result[3:0]` — Registered 4-bit result
- `carry` — Registered carry/borrow or shifted-out bit

Operation selection and arithmetic are implemented using combinational logic, while the output registers update on the rising edge of the clock.

The carry output indicates addition carry-out, subtraction borrow, or the final shifted-out bit for supported shift amounts. For other operations, the carry output is zero.

## Verification

The ALU was verified using a self-checking SystemVerilog testbench.

The testbench exhaustively evaluates every combination of the two operands and the 12 supported operations.

**16 × 16 × 12 = 3,072 test cases**

Verification includes:

- Arithmetic and logical correctness
- Addition carry-out and subtraction borrow
- Logical and arithmetic shift behavior
- Comparisons and truncated multiplication
- Clock-synchronized registered outputs
- Synchronous reset timing and priority
- Recovery following reset deassertion

**Result: All 3,072 exhaustive test cases and reset checks passed in behavioral simulation.**

## Development Tools

- **HDL:** SystemVerilog
- **FPGA Design Suite:** AMD Vivado
- **Target FPGA Family:** AMD/Xilinx Artix-7
- **Verification:** Vivado Simulator (XSim)
- **Version Control:** Git and GitHub

## Project Structure

```text
fpga_fundamentals/
├── fpga_fundamentals.srcs/
│   ├── sources_1/
│   │   ├── new/
│   │   │   └── alu_4bit.sv
│   │   └── bd/
│   │       └── design_1/
│   └── sim_1/
│       └── new/
│           └── alu_4bit_tb.sv
├── fpga_fundamentals.xpr
├── .gitignore
└── README.md
```

Vivado-generated simulation, synthesis, and implementation artifacts are excluded from version control.

## Development Roadmap

- [x] Implement a synchronous 4-bit ALU
- [x] Expand to 12 operations
- [x] Develop exhaustive self-checking verification
- [x] Verify synchronous reset behavior
- [ ] Add processor status flags (Zero, Negative, Overflow)
- [ ] Parameterize arithmetic width
- [ ] Implement a register file
- [ ] Develop finite-state-machine controllers
- [ ] Implement a processor instruction decoder
- [ ] Explore UART and SPI interfaces
- [ ] Develop more advanced processor and FPGA datapaths
- [ ] Investigate aerospace-oriented FPGA applications

## Long-Term Objective

Build progressively more capable FPGA systems that connect digital logic, computer architecture, and embedded engineering.

Potential applications include sensor interfaces, telemetry processing, avionics data handling, and hardware-in-the-loop testing.

---

**Project Status:** Active development — foundational ALU implemented and verified.

**Note:** Behavioral simulation verification does not imply completed physical FPGA implementation or hardware validation.
