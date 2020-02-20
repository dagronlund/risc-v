//!import std/std_pkg
//!import std/std_register

`timescale 1ns/1ps

// TODO: Support mask usage
// TODO: Support asymmetric widths
module xilinx_block_ram_simple
    import std_pkg::*;
#(
    parameter std_clock_info_t CLOCK_INFO = 'b0,
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 10,
    parameter int ENABLE_OUTPUT_REG = 0,
    parameter HEX_FILE = ""
)(
    input wire clk, 
    input wire rst,

    input wire                    write_enable,
    input wire [ADDR_WIDTH-1:0]   write_addr,
    input wire [DATA_WIDTH-1:0]   write_data,

    input wire                    read_enable,
    input wire                    read_output_enable,
    input wire [ADDR_WIDTH-1:0]   read_addr,
    output logic [DATA_WIDTH-1:0] read_data
);

    localparam DATA_LENGTH = 2**ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] data [DATA_LENGTH];

    initial begin
        for (int i = 0; i < DATA_LENGTH; i++) begin
            data[i] = 'b0;
        end
        if (HEX_FILE != "") begin
            $readmemh(HEX_FILE, data);
        end
    end

    logic [DATA_WIDTH-1:0] read_data_temp;

    generate

    if (CLOCK_INFO.clock_edge == STD_CLOCK_EDGE_RISING) begin

        always_ff @(posedge clk) begin
            if (write_enable) begin
                data[write_addr] <= write_data;
            end

            if (read_enable) begin
                read_data_temp <= data[read_addr];
            end
        end

    end else begin

        always_ff @(negedge clk) begin
            if (write_enable) begin
                data[write_addr] <= write_data;
            end

            if (read_enable) begin
                read_data_temp <= data[read_addr];
            end
        end

    end

    if (ENABLE_OUTPUT_REG) begin

        std_register #(
            .CLOCK_INFO(CLOCK_INFO),
            .T(logic[DATA_WIDTH-1:0]),
            .RESET_VECTOR('b0)
        ) output_reg_inst (
            .clk, .rst,
            .enable(read_output_enable),
            .next(read_data_temp),
            .value(read_data)
        );

    end else begin
        assign read_data = read_data_temp;
    end
    endgenerate

endmodule