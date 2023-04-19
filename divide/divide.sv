module divide #(
    parameter Q_BITS = 'd10,
    parameter D_WIDTH = 'd32,       //data width
    parameter ED_WIDTH = 2*D_WIDTH  //expanded data width
    //ED_WIDTH should never be larger than Q_BITS + D_WIDTH + 1
)(
    input logic clock,
    input logic reset,
    input logic signed [D_WIDTH-1:0] dividend,
    input logic signed [D_WIDTH-1:0] divisor,
    output logic signed [D_WIDTH-1:0] quotient,

    input logic valid_in,
    output logic valid_out
);

logic signed [D_WIDTH-1:0] Q, Q_c; //Q is dividend
logic signed [D_WIDTH-1:0] B, B_c; //B is divisor
logic signed [2*ED_WIDTH:0] EAQ, EAQ_c; //register with all our math
logic[7:0] i_c, i;
logic negative; //flag

enum logic[1:0] {s0, s1, s2} state, next_state;

always_ff @(posedge clock or posedge reset) begin
    if(reset) begin
        state <= s0;
        B <= 'b0;
        i <= 'b0;
        EAQ <= 'b0;
    end else begin
        state <= next_state;
        B <= B_c; 
        i <= i_c;
        EAQ <= EAQ_c;
    end
end

logic signed [ED_WIDTH-1:0] temp;

always_comb begin
    next_state = state;
    quotient = 'b0;
    valid_out = 'b0;
    i_c = i;
    B_c = B;
    EAQ_c = EAQ;

    case(state)
        s0: begin
            if(valid_in) begin
                B_c = divisor;
                temp = ((ED_WIDTH)'(dividend) << Q_BITS) + (divisor >> 1);
                EAQ_c = {1'b0, ED_WIDTH'(0), temp};
                i_c = 'b0;
                next_state = s1;
            end
        end

        s1: begin
            EAQ_c = EAQ << 1;
            if(EAQ_c[2*ED_WIDTH])   EAQ_c[2*ED_WIDTH:ED_WIDTH] = EAQ_c[2*ED_WIDTH:ED_WIDTH] + (ED_WIDTH+1)'(B);
            else                    EAQ_c[2*ED_WIDTH:ED_WIDTH] = EAQ_c[2*ED_WIDTH:ED_WIDTH] - (ED_WIDTH+1)'(B);

            if(EAQ_c[2*ED_WIDTH])    EAQ_c[0] = 1'b0;
            else                    EAQ_c[0] = 1'b1;
            i_c = i + 1;
            if(i_c == ED_WIDTH) begin
                if(EAQ_c[2*ED_WIDTH]) EAQ_c[2*ED_WIDTH:ED_WIDTH] = EAQ_c[2*ED_WIDTH:ED_WIDTH] + B;
                next_state = s2;
            end
        end

        s2: begin   //write
            quotient = EAQ[D_WIDTH-1:0]; //quotient in Q     EAQ[ED_WIDTH-1:0]
            valid_out = 'b1;
        end
    endcase
end

endmodule