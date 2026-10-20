# RISC Arcade: Pong & Breakout on an FPGA

A Verilog project for the Terasic DE10 board that combines a small custom 8-bit RISC CPU with a hardware game engine and a VGA renderer. It plays **Pong** (2 players) and **Breakout** (1 player) on a 640x480 VGA display, with scores shown on the seven-segment displays.

<!-- Add a photo or GIF of the game running: ![Demo](docs/demo.gif) -->

## Features

- Custom 16-bit-instruction, 8-bit-data RISC CPU (11 instructions, 8 registers)
- Memory-mapped I/O bus that exposes game state to the CPU (`0xF0`-`0xF8`)
- Hardware game engine running at 50 updates per second
- VGA output at 640x480 @ 60 Hz (25 MHz pixel clock from the 50 MHz board clock)
- Three screens selected with switches: home screen, Pong, Breakout
- Scores on HEX0-HEX3 (hexadecimal), current mode on HEX4

## Hardware and tools

| Item | Details |
|------|---------|
| Board | Terasic DE10 (**fill in exact model, e.g. DE10-Standard**) |
| Toolchain | Intel Quartus Prime (**fill in version**) |
| Top-level entity | `RISC_Arcade` (`src/RISC_Arcade.v`) |
| Clock | `CLOCK_50` (50 MHz) |
| Display | VGA monitor |

## Controls

| Input | Function |
|-------|----------|
| `SW[9]` | Reset (active high) |
| `SW[1:0]` | Mode: `00` = home screen, `01` = Pong, `10` = Breakout |
| `SW[2]` / `SW[3]` | Pong: left paddle up / down. Breakout: paddle left / right |
| `SW[4]` / `SW[5]` | Pong: right paddle up / down |

Scores: `HEX1:HEX0` = Player 1, `HEX3:HEX2` = Player 2, `HEX4` = game mode.

## Architecture

```
                +-----------+    I/O bus    +----------+
   CLOCK_50 --> |    CPU    | <-----------> | game_io  |
                +-----------+  (0xF0-0xF8)  +----------+

   SW / KEY --> +--------------+   ball, paddles,   +----------------+   +----------------+
                | game_engine  | -----------------> | pixel_renderer | ->| VGA R,G,B      |
                +--------------+   scores, bricks   +----------------+   +----------------+
                                                            ^
                                   +----------------+       |
                                   | vga_controller | ------+  (pixel_x, pixel_y, video_on)
                                   +----------------+  --> VGA_HS, VGA_VS
```

The game area is 256x192 and is scaled by 2.5x to fill the 640x480 screen.

### Source files (`src/`)

| File | Description |
|------|-------------|
| `RISC_Arcade.v` | Top level: wires everything to the board pins and 7-segment decoders |
| `cpu.v` | CPU top: connects PC, ROM, decoder, control unit, register file, ALU, data memory |
| `program_counter.v` | 8-bit program counter with jump and halt-enable |
| `instruction_rom.v` | 256 x 16-bit instruction memory |
| `instruction_decoder.v` | Splits a 16-bit instruction into opcode, registers and immediate |
| `control_unit.v` | Generates control signals from the opcode |
| `register_file.v` | 8 x 8-bit register file |
| `alu.v` | ADD, SUB, AND, OR, XOR, PASS with zero and carry flags |
| `data_memory.v` | 256 x 8-bit data RAM |
| `game_io.v` | Memory-mapped I/O registers visible to the CPU |
| `game_engine.v` | Pong and Breakout game logic (ball, paddles, bricks, scoring) |
| `vga_controller.v` | 640x480 @ 60 Hz timing generator |
| `pixel_renderer.v` | Converts game state into RGB pixel colours |

## CPU instruction set

Instruction format (16 bits): `[15:12]` opcode, `[11:9]` destination, `[8:6]` source A, `[5:3]` source B, `[7:0]` immediate / address.

| Opcode | Mnemonic | Operation |
|--------|----------|-----------|
| `0001` | `LDI`  | Load immediate into register |
| `0010` | `ADD`  | rd = ra + rb |
| `0011` | `SUB`  | rd = ra - rb |
| `0100` | `AND`  | rd = ra & rb |
| `0101` | `OR`   | rd = ra \| rb |
| `0110` | `XOR`  | rd = ra ^ rb |
| `0111` | `JMP`  | Jump to address |
| `1000` | `BZ`   | Branch to address if the last ALU result was zero |
| `1001` | `LD`   | Load from data memory or I/O |
| `1010` | `ST`   | Store to data memory or I/O |
| `1011` | `HALT` | Stop the CPU |

Addresses `0xF0` and above go to the I/O bus instead of data memory.

### I/O memory map

| Address | Register | Access |
|---------|----------|--------|
| `0xF0` | Game mode | R |
| `0xF1` | Controls | R |
| `0xF2` | Ball X | R/W |
| `0xF3` | Ball Y | R/W |
| `0xF4` | Paddle 1 position | R/W |
| `0xF5` | Paddle 2 position | R/W |
| `0xF6` | Score 1 | R/W |
| `0xF7` | Score 2 | R/W |
| `0xF8` | Brick state (1 bit per brick) | R/W |

## Building and running

1. Open Quartus Prime and create a new project targeting your DE10's FPGA.
2. Add all files in `src/` and set `RISC_Arcade` as the top-level entity.
3. Import the DE10 pin assignments (the board's `.qsf` / pin assignment file from Terasic) so `CLOCK_50`, `SW`, `KEY`, `HEX0-5` and the `VGA_*` signals map to the right pins.
4. Compile, then program the board with the generated `.sof` using the Programmer.
5. Connect a VGA monitor. Flip `SW[9]` up then down to reset, and use `SW[1:0]` to pick a game.

## Repository layout

```
.
├── src/        Verilog source files
├── docs/       Screenshots, diagrams, demo media
├── .gitignore
├── LICENSE
└── README.md
```

## License

Released under the [MIT License](LICENSE).
