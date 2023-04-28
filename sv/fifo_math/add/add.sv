module add_module (
    input logic clock,
    input logic reset,
    input logic signed [31:0] x[2:0],
    input logic signed [31:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed [31:0] out[2:0],
    input logic out_full,
    output logic out_wr_en
);

//subtract x from y

enum logic {s0, s1} state, next_state;
logic signed [31:0] out_c[2:0];

always_ff @(posedge clock or posedge reset) begin
    if(reset) begin
        state <= s0;
        out[0] <= 'b0;
        out[1] <= 'b0;
        out[2] <= 'b0;
    end else begin
        state <= next_state;
        out[0] <= out_c[0];
        out[1] <= out_c[1];
        out[2] <= out_c[2];
    end
end

always_comb begin
    out_c = out;
    next_state = state;

    in_rd_en = 'b0;
    out_wr_en = 'b0;

    // test1 = x[0];
    // test2 = x[1];
    // test3 = x[2];

    case(state)
    s0: begin
        if(!in_empty) begin
            out_c[0] = x[0] + y[0];
            out_c[1] = x[1] + y[1];
            out_c[2] = x[2] + y[2];

            in_rd_en = 'b1;
            next_state = s1;
        end
    end

    s1: begin
        if(!out_full) begin
            out_wr_en = 'b1;
            next_state = s0;
        end
    end
    endcase
end
endmodule

module add(
    input logic clock,
    input logic reset,
    input logic signed [31:0] x[2:0],
    input logic signed [31:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed [31:0] out[2:0],
    output logic out_empty,
    input logic out_rd_en
);

logic signed [31:0] out_din[2:0];
logic out_full, out_wr_en;

sub_module u_sub_module (
    .clock        (clock),
    .reset        (reset),
    .x            (x[2:0]),
    .y            (y[2:0]),
    .in_empty     (in_empty),
    .in_rd_en     (in_rd_en),
    .out          (out_din[2:0]),
    .out_full     (out_full),
    .out_wr_en    (out_wr_en)
);

fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) u_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (out_wr_en),
    .din                     (out_din[2:0]),
    .full                    (out_full),
    .rd_en                   (out_rd_en),
    .dout                    (out[2:0]),
    .empty                   (out_empty)
);

endmodule