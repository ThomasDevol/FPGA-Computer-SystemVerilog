
module alu_4bit (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic [3:0] op,
    input  logic       clk,
    input  logic       rst,
    output logic [3:0] result,
    output logic       carry, 
    output logic       zero, 
    output logic       neg, 
    output logic       ovf
);

    // Internal combinational signals
    logic [4:0] full_sum;
    logic [3:0] alu_out;
    logic       carry_out;
    logic       ovf_out;

    // Combinational ALU

always_comb begin
    full_sum  = 5'b00000;
    carry_out = 1'b0;
    ovf_out = 0; 

    case (op)

        // ADD: carry from bit 4
        4'b0000: begin
            full_sum  = {1'b0, a} + {1'b0, b};
            carry_out = full_sum[4];
            ovf_out = (a[3] == b[3]) && (a[3] != full_sum[3]);
        end

        // SUB: carry flag indicates borrow
        4'b0001: begin
            full_sum  = {1'b0, a} - {1'b0, b};
            carry_out = full_sum[4];
            ovf_out = (a[3] != b[3]) && (a[3] != full_sum[3]);

        end

        // Bitwise operations
        4'b0010: full_sum = {1'b0, a & b};
        4'b0011: full_sum = {1'b0, a | b};
        4'b0100: full_sum = {1'b0, a ^ b};
        4'b0101: full_sum = {1'b0, ~a};

        // Logical Shift Left
        4'b0110: begin
            full_sum = {1'b0, (a << b)};
            if (b > 0 && b <= 4)
                carry_out = a[4-b];
        end

        // Logical Shift Right
        4'b0111: begin
            full_sum = {1'b0, (a >> b)};
            if (b > 0 && b <= 4)
                carry_out = a[b-1];
        end

        // Arithmetic Shift Right
        4'b1000: begin
            full_sum = {1'b0, ($signed(a) >>> b)};
            if (b > 0 && b <= 4)
                carry_out = a[b-1];
        end

        // Comparisons
        4'b1001: full_sum = {4'b0000, (a == b)};
        4'b1010: full_sum = {4'b0000, (a < b)};

        // Multiplication: lower 4 bits retained
        4'b1011: full_sum = a * b;

        // Reserved
        4'b1100: full_sum = 0;
        4'b1101: full_sum = 0;
        4'b1110: full_sum = 0;
        4'b1111: full_sum = 0;

        default: full_sum = 5'b00000;
    endcase

    alu_out = full_sum[3:0];
end

    // Synchronous output registers
    always_ff @(posedge clk) begin
        if (rst) begin
            result <= 4'b0000;
            carry  <= 1'b0;
            zero <= 0;
            neg <= 0;
            ovf <= 0; 
        end
        else begin
            result <= alu_out;
            carry  <= carry_out;
            zero <= (alu_out == 4'b0000);
            neg <= alu_out[3];       
            ovf <= ovf_out;   
        end
    end

endmodule
