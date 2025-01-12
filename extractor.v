new 
module extractor #(
    parameter BUFFER_DEPTH = 6,  // Total number of flits
    parameter COUNT_WIDTH = $clog2(BUFFER_DEPTH),  // Log2 for buffer depth
    parameter MAX_BODY_FLITS = 4,  // Max number of body flits
    parameter BODY_COUNT_WIDTH = $clog2(MAX_BODY_FLITS)  // Log2 for body flits count
) (
    input clk,
    input rst,
    input [15:0] i_flit,
    output reg o_done,
    output reg [15:0] o_head_flit,
    output reg [15:0] o_body_flit_1,
    output reg [15:0] o_body_flit_2,
    output reg [15:0] o_body_flit_3,
    output reg [15:0] o_body_flit_4,
    output reg [15:0] o_tail_flit
);

    reg [COUNT_WIDTH-1:0] r_count;
    reg [15:0] r_buffer[0:BUFFER_DEPTH-1];

    // Counting block for sampling
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_count <= 0;
        end else if (r_count == BUFFER_DEPTH - 1) begin
            r_count <= 0;
        end else begin
            r_count <= r_count + 1;
        end
    end

    // Input sampling
    always @(posedge clk) begin
        r_buffer[r_count] <= i_flit;
    end

    // Output driving block
    always @(posedge clk) begin
        if (r_count == BUFFER_DEPTH - 1) begin
            o_head_flit   <= r_buffer[0];
            o_body_flit_1 <= r_buffer[1];
            o_body_flit_2 <= r_buffer[2];
            o_body_flit_3 <= r_buffer[3];
            o_body_flit_4 <= r_buffer[4];
            o_tail_flit   <= r_buffer[BUFFER_DEPTH-1];
            o_done <= 1;
        end else begin
            o_done <= 0;
        end
    end

endmodule