module dot_module #(
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] x[2:0],
    input logic signed [31:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed[31:0] out,
    input logic out_full,
    output logic out_wr_en
);

enum logic {s0, s1} state, next_state;
logic signed [31+Q_BITS:0] out_big [2:0];
logic signed [31:0] out_c;

always_ff @(posedge clock or posedge reset) begin
    if(reset) begin
        state <= s0;
        out <= 'b0;
    end else begin
        state <= next_state;
        out <= out_c;
    end
end

//testing
logic signed [31+Q_BITS:0] temp1, temp2, temp3;
logic signed [31:0] temp4, temp5, temp6, temp7;

always_comb begin
    temp1 = out_big[0];
    temp2 = out_big[1];
    temp3 = out_big[2];
    temp4 = x[0];
    temp5 = x[2];
    temp6 = y[0];
    temp7 = y[2];
end
//testing

always_comb begin
    out_c = out;
    next_state = state;

    in_rd_en = 'b0;
    out_wr_en = 'b0;

    case(state)
    s0: begin
        if(!in_empty) begin
            out_big[0] = (64'(x[0] * y[0])) >>> Q_BITS;
            out_big[1] = (64'(x[1] * y[1])) >>> Q_BITS;
            out_big[2] = (64'(x[2] * y[2])) >>> Q_BITS;

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
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] x[2:0],
    input logic signed [31:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed [31:0] out,
    output logic out_empty,
    input logic out_rd_en
);

logic signed [31:0] out_din;
logic out_full, out_wr_en;

dot_module #(
    .Q_BITS      (Q_BITS)
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

