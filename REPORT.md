# High-Level Description

This project implements the Game of Checkers through the following steps:

1. **Input**: The user selects a piece to move and specifies its destination.
2. **Validation**: The move is checked for legality.
3. **Move Execution**: If the move is valid, it is executed; otherwise, no action is taken.
4. **Board Update**: The board is redrawn to reflect the new state after the move.

---

# Background Information

The project is organized into multiple modules, each placed in its own file. The main file, `FINAL_PROJECT.v`, contains a finite state machine (FSM) that manages the game flow by processing the different modules. The FSM sends an enable signal to each module, waits for the "done" signal, and then moves to the next module.

The system uses modular design principles, where each functionality is seperated within its module. This was done so that it is easier to test and extend the design in the future.

---

# MODULES

## FINAL_PROJECT

This module controls the sequence of game actions by enabling each instantiated module, waiting for them to finish, and then moving to the next. The sequence of modules is as follows:

1. **SELECTOR**
2. **PIECE_MOVER**
3. **Update the Board State**
4. **BOARD_DRAWER**
5. **Update whose turn it is**

## BOARD_DRAWER

This module iterates through memory locations 0-14000, writing values corresponding to each index based on its translation to (x, y) coordinates on the board. The coordinates are indexed from the bottom-left (0, 0), with values increasing as you move left and up. The color of each square is determined by a 3-bit section of the board register.

## PIECE_MOVER

This module handles the movement of pieces. It receives the selected and target locations and processes the move according to the rules of checkers. The module follows these steps:
- **Piece Ownership**: It first checks that the selected piece belongs to the current player.
- **Destination Check**: It verifies that the target square is an empty black square.
- **Move Validation**: It checks whether the piece is moving one square or jumping over another piece.
  - **Jumping**: If the move is a jump, the jumped piece is removed, and the moving piece is placed on the target square.
- After completing the move, the module sends a "done" signal, updates the board, and updates the turn indicator.

## SELECTOR

This module implements an FSM that processes user input in the following steps:
1. Get the x-coordinate of the selected piece (x1), saving it when the submit signal goes high.
2. Wait for the submit signal to go low.
3. Get the y-coordinate of the selected piece (y1), saving it when the submit signal goes high.
4. Wait for the submit signal to go low.
5. Get the x-coordinate of the target square (x2), saving it when the submit signal goes high.
6. Wait for the submit signal to go low.
7. Get the y-coordinate of the target square (y2), saving it when the submit signal goes high.
8. Wait for the submit signal to go low.
9. Send a "done" signal to notify the higher-level module that x1, y1, x2, and y2 are ready for processing.

## GETSTATUS

This module checks the status of a square at a given X-Y board location and outputs the current state of the piece located there.

## THREE_DECIMAL_VALS_W_NEG

This module is used to display the current player on the HEX displays.

## VGA_FRAME_DRIVER

This module, created by Dr. Jamison, is used in **BOARD_DRAWER** to write the memory to the VGA screen.

---

# Board Encoding

The board is represented by a 192-bit register, which is updated multiple times during the execution of the FSM. Each 3-bit section represents the following:

| DATA | REPRESENTATION           |
|------|--------------------------|
| 000  | White Square             |
| 001  | Normal Player 1 Piece    |
| 010  | Normal Player 2 Piece    |
| 101  | King of Player 1         |
| 110  | King of Player 2         |
| 111  | Black Square             |

---

# Running the Game

To start the game, press **Key[1]** to initialize the board.

Players take turns inputting the location of the piece they want to move and the target square. The current player is displayed on the HEX displays. A turn is passed only if the player successfully makes a move; otherwise, the turn remains with the current player. This is also true when a player makes a jump.


# Conclusion

This project successfully implements a functional Game of Checkers using a modular design and finite state machine (FSM) architecture. The system is organized into distinct modules, each responsible for a specific aspect of the game, including piece selection, move validation, board updates, and turn management.

Key components include:
- **FINAL_PROJECT**: The central module that coordinates the game flow, enabling and waiting for the completion of tasks in the correct sequence.
- **BOARD_DRAWER**: Responsible for visualizing the game board by translating a 192-bit register into VGA-compatible output.
- **PIECE_MOVER**: Handles the logic for validating and executing moves, ensuring adherence to the game rules.
- **SELECTOR**: Facilitates user input, gathering coordinates for the selected piece and its destination.
- **GETSTATUS**: Checks and outputs the status of specific board squares, assisting in move validation.
- **VGA_FRAME_DRIVER**: Manages the display of the game board and player status on the screen.
- **THREE_DECIMAL_VALS_W_NEG**: Displays the current player on the HEX displays.

The project effectively integrates these modules to create an interactive and playable checkers game, with clear player turn management and visual feedback. The modular design ensures that each component can be tested and extended easily, making it adaptable for future enhancements.


# CITATIONS
The VGA_FRAME_DRIVER and all of it's submodules where written and provided by Dr.Jamison.

the overall functionality of BOARD_DRAWER is based on the following code provided by Dr.Jamison, that we converted into a FSM and to be sequential:
{
always @(posedge clk or negedge rst)
begin	
	if (rst == 1'b0)
	begin
		the_vga_draw_frame_write_mem_address <= 15'd0;
		the_vga_draw_frame_write_mem_data <= 24'd0;
		the_vga_draw_frame_write_a_pixel <= 1'b0;
		flag1 <= 1'b0;
		flag2 <= 1'b0;
	end
	else
	begin
		/* !!!!! NOTE
			I use flag logic to cludge this together - a bad idea */
		if (KEY[1] == 1'b0 && flag1 == 1'b0)
		begin
			/* this is the code to write a pixel when KEY[1] is pressed */
			the_vga_draw_frame_write_mem_address <= idx_location;
			the_vga_draw_frame_write_mem_data <= {SW[7:0], SW[7:0], SW[7:0]};
			the_vga_draw_frame_write_a_pixel <= 1'b1;
			flag1 <= 1'b1;
		end
		else if (KEY[1] == 1'b0)
		begin
			flag1 <= 1'b1;
			the_vga_draw_frame_write_a_pixel <= 1'b0;
		end
		else
		begin
			flag1 <= 1'b0;
			the_vga_draw_frame_write_a_pixel <= 1'b0;
		end
		
		/* !!!!! NOTE
			I use flag logic to cludge this together - a bad idea */
		/* this is the code to increment the idx_location, which is the address to draw the pixel into the frame memory */
		if (KEY[2] == 1'b0  && flag2 == 1'b0)
		begin
			flag2 <= 1'b1;
			idx_location <= idx_location + 1'b1;
		end
		else if (KEY[2] == 1'b1)
		begin
			flag2 <= 1'b0;
		end

	end
end
}