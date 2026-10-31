`timescale 1ns / 1ps

// 8-bit ALU based on the Harris & Harris two-functional-unit architecture.
// AluOp[2] selects the output path: 0 = logic, 1 = arithmetic.
// AluOp[3] is reserved and must be 0 for a valid operation.
//
// Adapted 4-bit operation encoding:
//   0000 = A AND B       0100 = A + B
//   0001 = A OR B        0101 = A - B
//   0010 = A AND ~B      0110 = signed SLT
//   0011 = A OR ~B       0111 = reserved
module alu_top (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [3:0] AluOp,
    output wire [7:0] Result,
    output wire       Carry,
    output wire       Overflow,
    output wire       Zero,
    output wire       Negative
);
    wire [7:0] ArithResult;
    wire [7:0] LogicResult;
    wire       ArithCarry;
    wire       ArithOverflow;
    wire [7:0] MuxResult;

    arithmetic_unit AU (
        .A(A),
        .B(B),
        .ArithSel(AluOp[1:0]),
        .ArithResult(ArithResult),
        .Carry(ArithCarry),
        .Overflow(ArithOverflow)
    );

    logic_unit LU (
        .A(A),
        .B(B),
        .LogicSel(AluOp[1:0]),
        .LogicResult(LogicResult)
    );

    // AluOp[2] is the same arithmetic-versus-logic mux select as in the
    // reference architecture. AluOp[3] = 1 makes the operation invalid.
    mux2_8 OUTPUT_MUX (
        .D0(LogicResult),
        .D1(ArithResult),
        .S(AluOp[2]),
        .Y(MuxResult)
    );

    assign Result   = AluOp[3] ? 8'b00000000 : MuxResult;
    assign Carry    = (AluOp[3:2] == 2'b01) ? ArithCarry    : 1'b0;
    assign Overflow = (AluOp[3:2] == 2'b01) ? ArithOverflow : 1'b0;

    flag_unit FLAGS (
        .Result(Result),
        .Zero(Zero),
        .Negative(Negative)
    );
endmodule
