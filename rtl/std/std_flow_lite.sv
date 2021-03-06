`timescale 1ns/1ps

/*
 * ⚛🔋 My abstractions keep getting better! 🔫🏹
 */
module std_flow_lite #(
    parameter int NUM_INPUTS = 1, 
    parameter int NUM_OUTPUTS = 1
)(
    input logic clk, rst,

    input logic [NUM_INPUTS-1:0] valid_input,
    output logic [NUM_INPUTS-1:0] ready_input,

    output logic [NUM_OUTPUTS-1:0] valid_output,
    input logic [NUM_OUTPUTS-1:0] ready_output,

    input logic [NUM_INPUTS-1:0] consume, // If input being read this cycle
    input logic [NUM_OUTPUTS-1:0] produce, // If an output will be present next cycle

    output logic enable // Enable for current state
);

    always_comb begin
        
        // Create seperate enables for each channel, avoid valid/ready dependence
        automatic logic output_enable = 'b1, input_enable = 'b1;
        automatic logic [NUM_OUTPUTS-1:0] output_enables = {NUM_OUTPUTS{1'b1}};
        automatic logic [NUM_INPUTS-1:0] input_enables = {NUM_INPUTS{1'b1}};

        // Enable if all outputs are either not being produced or ready
        for (int i = 0; i < NUM_OUTPUTS; i++) begin
            output_enable &= (!produce[i]) || (ready_output[i]);
            for (int j = 0; j < NUM_OUTPUTS; j++) begin
                if (i != j) begin
                    output_enables[j] &= (!produce[i]) || (ready_output[i]);
                end
            end
        end

        // Enable if all inputs are either not being consumed or valid
        for (int i = 0; i < NUM_INPUTS; i++) begin
            input_enable &= (!consume[i]) || (valid_input[i]);
            for (int j = 0; j < NUM_INPUTS; j++) begin
                if (i != j) begin
                    input_enables[j] &= (!consume[i]) || (valid_input[i]);
                end
            end
        end

        // Set output valid signals if enabled and being produced
        for (int i = 0; i < NUM_OUTPUTS; i++) begin
            valid_output[i] = produce[i] && output_enables[i] && input_enable;
        end

        // Set input ready signals if enabled and being consumed
        for (int i = 0; i < NUM_INPUTS; i++) begin
            ready_input[i] = consume[i] && input_enables[i] && output_enable;
        end

        // Collapse individual enable signals for primary enable
        enable = output_enable && input_enable;
    end

endmodule
