`timescale 1ns/1ns

module tb();

localparam QUANTIZED_BITS = 'd10;
localparam DATA_WIDTH = 'd32;
localparam EXPANDED_DATA_WIDTH = DATA_WIDTH + QUANTIZED_BITS + 1;

localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = '0;
// logic start = '0;
// logic done  = '0;

logic signed [DATA_WIDTH-1:0] dividend;
logic signed [DATA_WIDTH-1:0] divisor;
logic signed [DATA_WIDTH-1:0] quotient;

logic valid_in, valid_out;

divide_module #(
    .Q_BITS(QUANTIZED_BITS),
    .D_WIDTH(DATA_WIDTH),
    .ED_WIDTH(EXPANDED_DATA_WIDTH)
) divide_inst(
    .clock(clock),
    .reset(reset),
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient),
    .valid_in(valid_in),
    .valid_out(valid_out)
);

always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end

initial begin: input_process
    @(negedge clock);
    dividend =  -'d190 << QUANTIZED_BITS;
    divisor =   'd7 << QUANTIZED_BITS;
    valid_in = 'b1;
end

initial begin: output_read
    wait(valid_out);
    $display("Answer is: %f", (real'(quotient)/real'(2**QUANTIZED_BITS)));
    $finish;
end

endmodule