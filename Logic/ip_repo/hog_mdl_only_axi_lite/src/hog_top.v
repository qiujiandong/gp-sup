// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : yongchan jeon (Kris) poucotm@gmail.com
// File   : hog_top.v
// Create : 2022-10-13 20:20:17
// Revise : 2023-03-16 15:46:50
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns/1ns
module hog_top #(
	parameter RAM_AW 			= 17,
	parameter IMAGE_SIZE 		= 18495,//136*136-1
	parameter IMAGE_WIDTH 		= 136,
	parameter QN 				= 8,
	parameter TOTAL_BIT_WIDTH 	= 35,
	parameter P_WIDTH 			= 8,
	parameter DELAY 			= 1,
	parameter PARAM_TRUNCATE    = 35'd51,//int(0.2 << QN)
	parameter PARAM_GAMA		= 35'd60//int(1/(根号18) << QN)

	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low
	
	//input initial_cell_bram,//当原始图像开始写入到图像缩放bram中时，启动histogram中的cell bram的初始化，一个周期高电平即可
	output hog_ready,//hog模块就绪

	input [7:0] p,//from IMG_top
	input p_valid,
	input finish,

	output [RAM_AW-1:0]  res_addra_0,//最终特征图结果写入地址
	output [RAM_AW-1:0]  res_addra_1,
	output [RAM_AW-1:0]  res_addra_2,
	output [RAM_AW-1:0]  res_addra_3,
    output [QN-1:0]  res_dina_0,//最终特征图结果写入数据
    output [QN-1:0]  res_dina_1,
    output [QN-1:0]  res_dina_2,
    output [QN-1:0]  res_dina_3,
    output ena_0,
    output ena_1,
    output ena_2,
    output ena_3, 
    output wea_0,
	output wea_1,
	output wea_2,
	output wea_3,
	output write_feature_done,//写特征完成
	output histogram_done
);

//wire histogram_done;
wire [12:0] normal_addra_0;//histogram aport
wire [12:0] normal_addra_1;
wire [12:0] normal_addra_2;
wire [12:0] normal_addra_3;
wire [TOTAL_BIT_WIDTH-1 : 0] douta_0;
wire [TOTAL_BIT_WIDTH-1 : 0] douta_1;
wire [TOTAL_BIT_WIDTH-1 : 0] douta_2;
wire [TOTAL_BIT_WIDTH-1 : 0] douta_3;
wire [12:0] normal_addrb_0;//histogram bport
wire [12:0] normal_addrb_1;
wire [12:0] normal_addrb_2;
wire [12:0] normal_addrb_3;
wire [TOTAL_BIT_WIDTH-1 : 0] doutb_0;
wire [TOTAL_BIT_WIDTH-1 : 0] doutb_1;
wire [TOTAL_BIT_WIDTH-1 : 0] doutb_2;
wire [TOTAL_BIT_WIDTH-1 : 0] doutb_3;


wire bin0_17_feature_valid;//最终输出结果到write_bin0_31_feature
wire bin18_26_feature_valid;
wire bin27_30_feature_valid;
wire [QN-1:0] bin0_17;
wire [QN-1:0] bin18_26;
wire [QN-1:0] bin27_30;

histogram_top #(
		.IMAGE_SIZE(IMAGE_SIZE),
		.IMAGE_WIDTH(IMAGE_WIDTH),
		.QN(QN),
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.P_WIDTH(P_WIDTH),
		.DELAY(DELAY)
	) inst_histogram_top (
		.aclk           (aclk),
		.arest_n        (arest_n),
		//.initial_cell_bram (initial_cell_bram),
		.write_feature_done (write_feature_done),
		.hog_ready 			(hog_ready),
		.p              (p),
		.p_valid        (p_valid),
		.finish         (finish),
		.histogram_done (histogram_done),
		.normal_addra_0 (normal_addra_0),
		.normal_addra_1 (normal_addra_1),
		.normal_addra_2 (normal_addra_2),
		.normal_addra_3 (normal_addra_3),
		.douta_0        (douta_0),
		.douta_1        (douta_1),
		.douta_2        (douta_2),
		.douta_3        (douta_3),
		.normal_addrb_0 (normal_addrb_0),
		.normal_addrb_1 (normal_addrb_1),
		.normal_addrb_2 (normal_addrb_2),
		.normal_addrb_3 (normal_addrb_3),
		.doutb_0        (doutb_0),
		.doutb_1        (doutb_1),
		.doutb_2        (doutb_2),
		.doutb_3        (doutb_3)
	);


normalization_pca_hamming_top #(
		.PARAM_TRUNCATE(PARAM_TRUNCATE),
		.PARAM_GAMA(PARAM_GAMA),
		.QN(QN),
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.DELAY(DELAY)
	) inst_normalization_pca_hamming_top (
		.aclk                   (aclk),
		.arest_n                (arest_n),
		.histogram_done         (histogram_done),
		.normal_addra_0         (normal_addra_0),
		.normal_addra_1         (normal_addra_1),
		.normal_addra_2         (normal_addra_2),
		.normal_addra_3         (normal_addra_3),
		.douta_0                (douta_0),
		.douta_1                (douta_1),
		.douta_2                (douta_2),
		.douta_3                (douta_3),
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


write_bin0_31_feature #(
		.RAM_AW(RAM_AW),
		.QN(QN),
		.DELAY(DELAY)
	) inst_write_bin0_31_feature (
		.aclk                   (aclk),
		.arest_n                (arest_n),
		.bin0_17_feature_valid  (bin0_17_feature_valid),
		.bin18_26_feature_valid (bin18_26_feature_valid),
		.bin27_30_feature_valid (bin27_30_feature_valid),
		.bin0_17                (bin0_17),
		.bin18_26               (bin18_26),
		.bin27_30               (bin27_30),
		.res_addra_0            (res_addra_0),
		.res_addra_1            (res_addra_1),
		.res_addra_2            (res_addra_2),
		.res_addra_3            (res_addra_3),
		.res_dina_0             (res_dina_0),
		.res_dina_1             (res_dina_1),
		.res_dina_2             (res_dina_2),
		.res_dina_3             (res_dina_3),
		.ena_0                  (ena_0),
		.ena_1                  (ena_1),
		.ena_2                  (ena_2),
		.ena_3                  (ena_3),
		.wea_0                  (wea_0),
		.wea_1                  (wea_1),
		.wea_2                  (wea_2),
		.wea_3                  (wea_3),
		.write_feature_done     (write_feature_done)
	);



endmodule