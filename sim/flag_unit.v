`timescale 1ns / 1ps

// Result-dependent flags.
module flag_unit (
    input  wire [7:0] Result,
    output wire       Zero,
    output wire       Negative
);
    assign Zero     = ~|Result;
    assign Negative = Result[7];
endmodule
