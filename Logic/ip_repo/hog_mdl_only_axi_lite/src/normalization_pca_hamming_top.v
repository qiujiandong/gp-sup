// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-21 16:18:22
// Author : Liman
// Email  : 944768976@qq.com
// File   : normalization_pca_hamming_top.v
// Description ：
// Revise : 2023-02-17 22:12:19
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns
module normalization_pca_hamming_top #(
	parameter PARAM_TRUNCATE    = 35'd51,//int(0.2 << QN)
	parameter PARAM_GAMA		= 35'd60,//int(1/(根号18) << QN)
	parameter QN 				= 8,
	parameter TOTAL_BIT_WIDTH 	= 35,
	parameter DELAY 			= 1
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low

	//表明histogram完成，需要进行下一步的normalization
	input histogram_done,

	output [12:0] normal_addra_0,//histogram aport
	output [12:0] normal_addra_1,
	output [12:0] normal_addra_2,
	output [12:0] normal_addra_3,

	input [TOTAL_BIT_WIDTH-1 : 0] douta_0,
	input [TOTAL_BIT_WIDTH-1 : 0] douta_1,
	input [TOTAL_BIT_WIDTH-1 : 0] douta_2,
	input [TOTAL_BIT_WIDTH-1 : 0] douta_3,

	output [12:0] normal_addrb_0,//histogram bport
	output [12:0] normal_addrb_1,
	output [12:0] normal_addrb_2,
	output [12:0] normal_addrb_3,

	input [TOTAL_BIT_WIDTH-1 : 0] doutb_0,
	input [TOTAL_BIT_WIDTH-1 : 0] doutb_1,
	input [TOTAL_BIT_WIDTH-1 : 0] doutb_2,
	input [TOTAL_BIT_WIDTH-1 : 0] doutb_3,
	
	

	output bin0_17_feature_valid,//最终输出结果到write_bin0_31_feature
	output bin18_26_feature_valid,
	output bin27_30_feature_valid,
	output [QN-1:0] bin0_17,
	output [QN-1:0] bin18_26,
	output [QN-1:0] bin27_30


);


wire sos_valid;
wire [TOTAL_BIT_WIDTH-1:0] sum_of_squares;
wire window_valid;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg1;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg2;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg3;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg4;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg5;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg6;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg7;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg8;
wire [TOTAL_BIT_WIDTH-1:0] sos_reg9;



calculate_sum_of_squares #(
		.QN(QN),
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.DELAY(DELAY)
	) inst_calculate_sum_of_squares (
		.aclk           (aclk),
		.arest_n        (arest_n),
		.normal_addra_0 (normal_addra_0),
		.normal_addra_1 (normal_addra_1),
		.normal_addra_2 (normal_addra_2),
		.normal_addra_3 (normal_addra_3),
		.douta_0        (douta_0),
		.douta_1        (douta_1),
		.douta_2        (douta_2),
		.douta_3        (douta_3),
		.histogram_done (histogram_done),
		.sos_valid      (sos_valid),
		.sum_of_squares (sum_of_squares)
	);



sos_cache #(
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.DELAY(DELAY)
	) inst_sos_cache (
		.aclk           (aclk),
		.arest_n        (arest_n),
		.sos_valid      (sos_valid),
		.sum_of_squares (sum_of_squares),
		.window_valid   (window_valid),
		.sos_reg1       (sos_reg1),
		.sos_reg2       (sos_reg2),
		.sos_reg3       (sos_reg3),
		.sos_reg4       (sos_reg4),
		.sos_reg5       (sos_reg5),
		.sos_reg6       (sos_reg6),
		.sos_reg7       (sos_reg7),
		.sos_reg8       (sos_reg8),
		.sos_reg9       (sos_reg9)
	);



normalize_truncate_pca #(
		.PARAM_TRUNCATE(PARAM_TRUNCATE),
		.PARAM_GAMA(PARAM_GAMA),
		.QN(QN),
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.DELAY(DELAY)
	) inst_normalize_truncate_pca (
		.aclk                   (aclk),
		.arest_n                (arest_n),
		.window_valid           (window_valid),
		.sos_reg1               (sos_reg1),
		.sos_reg2               (sos_reg2),
		.sos_reg3               (sos_reg3),
		.sos_reg4               (sos_reg4),
		.sos_reg5               (sos_reg5),
		.sos_reg6               (sos_reg6),
		.sos_reg7               (sos_reg7),
		.sos_reg8               (sos_reg8),
		.sos_reg9               (sos_reg9),
		.normal_addrb_0         (normal_addrb_0),
		.normal_addrb_1         (normal_addrb_1),
		.normal_addrb_2         (normal_addrb_2),
		.normal_addrb_3         (normal_addrb_3),
		.doutb_0                (doutb_0),
		.doutb_1                (doutb_1),
		.doutb_2                (doutb_2),
		.doutb_3                (doutb_3),
		.bin0_17_feature_valid  (bin0_17_feature_valid),
		.bin18_26_feature_valid (bin18_26_feature_valid),
		.bin27_30_feature_valid (bin27_30_feature_valid),
		.bin0_17                (bin0_17),
		.bin18_26               (bin18_26),
		.bin27_30               (bin27_30)
	);
















endmodule