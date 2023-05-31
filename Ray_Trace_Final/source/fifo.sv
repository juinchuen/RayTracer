module fifo #(
    parameter FIFO_DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 1024) 
(
    input  logic reset,
    input  logic wr_clk,
    input  logic wr_en,
    input  logic [FIFO_DATA_WIDTH-1:0] din,
    output logic full,
    input  logic rd_clk,
    input  logic rd_en,
    output logic [FIFO_DATA_WIDTH-1:0] dout,
    output logic empty
);

    function automatic logic [FIFO_DATA_WIDTH-1:0] to01( input logic [FIFO_DATA_WIDTH-1:0] data );
        logic [FIFO_DATA_WIDTH-1:0] result;
		for ( int i=0; i < $bits(data); i++ ) begin
			case ( data[i] )  
				0: result[i] = 1'b0;
                1: result[i] = 1'b1;
                default: result[i] = 1'b0;
			endcase;
		end;
		return result;
    endfunction

    localparam FIFO_ADDR_WIDTH = $clog2(FIFO_BUFFER_SIZE) + 1;
    logic [FIFO_DATA_WIDTH-1:0] fifo_buf [FIFO_BUFFER_SIZE-1:0];
    logic [FIFO_ADDR_WIDTH-1:0] wr_addr, wr_addr_t;
    logic [FIFO_ADDR_WIDTH-1:0] rd_addr, rd_addr_t;
    logic full_t, empty_t;

    always_ff @(posedge wr_clk) 
    begin : p_write_buffer
        if ( (wr_en == 1'b1) && (full_t == 1'b0) ) begin
            fifo_buf[$unsigned(wr_addr[FIFO_ADDR_WIDTH-2:0])] <= din;
        end
    end

    always_ff @(posedge wr_clk, posedge reset) 
    begin : p_wr_addr
        if ( reset == 1'b1 ) 
            wr_addr <= '0;
        else
            wr_addr <= wr_addr_t;
    end

    always_ff @(posedge rd_clk) 
    begin : p_rd_buffer
        dout <= to01(fifo_buf[$unsigned(rd_addr_t[FIFO_ADDR_WIDTH-2:0])]);
    end

    always_ff @(posedge rd_clk, posedge reset) 
    begin : p_rd_addr
        if ( reset == 1'b1 ) 
            rd_addr <= '0;
        else
            rd_addr <= rd_addr_t;
    end

    always_ff @(posedge rd_clk, posedge reset) 
    begin : p_empty
        if ( reset == 1'b1 ) 
            empty <= '1;
        else
            empty <= (wr_addr == rd_addr_t) ? 1'b1 : 1'b0;
    end

	assign rd_addr_t = (rd_en == 1'b1 && empty_t == 1'b0) ? ($unsigned(rd_addr) + 'h1) : rd_addr;
	assign wr_addr_t = (wr_en == 1'b1 && full_t == 1'b0) ? ($unsigned(wr_addr) + 'h1) : wr_addr;
	assign empty_t = (wr_addr == rd_addr) ? 1'b1 : 1'b0;
	assign full_t = (wr_addr[FIFO_ADDR_WIDTH-2:0] == rd_addr[FIFO_ADDR_WIDTH-2:0]) &&
                    (wr_addr[FIFO_ADDR_WIDTH-1] != rd_addr[FIFO_ADDR_WIDTH-1]) ? 1'b1 : 1'b0;
	assign full = full_t;
endmodule

module fifo_array #(
    parameter FIFO_DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 1024,
    parameter ARRAY_SIZE = 3
) (
    input  logic reset,
    input  logic clock,

    input  logic wr_en,
    input  logic signed [FIFO_DATA_WIDTH-1:0] din[ARRAY_SIZE-1:0],
    output logic full,
    
    input  logic rd_en,
    output logic signed [FIFO_DATA_WIDTH-1:0] dout[ARRAY_SIZE-1:0],
    output logic empty
);

    logic full_arr[ARRAY_SIZE-1:0], empty_arr[ARRAY_SIZE-1:0];

    logic signed [FIFO_DATA_WIDTH-1:0] temp1, temp2, temp3;

    always_comb begin
        temp1 = din[0];
        temp2 = din[1];
        temp3 = din[2];
    end

    genvar i;
    generate for(i = 0; i < ARRAY_SIZE; i = i + 1) begin : fifo_doing_stuff
        fifo #(
            .FIFO_DATA_WIDTH     (FIFO_DATA_WIDTH),
            .FIFO_BUFFER_SIZE    (FIFO_BUFFER_SIZE)
        ) u_fifo (
            .reset               (reset),
            .wr_clk              (clock),
            .rd_clk              (clock),

            .din                 (din[i]),
            .wr_en               (wr_en),
            .full                (full_arr[i]),
            
            .dout                (dout[i]),
            .rd_en               (rd_en),
            .empty               (empty_arr[i])
        );
    end
    endgenerate

    logic all_empty = 0;
    logic all_full = 0;

    always_comb begin
        all_empty = empty_arr[0];
        all_full = full_arr[0];
        for(int j = 0; j < ARRAY_SIZE; j = j + 1) begin
            all_empty = all_empty || empty_arr[j];
            all_full = all_full || full_arr[j];
        end
        empty = all_empty;
        full = all_full;
    end
endmodule