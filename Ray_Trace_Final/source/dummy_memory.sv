module dummy_memory #(
    parameter Q_BITS = 'd10,
    parameter D_BITS = 'd32,
    parameter M_BITS = 'd12
) (
    input logic clock,
    input logic reset,
    input logic [M_BITS-1 : 0] mem_addr,

    output logic signed [D_BITS-1 : 0] data_out [11:0]
);

    logic signed [D_BITS*12-1 : 0] data_out_buf;

    genvar i;

    generate

        for (i = 0; i < 12; i = i + 1) begin : dum_mem_parse

            assign data_out[i] = (data_out_buf[D_BITS * (i + 1) - 1 : D_BITS * i]);

        end

    endgenerate

	 tri_rom TR0 (
	 
		.address 	(mem_addr[3:0]),
		.clock		(clock),
		.q				(data_out_buf));

endmodule

