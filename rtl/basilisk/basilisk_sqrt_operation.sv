`timescale 1ns/1ps

`ifdef __LINTER__

`include "../../lib/std/std_util.svh"
`include "../../lib/isa/rv.svh"
`include "../../lib/isa/rv32.svh"
`include "../../lib/isa/rv32f.svh"
`include "../../lib/fpu/fpu.svh"
`include "../../lib/fpu/fpu_sqrt.svh"
`include "../../lib/basilisk/basilisk.svh"

`else

`include "std_util.svh"
`include "rv.svh"
`include "rv32.svh"
`include "rv32f.svh"
`include "basilisk.svh"
`include "fpu.svh"
`include "fpu_sqrt.svh"

`endif

module basilisk_sqrt_operation
    import rv::*;
    import rv32::*;
    import rv32f::*;
    import fpu::*;
    import fpu_sqrt::*;
    import basilisk::*;
#(
    parameter int OUTPUT_REGISTER_MODE = 1
)(
    input logic clk, rst,

    std_stream_intf.in sqrt_exponent_command, // basilisk_sqrt_operation_t
    std_stream_intf.out sqrt_operation_command // basilisk_sqrt_operation_t
);

    std_stream_intf #(.T(basilisk_sqrt_operation_t)) next_sqrt_operation_command (.clk, .rst);

    logic enable, consume, produce;

    std_flow_lite #(
        .NUM_INPUTS(1),
        .NUM_OUTPUTS(1)
    ) std_flow_lite_inst (
        .clk, .rst,

        .valid_input({sqrt_exponent_command.valid}),
        .ready_input({sqrt_exponent_command.ready}),

        .valid_output({next_sqrt_operation_command.valid}),
        .ready_output({next_sqrt_operation_command.ready}),

        .consume, .produce, .enable
    );

    std_flow_stage #(
        .T(basilisk_sqrt_operation_t),
        .MODE(OUTPUT_REGISTER_MODE)
    ) output_stage_inst (
        .clk, .rst,
        .stream_in(next_sqrt_operation_command), .stream_out(sqrt_operation_command)
    );

    rv32_reg_addr_t dest_reg_addr, next_dest_reg_addr;
    basilisk_offset_addr_t dest_offset_addr, next_dest_offset_addr;
    fpu_sqrt_result_t partial_result, next_partial_result;
    logic [4:0] counter, next_counter;

    always_ff @(posedge clk) begin
        if(rst) begin
            counter <= 'b0;
            dest_reg_addr <= 'b0;
            dest_offset_addr <= 'b0;
        end else if (enable) begin
            counter <= next_counter;
            dest_reg_addr <= next_dest_reg_addr;
            dest_offset_addr <= next_dest_offset_addr;
        end

        if (enable) begin
            partial_result <= next_partial_result;
        end
    end

    always_comb begin
       automatic fpu_sqrt_result_t starting_result = partial_result;

       consume = 'b0;
       produce = 'b0;

       next_counter = counter + 'b1;
       next_dest_reg_addr = dest_reg_addr;
       next_dest_offset_addr = dest_offset_addr;

       // Runs the operation 27 times in a loop
        if (counter == 0) begin
            consume = 'b1;
            starting_result = sqrt_exponent_command.payload.result;
            next_dest_reg_addr = sqrt_exponent_command.payload.dest_reg_addr;
            next_dest_offset_addr = sqrt_exponent_command.payload.dest_offset_addr;
        end else if (counter == 26) begin
            produce = 'b1;
            next_counter = 'b0;
        end
        
        next_partial_result = fpu_float_sqrt_operation(starting_result);

        next_sqrt_operation_command.payload.dest_reg_addr = dest_reg_addr;
        next_sqrt_operation_command.payload.dest_offset_addr = dest_offset_addr;
        next_sqrt_operation_command.payload.result = next_partial_result;
    end

endmodule
