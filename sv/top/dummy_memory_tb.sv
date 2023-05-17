module memory_tb ();

    logic clock;
    logic reset;

    logic [11:0] addr;
    logic signed [31:0] data_out [11:0];

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

endmodule