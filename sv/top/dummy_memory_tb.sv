module memory_tb ();

    logic clock;
    logic reset;

    logic [11:0] addr;
    logic signed [31:0] data_out [11:0];

    logic signed [32 * 12 - 1 : 0] data_out_sram;

    logic signed [31:0] data_out_sram_parse [11:0];

    logic signed [11:0] dummy_addr;
    logic signed [32 * 12 - 1 : 0] dummy_din;
    logic dummy_wr_en;

    assign dummy_addr = 'h0;
    assign dummy_din = 'h0;
    assign dummy_wr_en = 'h0;

    int counter;

    initial begin

        clock  = 1;
        reset = 0;
        addr = 'h0;

        # 10

        reset = 1;

        #20

        reset = 0;

        wait(addr == 'hf);

        $finish;

    end

    always begin

        #10

        clock = ~clock;

    end

    always @ (posedge clock) counter = counter + 1;

    always @ (counter) begin

        if (counter == 3) begin

            counter = 0;
            addr = addr + 1;

        end

    end

    dummy_memory DUT_INST0 (.clock (clock), .reset(reset), .mem_addr(addr), .data_out(data_out));

    sramb #(

	    .SRAMB_BUFFER_SIZE  ('d1024),
	    .SRAMB_ADDR_WIDTH   ('d12),
	    .SRAMB_DATA_WIDTH   ('d384)
	
    ) SRAM_INST0 (
	    .clock      (clock),
	    .rd_addr    (addr),
	    .wr_addr    (dummy_addr),
	    .wr_en      (dummy_wr_en),
	    .dout       (data_out_sram),
	    .din        (dummy_din)
    );

    genvar i;

    generate

        for (i = 0; i < 12; i = i + 1) begin

            assign data_out_sram_parse [i] = data_out_sram [32 * i + 31 : 32 * i];

        end

    endgenerate

endmodule