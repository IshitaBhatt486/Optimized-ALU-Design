`timescale 1ns / 1ps

// 4-bit carry-lookahead adder block.
// Pgroup and Ggroup allow this block to be cascaded with another CLA block.
module cla4 (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output wire [3:0] Sum,
    output wire       Cout,
    output wire       Pgroup,
    output wire       Ggroup
);
    wire [3:0] P;
    wire [3:0] G;
    wire C1, C2, C3;

    assign P = A ^ B;
    assign G = A & B;

    // Lookahead carry equations within this 4-bit group.
    assign C1 = G[0] | (P[0] & Cin);
    assign C2 = G[1] | (P[1] & G[0]) |
                (P[1] & P[0] & Cin);
    assign C3 = G[2] | (P[2] & G[1]) |
                (P[2] & P[1] & G[0]) |
                (P[2] & P[1] & P[0] & Cin);
    assign Cout = G[3] | (P[3] & G[2]) |
                  (P[3] & P[2] & G[1]) |
                  (P[3] & P[2] & P[1] & G[0]) |
                  (P[3] & P[2] & P[1] & P[0] & Cin);

    assign Sum = P ^ {C3, C2, C1, Cin};

    assign Pgroup = &P;
    assign Ggroup = G[3] | (P[3] & G[2]) |
                    (P[3] & P[2] & G[1]) |
                    (P[3] & P[2] & P[1] & G[0]);
endmodule
