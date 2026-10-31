`timescale 1ns / 1ps

// Logic operations selected by AluOp[1:0] when AluOp[2] = 0.
// 00 = AND, 01 = OR, 10 = AND-NOT, 11 = OR-NOT.
module logic_unit (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [1:0] LogicSel,
    output reg  [7:0] LogicResult
);
    wire [7:0] NotB;
    assign NotB = ~B; // Shared inversion for AND-NOT and OR-NOT.

    always @(*) begin
        case (LogicSel)
            2'b00: LogicResult = A & B;
            2'b01: LogicResult = A | B;
            2'b10: LogicResult = A & NotB;
            2'b11: LogicResult = A | NotB;
            default: LogicResult = 8'b00000000;
        endcase
    end
endmodule
