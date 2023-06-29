// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-21 16:32:53
// Author : Liman
// Email  : 944768976@qq.com
// File   : histogram_top.v
// Description ：
// Revise : 2023-02-17 22:10:02
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module histogram_top #(
	parameter IMAGE_SIZE 		= 18495,//136*136-1
	parameter IMAGE_WIDTH 		= 136,
	parameter QN 				= 8,
	parameter TOTAL_BIT_WIDTH 	= 35,
	parameter P_WIDTH 			= 8,
	parameter DELAY 			= 1,
	parameter BIN_VEC_X0 = 39'd4096,//int(cos(0)<<QN)
	parameter BIN_VEC_X1 = 39'd3848,//int(cos(20)<<QN)
	parameter BIN_VEC_X2 = 39'd3137,//int(cos(40)<<QN)
	parameter BIN_VEC_X3 = 39'd2048,//int(cos(60)<<QN)
	parameter BIN_VEC_X4 = 39'd711,//int(cos(80)<<QN)
	parameter BIN_VEC_Y0 = 39'd0,//int(sin(0)<<QN)
	parameter BIN_VEC_Y1 = 39'd1400,//int(sin(20)<<QN)
	parameter BIN_VEC_Y2 = 39'd2632,//int(sin(40)<<QN)
	parameter BIN_VEC_Y3 = 39'd3547,//int(sin(60)<<QN)
	parameter BIN_VEC_Y4 = 39'd4033//int(sin(80)<<QN)
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low

	//input initial_cell_bram,//每次histogram前需要初始化bram
	input write_feature_done,
	output hog_ready,//每次histogram前需要初始化bram

	input [7:0] p,//from IMG_top
	input p_valid,
	input finish,

	output histogram_done,

	input [12:0] normal_addra_0,//提供aport和bport接口给后续的normalization、pca、hamming
	input [12:0] normal_addra_1,
	input [12:0] normal_addra_2,
	input [12:0] normal_addra_3,
	output [TOTAL_BIT_WIDTH-1 : 0] douta_0,
	output [TOTAL_BIT_WIDTH-1 : 0] douta_1,
	output [TOTAL_BIT_WIDTH-1 : 0] douta_2,
	output [TOTAL_BIT_WIDTH-1 : 0] douta_3,

	input [12:0] normal_addrb_0,
	input [12:0] normal_addrb_1,
	input [12:0] normal_addrb_2,
	input [12:0] normal_addrb_3,
	output [TOTAL_BIT_WIDTH-1 : 0] doutb_0,
	output [TOTAL_BIT_WIDTH-1 : 0] doutb_1,
	output [TOTAL_BIT_WIDTH-1 : 0] doutb_2,
	output [TOTAL_BIT_WIDTH-1 : 0] doutb_3
	
);


wire [4:0] bin_num;
wire bin_num_valid;
wire [7:0] mod_row;
wire [7:0] mod_col;
wire [TOTAL_BIT_WIDTH-1:0] intensity_0;
wire [TOTAL_BIT_WIDTH-1:0] intensity_1;
wire [TOTAL_BIT_WIDTH-1:0] intensity_2;
wire [TOTAL_BIT_WIDTH-1:0] intensity_3;
wire intensity_valid;


histogram #(
		.IMAGE_SIZE(IMAGE_SIZE),
		.IMAGE_WIDTH(IMAGE_WIDTH),
		.QN(QN),
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.P_WIDTH(P_WIDTH),
		.DELAY(DELAY),
		.BIN_VEC_X0(BIN_VEC_X0),
		.BIN_VEC_X1(BIN_VEC_X1),
		.BIN_VEC_X2(BIN_VEC_X2),
		.BIN_VEC_X3(BIN_VEC_X3),
		.BIN_VEC_X4(BIN_VEC_X4),
		.BIN_VEC_Y0(BIN_VEC_Y0),
		.BIN_VEC_Y1(BIN_VEC_Y1),
		.BIN_VEC_Y2(BIN_VEC_Y2),
		.BIN_VEC_Y3(BIN_VEC_Y3),
		.BIN_VEC_Y4(BIN_VEC_Y4)
	) inst_histogram (
		.aclk            (aclk),
		.arest_n         (arest_n),
		.p               (p),
		.p_valid         (p_valid),
		.finish          (finish),
		.bin_num         (bin_num),
		.bin_num_valid   (bin_num_valid),
		.mod_row_r2      (mod_row),
		.mod_col_r2      (mod_col),
		.intensity_0     (intensity_0),
		.intensity_1     (intensity_1),
		.intensity_2     (intensity_2),
		.intensity_3     (intensity_3),
		.intensity_valid (intensity_valid)
	);


read_write_cell_bram #(
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.DELAY(DELAY)
	) inst_read_write_cell_bram (
		.aclk            (aclk),
		.arest_n         (arest_n),
		.bin_num         (bin_num),
		.bin_num_valid   (bin_num_valid),
		.mod_row         (mod_row),
		.mod_col         (mod_col),
		.intensity_0     (intensity_0),
		.intensity_1     (intensity_1),
		.intensity_2     (intensity_2),
		.intensity_3     (intensity_3),
		.intensity_valid (intensity_valid),
		.normal_addra_0  (normal_addra_0),
		.normal_addra_1  (normal_addra_1),
		.normal_addra_2  (normal_addra_2),
		.normal_addra_3  (normal_addra_3),
		.douta_0         (douta_0),
		.douta_1         (douta_1),
		.douta_2         (douta_2),
		.douta_3         (douta_3),
		.normal_addrb_0  (normal_addrb_0),
		.normal_addrb_1  (normal_addrb_1),
		.normal_addrb_2  (normal_addrb_2),
		.normal_addrb_3  (normal_addrb_3),
		.doutb_0         (doutb_0),
		.doutb_1         (doutb_1),
		.doutb_2         (doutb_2),
		.doutb_3         (doutb_3),
		//.initial_cell_bram (initial_cell_bram),
		.write_feature_done (write_feature_done),
		.hog_ready 			(hog_ready),
		.histogram_done  (histogram_done)
	);

endmodule