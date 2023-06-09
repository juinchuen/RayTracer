module accumulate #(
    parameter Q_BITS = 'd10,
    parameter D_BITS = 'd32
) (
    input logic clock,
    input logic reset,

    input logic in_empty,
    output logic in_rd_en,

    input logic out_full,
    output logic out_wr_en,

    input logic hit,
    input logic signed [D_BITS-1 : 0] p_hit [2:0],

    output logic signed [D_BITS-1 : 0] p_hit_min [2:0]
);

logic [3:0] state;

logic [D_BITS+Q_BITS-1 : 0] p_hit_squared [2:0];

logic [D_BITS-1 : 0] xy_add;
logic [D_BITS-1 : 0] d2;

logic signed [D_BITS-1 : 0] read_p_hit [2:0];
logic read_hit;

logic [D_BITS-1 : 0] dist_min;

always @ (posedge clock or posedge reset) begin

    if (reset) begin

        state               <= 'b0;

        read_p_hit[0]       <= 'b0;
        read_p_hit[1]       <= 'b0;
        read_p_hit[2]       <= 'b0;

        p_hit_squared[0]    <= 'b0;
        p_hit_squared[1]    <= 'b0;
        p_hit_squared[2]    <= 'b0;

        xy_add              <= 'b0;
        d2                  <= 'b0;

        in_rd_en            <= 'b0;
        out_wr_en           <= 'b0;

        p_hit_min[0]        <= 'b0;
        p_hit_min[1]        <= 'b0;
        p_hit_min[2]        <= 'b0;
    
        dist_min            <= ~'b0;

    end

    else begin

        case (state)

            'h0 :   begin

                        if (!in_empty) begin

                            in_rd_en    <= 1;
                            state       <= 'h1;

                        end

                    end

            'h1 :   begin

                        read_hit    <= hit;
                        read_p_hit  <= p_hit;
                        in_rd_en    <= 0;
                        state       <= 'h2;

                    end

            'h2 :   begin

                        if (!read_hit) begin

                            state <= 'h0;

                        end

                        else begin

                            state <= 'h3;

                        end

                    end

            'h3 :   begin

                        p_hit_squared[0] <= (read_p_hit[0] * read_p_hit[0]) >> Q_BITS;
                        p_hit_squared[1] <= (read_p_hit[1] * read_p_hit[1]) >> Q_BITS;
                        p_hit_squared[2] <= (read_p_hit[2] * read_p_hit[2]) >> Q_BITS;

                        state <= 'h4;

                    end

            'h4 :   begin

                        xy_add  <= p_hit_squared[0] + p_hit_squared[1];

                        state   <= 'h5;

                    end

            'h5 :   begin

                        d2      <= xy_add + p_hit_squared[2];

                        state   <= 'h6;

                    end

            'h6 :   begin

                        if (d2 < dist_min) begin

                            dist_min    <= d2;
                            p_hit_min   <= read_p_hit;

                            state <= 'h0;

                        end

                        else begin

                            state <= 'h0;

                        end

                    end

            default : begin

                        state               <= 'b0;

                        read_p_hit[0]       <= 'b0;
                        read_p_hit[1]       <= 'b0;
                        read_p_hit[2]       <= 'b0;

                        p_hit_squared[0]    <= 'b0;
                        p_hit_squared[0]    <= 'b0;
                        p_hit_squared[0]    <= 'b0;

                        xy_add              <= 'b0;
                        d2                  <= 'b0;
    
                        in_rd_en            <= 'b0;
                        out_wr_en           <= 'b0;
    
                        p_hit_min[0]        <= 'b0;
                        p_hit_min[1]        <= 'b0;
                        p_hit_min[2]        <= 'b0;
                        
                        dist_min            <= ~'b0;

                    end

        endcase

    end

end

endmodule



 