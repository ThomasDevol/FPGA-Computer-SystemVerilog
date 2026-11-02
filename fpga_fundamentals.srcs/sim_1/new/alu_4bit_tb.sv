
`timescale 1ns / 1ps

module alu_4bit_tb;

    logic [3:0] a, b;
    logic [3:0] op;
    logic [3:0] result;
    logic       carry;
    logic       zero; 
    logic       ovf;
    logic       neg; 
    logic       clk = 0;
    logic       rst;

    // Expected values for verification
    logic [3:0] expected;
    logic       expected_carry;
    logic [4:0] expected_full;
    logic       expected_zero;
    logic       expected_neg;
    logic       expected_ovf;
    
    //temp storage initialization
    logic [3:0] temp_value;
    logic       temp_carry;
    logic       temp_zero; 
    logic       temp_neg;
    logic       temp_ovf;


    int test_count = 0; 
    // Generate a 10 ns clock
    always #5 clk = ~clk;

    // Device Under Test
    alu_4bit dut (
        .a(a),
        .b(b),
        .op(op),
        .clk(clk),
        .rst(rst),
        .result(result),
        .carry(carry), 
        .zero(zero), 
        .neg(neg),
        .ovf(ovf)
    );

    initial begin
        a = 0;
        b = 0;
        op = 0;
        rst = 0;

        // Exhaustive verification: 3072 combinations
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                for (int k = 0; k < 12; k++) begin

                    a = i;
                    b = j;
                    op = k;

                    expected = 0; 
                    expected_carry = 0; 
                    expected_full = 0; 
                    expected_ovf = 0; 
                    
                    case (k)
                        //ADD
                        0: begin
                            expected_full = {1'b0, a} + {1'b0, b};
                            expected = expected_full[3:0];
                            expected_carry = expected_full[4];
                            expected_ovf = (a[3] == b[3]) && (a[3] != expected_full[3]); 
                        end
                        
                        //SUB
                        1: begin
                            expected = a - b;
                            expected_carry = (a < b);
                            expected_ovf = (a[3] != b[3]) && (a[3] != expected[3]); 
                        end

                        //AND
                        2: begin
                            expected = a & b;
                            expected_carry = 0;
                        end

                        //OR
                        3: begin
                            expected = a | b;
                            expected_carry = 0;
                        end
                        
                        //XOR
                        4: begin
                            expected = a ^ b; 
                        end
                        
                        //NOT A
                        5: begin
                            expected = ~a; 
                        end
                        
                        //Logical Shift Left
                        6: begin
                            expected = a << b; 
                            
                            if ((b > 0) && (b <= 4)) 
                                expected_carry = a[4-b]; 
                        end
                        
                        //Logical Shift Right
                        7: begin
                            expected = a >> b;

                            if ((b > 0) && (b <= 4))
                                expected_carry = a[b-1];
                        end

                        // Arithmetic Shift Right
                        8: begin
                            expected = $signed(a) >>> b;

                            if ((b > 0) && (b <= 4))
                                expected_carry = a[b-1];
                        end

                        // Equality
                        9: expected = (a == b);

                        // Unsigned Less Than
                        10: expected = (a < b);

                        // MUL (lower 4 bits)
                        11: expected = a * b;

                        default: begin
                            expected = 0;
                            expected_carry = 0;
                        end
                    endcase
                    
                    //expected zero assignment
                    expected_zero = (expected == 4'b0000);
                    expected_neg = expected[3]; 

                    @(posedge clk);
                    #1;
                    
                    assert (
                        result === expected &&
                        carry === expected_carry &&
                        zero === expected_zero &&
                        neg === expected_neg &&
                        ovf === expected_ovf
                    )
                    else $fatal(
                        1,
                        "ALU failed: a=%0d b=%0d op=%0d result=%0d expected=%0d carry=%b expected_carry=%b expected_zero=%b, expected_neg=%b expected_ovf=%b",
                        a, b, op, result, expected,
                        carry, expected_carry, expected_zero, expected_neg, expected_ovf
                    );
                    
                    test_count++;

                end
            end
        end

        $display("All 3072 ALU combinations passed!");

        // Save previous register values
        temp_value = result;
        temp_carry = carry;
        temp_zero = zero; 
        temp_neg = neg;
        temp_ovf = ovf;

        // Test synchronous reset holding
        @(negedge clk);
        rst = 1;
        #1;

        assert (
            result === temp_value &&
            carry === temp_carry &&
            zero === temp_zero &&
            neg === temp_neg &&
            ovf === temp_ovf
        )
        else $fatal(1, "Holding failed!");

        // Reset should take effect on rising edge
        @(posedge clk);
        #1;

        assert (result === 4'b0000 && carry === 1'b0 && zero === 1'b0 && neg === 1'b0 && ovf === 1'b0)
        else $fatal(1, "Reset failed!");

        // Change inputs while reset remains active
        a = 9;
        b = 3;
        op = 0;
        expected = a + b;
        expected_carry = 0;
        expected_zero = 0; 
        expected_neg = expected[3]; 
        expected_ovf = (a[3] == b[3]) && (a[3] != expected[3]); 

        @(posedge clk);
        #1;

        assert (result === 0 && carry === 0 && zero === 0 && neg === 0 && ovf === 0)
        else $fatal(1, "Reset priority failed!");

        // Release reset on falling edge
        @(negedge clk);
        rst = 0;

        @(posedge clk);
        #1;

        assert (
            result === expected &&
            carry === expected_carry &&
            zero === expected_zero &&
            neg === expected_neg &&
            ovf === expected_ovf
        )
        else $fatal(1, "Reset release failed!");

        $display("All ALU and reset tests passed!");
        $finish;
    end

endmodule
