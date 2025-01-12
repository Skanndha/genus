new 
module top_noc_to_ram #(
    parameter BUFFER_DEPTH = 6,
    parameter ADDR_WIDTH   = 14,
    parameter DATA_WIDTH   = 32
)(
    input i_clk,
    input i_rst,
    input [15:0] i_flit,
    output write_ack,
    output read_ack,
    output [DATA_WIDTH-1:0] o_wdata
);

    wire [DATA_WIDTH-1:0] w_wdata;
    wire [ADDR_WIDTH-1:0] w_address;
    wire w_read_write_enable;
    wire w_en_ram;

    wire [15:0] w_head_flit;
    wire [15:0] w_body_flit_1;
    wire [15:0] w_body_flit_2;
    wire [15:0] w_body_flit_3;
    wire [15:0] w_body_flit_4;
    wire [15:0] w_tail_flit;

    wire sig_enable;

    extractor d_extractor (
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
        .clk(i_clk),
        .rst(i_rst),
        .i_en(sig_enable),
        .i_head_flit(w_head_flit),
        .i_body_flit_1(w_body_flit_1),
        .i_body_flit_2(w_body_flit_2),
        .i_body_flit_3(w_body_flit_3),
        .i_body_flit_4(w_body_flit_4),
        .i_tail_flit(w_tail_flit),
        .o_wdata(w_wdata),
        .o_address(w_address),
        .o_read_write_enable(w_read_write_enable),
        .o_en(w_en_ram)
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