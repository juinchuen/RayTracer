module wrapper_top (

    input logic         clock,
    input logic         reset,

    output logic        out_wr_en,
    output logic [7:0]  pixel [2:0]

);

    localparam D_BITS = 'd16;
    localparam M_BITS = 'd12;
    localparam Q_BITS = 'd8;

    logic in_wr_en;

    logic in_full;

    logic signed [6 * D_BITS - 1 : 0]  ray_data_single;

    logic signed [D_BITS-1 : 0]        ray_data_feed   [5:0];

    logic        [9:0]                 ray_addr;

    logic        [2:0]                 state;

    logic out_full;

    assign out_full = 0;

    genvar i;

    generate

        for (i  = 0; i < 6; i = i + 1) begin : wrapper_top_ray_data_parse

            assign ray_data_feed [i] = ray_data_single [D_BITS * (i + 1) - 1 : D_BITS * i];

        end

    endgenerate

    always @ (posedge clock or posedge reset) begin

        if (reset) begin

            ray_addr    <= 'b0;

            state       <= 'h00;

            in_wr_en    <= 0;

        end else begin

            case (state)

                'h00 :  begin

                            state <= 'h01;

                        end

                'h01 : begin

                            if (!in_full) begin

                                in_wr_en    <= 1;

                                ray_addr    <= ray_addr + 1;

                            end else begin

                                in_wr_en    <= 0;

                            end

                        end

                default : begin

                            ray_addr    <= 'b0;

                            state       <= 'h00;

                            in_wr_en    <= 0;

                        end

            endcase

        end

    end
	 
	ray_rom RAY_MEM0 (
	
		.address (ray_addr),
	
		.clock 	(clock),
	
		.q			(ray_data_single));

	ray_tracer_top #(

        .D_BITS     (D_BITS),
        .Q_BITS     (Q_BITS),
        .M_BITS     (M_BITS)

    ) DUT_INST0 (

        .clock                      (clock),
        .reset                      (reset),

        .in_wr_en                   (in_wr_en),
        .ray_in                     (ray_data_feed),
        .in_full                    (in_full),

        .full_world_shader          (out_full),
        .pixel_shader_world         (pixel),
        .wr_shader_world            (out_wr_en)

    );

endmodule