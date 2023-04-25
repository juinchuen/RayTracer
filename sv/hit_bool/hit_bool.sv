module hit_bool #(
    Q_BITS = 'd10
)
(
    //
    input logic clock,
    input logic reset,
    // p_hit module output, normal coordinates
    input logic [95:0] p_hit,
    input int normal [2:0],
    // Vector inputs
    input int v0 [2:0],
    input int v1 [2:0],
    input int v2 [2:0],

    // FIFO signals going in
    input logic fifo_in_empty,
    input logic fifo_out_rd_en,  

    // FIFO signals going out 
    output logic fifo_in_rd_en,
    output logic fifo_out_dout,   
    output logic fifo_out_empty  
); 

// Intermediary signals
// Vector subtraction outputs
int o0 [2:0]; 
int o1 [2:0];
int o2 [2:0];
// p_hit and vector subtraction outputs
int p0 [2:0]; 
int p1 [2:0];
int p2 [2:0];
// cross product outputs
int c0 [2:0]; 
int c1 [2:0];
int c2 [2:0];
// Dot product outputs
int d0;
int d1;
int d2;
// hit bool
logic hit, hit_c;
// unpack the p_hit input to put into an array of ints
int p_hit_arr [2:0];
assign p_hit_arr[0] = int'(p_hit[31:0]);
assign p_hit_arr[1] = int'(p_hit[63:32]);
assign p_hit_arr[2] = int'(p_hit[95:64]);
// Output FIFO 
logic fifo_out_full;   
logic fifo_out_wr_en; 
// State email
typedef enum logic [1:0] {s0, s1} state_types;
state_types state; 
state_types state_c = s0;

// Place debug statements here:

/////////////////////////////////
// Module instantiation
// Subtract stage 1
subtract u_subtract_one (
    .out    (o0),
    .x      (v1),
    .y      (v0)
);
subtract u_subtract_two (
    .out    (o1),
    .x      (v2),
    .y      (v1)
);
subtract u_subtract_three (
    .out    (o2),
    .x      (v0),
    .y      (v2)
);
// Subtract stage 2
subtract u_subtract_four (
    .out    (p0),
    .x      (p_hit_arr),
    .y      (v0)
);
subtract u_subtract_five (
    .out    (p1),
    .x      (p_hit_arr),
    .y      (v1)
);
subtract u_subtract_six (
    .out    (p2),
    .x      (p_hit_arr),
    .y      (v2)    
);
// Cross stage
Cross #(
    .Q_BITS(Q_BITS)
) u_Cross_one (
    .out   (c0),
    .x     (o0),
    .y     (p0)
);
Cross #(
    .Q_BITS (Q_BITS)
) u_Cross_two (
    .out   (c1),
    .x     (o1),
    .y     (p1)
);
Cross #(
    .Q_BITS (Q_BITS)
) u_Cross_three (
    .out   (c2),
    .x     (o2),
    .y     (p2)
);
// Dot stage
dot #(
    .Q_BITS (Q_BITS)
) u_dot_one (
    .out    (d0),
    .x      (normal),
    .y      (c0)
);
dot #(
    .Q_BITS (Q_BITS)
) u_dot_two (
    .out    (d1),
    .x      (normal),
    .y      (c1)
);
dot #(
    .Q_BITS (Q_BITS)
) u_dot_three (
    .out    (d2),
    .x      (normal),
    .y      (c2)
);

// FIFO to hold outputs
fifo #(
    .FIFO_DATA_WIDTH     (1),
    .FIFO_BUFFER_SIZE    (1024)
) u_fifo_out (
    .reset               (reset),
    .wr_clk              (clock),
    .wr_en               (fifo_out_wr_en),
    .din                 (hit),
    .full                (fifo_out_full),
    .rd_clk              (clock),
    .rd_en               (fifo_out_rd_en),
    .dout                (fifo_out_dout),
    .empty               (fifo_out_empty)
);

always_ff @(posedge clock or posedge reset) begin
    if(reset)begin
        hit <= 0;
        state <= s0;
    end else begin
        hit <= hit_c;
        state <= state_c;
    end
end

always_comb begin
    // Check if dot products are greater than 0
    // If greater return 1. Else return 0
    fifo_in_rd_en = 0;
    fifo_out_wr_en = 0;
    hit_c = hit;
    
    case (state)
        s0: begin
            if (fifo_in_empty == 1'b0) begin
                hit_c = (d0 > 0) && (d1 > 0) && (d2 > 0);
                fifo_in_rd_en = 1'b1;
                state_c = s1;
            end else begin
                state_c = s0;
            end
        end
        s1: begin
            if (fifo_out_full == 1'b0)begin
                fifo_out_wr_en = 1'b1;
                hit_c = 0;
                state_c = s0;
            end else begin
                state_c = s1;
            end
        end
    endcase
end
endmodule

// Debug statements
// int v0_0;
// int v0_1;
// int v0_2;

// int v1_0;
// int v1_1;
// int v1_2;

// int v2_0;
// int v2_1;
// int v2_2;

// int normal_0;
// int normal_1;
// int normal_2;

// int p_hit_arr_show_0;
// int p_hit_arr_show_1;
// int p_hit_arr_show_2;

// int o0_show_0;
// int o0_show_1;
// int o0_show_2;
// int o1_show_0;
// int o1_show_1;
// int o1_show_2;
// int o2_show_0;
// int o2_show_1;
// int o2_show_2;

// int p0_show_0;
// int p0_show_1;
// int p0_show_2;
// int p1_show_0;
// int p1_show_1;
// int p1_show_2;
// int p2_show_0;
// int p2_show_1;
// int p2_show_2;

// int c0_show_0;
// int c0_show_1;
// int c0_show_2;
// int c1_show_0;
// int c1_show_1;
// int c1_show_2;
// int c2_show_0;
// int c2_show_1;
// int c2_show_2;

// assign v0_0 = v0[0];
// assign v0_1 = v0[1];
// assign v0_2 = v0[2];

// assign v1_0 = v1[0];
// assign v1_1 = v1[1];
// assign v1_2 = v1[2];

// assign v2_0 = v2[0];
// assign v2_1 = v2[1];
// assign v2_2 = v2[2];

// assign normal_0 = normal[0];
// assign normal_1 = normal[1];
// assign normal_2 = normal[2];

// assign p_hit_arr_show_0 = p_hit_arr[0];
// assign p_hit_arr_show_1 = p_hit_arr[1];
// assign p_hit_arr_show_2 = p_hit_arr[2];

// assign o0_show_0 = o0[0];
// assign o0_show_1 = o0[1];
// assign o0_show_2 = o0[2];
// assign o1_show_0 = o1[0];
// assign o1_show_1 = o1[1];
// assign o1_show_2 = o1[2];
// assign o2_show_0 = o2[0];
// assign o2_show_1 = o2[1];
// assign o2_show_2 = o2[2];

// assign p0_show_0 = p0[0];
// assign p0_show_1 = p0[1];
// assign p0_show_2 = p0[2];
// assign p1_show_0 = p1[0];
// assign p1_show_1 = p1[1];
// assign p1_show_2 = p1[2];
// assign p2_show_0 = p2[0];
// assign p2_show_1 = p2[1];
// assign p2_show_2 = p2[2];

// assign c0_show_0 = c0[0];
// assign c0_show_1 = c0[1];
// assign c0_show_2 = c0[2];
// assign c1_show_0 = c1[0];
// assign c1_show_1 = c1[1];
// assign c1_show_2 = c1[2];
// assign c2_show_0 = c2[0];
// assign c2_show_1 = c2[1];
// assign c2_show_2 = c2[2];