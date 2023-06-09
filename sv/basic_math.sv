module Cross #(
    parameter Q_BITS = 'd10
) (
    input int x [2:0],
    input int y [2:0],
    output int out [2:0]
);

logic signed [47:0] out_big [2:0];

always_comb begin
    out_big[0] = (x[1] * y[2] - x[2] * y[1]) >> Q_BITS;
    out_big[1] = (x[2] * y[0] - x[0] * y[2]) >> Q_BITS;
    out_big[2] = (x[0] * y[1] - x[1] * y[0]) >> Q_BITS;
    out[0] = out_big[0];
    out[1] = out_big[1];    
    out[2] = out_big[2];

end
endmodule

module dot #(
    parameter Q_BITS = 'd10
) (
    input int x[2:0],
    input int y[2:0],
    output int out
);
	logic signed [47:0] out_big [2:0];

    always_comb begin
	    out_big[0] = (x[0] * y[0]) >> Q_BITS;
	    out_big[1] = (x[1] * y[1]) >> Q_BITS;
	    out_big[2] = (x[2] * y[2]) >> Q_BITS;

	    out = out_big[0] + out_big[1] + out_big[2];
    end
endmodule

module scale #(
    parameter Q_BITS = 'd10
) (
    input int x[2:0],
    input int a,
    output int out[2:0]
);
	logic signed [47:0] out_big [2:0];
	
    always_comb begin
        out_big[0] = (x[0] * a) >> Q_BITS;
        out_big[1] = (x[1] * a) >> Q_BITS;
        out_big[2] = (x[2] * a) >> Q_BITS;

        out[0] = out_big[0];
        out[1] = out_big[1];
        out[2] = out_big[2];
    end

endmodule

module add
(
    input int x[2:0],
    input int y[2:0],
    output int out[2:0]
);
    always_comb begin
	    out[0] = x[0] + y[0];
	    out[1] = x[1] + y[1];
	    out[2] = x[2] + y[2];
    end
endmodule

module subtract
(
    input int x[2:0],
    input int y[2:0],
    output int out[2:0]
);
    always_comb begin
	    out[0] = x[0] - y[0];
	    out[1] = x[1] - y[1];
	    out[2] = x[2] - y[2];
    end
endmodule