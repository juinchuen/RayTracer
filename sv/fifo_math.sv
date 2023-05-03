////////////////Add Module//////////////////////////
module add_module #(
    parameter D_BITS = 'd32
) (
    input  logic clock,
    input  logic reset,
    input  logic signed [D_BITS-1:0] x[2:0],
    input  logic signed [D_BITS-1:0] y[2:0],
    input  logic in_empty,
    output logic in_rd_en,
    
    output logic signed [D_BITS-1:0] out[2:0],
    input logic out_full,
    output logic out_wr_en
);

    enum logic {s0, s1} state, next_state;
    logic signed [D_BITS-1:0] out_c[2:0];

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

module add #(
    parameter D_BITS = 'd32
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] x[2:0],
    input logic signed [D_BITS-1:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed [D_BITS-1:0] out[2:0],
    output logic out_empty,
    input logic out_rd_en
);

    logic signed [D_BITS-1:0] out_din[2:0];
    logic out_full, out_wr_en;

    add_module #(
        .D_BITS       (D_BITS)
    ) u_add_module (
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
        .FIFO_DATA_WIDTH         (D_BITS),
        .FIFO_BUFFER_SIZE        (D_BITS*16),
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

////////////////Dot Module//////////////////////////
module dot_module #(
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] x[2:0],
    input logic signed [D_BITS-1:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed[D_BITS-1:0] out,
    input logic out_full,
    output logic out_wr_en
);
    enum logic {s0, s1} state, next_state;
    logic signed [(D_BITS*2)-1-Q_BITS:0] out_big [2:0];
    logic signed [D_BITS-1:0] out_c;

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

        case(state)
        s0: begin
            if(!in_empty) begin
                out_big[0] = ((D_BITS*2)'(x[0] * y[0])) >>> Q_BITS;
                out_big[1] = ((D_BITS*2)'(x[1] * y[1])) >>> Q_BITS;
                out_big[2] = ((D_BITS*2)'(x[2] * y[2])) >>> Q_BITS;

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
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] x[2:0],
    input logic signed [D_BITS-1:0] y[2:0],
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed [D_BITS-1:0] out,
    output logic out_empty,
    input logic out_rd_en
);
    logic signed [D_BITS-1:0] out_din;
    logic out_full, out_wr_en;

    dot_module #(
        .D_BITS      (D_BITS),
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
        .FIFO_DATA_WIDTH     (D_BITS),
        .FIFO_BUFFER_SIZE    (D_BITS*16)
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

////////////////Cross Module//////////////////////////
module cross_module #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] x[2:0],
    input logic signed [31:0] y[2:0],
    
    // Input FIFO ports
    input logic in_empty,
    output logic in_rd_en,
    
    // Output FIFO ports
    input logic out_full,
    output logic signed [31:0] out [2:0],
    output logic out_wr_en
);

    enum logic {s0, s1} state, next_state;
    logic signed [31:0] out_c [2:0];
    logic signed [31+Q_BITS:0] out_big [2:0];

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
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

        in_rd_en = 1'b0;
        out_wr_en = 1'b0;

        case(state)
        s0: begin // Perform cross calculation operation
            if (!in_empty) begin
                // Cross
                out_big[0] = (x[1] * y[2] - x[2] * y[1]) >> Q_BITS;
                out_big[1] = (x[2] * y[0] - x[0] * y[2]) >> Q_BITS;
                out_big[2] = (x[0] * y[1] - x[1] * y[0]) >> Q_BITS;
                out_c[0] = out_big[0];
                out_c[1] = out_big[1];
                out_c[2] = out_big[2];

                // Request new data and transition to next state
                in_rd_en = 1'b1;
                next_state = s1;
            end
        end

        s1: begin
            if (!out_full) begin
                out_wr_en = 1'b1;
                next_state = s0;
            end
        end
        endcase    
    end
endmodule

module Cross #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] x[2:0],
    input logic signed [31:0] y[2:0],
    
    // Input FIFO ports
    input logic in_empty,
    output logic in_rd_en,
    
    // Output FIFO ports
    input logic out_rd_en,
    output logic out_empty,
    output logic signed [31:0] out [2:0]
);
    logic signed [31:0] out_din [2:0];
    logic out_full, out_wr_en;

    cross_module #(
        .Q_BITS       (Q_BITS)
    ) u_cross_module (
        .clock        (clock),
        .reset        (reset),
        .x            (x[2:0]),
        .y            (y[2:0]),
        // Input FIFO ports
        .in_empty     (in_empty),
        .in_rd_en     (in_rd_en),
        // Output FIFO ports
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

////////////////Scale Module//////////////////////////
module scale_module #(
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] x[2:0],
    input logic signed [D_BITS-1:0] a,
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed [D_BITS-1:0] out[2:0],
    input logic out_full,
    output logic out_wr_en
);
    //multiply each x by a

    enum logic {s0, s1} state, next_state;
    logic signed [(D_BITS*2)-1-Q_BITS:0] out_big [2:0];
    logic signed [D_BITS-1:0] out_c[2:0];

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

        case(state)
        s0: begin
            if(!in_empty) begin
                out_big[0] = 64'((x[0] * a)) >>> Q_BITS;
                out_big[1] = 64'((x[1] * a)) >>> Q_BITS;
                out_big[2] = 64'((x[2] * a)) >>> Q_BITS;
                
                out_c[0] = out_big[0];
                out_c[1] = out_big[1];
                out_c[2] = out_big[2];

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

module scale #(
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] x[2:0],
    input logic signed [D_BITS-1:0] a,
    input logic in_empty,
    output logic in_rd_en,
    
    output logic signed [D_BITS-1:0] out[2:0],
    output logic out_empty,
    input logic out_rd_en
);

    logic signed [D_BITS-1:0] out_din[2:0];
    logic out_full, out_wr_en;

    scale_module #(
        .D_BITS       (D_BITS),
        .Q_BITS       (Q_BITS)
    ) u_scale_module (
        .clock        (clock),
        .reset        (reset),
        .x            (x[2:0]),
        .a            (a),
        .in_empty     (in_empty),
        .in_rd_en     (in_rd_en),
        .out          (out_din[2:0]),
        .out_full     (out_full),
        .out_wr_en    (out_wr_en)
    );

    fifo_array #(
        .FIFO_DATA_WIDTH         (D_BITS),
        .FIFO_BUFFER_SIZE        (D_BITs*16),
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