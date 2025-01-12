module ram_16kx16 #(
    parameter ADDR_WIDTH = 14,
    parameter DATA_WIDTH = 32,
    parameter RAM_DEPTH  = 16000
) (
    input [DATA_WIDTH-1:0] i_wdata,
    input [ADDR_WIDTH-1:0] i_address,
    input i_read_write_enable,
    input i_en,
    input i_clk,
    input i_rst,
    output reg write_ack,
    output reg read_ack,
    output reg [DATA_WIDTH-1:0] o_wdata
);

    // Define constants for read and write operations
    parameter RAM_WRITE = 1, RAM_READ = 0;

    // Define the RAM as a reg array
    reg [DATA_WIDTH-1:0] ram[0:RAM_DEPTH-1];

    // Sequential logic block
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            // Reset logic
            o_wdata <= 0;
            write_ack <= 0;
            read_ack <= 0;
        end else if (i_en) begin
            // Perform read or write operations based on the enable signal
            case (i_read_write_enable)
                RAM_READ: begin  
                    o_wdata <= ram[i_address];
                    write_ack <= 1'b0;
                    read_ack <= 1'b1;
                end

                RAM_WRITE: begin 
                    ram[i_address] <= i_wdata;
                    read_ack <= 1'b0;
                    write_ack <= 1'b1;
                end
            endcase
        end
    end

endmodule
