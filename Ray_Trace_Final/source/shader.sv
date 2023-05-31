module shader # (
    parameter M_BITS = 'd12,
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16
) (
    input   logic           clock,
    input   logic           reset,

    input   logic                   hit_in,
    input   logic [M_BITS-1 : 0]    triangle_ID_in,
    input   logic                   wr_en_in,

    output  logic           in_fifo_full,
    input   logic           out_full,

    output  logic   [7:0]   pixel               [2:0],
    output  logic           out_wr_en
);

    logic                   in_fifo_empty;
    logic [2:0]             state;

    logic [M_BITS-1 : 0]    read_triangle_ID;
    logic                   read_hit;

    logic signed [D_BITS-1 : 0]    triangle_parse      [11:0];

    logic                   rd_en_in;

    logic                   hit_out;
    logic [M_BITS-1 : 0]    triangle_ID_out;

    logic                   tri_fifo_empty;
    logic                   hit_fifo_empty;
    logic                   tri_fifo_full;
    logic                   hit_fifo_full;

    logic [D_BITS - 1 : 0]  pix_val;

    assign pix_val = (triangle_parse[11] + ('b1 << Q_BITS)) >> 1;

    assign in_fifo_full = tri_fifo_full | hit_fifo_full;
    assign in_fifo_empty = tri_fifo_empty | hit_fifo_empty;

    fifo #(
        .FIFO_DATA_WIDTH    (M_BITS),
        .FIFO_BUFFER_SIZE   ('d1024)
    ) input_tri_fifo (
        .reset      (reset),
        .wr_clk     (clock),

        .wr_en      (wr_en_in),
        .din        (triangle_ID_in),

        .full       (tri_fifo_full),
        .rd_clk     (clock),
        .rd_en      (rd_en_in),
        .dout       (triangle_ID_out),
        .empty      (tri_fifo_empty)
    );

    fifo #(
        .FIFO_DATA_WIDTH    ('d1),
        .FIFO_BUFFER_SIZE   ('d1024)
    ) input_hit_fifo (
        .reset      (reset),
        .wr_clk     (clock),

        .wr_en      (wr_en_in),
        .din        (hit_in),

        .full       (hit_fifo_full),
        .rd_clk     (clock),
        .rd_en      (rd_en_in),
        .dout       (hit_out),
        .empty      (hit_fifo_empty)
    );

    dummy_memory #(
        .Q_BITS (Q_BITS),
        .D_BITS (D_BITS),
        .M_BITS (M_BITS)
    ) DUM_MEM0 (
        .clock      (clock),
        .reset      (reset),
        .mem_addr   (read_triangle_ID),

        .data_out   (triangle_parse)
    );

    always @ (posedge clock or posedge reset) begin

        if (reset) begin

            pixel[0]    <= 'b0;
            pixel[1]    <= 'b0;
            pixel[2]    <= 'b0;

            out_wr_en   <= 'b0;
            rd_en_in    <= 'b0;

            state       <= 'b0;

            read_hit    <= 0;
            read_triangle_ID <= 'b0;

        end else begin

            case (state)

                'h00 :  begin

                            out_wr_en               <= 0;

                            if (!in_fifo_empty) begin

                                read_triangle_ID    <= triangle_ID_out;
                                read_hit            <= hit_out;

                                rd_en_in            <= 'b1;

                                state               <= 'h01;

                            end

                        end

                'h01 :  begin

                            rd_en_in    <= 'b0;

                            state       <= 'h03;

                        end

                'h03 :  begin

                            if (read_hit) begin

                                pixel[0]    <= pix_val[Q_BITS - 1 : Q_BITS - 8];
                                pixel[1]    <= pix_val[Q_BITS - 1 : Q_BITS - 8];
                                pixel[2]    <= pix_val[Q_BITS - 1 : Q_BITS - 8];

                            end else begin

                                pixel[0]    <= 'b0;
                                pixel[1]    <= 'b0;
                                pixel[2]    <= 'b0;

                            end                           

                            state       <= 'h02;
                            
                        end

                'h02 :  begin

                            if (!out_full) begin

                                out_wr_en   <= 1;

                                state       <= 'h00;

                            end

                        end

                default : begin

                            pixel[0]    <= 'b0;
                            pixel[1]    <= 'b0;
                            pixel[2]    <= 'b0;
                
                            out_wr_en   <= 'b0;
                            rd_en_in    <= 'b0;
                
                            state       <= 'b0;
                
                            read_hit    <= 0;
                            read_triangle_ID <= 'b0;

                        end

            endcase

        end

    end

endmodule


            
            

