module hit_bool #(
    D_BITS = 'd32,
    Q_BITS = 'd10,
    M_BITS = 'd12
)(
    //
    input logic clock,
    input logic reset,

    // p_hit data from module
    input logic signed [D_BITS-1:0] p_hit_din [2:0],

    // normal data
    input logic signed [D_BITS-1:0] normal [2:0],

    // Vector inputs 
    input logic signed [D_BITS-1:0] v0 [2:0],
    input logic signed [D_BITS-1:0] v1 [2:0],
    input logic signed [D_BITS-1:0] v2 [2:0],

    // Pass through data
    input logic [M_BITS-1:0] tri_id_din,
    input logic [M_BITS-1:0] ray_id_din,
    input logic signed [D_BITS-1:0] ray_origin_din [2:0],
    output logic [M_BITS-1:0] tri_id_dout,
    output logic [M_BITS-1:0] ray_id_dout,
    output logic signed [D_BITS-1:0] ray_origin_dout [2:0],
    
    // hit_bool output
    output logic hit_bool_dout,

    // p_hit output (passed through)
    output logic signed [D_BITS-1:0] p_hit_dout [2:0],

    // Tied together FIFO signals 
    output logic in_rd_en,      // Signal that reads from p_hit's output FIFOs
    input logic out_rd_en,      // Read enable for all output FIFOs
    input logic in_empty,       // Signal that indicates if any of p_hit's output FIFOs are empty
    output logic out_empty      // Signal that indicates if any output FIFOs in this module are empty
); 

// Tie input FIFO full signals together
logic in_full; 
logic v0_in_full;
logic v1_in_full;
logic v2_in_full;
logic normal_in_full;
logic tri_id_fifo_full;
logic ray_id_fifo_full;
logic ray_origin_fifo_full;
logic p_hit_calc_fifo_full;
logic p_hit_fifo_out_full;
assign in_full = v0_in_full || v1_in_full || v2_in_full || normal_in_full || tri_id_fifo_full || ray_id_fifo_full || ray_origin_fifo_full || p_hit_calc_fifo_full || p_hit_fifo_out_full;

// Tie output FIFO empty signals together
logic tri_id_fifo_empty;
logic ray_id_fifo_empty;
logic ray_origin_fifo_empty;
logic p_hit_fifo_out_empty;
logic hit_bool_empty;
assign out_empty = tri_id_fifo_empty || ray_id_fifo_empty || ray_origin_fifo_empty || p_hit_fifo_out_empty || hit_bool_empty;

// Global write var for all input FIFOs
logic in_wr_en; 

// Intermediary signals
// Vector subtraction outputs
logic signed [D_BITS-1:0] o0 [2:0]; 
logic signed [D_BITS-1:0] o1 [2:0];
logic signed [D_BITS-1:0] o2 [2:0];
// p_hit and vector subtraction outputs
logic signed [D_BITS-1:0] p0 [2:0]; 
logic signed [D_BITS-1:0] p1 [2:0];
logic signed [D_BITS-1:0] p2 [2:0];
// cross product outputs
logic signed [D_BITS-1:0] c0 [2:0]; 
logic signed [D_BITS-1:0] c1 [2:0];
logic signed [D_BITS-1:0] c2 [2:0];
// Dot product outputs
logic signed [D_BITS-1:0] d0;
logic signed [D_BITS-1:0] d1;
logic signed [D_BITS-1:0] d2;
// hit bool
logic hit, hit_c;

// Input FIFOs
logic normal_in_rd_en;
logic normal_in_empty;
logic signed [D_BITS-1:0] normal_in_dout [2:0];

logic v0_in_rd_en;
logic signed [D_BITS-1:0] v0_in_dout[2:0];
logic v0_in_empty;

logic v1_in_rd_en;
logic signed [D_BITS-1:0] v1_in_dout[2:0];
logic v1_in_empty;

logic v2_in_rd_en;
logic signed [D_BITS-1:0] v2_in_dout[2:0];
logic v2_in_empty;

// Output hit_bool FIFO 
logic hit_bool_full;   
logic hit_bool_wr_en;

// calc buffer p_hit fifo
logic p_hit_calc_fifo_rd_en;
logic p_hit_calc_fifo_empty;
logic signed [D_BITS-1:0] p_hit_calc_fifo_dout [2:0];

// Output p_hit FIFO
logic signed [D_BITS-1:0] p_hit_fifo_out_din [2:0];

// States
typedef enum logic [1:0] {s0, s1, s2} state_types;
state_types state; 
state_types state_c = s0;

// Module instantiation vars
logic sub_0_in_empty;
logic sub_0_in_rd_en;
logic sub_0_out_empty;
logic sub_0_out_rd_en;

logic sub_1_in_empty;
logic sub_1_in_rd_en;
logic sub_1_out_empty;
logic sub_1_out_rd_en;
logic sub_2_in_empty;

logic sub_2_in_rd_en;
logic sub_2_out_empty;
logic sub_2_out_rd_en;

logic sub_3_in_empty;
logic sub_3_in_rd_en;
logic sub_3_out_empty;
logic sub_3_out_rd_en;

logic sub_4_in_empty;
logic sub_4_in_rd_en;
logic sub_4_out_empty;
logic sub_4_out_rd_en;

logic sub_5_in_empty;
logic sub_5_in_rd_en;
logic sub_5_out_empty;
logic sub_5_out_rd_en;

logic cross_0_in_empty;
logic cross_0_in_rd_en; 
logic cross_0_out_empty;
logic cross_0_out_rd_en;

logic cross_1_in_empty;
logic cross_1_in_rd_en; 
logic cross_1_out_empty;
logic cross_1_out_rd_en;

logic cross_2_in_empty;
logic cross_2_in_rd_en;
logic cross_2_out_empty;
logic cross_2_out_rd_en;

logic dot_rd_en; 

logic dot_0_in_empty;
logic dot_0_in_rd_en;
logic dot_0_out_empty;
logic dot_0_out_rd_en;

logic dot_1_in_empty;
logic dot_1_in_rd_en;
logic dot_1_out_empty;
logic dot_1_out_rd_en;

logic dot_2_in_empty;
logic dot_2_in_rd_en;
logic dot_2_out_empty;
logic dot_2_out_rd_en;

logic dot_empty;

// Assignments 
assign sub_0_in_empty = v0_in_empty || v1_in_empty;
assign sub_0_out_rd_en = cross_0_in_rd_en;
assign sub_1_in_empty = v1_in_empty || v2_in_empty;
assign sub_1_out_rd_en = cross_1_in_rd_en;
assign sub_2_in_empty = v2_in_empty || v0_in_empty;
assign sub_2_out_rd_en = cross_2_in_rd_en;

assign v0_in_rd_en = sub_0_in_rd_en || sub_2_in_rd_en;
assign v1_in_rd_en = sub_0_in_rd_en || sub_1_in_rd_en;
assign v2_in_rd_en = sub_1_in_rd_en || sub_2_in_rd_en;

assign sub_3_in_empty = p_hit_calc_fifo_empty || v0_in_empty;
assign sub_3_out_rd_en = cross_0_in_rd_en;
assign sub_4_in_empty = p_hit_calc_fifo_empty || v1_in_empty;
assign sub_4_out_rd_en = cross_1_in_rd_en;
assign sub_5_in_empty = p_hit_calc_fifo_empty || v2_in_empty;
assign sub_5_out_rd_en = cross_2_in_rd_en;
assign p_hit_calc_fifo_rd_en = sub_3_in_rd_en && sub_4_in_rd_en && sub_5_in_rd_en;
assign cross_0_in_empty = sub_0_out_empty || sub_3_out_empty; // sub 0 and 3 feed cross 0
assign cross_0_out_rd_en = dot_0_in_rd_en;
assign cross_1_in_empty = sub_1_out_empty || sub_4_out_empty; // sub 0 and 3 feed cross 0
assign cross_1_out_rd_en = dot_1_in_rd_en;
assign cross_2_in_empty = sub_2_out_empty || sub_5_out_empty;
assign cross_2_out_rd_en = dot_2_in_rd_en;
assign dot_0_in_empty = cross_0_out_empty || normal_in_empty;
assign dot_0_out_rd_en = dot_rd_en;
assign dot_1_in_empty = cross_1_out_empty || normal_in_empty;
assign dot_1_out_rd_en = dot_rd_en;
assign dot_2_in_empty = cross_2_out_empty || normal_in_empty;
assign dot_2_out_rd_en = dot_rd_en;
assign normal_in_rd_en = dot_0_in_rd_en && dot_1_in_rd_en && dot_2_in_rd_en;
assign dot_empty = dot_0_out_empty && dot_1_out_empty && dot_2_out_empty;

// Subtract stage 1

sub  #(
    .D_BITS       (D_BITS)
) u_sub_0 ( // Pipes to cross 0
    .clock        (clock),
    .reset        (reset),
    .x            (v1_in_dout[2:0]),
    .y            (v0_in_dout[2:0]),
    .in_empty     (sub_0_in_empty),
    .in_rd_en     (sub_0_in_rd_en),
    .out          (o0[2:0]),
    .out_empty    (sub_0_out_empty),
    .out_rd_en    (sub_0_out_rd_en)
);

logic [D_BITS-1:0] o0_0;
logic [D_BITS-1:0] o0_1;
logic [D_BITS-1:0] o0_2;
assign o0_0 = o0[0];
assign o0_1 = o0[1];
assign o0_2 = o0[2];

sub  #(
    .D_BITS       (D_BITS)
) u_sub_1 ( // Pipes to cross 1 
    .clock        (clock),
    .reset        (reset),
    .x            (v2_in_dout[2:0]),
    .y            (v1_in_dout[2:0]),
    .in_empty     (sub_1_in_empty),
    .in_rd_en     (sub_1_in_rd_en),
    .out          (o1[2:0]),
    .out_empty    (sub_1_out_empty),
    .out_rd_en    (sub_1_out_rd_en)
);

sub  #(
    .D_BITS       (D_BITS)
) u_sub_2 ( // Pipes to cross 2
    .clock        (clock),
    .reset        (reset),
    .x            (v0_in_dout[2:0]),
    .y            (v2_in_dout[2:0]),
    .in_empty     (sub_2_in_empty),
    .in_rd_en     (sub_2_in_rd_en),
    .out          (o2[2:0]),
    .out_empty    (sub_2_out_empty),
    .out_rd_en    (sub_2_out_rd_en)
);

// Subtract stage 2
sub  #(
    .D_BITS       (D_BITS)
) u_sub_3 ( // Pipes to cross 0
    .clock        (clock),
    .reset        (reset),
    .x            (p_hit_calc_fifo_dout[2:0]),
    .y            (v0_in_dout[2:0]),
    .in_empty     (sub_3_in_empty),
    .in_rd_en     (sub_3_in_rd_en),
    .out          (p0[2:0]),
    .out_empty    (sub_3_out_empty),
    .out_rd_en    (sub_3_out_rd_en)
);

sub  #(
    .D_BITS       (D_BITS)
) u_sub_4 ( // Pipes to cross 1
    .clock        (clock),
    .reset        (reset),
    .x            (p_hit_calc_fifo_dout[2:0]),
    .y            (v1_in_dout[2:0]),
    .in_empty     (sub_4_in_empty),
    .in_rd_en     (sub_4_in_rd_en),
    .out          (p1[2:0]),
    .out_empty    (sub_4_out_empty),
    .out_rd_en    (sub_4_out_rd_en)
);

sub  #(
    .D_BITS       (D_BITS)
) u_sub_5 ( // Pipes to cross 2
    .clock        (clock),
    .reset        (reset),
    .x            (p_hit_calc_fifo_dout[2:0]),
    .y            (v2_in_dout[2:0]),
    .in_empty     (sub_5_in_empty),
    .in_rd_en     (sub_5_in_rd_en),
    .out          (p2[2:0]),
    .out_empty    (sub_5_out_empty),
    .out_rd_en    (sub_5_out_rd_en)
);

// Cross stage

Cross #(
    .D_BITS       (D_BITS),
    .Q_BITS       (Q_BITS)
) u_Cross_0 (
    .clock        (clock),
    .reset        (reset),
    .x            (o0[2:0]),
    .y            (p0[2:0]),
    .in_empty     (cross_0_in_empty),
    .in_rd_en     (cross_0_in_rd_en),
    .out_rd_en    (cross_0_out_rd_en),
    .out_empty    (cross_0_out_empty),
    .out          (c0[2:0])
);

Cross #(
    .D_BITS       (D_BITS),
    .Q_BITS       (Q_BITS)
) u_Cross_1 (
    .clock        (clock),
    .reset        (reset),
    .x            (o1[2:0]),
    .y            (p1[2:0]),
    .in_empty     (cross_1_in_empty),
    .in_rd_en     (cross_1_in_rd_en),
    .out_rd_en    (cross_1_out_rd_en),
    .out_empty    (cross_1_out_empty),
    .out          (c1[2:0])
);

Cross #(
    .D_BITS       (D_BITS),
    .Q_BITS       (Q_BITS)
) u_Cross_2 (
    .clock        (clock),
    .reset        (reset),
    .x            (o2[2:0]),
    .y            (p2[2:0]),
    .in_empty     (cross_2_in_empty),
    .in_rd_en     (cross_2_in_rd_en),
    .out_rd_en    (cross_2_out_rd_en),
    .out_empty    (cross_2_out_empty),
    .out          (c2[2:0])
);

// Dot stage
dot #(
    .D_BITS       (D_BITS),
    .Q_BITS       (Q_BITS)
) u_dot_0 (
    .clock        (clock),
    .reset        (reset),
    .x            (normal_in_dout[2:0]),
    .y            (c0[2:0]),
    .in_empty     (dot_0_in_empty),
    .in_rd_en     (dot_0_in_rd_en),
    .out          (d0),
    .out_empty    (dot_0_out_empty),
    .out_rd_en    (dot_0_out_rd_en)
);

dot #(
    .D_BITS       (D_BITS),
    .Q_BITS       (Q_BITS)
) u_dot_1 (
    .clock        (clock),
    .reset        (reset),
    .x            (normal_in_dout[2:0]),
    .y            (c1[2:0]),
    .in_empty     (dot_1_in_empty),
    .in_rd_en     (dot_1_in_rd_en),
    .out          (d1),
    .out_empty    (dot_1_out_empty),
    .out_rd_en    (dot_1_out_rd_en)
);

dot #(
    .D_BITS       (D_BITS),
    .Q_BITS       (Q_BITS)
) u_dot_2 (
    .clock        (clock),
    .reset        (reset),
    .x            (normal_in_dout[2:0]),
    .y            (c2[2:0]),
    .in_empty     (dot_2_in_empty),
    .in_rd_en     (dot_2_in_rd_en),
    .out          (d2),
    .out_empty    (dot_2_out_empty),
    .out_rd_en    (dot_2_out_rd_en)
);

// FIFOs to hold inputs
fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (D_BITS*4),
    .ARRAY_SIZE              (3)
) normal_in_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en),
    .din                     (normal[2:0]),
    .full                    (normal_in_full),
    .rd_en                   (normal_in_rd_en),
    .dout                    (normal_in_dout[2:0]),
    .empty                   (normal_in_empty)
);

// Vector fifos
fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (D_BITS*4),
    .ARRAY_SIZE              (3)
) v0_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en),
    .din                     (v0[2:0]),
    .full                    (v0_in_full),
    .rd_en                   (v0_in_rd_en),
    .dout                    (v0_in_dout[2:0]),
    .empty                   (v0_in_empty)
);

fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (D_BITS*4),
    .ARRAY_SIZE              (3)
) v1_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en),
    .din                     (v1[2:0]),
    .full                    (v1_in_full),
    .rd_en                   (v1_in_rd_en),
    .dout                    (v1_in_dout[2:0]),
    .empty                   (v1_in_empty)
);

fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (D_BITS*4),
    .ARRAY_SIZE              (3)
) v2_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en),
    .din                     (v2[2:0]),
    .full                    (v2_in_full),
    .rd_en                   (v2_in_rd_en),
    .dout                    (v2_in_dout[2:0]),
    .empty                   (v2_in_empty)
);

// Calculations take 2 clock cycles, but we want to store the new p_hit data being
// read every cycle, so we unfortunately need two buffers, one for holding and one 
// to pass to the data operations

// Fifo to hold triangle ID
fifo #(
    .FIFO_DATA_WIDTH     (M_BITS),
    .FIFO_BUFFER_SIZE    (M_BITS*4)
) u_tri_id_fifo (
    .reset               (reset),
    .wr_clk              (clock),
    .wr_en               (in_wr_en),
    .din                 (tri_id_din),
    .full                (tri_id_fifo_full),
    .rd_clk              (clock),
    .rd_en               (out_rd_en),
    .dout                (tri_id_dout),
    .empty               (tri_id_fifo_empty)
);

// Fifo to hold ray ID
fifo #(
    .FIFO_DATA_WIDTH     (M_BITS),
    .FIFO_BUFFER_SIZE    (M_BITS*4)
) u_ray_id_fifo (
    .reset               (reset),
    .wr_clk              (clock),
    .wr_en               (in_wr_en),
    .din                 (ray_id_din),
    .full                (ray_id_fifo_full),
    .rd_clk              (clock),
    .rd_en               (out_rd_en),
    .dout                (ray_id_dout),
    .empty               (ray_id_fifo_empty)
);

// Fifo to hold ray origin
fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (D_BITS*4),
    .ARRAY_SIZE              (3)
) u_ray_origin_fifo(
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en),
    .din                     (ray_origin_din[2:0]),
    .full                    (ray_origin_fifo_full),
    .rd_en                   (out_rd_en),
    .dout                    (ray_origin_dout[2:0]),
    .empty                   (ray_origin_fifo_empty)
);

// Fifo array to hold p_hit, used for calculations
fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (D_BITS*4),
    .ARRAY_SIZE              (3)
) u_calc_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en),
    .din                     (p_hit_din[2:0]),
    .full                    (p_hit_calc_fifo_full),
    .rd_en                   (p_hit_calc_fifo_rd_en),
    .dout                    (p_hit_calc_fifo_dout[2:0]),
    .empty                   (p_hit_calc_fifo_empty)
);
// FIFO array to hold p_hit, used to output alongside a boolean
// assign p_hit_fifo_out_din = p_hit;
fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (D_BITS*4),
    .ARRAY_SIZE              (3)
) u_p_hit_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en),
    .din                     (p_hit_din[2:0]),
    .full                    (p_hit_fifo_out_full),
    .rd_en                   (out_rd_en),
    .dout                    (p_hit_dout[2:0]),
    .empty                   (p_hit_fifo_out_empty)
);
// FIFO to hold outputs
fifo #(
    .FIFO_DATA_WIDTH     (1),
    .FIFO_BUFFER_SIZE    (4)
) u_hit_bool_fifo (
    .reset               (reset),
    .wr_clk              (clock),
    .wr_en               (hit_bool_wr_en),
    .din                 (hit),
    .full                (hit_bool_full),
    .rd_clk              (clock),
    .rd_en               (out_rd_en),
    .dout                (hit_bool_dout),
    .empty               (hit_bool_empty)
);

logic signed [D_BITS-1:0] help1;
assign help1 = ray_origin_din[0];

logic signed [D_BITS-1:0] help2;
assign help2 = ray_origin_din[1];

logic signed [D_BITS-1:0] help3;
assign help3 = ray_origin_din[2];


logic signed [D_BITS-1:0] break1;
assign break1 = ray_origin_dout[0];

logic signed [D_BITS-1:0] break2;
assign break2 = ray_origin_dout[1];

logic signed [D_BITS-1:0] break3;
assign break3 = ray_origin_dout[2];

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
    
    hit_bool_wr_en = 1'b0;
    dot_rd_en = 1'b0;
    hit_c = hit;
    state_c = state;
    in_wr_en = 1'b0;
    in_rd_en = 1'b0;

    if (!in_full && !in_empty)begin
        // Check if input fifos are full, and if p_hit's output fifos are empty
        in_wr_en = 1'b1;
        in_rd_en = 1'b1;
    end

    case (state)
        s0: begin   // Calculate hit_c
            if (!dot_empty) begin
                hit_c = (d0 > 0) && (d1 > 0) && (d2 > 0);
                dot_rd_en = 1'b1;
                state_c = s1;
            end else begin
                state_c = s0;
            end
        end
        s1: begin   // Write hit_c to output fifo 
            if (hit_bool_full == 1'b0)begin
                hit_bool_wr_en = 1'b1;
                hit_c = 1'b0;
                state_c = s0;
            end else begin
                state_c = s1;
            end
        end
    endcase
end
endmodule

