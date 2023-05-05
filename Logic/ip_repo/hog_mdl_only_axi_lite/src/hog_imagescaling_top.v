// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-27 15:29:50
// Author : Liman
// Email  : 944768976@qq.com
// File   : hog_imagescaling_top.v
// Description ：
// Revise : 2023-02-18 13:39:36
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module hog_imagescaling_top #(
	parameter RAM_AW 			= 17,
	parameter IMAGE_SIZE 		= 18495,//136*136-1
	parameter IMAGE_WIDTH 		= 136,
	parameter QN 				= 10,
	parameter TOTAL_BIT_WIDTH 	= 37,
	parameter P_WIDTH 			= 8,
	parameter DELAY 			= 1,
	parameter PARAM_TRUNCATE    = 37'd204,//int(0.2 << QN)
	parameter PARAM_GAMA		= 37'd241,//int(1/(根号18) << QN)

	parameter	IMGX = 136,
	parameter	IMGY = 136
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low

	//imagescaling_top控制接口
	input start,
	//input stallreq,
	input [31:0] img0x,
	input [31:0] img0y,
	input [31:0] t_x,
	input [31:0] t_y,
	input [31:0] n,
	input [31:0] test_mode,

	//hog_top控制完成接口
	//input initial_cell_bram,//初始化hog_top中histogram用到的cell bram
	//output hog_ready,
	output scaling_finish,//图像缩放完成
	output write_feature_done,//hog_top特征提取完毕
	output histogram_done,

	//读imagescaling中的结果bram：bank0-3
	input  res_enb_0,
	input  res_enb_1,
	input  res_enb_2,
	input  res_enb_3,
	input [RAM_AW-1 : 0] res_addrb_0,
	input [RAM_AW-1 : 0] res_addrb_1,
	input [RAM_AW-1 : 0] res_addrb_2,
	input [RAM_AW-1 : 0] res_addrb_3,
	output [QN-1 : 0] res_doutb_0,
	output [QN-1 : 0] res_doutb_1,
	output [QN-1 : 0] res_doutb_2,
	output [QN-1 : 0] res_doutb_3,

	//写原始数据到imagescaling中的bram：bank0-3
	input [31:0] row_signal,
	input initial_wea_0,
	input initial_wea_1,
	input initial_wea_2,
	input initial_wea_3,
	input initial_ena_0,
	input initial_ena_1,
	input initial_ena_2,
	input initial_ena_3,
	input [RAM_AW-1:0] initial_addra_0,
	input [RAM_AW-1:0] initial_addra_1,
	input [RAM_AW-1:0] initial_addra_2,
	input [RAM_AW-1:0] initial_addra_3,
	input [P_WIDTH-1:0] initial_dina_0,
	input [P_WIDTH-1:0] initial_dina_1,
	input [P_WIDTH-1:0] initial_dina_2,
	input [P_WIDTH-1:0] initial_dina_3,
	output [3:0] img_status

);


//wire initial_cell_bram;
//add test_mode ;bit1: = 1,则，写入到hog模块的p为1、2、3.。。。256循环
reg [7:0] p_test;
wire [7:0] p_scaling;
(* mark_debug="true" *)wire [7:0] p;
(* mark_debug="true" *)wire p_valid;
//wire finish;
wire [RAM_AW-1:0] res_addra_0;//hog_top写结果到imagescaling中的bram：bank0-3
wire [RAM_AW-1:0] res_addra_1;
wire [RAM_AW-1:0] res_addra_2;
wire [RAM_AW-1:0] res_addra_3;
wire [QN-1:0] res_dina_0;
wire [QN-1:0] res_dina_1;
wire [QN-1:0] res_dina_2;
wire [QN-1:0] res_dina_3;
wire res_ena_0;
wire res_ena_1;
wire res_ena_2;
wire res_ena_3;
wire res_wea_0;
wire res_wea_1;
wire res_wea_2;
wire res_wea_3;
//wire write_feature_done;

//wire  res_enb_0;//读imagescaling中的结果bram：bank0-3
//wire  res_enb_1;
//wire  res_enb_2;
//wire  res_enb_3;
//wire [12 : 0] res_addrb_0;
//wire [12 : 0] res_addrb_1;
//wire [12 : 0] res_addrb_2;
//wire [12 : 0] res_addrb_3;
//wire [7 : 0] res_doutb_0;
//wire [7 : 0] res_doutb_1;
//wire [7 : 0] res_doutb_2;
//wire [7 : 0] res_doutb_3;
wire  rsta_busy;
wire  rstb_busy;


//imagescaling_top接口（部分与bram相关）
//wire start;
//wire stallreq;
//wire [31:0] img0x;
//wire [31:0] img0y;
//wire [31:0] t_x;
//wire [31:0] t_y;
//wire [31:0] n;
wire wea_1;
wire wea_2;
wire wea_3;
wire wea_4;
wire ena_1;
wire ena_2;
wire ena_3;
wire ena_4;
wire [RAM_AW-1:0] addra_1;
wire [RAM_AW-1:0] addra_2;
wire [RAM_AW-1:0] addra_3;
wire [RAM_AW-1:0] addra_4;
wire [QN-1:0] dina_1;
wire [QN-1:0] dina_2;
wire [QN-1:0] dina_3;
wire [QN-1:0] dina_4;

//外部写原始数据到imagescaling中的bram：bank0-3
//wire initial_wea_0;
//wire initial_wea_1;
//wire initial_wea_2;
//wire initial_wea_3;
//wire initial_ena_0;
//wire initial_ena_1;
//wire initial_ena_2;
//wire initial_ena_3;
//wire [12:0] initial_addra_0;
//wire [12:0] initial_addra_1;
//wire [12:0] initial_addra_2;
//wire [12:0] initial_addra_3;
//wire [7:0] initial_dina_0;
//wire [7:0] initial_dina_1;
//wire [7:0] initial_dina_2;
//wire [7:0] initial_dina_3;
//
wire hog_ready;


//写结果与写原始数据选通
assign wea_1 = res_ena_0 ? res_wea_0 : initial_wea_0;//wea_0:写结果  wea：写原始数据
assign wea_2 = res_ena_1 ? res_wea_1 : initial_wea_1;
assign wea_3 = res_ena_2 ? res_wea_2 : initial_wea_2;
assign wea_4 = res_ena_3 ? res_wea_3 : initial_wea_3;

assign ena_1 = res_ena_0 ? res_ena_0 : initial_ena_0;
assign ena_2 = res_ena_1 ? res_ena_1 : initial_ena_1;
assign ena_3 = res_ena_2 ? res_ena_2 : initial_ena_2;
assign ena_4 = res_ena_3 ? res_ena_3 : initial_ena_3;

assign addra_1 = res_ena_0 ? res_addra_0 : initial_addra_0;
assign addra_2 = res_ena_1 ? res_addra_1 : initial_addra_1;
assign addra_3 = res_ena_2 ? res_addra_2 : initial_addra_2;
assign addra_4 = res_ena_3 ? res_addra_3 : initial_addra_3;

assign dina_1 = res_ena_0 ? res_dina_0 : {{QN-P_WIDTH{1'b0}},initial_dina_0};
assign dina_2 = res_ena_1 ? res_dina_1 : {{QN-P_WIDTH{1'b0}},initial_dina_1};
assign dina_3 = res_ena_2 ? res_dina_2 : {{QN-P_WIDTH{1'b0}},initial_dina_2};
assign dina_4 = res_ena_3 ? res_dina_3 : {{QN-P_WIDTH{1'b0}},initial_dina_3};

	hog_top #(
			.RAM_AW(RAM_AW),
			.IMAGE_SIZE(IMAGE_SIZE),
			.IMAGE_WIDTH(IMAGE_WIDTH),
			.QN(QN),
			.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
			.P_WIDTH(P_WIDTH),
			.DELAY(DELAY),
			.PARAM_TRUNCATE(PARAM_TRUNCATE),
			.PARAM_GAMA(PARAM_GAMA)
		) inst_hog_top (
			.aclk               (aclk),
			.arest_n            (arest_n),
			//.initial_cell_bram  (initial_cell_bram),
			.hog_ready			(hog_ready),
			.p                  (p),
			.p_valid            (p_valid),
			.finish             (scaling_finish),
			.res_addra_0        (res_addra_0),
			.res_addra_1        (res_addra_1),
			.res_addra_2        (res_addra_2),
			.res_addra_3        (res_addra_3),
			.res_dina_0         (res_dina_0),
			.res_dina_1         (res_dina_1),
			.res_dina_2         (res_dina_2),
			.res_dina_3         (res_dina_3),
			.ena_0              (res_ena_0),
			.ena_1              (res_ena_1),
			.ena_2              (res_ena_2),
			.ena_3              (res_ena_3),
			.wea_0              (res_wea_0),
			.wea_1              (res_wea_1),
			.wea_2              (res_wea_2),
			.wea_3              (res_wea_3),
			.write_feature_done (write_feature_done),
			.histogram_done		(histogram_done)
		);

	IMG_top #(
			.RAM_AW(RAM_AW),
			.imgx(IMGX),
			.imgy(IMGY),
			.QN(QN)
		) inst_IMG_top (
			.clk       (aclk),
			.start     (start),
			.rst       (~arest_n),
			//.stallreq  (stallreq),
			.hog_ready (hog_ready),
			.row_signal (row_signal),
			.img0x     (img0x),
			.img0y     (img0y),
			.t_x       (t_x),
			.t_y       (t_y),
			.N         (n),
			.wea1      (wea_1),//bram写操作
			.wea2      (wea_2),
			.wea3      (wea_3),
			.wea4      (wea_4),
			.ena1      (ena_1),//bram写使能
			.ena2      (ena_2),
			.ena3      (ena_3),
			.ena4      (ena_4),
			.enb       (1),//时钟允许读取bram：bank0-3
			.rstb      (~arest_n),
			.AA1       (addra_1),//bram写地址
			.AA2       (addra_2),
			.AA3       (addra_3),
			.AA4       (addra_4),
			.DA1       (dina_1),//bram写数据
			.DA2       (dina_2),
			.DA3       (dina_3),
			.DA4       (dina_4),
			.enb1      (res_enb_0),//bram读结果使能
			.enb2      (res_enb_1),
			.enb3      (res_enb_2),
			.enb4      (res_enb_3),
			.addrb1    (res_addrb_0),//bram读结果地址
			.addrb2    (res_addrb_1),
			.addrb3    (res_addrb_2),
			.addrb4    (res_addrb_3),
			.doutb1    (res_doutb_0),//bram读结果数据
			.doutb2    (res_doutb_1),
			.doutb3    (res_doutb_2),
			.doutb4    (res_doutb_3),
			.valid     (p_valid),
			.finish    (scaling_finish),
			.P         (p_scaling),
			.img_status(img_status),
			.rsta_busy (rsta_busy),
			.rstb_busy (rstb_busy)
		);

//add test mode  ;bit1: = 1,则，写入到hog模块的p为1、2、3.。。。256循环

assign p = test_mode[1] ? {3'd0,p_test[4:0]} : p_scaling;
always @(posedge aclk)begin 
	if(!arest_n)begin 
		p_test <=#DELAY 8'd0;
	end
	else begin 
		if(scaling_finish)begin 
			p_test <=#DELAY 8'd0;
		end
		else begin 
			if(p_valid)begin 
				p_test <=#DELAY p_test + 8'd1;
			end
		end
	end
end


endmodule