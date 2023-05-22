module streamer #(
    parameter Q_BITS = 'd10,
    parameter D_BITS = 'd32,
    parameter M_BITS = 'd12
) (
    input logic clock,
    input logic reset,

    input logic in_empty,
    output logic in_rd_en,
    input logic signed [D_BITS-1 : 0] ray_in [5:0],

    input logic out_full,
    output logic out_wr_en,
    output logic signed [D_BITS-1 : 0] instruction_out [17:0],

    output logic [M_BITS-1 : 0] mem_addr,
    input logic signed [D_BITS-1 : 0] mem_data [11:0]
);

localparam [12:0] TRI_MAX = 'hb; 
logic [2:0] state;

always @ (posedge clock or posedge reset) begin

    if (reset) begin

        in_rd_en            <= 0;
        out_wr_en           <= 0;

        instruction_out[ 0] <= 'b0;
        instruction_out[ 1] <= 'b0;
        instruction_out[ 2] <= 'b0;
        instruction_out[ 3] <= 'b0;
        instruction_out[ 4] <= 'b0;
        instruction_out[ 5] <= 'b0;
        instruction_out[ 6] <= 'b0;
        instruction_out[ 7] <= 'b0;
        instruction_out[ 8] <= 'b0;
        instruction_out[ 9] <= 'b0;
        instruction_out[10] <= 'b0;
        instruction_out[11] <= 'b0;
        instruction_out[12] <= 'b0;
        instruction_out[13] <= 'b0;
        instruction_out[14] <= 'b0;
        instruction_out[15] <= 'b0;
        instruction_out[16] <= 'b0;
        instruction_out[17] <= 'b0;
        
        mem_addr            <= 'b0;
        state               <= 'b0;

    end

    else begin

        case (state)

            'h0 :   begin

                        out_wr_en       <= 0;
                        mem_addr        <= 'b0;

                        if (!in_empty) begin

                            in_rd_en    <= 1;
                            state       <= 'h1;

                        end

                    end
            
            'h1 :   begin

                        instruction_out [5:0]   <= ray_in;
                        in_rd_en                <= 0;
                        state                   <= 'h2;

                    end
                
            'h2 :   begin

                        out_wr_en               <= 0;
                        instruction_out [17:6]  <= mem_data;
                        mem_addr                <= mem_addr + 1;
                        state                   <= 'h3;

                    end

            'h3 :   begin

                        if (!out_full) begin

                            out_wr_en   <= 1;
                            state       <= (mem_addr == (TRI_MAX + 1)) ? 'h0 : 'h2;

                        end

                    end

            default :   begin

                            in_rd_en        <= 0;
                            out_wr_en       <= 0;

                            instruction_out[ 0] <= 'b0;
                            instruction_out[ 1] <= 'b0;
                            instruction_out[ 2] <= 'b0;
                            instruction_out[ 3] <= 'b0;
                            instruction_out[ 4] <= 'b0;
                            instruction_out[ 5] <= 'b0;
                            instruction_out[ 6] <= 'b0;
                            instruction_out[ 7] <= 'b0;
                            instruction_out[ 8] <= 'b0;
                            instruction_out[ 9] <= 'b0;
                            instruction_out[10] <= 'b0;
                            instruction_out[11] <= 'b0;
                            instruction_out[12] <= 'b0;
                            instruction_out[13] <= 'b0;
                            instruction_out[14] <= 'b0;
                            instruction_out[15] <= 'b0;
                            instruction_out[16] <= 'b0;
                            instruction_out[17] <= 'b0;

                            mem_addr            <= 'b0;
                            state               <= 'b0;

                        end

        endcase

    end

end

endmodule

    