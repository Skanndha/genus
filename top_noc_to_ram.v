`include "../extractor/extractor_test.v"
`include "../decoder/decoder.v"
`include "ram_16kx16.v"

module top_noc_to_ram #(
	parameter BUFFER_DEPTH = 6,   // Put the total number of flits here
    	parameter ADDR_WIDTH   = 14,
    	parameter DATA_WIDTH   = 32
)(
	input i_clk,
	input i_rst,
	input [15:0] i_flit,
	output write_ack,
	output read_ack,
	output [DATA_WIDTH-1:0] o_wdata        // Wire for output write data
);

wire [DATA_WIDTH-1:0] w_wdata;		// Wire for sending data to sram
wire [ADDR_WIDTH-1:0] w_address;      // Wire for wire address
wire w_read_write_enable;             // Wire for read/write enable signal
wire w_en_ram;			// Wire for enable to sram

wire [15:0] w_head_flit;
wire [15:0] w_body_flit_1;
wire [15:0] w_body_flit_2;
wire [15:0] w_body_flit_3;
wire [15:0] w_body_flit_4;
wire [15:0] w_tail_flit;

wire sig_enable;

/*
	1. Considering o_done output from extractor as the input i_en for decoder
*/
extractor d_extractor(
      .clk(i_clk),
      .rst(i_rst),
      .i_flit(i_flit),
      .o_done(sig_enable),
      .o_head_flit(w_head_flit),
      .o_body_flit_1(w_body_flit_1),
      .o_body_flit_2(w_body_flit_2),
      .o_body_flit_3(w_body_flit_3),
      .o_body_flit_4(w_body_flit_4),
      .o_tail_flit(w_tail_flit)
);

decoder d_decoder (
    .clk(i_clk),                           // Clock input
    .rst(i_rst),                           // Reset input
    .i_en(sig_enable),                     // Enable signal
    .i_head_flit(w_head_flit),             // Head flit input
    .i_body_flit_1(w_body_flit_1),         // Body flit 1 (address)
    .i_body_flit_2(w_body_flit_2),         // Body flit 2 (data)
    .i_body_flit_3(w_body_flit_3),         // Body flit 3 (data)
    .i_body_flit_4(w_body_flit_4),         // Body flit 4 (data)
    .i_tail_flit(w_tail_flit),             // Tail flit input
    .o_wdata(w_wdata),                     // Output write data
    .o_address(w_address),                 // Output address
    .o_read_write_enable(w_read_write_enable), // Read/write enable signal
    .o_en(w_en_ram)                        // Output enable
);

ram_16kx16 d_ram_16kx16 (
    .i_wdata(w_wdata),
    .i_address(w_address),
    .i_read_write_enable(w_read_write_enable),
    .i_en(w_en_ram),
    .i_clk(i_clk),
    .i_rst(i_rst),
    .write_ack(write_ack),
    .read_ack(read_ack),
    .o_wdata(o_wdata)
);

endmodule
