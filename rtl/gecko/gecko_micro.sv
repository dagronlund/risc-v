`timescale 1ns/1ps

`ifdef __LINTER__

`include "../../lib/std/std_util.svh"
`include "../../lib/std/std_mem.svh"
`include "../../lib/isa/rv.svh"
`include "../../lib/isa/rv32.svh"
`include "../../lib/isa/rv32i.svh"
`include "../../lib/gecko/gecko.svh"

`else

`include "std_util.svh"
`include "std_mem.svh"
`include "rv.svh"
`include "rv32.svh"
`include "rv32i.svh"
`include "gecko.svh"

`endif

module gecko_micro
    import rv::*;
    import rv32::*;
    import rv32i::*;
    import gecko::*;
#(
    parameter ADDR_SPACE_WIDTH = 16,
    parameter INST_LATENCY = 2,
    parameter DATA_LATENCY = 2,
    parameter gecko_pc_t START_ADDR = 'h0,
    parameter int ENABLE_PERFORMANCE_COUNTERS = 1,
    parameter int ENABLE_PRINT = 1
)(
    input logic clk, rst,

    std_mem_intf.in supervisor_request,
    std_mem_intf.out supervisor_response,

    std_stream_intf.out print_out,

    output logic faulted_flag, finished_flag
);

    `STATIC_ASSERT(INST_LATENCY > 0)
    `STATIC_ASSERT(DATA_LATENCY > 0)

    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) inst_request (.clk, .rst);
    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) inst_result (.clk, .rst);
    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) inst_result_registered (.clk, .rst);
    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) data_request (.clk, .rst);
    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) data_result (.clk, .rst);
    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) data_result_registered (.clk, .rst);

    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) mem_request0 (.clk, .rst);
    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) mem_response0 (.clk, .rst);

    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) master_requests [2] (.clk, .rst);
    std_mem_intf #(.DATA_WIDTH(32), .ADDR_WIDTH(32)) master_responses [2] (.clk, .rst);

    mem_tie tie_inst0(.mem_in(inst_request), .mem_out(master_requests[0]));
    mem_tie tie_inst1(.mem_in(supervisor_request), .mem_out(master_requests[1]));
    mem_tie tie_inst2(.mem_in(master_responses[0]), .mem_out(inst_result));
    mem_tie tie_inst3(.mem_in(master_responses[1]), .mem_out(supervisor_response));

    mem_mux #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ID_WIDTH(1),
        .SLAVE_PORTS(2),
        .MERGE_PIPELINE_MODE(0),
        .SPLIT_PIPELINE_MODE(0)
    ) super_inst_mux (
        .clk, .rst,

        .slave_command(master_requests),
        .slave_result(master_responses),

        .master_command(mem_request0),
        .master_result(mem_response0)
    );

    std_mem_stage #(
        .LATENCY((INST_LATENCY > 1) ? (INST_LATENCY - 2) : 0)
    ) inst_register_stage (
        .clk, .rst,
        .data_in(inst_result),
        .data_out(inst_result_registered)
    );

    std_mem_stage #(
        .LATENCY((DATA_LATENCY > 1) ? (DATA_LATENCY - 2) : 0)
    ) data_register_stage (
        .clk, .rst,
        .data_in(data_result),
        .data_out(data_result_registered)
    );

    std_mem_double #(
        .MANUAL_ADDR_WIDTH(ADDR_SPACE_WIDTH),
        .ADDR_BYTE_SHIFTED(1),
        .ENABLE_OUTPUT_REG0((INST_LATENCY > 1) ? 1 : 0),
        .ENABLE_OUTPUT_REG1((DATA_LATENCY > 1) ? 1 : 0),
        .HEX_FILE("test.mem")
    ) memory_inst (
        .clk, .rst,
        .command0(mem_request0),
        .result0(mem_response0),
        .command1(data_request),
        .result1(data_result)
    );

    gecko_core #(
        .INST_LATENCY(INST_LATENCY),
        .DATA_LATENCY(DATA_LATENCY),
        .START_ADDR(START_ADDR),
        .ENABLE_PERFORMANCE_COUNTERS(ENABLE_PERFORMANCE_COUNTERS),
        .ENABLE_PRINT(ENABLE_PRINT)
    ) gecko_core_inst (
        .clk, .rst,
        .inst_request, .inst_result(inst_result_registered),
        .data_request, .data_result(data_result_registered),
        .print_out,
        .faulted_flag, .finished_flag
    );

endmodule
