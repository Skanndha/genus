new
module decoder #(
    parameter BUFFER_DEPTH = 6,   // Total number of flits
    parameter ADDR_WIDTH   = 14,
    parameter DATA_WIDTH   = 32
) (
    input clk,
    input rst,
    input i_en,
    input [15:0] i_head_flit,
    input [15:0] i_body_flit_1,  // Address
    input [15:0] i_body_flit_2,  // Data
    input [15:0] i_body_flit_3,  // Data
    input [15:0] i_body_flit_4,  // Data
    input [15:0] i_tail_flit,
    output [DATA_WIDTH-1:0] o_wdata,
    output [ADDR_WIDTH-1:0] o_address,
    output o_read_write_enable,
    output reg o_en
);

    // State definitions
    parameter s_IDLE   = 2'b00;
    parameter s_SAMPLE = 2'b01;
    parameter s_DECODE = 2'b10;
    parameter s_DRIVE  = 2'b11;

    // Buffer to store the input values
    reg [15:0] r_buffer[0:BUFFER_DEPTH-1];
    reg [1:0] r_state;

    // Flags for state completion
    reg r_sample_complete_flag;
    reg r_decode_complete_flag;

    // Registers to store decoded data
    reg [DATA_WIDTH-1:0] r_data;
    reg [ADDR_WIDTH-1:0] r_address;
    reg r_rw;
    reg r_drive_complete_flag;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_state <= s_IDLE;
        end else begin
            case (r_state)
                s_IDLE: r_state <= (i_en) ? s_SAMPLE : s_IDLE;
                s_SAMPLE: r_state <= (r_sample_complete_flag) ? s_DECODE : s_SAMPLE;
                s_DECODE: r_state <= (r_decode_complete_flag) ? s_DRIVE : s_DECODE;
                s_DRIVE: r_state <= (r_drive_complete_flag) ? s_IDLE : s_DRIVE;
            endcase
        end
    end

    // State behavior logic
    always @(posedge clk) begin
        case (r_state)
            s_IDLE: begin
                r_sample_complete_flag <= 0;
                r_decode_complete_flag <= 0;
                r_drive_complete_flag <= 0;
                o_en <= 0;
            end
            s_SAMPLE: begin
                r_buffer[0] <= i_head_flit;
                r_buffer[1] <= i_body_flit_1;
                r_buffer[2] <= i_body_flit_2;
                r_buffer[3] <= i_body_flit_3;
                r_buffer[4] <= i_body_flit_4;
                r_buffer[5] <= i_tail_flit;
                r_sample_complete_flag <= 1;
            end
            s_DECODE: begin
                r_address <= r_buffer[1][15:2];
                r_rw <= r_buffer[1][1];
                r_data <= {r_buffer[2][15:1], r_buffer[3][15:1], r_buffer[4][15:14]};
                r_decode_complete_flag <= 1;
            end
            s_DRIVE: begin
                o_en <= 1;
                r_drive_complete_flag <= 1;
            end
        endcase
    end

    // Output assignments
    assign o_wdata = r_data;
    assign o_address = r_address;
    assign o_read_write_enable = r_rw;

endmodule