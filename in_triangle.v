`timescale 1ns/10ps

module inside_triangle(out, v0, v1, v2, p_hit, normal);

    input signed [31:0] v0     [2:0];
    input signed [31:0] v1     [2:0];
    input signed [31:0] v2     [2:0];
    input signed [31:0] p_hit  [2:0];
    input signed [31:0] normal [2:0];

    output out;

    logic signed [31:0] e0 [2:0];
    logic signed [31:0] e1 [2:0];
    logic signed [31:0] e2 [2:0];

    logic signed [31:0] c0 [2:0];
    logic signed [31:0] c1 [2:0];
    logic signed [31:0] c2 [2:0];

    logic signed [31:0] cross0 [2:0];
    logic signed [31:0] cross1 [2:0];
    logic signed [31:0] cross2 [2:0];

    logic signed [31:0] check0;
    logic signed [31:0] check1;
    logic signed [31:0] check2;

    subtract s0 (e0, v1, v0);
    subtract s1 (e1, v2, v1);
    subtract s2 (e2, v0, v2);
    
    subtract s3 (c0, p_hit, v0);
    subtract s4 (c1, p_hit, v1);
    subtract s5 (c2, p_hit, v2);

    cross c0 (cross0, e0, c0);
    cross c1 (cross1, e1, c1);
    cross c2 (cross2, e2, c2);

    assign out = (check0 > 0) && (check1 > 0) && (check2 > 0);

endmodule
    



