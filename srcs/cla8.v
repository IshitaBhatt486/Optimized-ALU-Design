`timescale 1ns / 1ps

// 8-bit grouped carry-lookahead adder made from two 4-bit CLA blocks.
// The carry between the 4-bit groups is formed from group P/G terms.
module cla8 (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire       Cin,
    output wire [7:0] Sum,
    output wire       Cout
);
    wire carry4;
    wire p_low, g_low;
    wire p_high, g_high;

    cla4 CLA_LOW (
        .A(A[3:0]),
        .B(B[3:0]),
        .Cin(Cin),
        .Sum(Sum[3:0]),
        .Cout(),
        .Pgroup(p_low),
        .Ggroup(g_low)
    );

    cla4 CLA_HIGH (
        .A(A[7:4]),
        .B(B[7:4]),
        .Cin(carry4),
        .Sum(Sum[7:4]),
        .Cout(),
        .Pgroup(p_high),
        .Ggroup(g_high)
    );

    // Group-level lookahead carries.
    assign carry4 = g_low | (p_low & Cin);
    assign Cout   = g_high | (p_high & carry4);
endmodule
