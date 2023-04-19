module hit_bool(
    // p_hit module output, normal coordinates
    input int [2:0] p_hit,
    input int [2:0] normal,
    // Vector inputs
    input int [2:0] v0,
    input int [2:0] v1,
    input int [2:0] v2,
    // Output bool
    output int [2:0] hit
); 

// Intermediary signals
// Vector subtraction outputs
int [2:0] o0; 
int [2:0] o1;
int [2:0] o2;
// p_hit and vector subtraction outputs
int [2:0] p0; 
int [2:0] p1;
int [2:0] p2;
// cross product outputs
int [2:0] c0; 
int [2:0] c1;
int [2:0] c2;
// Dot product outputs
int d0;
int d1;
int d2;

// Module instantiation
// Subtract stage 1
subtract u_subtract (
    .out    (o0),
    .x      (v1),
    .y      (v0)
    
);
subtract u_subtract (
    .out    (o1),
    .x      (v2),
    .y      (v1)
);
subtract u_subtract (
    .out    (o2),
    .x      (v0),
    .y      (v2)
);
// Subtract stage 2
subtract u_subtract (
    .out    (p0),
    .x      (p_hit),
    .y      (v0)
);
subtract u_subtract (
    .out    (p1),
    .x      (p_hit),
    .y      (v1)
);
subtract u_subtract (
    .out    (p2),
    .x      (p_hit),
    .y      (v2)    
);
// Cross stage
cross #(
    .Q_BITS('d10)
) u_cross (
    .out   (c0),
    .x     (o0),
    .y     (p0)
);
cross #(
    .Q_BITS ('d10)
) u_cross (
    .out   (c1),
    .x     (o1),
    .y     (p1)
);
cross #(
    .Q_BITS ('d10)
) u_cross (
    .out   (c2),
    .x     (o2),
    .y     (p2)
);
// Dot stage
dot #(
    .Q_BITS ('d10)
) u_dot (
    .out    (d0),
    .x      (c0),
    .y      (normal)
);
dot #(
    .Q_BITS ('d10)
) u_dot (
    .out    (d1),
    .x      (c1),
    .y      (normal)
);
dot #(
    .Q_BITS ('d10)
) u_dot (
    .out    (d2),
    .x      (c2),
    .y      (normal)
);

always_comb begin:
    // Check if dot products are greater than 0
    // If greater return 1. Else return 0
    hit = (d0 > 0) && (d1 > 0) && (d2 > 0);
end

endmodule