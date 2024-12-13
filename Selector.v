module selector (
    input clk,
    input rst,
    input submit,
    input [3:0] num,
    output reg [3:0] x1,
    output reg [3:0] y1,
    output reg [3:0] x2,
    output reg [3:0] y2,
    output reg done
);
// FSM States
reg [3:0] S;
reg [3:0] NS;

parameter START = 4'b0000,
    SET_x1 = 4'b0001,
    Debounce_1 = 4'b0010,
    SET_y1 = 4'b0011,
    Debounce_2 = 4'b0100,
    SET_x2 = 4'b0101,
    Debounce_3 = 4'b0110,
    SET_y2 = 4'b0111, 
    Debounce_4 = 4'b1000,
    DONE = 4'b1001;

// S transition Block
always @(posedge clk or negedge rst) begin
    if (rst == 0)
        S <= START;
    else 
        S <= NS;
end

// NS Transition Block
always @(*) begin
    case (S)
        START : begin
            if (submit == 0) // the button is pushed
                NS = SET_x1;
            else
                NS = START;
        end
        SET_x1 : begin
            if (submit == 1)
                NS = Debounce_1;
            else
                NS = SET_x1;
        end
        Debounce_1 : begin
            if (submit == 0)
                NS = SET_y1;
            else
                NS = Debounce_1; 
        end
        SET_y1 : begin
            if (submit == 1)
                NS = Debounce_2;
            else
                NS = SET_y1;
        end
        Debounce_2 : begin
            if (submit == 0)
                NS = SET_x2;
            else
                NS = Debounce_2;
        end
        SET_x2 : begin
            if (submit == 1)
                NS = Debounce_3;
            else
                NS = SET_x2;
        end
        Debounce_3 : begin
            if (submit == 0)
                NS = SET_y2;
            else
                NS = Debounce_3;
        end
        SET_y2 : begin
            if (submit == 1)
                NS = Debounce_4;
            else
                NS = SET_y2;
        end
        Debounce_4 : begin
            if (submit == 0)
                NS = DONE;
            else
                NS = Debounce_4; 
        end
        DONE : NS = DONE;
		  default : NS = START;
    endcase
end

// logic block
always @(posedge clk or negedge rst) begin
    if (rst == 0) begin
        done <= 0;
        x1 <= 0;
        y1 <= 0;
        x2 <= 0;
        y2 <= 0;
    end
    else begin
        case (S)
            START : done <=0;
            SET_x1 : x1 <= num;
            Debounce_1 : done <= 0;
            SET_y1 : y1 <= num;
            Debounce_2 : done <= 0;
            SET_x2 : x2 <= num;
            Debounce_3 : done <= 0;
            SET_y2 : y2 <= num;
            Debounce_4 : done <= 0;
            DONE : done <= 1;
            default: done <= 0; 
        endcase
    end
end
endmodule