module lsu(
    // General ports
    input wire clk,
    input wire reset, // Active-low reset
    output reg done_out, // Signal indicating the operation is complete
    // Design preferences
    input en_ls, // lsu activation
    input [1:0] cu_state,
    input wire [7:0] address, // 8-bit address to be sent
    input [15:0] data_to_store,
    output reg [15:0] data_to_load, // 16-bit instruction received
    // Ports for UART module
    input wire rx_do, // Signal indicating data received
    input wire [7:0] rx_data, // Data received from UART
    input wire tx_done, // Signal indicating transmission is done
    output reg tx_start_out, // Signal to start UART transmission -> low active
    output reg [7:0] tx_data_out // Data to be transmitted over UART
);
    // State encoding
    parameter IDLE = 4'b0000;
    parameter SEND_FLAG = 4'b0001;
    parameter SEND_ADDR = 4'b0010;
    parameter RECEIVE_DATA_HIGH = 4'b0011;
    parameter RECEIVE_DATA_LOW = 4'b0100;
    parameter SEND_DATA_HIGH = 4'b0101;
    parameter SEND_DATA_LOW = 4'b0110;
    parameter DONE = 4'b0111;

    reg [3:0] state, next_state;

    // Sequential logic for state transition
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // State machine logic
    always @(*) begin
        // Default values
        next_state = IDLE;  // Default next state
        tx_start_out = 1;   // No transmission by default
        tx_data_out = 8'b00000000;
        done_out = 0;

        case (state)
            IDLE: begin
                done_out = 0;
                if (en_ls) begin
                    next_state = SEND_FLAG;
                end else begin
                    next_state = IDLE;
                end
            end
            SEND_FLAG: begin
                tx_data_out = 8'b00000011;  // Send flag byte
                tx_start_out = 0;  // Start transmission
                if (tx_done) begin
                    tx_start_out = 1;  // Stop transmission
                    next_state = SEND_ADDR;
                end else begin
                    next_state = SEND_FLAG;
                end
            end
            SEND_ADDR: begin
                tx_data_out = address;  // Send address byte
                tx_start_out = 0;  // Start transmission
                if (tx_done) begin
                    tx_start_out = 1;  // Stop transmission
                    case (cu_state)
                        2'b01: next_state = RECEIVE_DATA_HIGH;  // Load
                        2'b10: next_state = SEND_DATA_HIGH;     // Store
                        default: next_state = IDLE;             // Invalid state
                    endcase
                end else begin
                    next_state = SEND_ADDR;
                end
            end
            RECEIVE_DATA_HIGH: begin
                if (rx_do) begin
                    data_to_load[15:8] <= rx_data;  // Store high 8 bits of data
                    next_state = RECEIVE_DATA_LOW;
                end else begin
                    next_state = RECEIVE_DATA_HIGH;
                end
            end
            RECEIVE_DATA_LOW: begin
                if (rx_do) begin
                    data_to_load[7:0] <= rx_data;  // Store low 8 bits of data
                    next_state = DONE;
                end else begin
                    next_state = RECEIVE_DATA_LOW;
                end
            end
            SEND_DATA_HIGH: begin
                tx_data_out = data_to_store[15:8];  // Send high 8 bits of data
                tx_start_out = 0;  // Start transmission
                if (tx_done) begin
                    tx_start_out = 1;  // Stop transmission
                    next_state = SEND_DATA_LOW;
                end else begin
                    next_state = SEND_DATA_HIGH;
                end
            end
            SEND_DATA_LOW: begin
                tx_data_out = data_to_store[7:0];  // Send low 8 bits of data
                tx_start_out = 0;  // Start transmission
                if (tx_done) begin
                    tx_start_out = 1;  // Stop transmission
                    next_state = DONE;
                end else begin
                    next_state = SEND_DATA_LOW;
                end
            end
            DONE: begin
                done_out = 1;  // Set done signal
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
endmodule