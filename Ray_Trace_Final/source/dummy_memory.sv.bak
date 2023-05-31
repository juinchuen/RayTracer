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

        for (i = 0; i < 12; i = i + 1) begin

            assign data_out[i] = (data_out_buf[D_BITS * i + 31 : D_BITS * i]);

        end

    endgenerate

    always @ (posedge clock or posedge reset) begin

        if (reset) begin

            data_out_buf <= 'h0;

        end

        else begin

            case (mem_addr)

                'h00 : data_out_buf <= 384'h0000eecbffffbe08ffffbf7700024b1300011bbaffffaf6b00024b13ffffb5bb00011d720001927effffc651fffe617e;
                'h01 : data_out_buf <= 384'h00000000ffff4d020000b703ffffb4edfffee446000050950001927efffe6050ffffcf8500006d81000039af00019e82;
                'h02 : data_out_buf <= 384'hffffa3b7ffff554dffff590affffb4edfffee44600005095ffffb4ed00004a45fffee28e0001927efffe6050ffffcf85;
                'h03 : data_out_buf <= 384'hffff1135000041f800004089ffffb4edfffee4460000509500006d81000039af00019e82ffffb4ed00004a45fffee28e;
                'h04 : data_out_buf <= 384'h00005c490000aab30000a6f600006d8100019fb00000307b00006d81000039af00019e8200024b1300011bbaffffaf6b;
                'h05 : data_out_buf <= 384'h000000000000b2feffff48fdffffb4ed00004a45fffee28e00006d8100019fb00000307b0001927effffc651fffe617e;
                'h06 : data_out_buf <= 384'h0000eecbffffbe08ffffbf7700024b13ffffb5bb00011d720001927efffe6050ffffcf850001927effffc651fffe617e;
                'h07 : data_out_buf <= 384'h00000000ffff4d020000b7030001927efffe6050ffffcf8500024b13ffffb5bb00011d7200006d81000039af00019e82;
                'h08 : data_out_buf <= 384'hffffa3b7ffff554dffff590affffb4ed00004a45fffee28e0001927effffc651fffe617e0001927efffe6050ffffcf85;
                'h09 : data_out_buf <= 384'hffff1135000041f80000408900006d81000039af00019e8200006d8100019fb00000307bffffb4ed00004a45fffee28e;
                'h0a : data_out_buf <= 384'h00005c490000aab30000a6f600006d81000039af00019e8200024b13ffffb5bb00011d7200024b1300011bbaffffaf6b;
                'h0b : data_out_buf <= 384'h000000000000b2feffff48fd00006d8100019fb00000307b00024b1300011bbaffffaf6b0001927effffc651fffe617e;

                default : data_out_buf <= 'h0;

            endcase

        end

    end

endmodule

