module p_hit_2_module #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input int dir[2:0],   
    input int origin[2:0],
    input int division_result,
    input logic in_empty,
    output logic in_rd_en,

    output int p_hit[2:0],
    output logic out_wr_en,
    input logic out_full
);

int scale_out[2:0], p_hit_c[2:0], p_hit_temp[2:0];

scale #(
    .Q_BITS ('d10)
) u_scale (
    .x      (dir),
    .a      (division_result),
    .out    (scale_out)
);

add u_add (
    .x      (scale_out),
    .y      (origin),
    .out    (p_hit_temp)
);


enum logic[1:0] {s0, s1} state, next_state;

always_ff @(posedge clock or posedge reset) begin
    if(reset) begin
        state <= s0;
        p_hit <= '{default: '0};
    end else begin
        state <= next_state;
        p_hit <= p_hit_c;
    end
end

always_comb begin
    next_state = state;
    p_hit_c = '0;

    in_rd_en = 'b0;
    out_wr_en = 'b0;

    case(state)
        s0: begin   //read from fifos
            if(!in_empty) begin
                //math needs to happen here
                p_hit_c = p_hit_temp;
                in_rd_en = 'b1;
                next_state = s1;
            end
        end
        
        s1: begin
            if(!out_full) begin
                //must assign p_hit with the right answer somehow;
                p_hit_c = '{default: '0};
                out_wr_en = 'b1;
                next_state = s0;
            end
        end
    endcase
end
    
endmodule