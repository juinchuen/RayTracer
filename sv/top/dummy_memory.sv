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

                'h00 : data_out_buf <= 384'hfffe617effffc6510001927e00011d72ffffb5bb00024b13ffffaf6b00011bba00024b13ffffbf77ffffbe080000eecb;
                'h01 : data_out_buf <= 384'h00019e82000039af00006d81ffffcf85fffe60500001927e00005095fffee446ffffb4ed0000b703ffff4d0200000000;
                'h02 : data_out_buf <= 384'hffffcf85fffe60500001927efffee28e00004a45ffffb4ed00005095fffee446ffffb4edffff590affff554dffffa3b7;
                'h03 : data_out_buf <= 384'hfffee28e00004a45ffffb4ed00019e82000039af00006d8100005095fffee446ffffb4ed00004089000041f8ffff1135;
                'h04 : data_out_buf <= 384'hffffaf6b00011bba00024b1300019e82000039af00006d810000307b00019fb000006d810000a6f60000aab300005c49;
                'h05 : data_out_buf <= 384'hfffe617effffc6510001927e0000307b00019fb000006d81fffee28e00004a45ffffb4edffff48fd0000b2fe00000000;
                'h06 : data_out_buf <= 384'hfffe617effffc6510001927effffcf85fffe60500001927e00011d72ffffb5bb00024b13ffffbf77ffffbe080000eecb;
                'h07 : data_out_buf <= 384'h00019e82000039af00006d8100011d72ffffb5bb00024b13ffffcf85fffe60500001927e0000b703ffff4d0200000000;
                'h08 : data_out_buf <= 384'hffffcf85fffe60500001927efffe617effffc6510001927efffee28e00004a45ffffb4edffff590affff554dffffa3b7;
                'h09 : data_out_buf <= 384'hfffee28e00004a45ffffb4ed0000307b00019fb000006d8100019e82000039af00006d8100004089000041f8ffff1135;
                'h0a : data_out_buf <= 384'hffffaf6b00011bba00024b1300011d72ffffb5bb00024b1300019e82000039af00006d810000a6f60000aab300005c49;
                'h0b : data_out_buf <= 384'hfffe617effffc6510001927effffaf6b00011bba00024b130000307b00019fb000006d81ffff48fd0000b2fe00000000;

                default : data_out_buf <= 'h0;

            endcase

        end

    end

endmodule

