`timescale 1ns/1ns

module tb();

localparam QUANTIZED_BITS = 'd10;
localparam DATA_WIDTH = 'd8;
localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = '0;
// logic start = '0;
// logic done  = '0;

logic signed [DATA_WIDTH-1:0] dividend;
logic signed [DATA_WIDTH-1:0] divisor;
logic signed [DATA_WIDTH-1:0] quotient;
logic signed [DATA_WIDTH-1:0] remainder;

logic valid_in, valid_out;

divide #(
    .QUANTIZED_BITS(QUANTIZED_BITS),
    .DATA_WIDTH(DATA_WIDTH)
) divide_inst(
    .clock(clock),
    .reset(reset),
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient),
    .remainder(remainder),
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
    dividend = 'd194;
    divisor = 'd10;
    valid_in = 'b1;
end

initial begin: output_read
    wait(valid_out);
    $finish;
end



endmodule