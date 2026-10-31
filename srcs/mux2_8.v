`timescale 1ns / 1ps

// Functional 8-bit 2:1 mux model.
// This is synthesizable RTL; it does not force a physical transmission-gate
// implementation. The transistor-level TG circuit should be documented
// separately in KiCad or SPICE.
module mux2_8 (
    input  wire [7:0] D0,
    input  wire [7:0] D1,
    input  wire       S,
    output wire [7:0] Y
);
    assign Y = S ? D1 : D0;
endmodule
