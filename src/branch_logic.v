module branch_logic (
    input [7:0] address,
    /* verilator lint_off UNUSED */
    input [15:0] instruction,
    input [15:0] last_alu_result,
    output reg [7:0] new_pc // Updated program counter
);
    always @(*) begin
        new_pc = 0;
        if (instruction[1:0] == 2) begin
            new_pc = address + 8'b00000001;
            // if(instruction[3:2] == 0 && last_alu_result == 0) begin
            //     new_pc <= instruction[15:4];
            //     $display("THERE IS SOMETHING");
            // end
            if(instruction[3:2] == 0 && last_alu_result == 0) new_pc = instruction[11:4];
            else if(instruction[3:2] == 1 && last_alu_result == 1) new_pc = instruction[11:4];
            else if(instruction[3:2] == 2 && last_alu_result == 2) new_pc = instruction[11:4];
            $display("VERILOG BRANCH!!! New pc is %d", new_pc);
        end else begin
            new_pc = address + 8'b00000001;
        end
    end
endmodule