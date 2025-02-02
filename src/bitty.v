module bitty (
    input [15:0] d_instr,
    input clk,
    input run,
    input reset,
    output reg [15:0] d_out,
    output done,
    // UART communication ports
    input [7:0] rx_data,
    input rx_done,
    input tx_done,
    output tx_en,
    output reg [7:0] tx_data
);
    reg [15:0] reg_i, reg_c, reg_s; 
    reg [15:0] registers [7:0];
    wire en_c, en_s;
    reg [2:0] Rx, Ry, sel;
    reg [7:0] en_reg;
    reg [15:0] result, operand;
    reg [1:0] current_state, format;

    // Control Unit instance
    control_unit control(
        .instruction(reg_i),
        .run(run),
        .clk(clk),
        .reset(reset),
        .rx_done(rx_done),
        .tx_done(tx_done),
        .en_c(en_c),
        .en_s(en_s),
        .en_reg(en_reg),
        .current_state(current_state),
        .done(done)
    );

    // LSU instance
    wire lsu_done;
    wire [15:0] lsu_data_to_load;
    reg [7:0] address;  // Address for LSU
    reg [15:0] data_to_store;  // Data to be stored by LSU
    lsu lsu_inst(
        .clk(clk),
        .reset(reset),
        .done_out(lsu_done),
        .en_ls((format == 3)),  // the lsu module activation
        .cu_state(current_state),
        .address(address),  // Address comes from decoded instruction or PC
        .data_to_store(data_to_store),  // Data to be stored comes from ALU result
        .data_to_load(lsu_data_to_load),
        .rx_do(rx_done),
        .rx_data(rx_data),
        .tx_done(tx_done),
        .tx_start_out(tx_en),
        .tx_data_out(tx_data)
    );

    // Combinational logic for ALU and output
    always @(*) begin
        // Default values
        operand = 16'b0;
        d_out = 16'b0;

        // ALU logic
        if (en_s) begin
            operand = (format == 1) ? {8'b0, d_instr[12:5]} : registers[Ry];
        end

        // Output logic
        if (done) begin
            d_out = result;
        end
    end

    // Sequential logic for registers and state updates
    always @(posedge clk or posedge reset) begin
        if (!reset) begin
            for (integer i = 0; i < 8; i = i + 1) begin
                registers[i] <= 16'b0;  // Initialize registers to 0
            end
            reg_i <= 16'b0;
            reg_c <= 16'b0;
            reg_s <= 16'b0;
            address <= 8'b0;
            data_to_store <= 16'b0;
        end else if (run) begin
            reg_i <= d_instr;
            Rx <= d_instr[15:13];
            Ry <= d_instr[12:10];
            sel <= d_instr[4:2];
            format <= d_instr[1:0];

            if (en_s) begin
                reg_s <= registers[Rx];
            end

            if (en_c) begin
                reg_c <= result;
                if (format == 3) begin
                    if (d_instr[2]) begin
                        data_to_store <= registers[Rx];
                    end else begin
                        registers[Rx] <= lsu_data_to_load;
                        data_to_store <= lsu_data_to_load;
                    end
                end                
            end

            if (en_reg[Rx]) begin
                if (format != 3) begin
                    registers[Rx] <= reg_c; 
                end    
            end

        end
    end

    // ALU instance
    alu alu_inst(
        .clk(clk),
        .in_a(reg_s),
        .in_b(operand),
        .select(sel),
        .run(run),
        .alu_out(result)
    );
endmodule