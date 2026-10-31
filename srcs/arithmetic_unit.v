`timescale 1ns / 1ps

// Arithmetic operations selected by AluOp[1:0] when AluOp[2] = 1.
// 00 = ADD, 01 = SUB, 10 = signed SLT, 11 = reserved.
module arithmetic_unit (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [1:0] ArithSel,
    output reg  [7:0] ArithResult,
    output reg        Carry,
    output reg        Overflow
);
    wire       DoSubtract;
    wire [7:0] B_modified;
    wire [7:0] Sum;
    wire       CarryOut;
    wire       ArithmeticOverflow;
    wire       SignedLessThan;

    // One adder performs both A+B and A-B.
    // For subtraction, invert B and set the adder carry-in to 1.
    assign DoSubtract = (ArithSel == 2'b01) ||
                        (ArithSel == 2'b10);
    assign B_modified = B ^ {8{DoSubtract}};

    cla8 ADDER (
        .A(A),
        .B(B_modified),
        .Cin(DoSubtract),
        .Sum(Sum),
        .Cout(CarryOut)
    );

    // Two's-complement signed overflow for A + B_modified + Cin.
    assign ArithmeticOverflow =
        (~(A[7] ^ B_modified[7])) & (A[7] ^ Sum[7]);

    // Signed A < B from the subtraction result, corrected for overflow.
    assign SignedLessThan = Sum[7] ^ ArithmeticOverflow;

    always @(*) begin
        ArithResult = 8'b00000000;
        Carry       = 1'b0;
        Overflow    = 1'b0;

        case (ArithSel)
            2'b00: begin // ADD
                ArithResult = Sum;
                Carry       = CarryOut;
                Overflow    = ArithmeticOverflow;
            end

            2'b01: begin // SUB
                ArithResult = Sum;
                Carry       = CarryOut; // 1 means no borrow
                Overflow    = ArithmeticOverflow;
            end

            2'b10: begin // SLT (signed)
                ArithResult = {7'b0000000, SignedLessThan};
                Carry       = CarryOut;
                Overflow    = ArithmeticOverflow;
            end

            default: begin // 2'b11 is reserved
                ArithResult = 8'b00000000;
                Carry       = 1'b0;
                Overflow    = 1'b0;
            end
        endcase
    end
endmodule
