//lpm_divide CBX_SINGLE_OUTPUT_FILE="ON" LPM_DREPRESENTATION="SIGNED" LPM_HINT="MAXIMIZE_SPEED=6,LPM_REMAINDERPOSITIVE=FALSE" LPM_NREPRESENTATION="SIGNED" LPM_PIPELINE=4 LPM_TYPE="LPM_DIVIDE" LPM_WIDTHD=16 LPM_WIDTHN=16 aclr clock denom numer quotient remain
//VERSION_BEGIN 22.1 cbx_mgl 2023:02:14:18:07:18:SC cbx_stratixii 2023:02:14:18:07:11:SC cbx_util_mgl 2023:02:14:18:07:11:SC  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2023  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and any partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details, at
//  https://fpgasoftware.intel.com/eula.



//synthesis_resources = lpm_divide 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgd6o
	( 
	aclr,
	clock,
	denom,
	numer,
	quotient,
	remain) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   clock;
	input   [15:0]  denom;
	input   [15:0]  numer;
	output   [15:0]  quotient;
	output   [15:0]  remain;

	wire  [15:0]   wire_mgl_prim1_quotient;
	wire  [15:0]   wire_mgl_prim1_remain;

	lpm_divide   mgl_prim1
	( 
	.aclr(aclr),
	.clock(clock),
	.denom(denom),
	.numer(numer),
	.quotient(wire_mgl_prim1_quotient),
	.remain(wire_mgl_prim1_remain));
	defparam
		mgl_prim1.lpm_drepresentation = "SIGNED",
		mgl_prim1.lpm_nrepresentation = "SIGNED",
		mgl_prim1.lpm_pipeline = 4,
		mgl_prim1.lpm_type = "LPM_DIVIDE",
		mgl_prim1.lpm_widthd = 16,
		mgl_prim1.lpm_widthn = 16,
		mgl_prim1.lpm_hint = "MAXIMIZE_SPEED=6,LPM_REMAINDERPOSITIVE=FALSE";
	assign
		quotient = wire_mgl_prim1_quotient,
		remain = wire_mgl_prim1_remain;
endmodule //mgd6o
//VALID FILE
