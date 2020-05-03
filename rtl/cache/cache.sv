`timescale 1ns/1ps

`ifdef __LINTER__
    `include "../std/std_util.svh"
    `include "../mem/mem_util.svh"
`else
    `include "std_util.svh"
    `include "mem_util.svh"
`endif

module cache
    import std_pkg::*;
    import stream_pkg::*;
#(
    parameter std_clock_info_t CLOCK_INFO = 'b0,
    parameter std_technology_t TECHNOLOGY = STD_TECHNOLOGY_FPGA_XILINX,
    parameter stream_pipeline_mode_t MERGE_PIPELINE_MODE = STREAM_PIPELINE_MODE_TRANSPARENT,
    parameter stream_pipeline_mode_t DECODE_PIPELINE_MODE = STREAM_PIPELINE_MODE_TRANSPARENT,
    parameter logic                  MEMORY_OUTPUT_REGISTER = 'b0,
    parameter stream_pipeline_mode_t ENCODE_PIPELINE_MODE = STREAM_PIPELINE_MODE_TRANSPARENT,
    parameter stream_pipeline_mode_t SPLIT_PIPELINE_MODE = STREAM_PIPELINE_MODE_TRANSPARENT,

    parameter int PORTS = 1,
    parameter int BLOCK_ADDR_WIDTH = 6,
    parameter int INDEX_ADDR_BITS = 6,
    parameter int ASSOCIATIVITY = 1
)(
    input logic clk, rst,
    
    mem_intf.in child_request [PORTS],
    mem_intf.out child_response [PORTS],

    mem_intf.out parent_request,
    mem_intf.in parent_response
);

    localparam int ADDR_WIDTH = $bits(parent_request.addr);
    localparam int DATA_WIDTH = $bits(parent_request.data);
    localparam int CHILD_DATA_WIDTH = $bits(child_request[0].data);
    localparam int ID_WIDTH = $bits(child_request[0].id);

    `PROCEDURAL_ASSERT(ADDR_WIDTH == $bits(parent_response.addr))
    `PROCEDURAL_ASSERT(DATA_WIDTH == $bits(parent_response.data))

    // This is just to appease the Vivado overlords, it seems that passing
    // the same interface array through too many modules does not work
    mem_intf #(.DATA_WIDTH(CHILD_DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) child_request_temp [PORTS] (.clk, .rst);
    mem_intf #(.DATA_WIDTH(CHILD_DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) child_response_temp [PORTS] (.clk, .rst);

    generate
    genvar k;
    for (k = 0; k < PORTS; k++) begin
        `PROCEDURAL_ASSERT(ADDR_WIDTH == $bits(child_request[k].addr))
        `PROCEDURAL_ASSERT(ADDR_WIDTH == $bits(child_response[k].addr))

        `PROCEDURAL_ASSERT(CHILD_DATA_WIDTH == $bits(child_request[k].data))
        `PROCEDURAL_ASSERT(CHILD_DATA_WIDTH == $bits(child_response[k].data))

        `PROCEDURAL_ASSERT(ID_WIDTH == $bits(child_request[k].id))
        `PROCEDURAL_ASSERT(ID_WIDTH == $bits(child_response[k].id))

        mem_stage #(
            .CLOCK_INFO(CLOCK_INFO),
            .PIPELINE_MODE(STREAM_PIPELINE_MODE_TRANSPARENT)
        ) child_request_tie_inst (
            .clk, .rst,
            .mem_in(child_request[k]),
            .mem_out(child_request_temp[k])
        );

        mem_stage #(
            .CLOCK_INFO(CLOCK_INFO),
            .PIPELINE_MODE(STREAM_PIPELINE_MODE_TRANSPARENT)
        ) child_response_tie_inst (
            .clk, .rst,
            .mem_in(child_response_temp[k]),
            .mem_out(child_response[k])
        );
    end
    endgenerate

    localparam int WORD_BITS = $clog2(DATA_WIDTH/8);
    localparam int TAG_BITS = 32 - BLOCK_ADDR_WIDTH - INDEX_ADDR_BITS - WORD_BITS;
    localparam int LRU_BITS = ($clog2(ASSOCIATIVITY) > 1) ? $clog2(ASSOCIATIVITY) : 1;
    localparam int LOCAL_ADDR_WIDTH = BLOCK_ADDR_WIDTH + INDEX_ADDR_BITS;

    localparam int MERGED_ID_WIDTH = $clog2(PORTS) + $bits(child_request[0].id);

    typedef logic [ADDR_WIDTH-1:0] addr_t;

    // Identical type in cache_encode
    typedef struct packed {
        logic id;
        logic send_parent;
        addr_t addr;
    } local_meta_t;

    // Identical type in cache_encode
    typedef struct packed {
        logic id;
        addr_t addr;
    } bypass_t;

    mem_intf #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), 
        .ID_WIDTH(MERGED_ID_WIDTH)) merged_child_request (.clk, .rst);
    mem_intf #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), 
        .ID_WIDTH(MERGED_ID_WIDTH)) merged_child_response (.clk, .rst);

    mem_intf #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(LOCAL_ADDR_WIDTH), 
        .ID_WIDTH(MERGED_ID_WIDTH)) local_request (.clk, .rst);
    mem_intf #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(LOCAL_ADDR_WIDTH), 
        .ID_WIDTH(MERGED_ID_WIDTH)) local_response (.clk, .rst);

    stream_intf #(.T(local_meta_t)) local_request_meta (.clk, .rst);
    stream_intf #(.T(local_meta_t)) local_response_meta (.clk, .rst);

    stream_intf #(.T(bypass_t)) bypass_request (.clk, .rst);

    mem_merge #(
        .CLOCK_INFO(CLOCK_INFO),
        .PIPELINE_MODE(MERGE_PIPELINE_MODE),
        .PORTS(PORTS)
    ) mem_merge_inst (
        .clk, .rst,
        .mem_in(child_request_temp), .mem_out(merged_child_request)
    );

    cache_decode #(
        .CLOCK_INFO(CLOCK_INFO),
        .TECHNOLOGY(TECHNOLOGY),
        .PIPELINE_MODE(DECODE_PIPELINE_MODE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .CHILD_DATA_WIDTH(CHILD_DATA_WIDTH),
        .BLOCK_ADDR_WIDTH(BLOCK_ADDR_WIDTH),
        .INDEX_ADDR_BITS(INDEX_ADDR_BITS),
        .ASSOCIATIVITY(ASSOCIATIVITY)
    ) cache_decode_inst (
        .clk, .rst,

        .child_request(merged_child_request),
        .parent_response(parent_response),
        
        .local_request(local_request),
        .local_request_meta(local_request_meta),
        .bypass_request(bypass_request)
    );

    stream_stage_multiple #(
        .CLOCK_INFO(CLOCK_INFO),
        .PIPELINE_MODE(STREAM_PIPELINE_MODE_REGISTERED),
        .STAGES(MEMORY_OUTPUT_REGISTER ? 2 : 1),
        .T(local_meta_t)
    ) cache_local_meta_stage_inst (
        .clk, .rst,
        .stream_in(local_request_meta),
        .stream_out(local_response_meta)
    );

    // Cache data storage
    mem_sequential_single #(
        .CLOCK_INFO(CLOCK_INFO),
        .TECHNOLOGY(TECHNOLOGY),
        .MANUAL_ADDR_WIDTH(LOCAL_ADDR_WIDTH),
        .ADDR_BYTE_SHIFTED(0),
        .ENABLE_OUTPUT_REG(MEMORY_OUTPUT_REGISTER)
    ) cache_local_memory_inst (
        .clk, .rst,
        .mem_in(local_request), .mem_out(local_response)
    );

    cache_encode #(
        .CLOCK_INFO(CLOCK_INFO),
        .PIPELINE_MODE(DECODE_PIPELINE_MODE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .CHILD_DATA_WIDTH(CHILD_DATA_WIDTH),
        .BLOCK_ADDR_WIDTH(BLOCK_ADDR_WIDTH),
        .INDEX_ADDR_BITS(INDEX_ADDR_BITS),
        .ASSOCIATIVITY(ASSOCIATIVITY)
    ) cache_encode_inst (
        .clk, .rst,
        
        .local_response(local_response),
        .local_response_meta(local_response_meta),
        .bypass_response(bypass_request),

        .child_response(merged_child_response),
        .parent_request(parent_request)
    );

    mem_split #(
        .CLOCK_INFO(CLOCK_INFO),
        .PIPELINE_MODE(SPLIT_PIPELINE_MODE),
        .PORTS(PORTS)
    ) mem_split_inst (
        .clk, .rst,
        .mem_in(merged_child_response),
        .mem_out(child_response_temp)
    );

endmodule
