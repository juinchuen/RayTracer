

`timescale 1 ns / 1 ns

module div(clock, reset, start, dividend, divisor, quotient, done);
    parameter signed [31:0] DWIDTH = 32;
    parameter  FAST = 1'h1;
    input wire clock;
    input wire reset;
    input wire start;
    input wire signed [(DWIDTH - 1):0] dividend;
    input wire signed [(DWIDTH - 1):0] divisor;
    output wire signed [(DWIDTH - 1):0] quotient;
    output reg done;
    reg [(DWIDTH - 1):0] a;
    reg [(DWIDTH - 1):0] b;
    reg [(DWIDTH - 1):0] q;
    integer p;
    wire sign;

    reg [1:0] div_state;
    parameter S0 = 2'h0, S1 = 2'h1, S2 = 2'h2;

    function automatic integer  get_msb_pos;
        input reg [(DWIDTH - 1):0] dval;
        input reg signed [31:0] msb;
        input reg signed [31:0] lsb;
        integer size;
        integer top;
        integer bot;
        integer p;
        integer i;
        integer msb_pos;
        begin 
            if (((msb - lsb) + 1) <= (((DWIDTH / 8) >= 1) ? (DWIDTH / 8) : 1)) begin 
                p = 0;
                for ( i = lsb; i <= msb; i = i + 1 )
                begin 
                    if (dval[i] == 1'h1) begin 
                        p = i;
                    end
                end
                msb_pos = p;
            end
            else begin 
                size = (msb - lsb) + 1;
                bot = get_msb_pos(dval, (lsb + (size / 2)) - 1, lsb);
                top = get_msb_pos(dval, msb, lsb + (size / 2));
                msb_pos = (top != 0) ? top : bot;
            end
            get_msb_pos = msb_pos;
        end
    endfunction


    always @
    (
        posedge clock, 
        posedge reset
    )
    begin : div_process
        integer p_tmp;

        if (reset == 1'h1) begin 
            a <= 1'h0;
            b <= 1'h0;
            q <= 1'h0;
            p <= 0;
            p_tmp = 0;
            done <= 1'h0;
            div_state <= S0;
        end
        else if (clock == 1'b1) begin 
            p_tmp = 0;
            
            case (div_state)
                S0 : begin 
                    if (start == 1'h1) begin 
                        a <= (dividend < 0) ? $unsigned(-dividend) : $unsigned(dividend);
                        b <= (divisor < 0) ? $unsigned(-divisor) : $unsigned(divisor);
                        p <= 0;
                        q <= 1'h0;
                        done <= 1'h0;
                        div_state <= S1;
                    end
                    else begin 
                        div_state <= S0;
                    end
                end

                S1 : begin 
                    p_tmp = get_msb_pos(a, DWIDTH - 1, 0) - get_msb_pos(b, DWIDTH - 1, 0);
                    p <= p_tmp;
                    if (b == 1'h1) begin 
                        q <= a;
                        done <= 1'h1;
                        div_state <= S0;
                    end
                    else if ((b != 1'h0) & (a >= b)) begin 
                        if (FAST == 1'h1) begin 
                            div_state <= S2;
                        end
                        else begin 
                            if ((b << p_tmp) > a) begin 
                                q <= q + (1'h1 << (p_tmp - 1));
                                a <= a - (b << (p_tmp - 1));
                            end
                            else begin 
                                q <= q + (1'h1 << p_tmp);
                                a <= a - (b << p_tmp);
                            end
                            div_state <= S1;
                        end
                    end
                    else begin 
                        done <= 1'h1;
                        div_state <= S0;
                    end
                end

                S2 : begin 
                    if ((b << p) > a) begin 
                        q <= q + (1'h1 << (p - 1));
                        a <= a - (b << (p - 1));
                    end
                    else begin 
                        q <= q + (1'h1 << p);
                        a <= a - (b << p);
                    end
                    div_state <= S1;
                end

                default : begin 
                    a <= 1'h0;
                    b <= 1'h0;
                    q <= 1'h0;
                    p <= 0;
                    p_tmp = 0;
                    done <= 1'h0;
                    div_state <= S0;
                end

            endcase
        end
    end
    assign sign = dividend[DWIDTH - 1] ^ divisor[DWIDTH - 1];
    assign quotient = (sign == 1'h1) ? -$signed(q) : $signed(q);

endmodule
