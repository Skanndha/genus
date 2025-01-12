module extractor #(
    parameter BUFFER_DEPTH = 6,  // Put the total number of flits here
    parameter COUNT_WIDTH = $clog2(BUFFER_DEPTH),  // Calculate log2 for count width
    parameter MAX_BODY_FLITS = 4,  // To keep track of the max number of body flits
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

    wire w_count_flag;
    wire w_body_count_flag;

    // Counter to keep track of the number of data retrieved from the FIFO
    reg [COUNT_WIDTH-1:0] r_count;

    // Buffer to store the input values
    reg [15:0] r_buffer[0:BUFFER_DEPTH-1];

    // Counter to keep track of body flits
    reg [BODY_COUNT_WIDTH-1:0] r_body_count;

    // Flag to indicate that the count has reached max
    assign w_count_flag = (r_count == (BUFFER_DEPTH - 1));

    // Flag to indicate that the body count has reached max
    assign w_body_count_flag = (r_body_count == MAX_BODY_FLITS);

    // Counting block for sampling counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_count <= {COUNT_WIDTH{1'b0}};
        end else if (w_count_flag) begin
            r_count <= {COUNT_WIDTH{1'b0}};
        end else begin
            r_count <= r_count + {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
        end
    end

    // Counting block for body flit counter
    always @(posedge clk) begin
        if (w_body_count_flag) begin
            r_body_count <= {{(BODY_COUNT_WIDTH-1){1'b0}}, 1'b1};
        end else begin
            r_body_count <= r_body_count + {{(BODY_COUNT_WIDTH-1){1'b0}}, 1'b1};
        end
    end

    // Output driving block
    always @(posedge clk) begin
        if (r_count == {COUNT_WIDTH{1'b0}}) begin
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

    // Input sampling block
    always @(posedge clk) begin
        r_buffer[r_count] <= i_flit;
    end

endmodule
