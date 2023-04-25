module dot_module #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] x[2:0],
    input logic signed [31:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output int out,
    input logic out_full,
    output logic out_wr_en
);

enum logic {s0, s1} state, next_state;
logic signed [47:0] out_big [2:0];
int out_c;
logic signed [31:0] test1, test2, test3;

always_ff @(posedge clock or posedge reset) begin
    if(reset) begin
        state <= s0;
        out <= 'b0;
    end else begin
        state <= next_state;
        out <= out_c;
    end
end

always_comb begin
    out_c = out;
    next_state = state;

    in_rd_en = 'b0;
    out_wr_en = 'b0;

    test1 = out_big[0];
    test2 = out_big[1];
    test3 = out_big[2];

    case(state)
    s0: begin
        if(!in_empty) begin
            out_big[0] = (x[0] * y[0]) >> Q_BITS;
            out_big[1] = (x[1] * y[1]) >> Q_BITS;
            out_big[2] = (x[2] * y[2]) >> Q_BITS;

            out_c = out_big[0] + out_big[1] + out_big[2];

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

module dot #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] x[2:0],
    input logic signed [31:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output int out,
    input logic out_empty,
    input logic out_rd_en
);

int out_din;
logic out_full;

dot_module #(
    .Q_BITS      ('d10)
) u_dot_module (
    .clock       (clock),
    .reset       (reset),
    .x           (x[2:0]),
    .y           (y[2:0]),
    .in_empty    (in_empty),
    .in_rd_en    (in_rd_en),
    .out         (out_din),
    .out_full    (out_full),
    .out_wr_en   (out_wr_en)
);

fifo #(
    .FIFO_DATA_WIDTH     (32),
    .FIFO_BUFFER_SIZE    (32*16)
) u_fifo (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (out_wr_en),
    .din                 (out_din),
    .full                (out_full),
    
    .rd_en               (out_rd_en),
    .dout                (out),
    .empty               (out_empty)
);
    
endmodule

