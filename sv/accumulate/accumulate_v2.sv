module accumulate #(
    parameter Q_BITS = 'd10,
    parameter D_BITS = 'd32,
    parameter M_BITS = 'd12
) (
    input   logic                           clock,
    input   logic                           reset,

    input   logic                           in_empty,
    output  logic                           in_rd_en,

    input   logic                           out_full,
    output  logic                           out_wr_en,

    input   logic                           hit,
    input   logic signed    [D_BITS-1 : 0]  p_hit               [2:0],
    input   logic           [M_BITS-1 : 0]  triangle_ID,
    input   logic signed    [D_BITS-1 : 0]  origin              [2:0],

    output  logic                           hit_min,
    output  logic signed    [D_BITS-1 : 0]  p_hit_min           [2:0],
    output  logic           [M_BITS-1 : 0]  triangle_ID_min
);

logic           [3:0]                   state;

logic           [D_BITS+Q_BITS-1 : 0]   p_hit_squared   [2:0];

logic           [D_BITS+Q_BITS+1 : 0]   d2;

logic signed    [D_BITS-1 : 0]          read_p_hit      [2:0];
logic                                   read_hit;
logic           [M_BITS-1 : 0]          read_triangle_ID;
logic signed    [D_BITS-1 : 0]          read_origin     [2:0];

logic           [D_BITS+Q_BITS+1 : 0]   d2_min;

logic                                   start_up_flag;

int                                     i;

always @ (posedge clock or posedge reset) begin

    if (reset) begin

        for (i = 0; i < 3; i++) begin

            read_p_hit[i]       <= 'b0;
            p_hit_squared[i]    <= 'b0;
            p_hit_min[i]        <= 'b0;
            read_origin[i]      <= 'b0;

        end

        read_hit            <= 'b0;
        read_triangle_ID    <= 'b0;

        state               <= 'b0;

        d2                  <= 'b0;

        in_rd_en            <= 'b0;
        out_wr_en           <= 'b0;
    
        d2_min              <= ~'b0;
        triangle_ID_min     <= 'b0;
        hit_min             <= 'b0;

        start_up_flag       <= 'b1;

    end

    else begin
    
        case (state)

            'h00 :  begin

                        if (!in_empty) begin

                            in_rd_en    <= 'b1;
                            state       <= 'h1;

                        end

                    end

            'h01 :  begin

                        in_rd_en            <= 'b0;

                        read_hit            <= hit;

                        read_p_hit [0]      <= p_hit[0];
                        read_p_hit [1]      <= p_hit[1];
                        read_p_hit [2]      <= p_hit[2];

                        read_triangle_ID    <= triangle_ID;

                        read_origin         <= origin;

                        state               <= 'h2;

                    end

            'h02 :  begin

                        if (read_triangle_ID == 'b0) begin

                            d2_min  <= ~'b0;

                            if (start_up_flag) begin

                                start_up_flag   <= 'b0;

                                state           <= 'h3;

                            end

                            else begin

                                if (!out_full) begin

                                    out_wr_en   <= 'b1;

                                    state       <= 'h3;

                                end

                            end

                        end

                        else begin

                            state <= 'h3;

                        end

                    end

            'h03 :  begin

                        out_wr_en           <= 'b0;

                        if (read_triangle_ID == 'b0) begin

                            hit_min <= 'b0;

                        end

                        if (read_hit) begin

                            hit_min <= 'b1;

                            state   <= 'h7;

                        end

                        else begin

                            state <= 'h0;

                        end

                    end

            'h07 :  begin

                        read_p_hit[0]   <= read_p_hit[0] - read_origin[0];
                        read_p_hit[1]   <= read_p_hit[1] - read_origin[1];
                        read_p_hit[2]   <= read_p_hit[2] - read_origin[2];
                        
                        state           <= 'h4;

                    end

            'h04 :  begin

                        p_hit_squared[0]    <= read_p_hit[0] * read_p_hit[0];
                        p_hit_squared[1]    <= read_p_hit[1] * read_p_hit[1];
                        p_hit_squared[2]    <= read_p_hit[2] * read_p_hit[2];

                        state               <= 'h5;

                    end

            'h05 :  begin

                        d2      <= p_hit_squared[0] + p_hit_squared[1] + p_hit_squared[2];

                        state   <= 'h6;

                    end

            'h06 :  begin

                        if (d2 < d2_min) begin

                            p_hit_min[0]    <= read_p_hit[0];
                            p_hit_min[1]    <= read_p_hit[1];
                            p_hit_min[2]    <= read_p_hit[2];

                            triangle_ID_min <= read_triangle_ID;

                            d2_min          <= d2;

                        end

                        state <= 'h0;

                    end

            default : begin

                        for (i = 0; i < 3; i++) begin

                            read_p_hit[i]       <= 'b0;
                            p_hit_squared[i]    <= 'b0;
                            p_hit_min[i]        <= 'b0;

                        end

                        read_hit            <= 'b0;
                        read_triangle_ID    <= 'b0;

                        state               <= 'b0;

                        d2                  <= 'b0;

                        in_rd_en            <= 'b0;
                        out_wr_en           <= 'b0;
                    
                        d2_min              <= ~'b0;
                        triangle_ID_min     <= 'b0;

                        start_up_flag       <= 'b0;

                    end

        endcase

    end

end

endmodule