module PIECE_MOVER(
    input clk,
    input rst,
    input enable,
    input [191:0] BOARD,
    input Curr_Player_Turn,
    input [4:0] x_Selected,
    input [4:0] y_Selected,
    input [4:0] x_Target,
    input [4:0] y_Target,
    output reg [191:0] updated_board,
    output reg updated_Player_turn, // 1 is player 1, 0 is player 2
    output reg done
);

    // State machine registers
    reg [7:0] S;
    reg [7:0] NS;

    // Piece selection and target status wires
    wire [2:0] Select_Status;
    wire [2:0] Target_Status;

    // State machine parameters
    parameter START = 8'd0,
              CHECK_PLAYER = 8'd1,
              CHECK_TARGET = 8'd2,
              CHECK_DISTANCE = 8'd3,
              REMOVE_SELECTED = 8'd4,
              PLACE_TARGET = 8'd5,
              REMOVE_CAPTURED = 8'd6,
              DONE = 8'd7,
              FAIL = 8'd8;

    reg isLeft;

    // Instantiate the board memory as a 64x3-bit array (3 bits per position for piece states)
    reg [2:0] board_mem [0:63];

    // State machine logic
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0)
            S <= START;
        else
            S <= NS;
    end

    // Define distance logic
    reg [5:0] distance;

    always @(*) begin
        case (S)
            START: begin
                if (enable)
                    NS = CHECK_TARGET;
                else
                    NS = START;
            end
            CHECK_TARGET: begin
                if ((Select_Status != 3'b000) && (Select_Status != 3'b111) && (Target_Status == 3'b111)) // Piece is not Blank
                    NS = CHECK_PLAYER;
                else
                    NS = FAIL;
            end
            CHECK_PLAYER: begin
                if (Curr_Player_Turn == 1) begin
                    if ((Select_Status == 3'b001) || (Select_Status == 3'b101)) // Player 1 pieces
                        NS = CHECK_DISTANCE;
                    else
                        NS = FAIL;
                end else begin
                    if ((Select_Status == 3'b010) || (Select_Status == 3'b110)) // Player 2 pieces
                        NS = CHECK_DISTANCE;
                    else
                        NS = FAIL;
                end
            end
            CHECK_DISTANCE: begin
                // Calculate horizontal and vertical distance
                reg [5:0] x_distance, y_distance;
                x_distance = (x_Selected > x_Target) ? (x_Selected - x_Target) : (x_Target - x_Selected);
                y_distance = (y_Selected > y_Target) ? (y_Selected - y_Target) : (y_Target - y_Selected);
                
                if (x_distance == 1 && y_distance == 1)
                    NS = REMOVE_SELECTED; // Valid move (one step diagonally)
                else if (x_distance == 2 && y_distance == 2)
                    NS = REMOVE_CAPTURED; // Valid jump (two steps diagonally)
                else
                    NS = FAIL; // Invalid move
            end
            REMOVE_SELECTED: begin
                NS = PLACE_TARGET;
            end
            PLACE_TARGET: begin
                NS = DONE;
            end
            REMOVE_CAPTURED: begin
                NS = REMOVE_SELECTED;
            end
            DONE: begin
                NS = START;
                isLeft = 0;
            end
            FAIL: begin
                NS = START;
            end
            default: ;
        endcase    
    end

    // Temporary register to hold the current memory board state
    reg [191:0] next_board;

    // Registers for indexes and removal index
    reg [5:0] index_Target;
    reg [5:0] index_Selected;
    reg [5:0] removal_Index;

    reg [5:0] x_middle;
    reg [5:0] y_middle;


    // Initialize memory based on BOARD input
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            x_middle <=0;
            y_middle <=0;
            // Initialize the board memory with the current state of the board (from BOARD input)
            board_mem[0] <= BOARD[2:0];
            board_mem[1] <= BOARD[5:3];
            board_mem[2] <= BOARD[8:6];
            board_mem[3] <= BOARD[11:9];
            board_mem[4] <= BOARD[14:12];
            board_mem[5] <= BOARD[17:15];
            board_mem[6] <= BOARD[20:18];
            board_mem[7] <= BOARD[23:21];
            board_mem[8] <= BOARD[26:24];
            board_mem[9] <= BOARD[29:27];
            board_mem[10] <= BOARD[32:30];
            board_mem[11] <= BOARD[35:33];
            board_mem[12] <= BOARD[38:36];
            board_mem[13] <= BOARD[41:39];
            board_mem[14] <= BOARD[44:42];
            board_mem[15] <= BOARD[47:45];
            board_mem[16] <= BOARD[50:48];
            board_mem[17] <= BOARD[53:51];
            board_mem[18] <= BOARD[56:54];
            board_mem[19] <= BOARD[59:57];
            board_mem[20] <= BOARD[62:60];
            board_mem[21] <= BOARD[65:63];
            board_mem[22] <= BOARD[68:66];
            board_mem[23] <= BOARD[71:69];
            board_mem[24] <= BOARD[74:72];
            board_mem[25] <= BOARD[77:75];
            board_mem[26] <= BOARD[80:78];
            board_mem[27] <= BOARD[83:81];
            board_mem[28] <= BOARD[86:84];
            board_mem[29] <= BOARD[89:87];
            board_mem[30] <= BOARD[92:90];
            board_mem[31] <= BOARD[95:93];
            board_mem[32] <= BOARD[98:96];
            board_mem[33] <= BOARD[101:99];
            board_mem[34] <= BOARD[104:102];
            board_mem[35] <= BOARD[107:105];
            board_mem[36] <= BOARD[110:108];
            board_mem[37] <= BOARD[113:111];
            board_mem[38] <= BOARD[116:114];
            board_mem[39] <= BOARD[119:117];
            board_mem[40] <= BOARD[122:120];
            board_mem[41] <= BOARD[125:123];
            board_mem[42] <= BOARD[128:126];
            board_mem[43] <= BOARD[131:129];
            board_mem[44] <= BOARD[134:132];
            board_mem[45] <= BOARD[137:135];
            board_mem[46] <= BOARD[140:138];
            board_mem[47] <= BOARD[143:141];
            board_mem[48] <= BOARD[146:144];
            board_mem[49] <= BOARD[149:147];
            board_mem[50] <= BOARD[152:150];
            board_mem[51] <= BOARD[155:153];
            board_mem[52] <= BOARD[158:156];
            board_mem[53] <= BOARD[161:159];
            board_mem[54] <= BOARD[164:162];
            board_mem[55] <= BOARD[167:165];
            board_mem[56] <= BOARD[170:168];
            board_mem[57] <= BOARD[173:171];
            board_mem[58] <= BOARD[176:174];
            board_mem[59] <= BOARD[179:177];
            board_mem[60] <= BOARD[182:180];
            board_mem[61] <= BOARD[185:183];
            board_mem[62] <= BOARD[188:186];
            board_mem[63] <= BOARD[191:189];
            updated_Player_turn <= Curr_Player_Turn;
            done <= 0;
        end else begin
            case (S)
                START: begin
                    index_Selected <= ((y_Selected) * 8 + x_Selected); // Bottom-up indexing
                    index_Target <= ((y_Target) * 8 + x_Target);     // Bottom-up indexing
                    board_mem[0] <= BOARD[2:0];
                    board_mem[1] <= BOARD[5:3];
                    board_mem[2] <= BOARD[8:6];
                    board_mem[3] <= BOARD[11:9];
                    board_mem[4] <= BOARD[14:12];
                    board_mem[5] <= BOARD[17:15];
                    board_mem[6] <= BOARD[20:18];
                    board_mem[7] <= BOARD[23:21];
                    board_mem[8] <= BOARD[26:24];
                    board_mem[9] <= BOARD[29:27];
                    board_mem[10] <= BOARD[32:30];
                    board_mem[11] <= BOARD[35:33];
                    board_mem[12] <= BOARD[38:36];
                    board_mem[13] <= BOARD[41:39];
                    board_mem[14] <= BOARD[44:42];
                    board_mem[15] <= BOARD[47:45];
                    board_mem[16] <= BOARD[50:48];
                    board_mem[17] <= BOARD[53:51];
                    board_mem[18] <= BOARD[56:54];
                    board_mem[19] <= BOARD[59:57];
                    board_mem[20] <= BOARD[62:60];
                    board_mem[21] <= BOARD[65:63];
                    board_mem[22] <= BOARD[68:66];
                    board_mem[23] <= BOARD[71:69];
                    board_mem[24] <= BOARD[74:72];
                    board_mem[25] <= BOARD[77:75];
                    board_mem[26] <= BOARD[80:78];
                    board_mem[27] <= BOARD[83:81];
                    board_mem[28] <= BOARD[86:84];
                    board_mem[29] <= BOARD[89:87];
                    board_mem[30] <= BOARD[92:90];
                    board_mem[31] <= BOARD[95:93];
                    board_mem[32] <= BOARD[98:96];
                    board_mem[33] <= BOARD[101:99];
                    board_mem[34] <= BOARD[104:102];
                    board_mem[35] <= BOARD[107:105];
                    board_mem[36] <= BOARD[110:108];
                    board_mem[37] <= BOARD[113:111];
                    board_mem[38] <= BOARD[116:114];
                    board_mem[39] <= BOARD[119:117];
                    board_mem[40] <= BOARD[122:120];
                    board_mem[41] <= BOARD[125:123];
                    board_mem[42] <= BOARD[128:126];
                    board_mem[43] <= BOARD[131:129];
                    board_mem[44] <= BOARD[134:132];
                    board_mem[45] <= BOARD[137:135];
                    board_mem[46] <= BOARD[140:138];
                    board_mem[47] <= BOARD[143:141];
                    board_mem[48] <= BOARD[146:144];
                    board_mem[49] <= BOARD[149:147];
                    board_mem[50] <= BOARD[152:150];
                    board_mem[51] <= BOARD[155:153];
                    board_mem[52] <= BOARD[158:156];
                    board_mem[53] <= BOARD[161:159];
                    board_mem[54] <= BOARD[164:162];
                    board_mem[55] <= BOARD[167:165];
                    board_mem[56] <= BOARD[170:168];
                    board_mem[57] <= BOARD[173:171];
                    board_mem[58] <= BOARD[176:174];
                    board_mem[59] <= BOARD[179:177];
                    board_mem[60] <= BOARD[182:180];
                    board_mem[61] <= BOARD[185:183];
                    board_mem[62] <= BOARD[188:186];
                    board_mem[63] <= BOARD[191:189];
                    done <= 0;
                end

                REMOVE_SELECTED: begin
                    // Remove the selected piece from the memory
                    board_mem[index_Selected] <= 3'b111; // Clear the piece
                end

                PLACE_TARGET: begin
                    // Place the selected piece at the target position
                    board_mem[index_Target] <= Select_Status; // Assign selected piece to target
                end

                REMOVE_CAPTURED: begin
                    // Determine the direction of the jump in the x-direction
                    if (x_Target > x_Selected) begin
                        // Left Jump
                        x_middle <= (x_Selected - 1); // Middle index is one step to the right of x_Selected
                    end else begin
                        // Negative x direction (jump to the left)
                        x_middle <= (x_Selected + 1); // Middle index is one step to the left of x_Selected
                    end

                    // Determine the direction of the jump in the y-direction
                    if (y_Target > y_Selected) begin
                        // Positive y direction (jump down)
                        y_middle <= (y_Selected + 1); // Middle index is one step down from y_Selected
                    end else begin
                        // Negative y direction (jump up)
                        y_middle <= (y_Selected - 1); // Middle index is one step up from y_Selected
                    end

                    // Calculate the removal index based on the middle coordinates
                    removal_Index <= y_middle * 8 + x_middle;

                    // Ensure the removal index is within bounds (valid positions on the board)
                    if (removal_Index < 64) begin
                        // Check if the middle position has a piece to be removed (i.e., it's not empty)
                        if (board_mem[removal_Index] != 3'b111) begin
                            board_mem[removal_Index] <= 3'b111; // Clear the captured piece
                        end
                    end
                
                end

            


                DONE: begin
                    done <= 1;
                    updated_Player_turn <= !Curr_Player_Turn; // Switch player turn
                    updated_board[2:0]     <= board_mem[0];
                    updated_board[5:3]     <= board_mem[1];
                    updated_board[8:6]     <= board_mem[2];
                    updated_board[11:9]    <= board_mem[3];
                    updated_board[14:12]   <= board_mem[4];
                    updated_board[17:15]   <= board_mem[5];
                    updated_board[20:18]   <= board_mem[6];
                    updated_board[23:21]   <= board_mem[7];
                    updated_board[26:24]   <= board_mem[8];
                    updated_board[29:27]   <= board_mem[9];
                    updated_board[32:30]   <= board_mem[10];
                    updated_board[35:33]   <= board_mem[11];
                    updated_board[38:36]   <= board_mem[12];
                    updated_board[41:39]   <= board_mem[13];
                    updated_board[44:42]   <= board_mem[14];
                    updated_board[47:45]   <= board_mem[15];
                    updated_board[50:48]   <= board_mem[16];
                    updated_board[53:51]   <= board_mem[17];
                    updated_board[56:54]   <= board_mem[18];
                    updated_board[59:57]   <= board_mem[19];
                    updated_board[62:60]   <= board_mem[20];
                    updated_board[65:63]   <= board_mem[21];
                    updated_board[68:66]   <= board_mem[22];
                    updated_board[71:69]   <= board_mem[23];
                    updated_board[74:72]   <= board_mem[24];
                    updated_board[77:75]   <= board_mem[25];
                    updated_board[80:78]   <= board_mem[26];
                    updated_board[83:81]   <= board_mem[27];
                    updated_board[86:84]   <= board_mem[28];
                    updated_board[89:87]   <= board_mem[29];
                    updated_board[92:90]   <= board_mem[30];
                    updated_board[95:93]   <= board_mem[31];
                    updated_board[98:96]   <= board_mem[32];
                    updated_board[101:99]  <= board_mem[33];
                    updated_board[104:102] <= board_mem[34];
                    updated_board[107:105] <= board_mem[35];
                    updated_board[110:108] <= board_mem[36];
                    updated_board[113:111] <= board_mem[37];
                    updated_board[116:114] <= board_mem[38];
                    updated_board[119:117] <= board_mem[39];
                    updated_board[122:120] <= board_mem[40];
                    updated_board[125:123] <= board_mem[41];
                    updated_board[128:126] <= board_mem[42];
                    updated_board[131:129] <= board_mem[43];
                    updated_board[134:132] <= board_mem[44];
                    updated_board[137:135] <= board_mem[45];
                    updated_board[140:138] <= board_mem[46];
                    updated_board[143:141] <= board_mem[47];
                    updated_board[146:144] <= board_mem[48];
                    updated_board[149:147] <= board_mem[49];
                    updated_board[152:150] <= board_mem[50];
                    updated_board[155:153] <= board_mem[51];
                    updated_board[158:156] <= board_mem[52];
                    updated_board[161:159] <= board_mem[53];
                    updated_board[164:162] <= board_mem[54];
                    updated_board[167:165] <= board_mem[55];
                    updated_board[170:168] <= board_mem[56];
                    updated_board[173:171] <= board_mem[57];
                    updated_board[176:174] <= board_mem[58];
                    updated_board[179:177] <= board_mem[59];
                    updated_board[182:180] <= board_mem[60];
                    updated_board[185:183] <= board_mem[61];
                    updated_board[188:186] <= board_mem[62];
                    updated_board[191:189] <= board_mem[63];

                end

                FAIL: begin
                    done <= 1;
                    updated_Player_turn <= Curr_Player_Turn;
                    updated_board <= BOARD; // Reset to initial board
                end
                default: ;
            endcase

            // Rebuild the updated board from memory
            
        end
    end

    // Module instances for getting piece statuses
    getStatus Select_Get(
        x_Selected,
        y_Selected,
        BOARD,
        Select_Status
    );

    getStatus Target_Get(
        x_Target,
        y_Target,
        BOARD,
        Target_Status
    );

endmodule
