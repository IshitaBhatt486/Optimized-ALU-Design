`timescale 1ns / 1ps

module alu_tb;
    reg  [7:0] A;
    reg  [7:0] B;
    reg  [3:0] AluOp;

    wire [7:0] Result;
    wire Carry;
    wire Overflow;
    wire Zero;
    wire Negative;

    integer errors;

    alu_top DUT (
        .A(A),
        .B(B),
        .AluOp(AluOp),
        .Result(Result),
        .Carry(Carry),
        .Overflow(Overflow),
        .Zero(Zero),
        .Negative(Negative)
    );

    task check_result;
        input [3:0] op;
        input [7:0] a;
        input [7:0] b;
        input [7:0] expected;
        begin
            AluOp = op;
            A = a;
            B = b;
            #10;
            if (Result !== expected) begin
                $display("FAIL op=%b A=%h B=%h expected=%h got=%h",
                         op, a, b, expected, Result);
                errors = errors + 1;
            end else begin
                $display("PASS op=%b A=%h B=%h Result=%h",
                         op, a, b, Result);
            end
        end
    endtask

    initial begin
        errors = 0;
        A = 8'h00;
        B = 8'h00;
        AluOp = 4'b0000;
        #10;

        // Basic operation checks: A=0x0A, B=0x05.
        check_result(4'b0000, 8'h0A, 8'h05, 8'h00); // AND
        check_result(4'b0001, 8'h0A, 8'h05, 8'h0F); // OR
        check_result(4'b0010, 8'h0A, 8'h05, 8'h0A); // AND-NOT
        check_result(4'b0011, 8'h0A, 8'h05, 8'hFA); // OR-NOT
        check_result(4'b0100, 8'h0A, 8'h05, 8'h0F); // ADD
        check_result(4'b0101, 8'h0A, 8'h05, 8'h05); // SUB
        check_result(4'b0110, 8'h0A, 8'h05, 8'h00); // signed SLT
        check_result(4'b0111, 8'h0A, 8'h05, 8'h00); // reserved

        // Signed comparisons.
        check_result(4'b0110, 8'hFB, 8'h03, 8'h01); // -5 < 3
        check_result(4'b0110, 8'h05, 8'hFD, 8'h00); // 5 < -3 is false

        // ADD carry and zero flags: 0xFF + 1 = 0x00 with carry.
        AluOp = 4'b0100;
        A = 8'hFF;
        B = 8'h01;
        #10;
        if ((Result !== 8'h00) || (Carry !== 1'b1) ||
            (Overflow !== 1'b0) || (Zero !== 1'b1) ||
            (Negative !== 1'b0)) begin
            $display("FAIL ADD carry/zero flag test");
            errors = errors + 1;
        end else begin
            $display("PASS ADD carry/zero flag test");
        end

        // Signed overflow: 127 + 1 = -128 in 8-bit two's complement.
        AluOp = 4'b0100;
        A = 8'h7F;
        B = 8'h01;
        #10;
        if ((Result !== 8'h80) || (Overflow !== 1'b1) ||
            (Negative !== 1'b1) || (Zero !== 1'b0)) begin
            $display("FAIL ADD overflow flag test");
            errors = errors + 1;
        end else begin
            $display("PASS ADD overflow flag test");
        end

        // SUB overflow: -128 - 1 = 127 in 8-bit two's complement.
        AluOp = 4'b0101;
        A = 8'h80;
        B = 8'h01;
        #10;
        if ((Result !== 8'h7F) || (Carry !== 1'b1) ||
            (Overflow !== 1'b1)) begin
            $display("FAIL SUB overflow flag test");
            errors = errors + 1;
        end else begin
            $display("PASS SUB overflow flag test");
        end

        // AluOp[3] is reserved: output and arithmetic flags are forced low.
        AluOp = 4'b1000;
        A = 8'hAA;
        B = 8'h55;
        #10;
        if ((Result !== 8'h00) || (Carry !== 1'b0) ||
            (Overflow !== 1'b0) || (Zero !== 1'b1)) begin
            $display("FAIL invalid opcode test");
            errors = errors + 1;
        end else begin
            $display("PASS invalid opcode test");
        end

        if (errors == 0)
            $display("\nALL TESTS PASSED");
        else
            $display("\nTESTS FAILED: %0d error(s)", errors);

        $finish;
    end
endmodule
