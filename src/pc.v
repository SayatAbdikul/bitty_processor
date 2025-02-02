module pc(
    input clk,
    input en_pc, // Enable PC
    input reset, // Active-low reset
    input [7:0] d_in, // Input memory address
    output reg [7:0] d_out // Output memory address
);

    reg [7:0] current_pc;
    initial begin
        current_pc = 0;
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_pc <= 0;
        end else if(en_pc) begin
            current_pc <= d_in - 1;
        end else begin
            current_pc <= current_pc + 1;
        end
    end
    assign d_out = current_pc;

endmodule