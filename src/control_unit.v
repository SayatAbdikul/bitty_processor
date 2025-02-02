module control_unit (
    input [15:0] instruction,
    input run,
    input clk,
    input reset,
    input rx_done,
    input tx_done,
    output reg en_s, 
    output reg en_c, 
    output [1:0] current_state,
    output reg [7:0] en_reg, 
    output reg done
);
    reg [1:0] state, next_state;
    wire [2:0] Rx = instruction[15:13]; 

    // State encoding
    parameter IDLE = 2'b00;
    parameter FETCH = 2'b01;
    parameter EXECUTE = 2'b10;
    parameter STORE = 2'b11;

    always @(*) begin
        en_s = 0;
        en_c = 0;
        en_reg = 0;
        done = 0;
        next_state = state; 

        case (state)
            IDLE: begin
                if (run && instruction[1:0] != 2'b11) begin
                    next_state = FETCH;
                end else if (run && instruction[1:0] == 2'b11 && !rx_done) begin
                    next_state = IDLE; // Wait for rx_done
                end else if (run && instruction[1:0] == 2'b11 && rx_done) begin
                    next_state = FETCH;
                end
            end

            FETCH: begin
                en_s = 1;                
                next_state = EXECUTE;       
            end

            EXECUTE: begin
                en_c = 1;                
                next_state = STORE;   
            end

            STORE: begin
                en_reg[Rx] = 1;
                done = 1;
                if (instruction[1:0] == 2'b11 && !tx_done) begin
                    next_state = STORE; // Wait for tx_done
                    done = 0;
                end else begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;         
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            en_s = 0;
            en_c = 0;
            en_reg = 0;
            done = 0;
        end else if (run) begin 
            state <= next_state;
        end
    end
    assign current_state = state;
endmodule