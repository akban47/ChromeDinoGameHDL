# Chrome Dino Game HDL Implementation

A hardware implementation of the popular Chrome browser dinosaur game using Verilog HDL, designed to run on a Basys3 FPGA board.

## Features

- Gameplay from the 8 bit era
- VGA display output, 480p @ 60Hz
- Real time score display
- Progressively increasing difficulty, with 3 lives
- Randomly generated obstacles
- High score tracking

## Gameplay Requirements

- Basys3 FPGA board (Xilinx Artix-7 FPGA used here, but easily modifiable)
- VGA monitor and cable
- Micro USB cable for programming and power

## Controls

- **Center Button**: Reset game
- **Up Button**: Jump
- **Switch SW[0]**: Toggle between current score and high score display, which updates on game end

### VGA Controller
- Generates proper timing signals for 640x480 @ 60Hz VGA display
- Creates horizontal and vertical sync signals, though still contains jaggies due to timing issues
- Manages pixel coordinates and active display area

## Project Structure

- `vga_controller.v`: Handles VGA signal generation
- `top_game.v`: Main game logic implementation
- `vga_control.v`: Additional VGA control module

## Authors

- Akash
- Nathan

## Development
This project was developed using Vivado 2024.2, AMD edition