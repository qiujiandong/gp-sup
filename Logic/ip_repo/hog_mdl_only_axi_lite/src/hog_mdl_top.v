// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-27 11:14:55
// Author : Liman
// Email  : 944768976@qq.com
// File   : hog_mdl_top.v
// Description ：
// Revise : 2023-02-18 10:13:47
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns
module hog_mdl_top #(
	parameter AXIL_AW = 7,
	parameter AXIL_DW = 32,
	parameter AXI_AW = 31,
	parameter AXI_DW = 512,

	parameter IMAGE_SIZE 		= 18495,//136*136-1
	parameter IMAGE_WIDTH 		= 136,
	parameter QN 				= 8,
	parameter TOTAL_BIT_WIDTH 	= 35,
	parameter P_WIDTH 			= 8,
	parameter DELAY 			= 1,
	parameter PARAM_TRUNCATE    = 35'd51,//int(0.2 << QN)
	parameter PARAM_GAMA		= 35'd60,//int(1/(根号18) << QN)

	parameter	IMGX = 136,
	parameter	IMGY = 136


	)(
	input aclk,    // Clock
	//input arest_n,  // Asynchronous reset active low
	input arest_n,

//request done interrupt
	output [1:0] rd1_wr1_done,//bit0：rd bit1：wr
	//output [1:0] rd1_wr1_req,//bit0：rd bit1：wr

//AXI-Lite
 	input [31:0] 			s_axil_awaddr,
    input [2:0] 			s_axil_awprot,
    input 					s_axil_awvalid,
    output 					s_axil_awready,

    input [AXIL_DW-1:0] 	s_axil_wdata,
    input [3:0] 			s_axil_wstrb,
    input 					s_axil_wvalid,
    output 					s_axil_wready,

    output [1:0] 			s_axil_bresp,
    output 					s_axil_bvalid,
    input 					s_axil_bready,

    input [31:0] 			s_axil_araddr,
    input [2:0] 			s_axil_arprot,
    input 					s_axil_arvalid,
    output 					s_axil_arready,

    output [AXIL_DW-1:0] 	s_axil_rdata,
    output [1:0] 			s_axil_rresp,
    output 					s_axil_rvalid,
    input 					s_axil_rready,

//AXI ,访问空间大小2GB
 	output [3:0]		m_axi_awid          , 
    output [AXI_AW-1:0]	m_axi_awaddr        , 
    output [7:0]		m_axi_awlen         , 
    output [2:0]		m_axi_awsize        , 
    output [1:0]		m_axi_awburst       , 
    output [0:0]		m_axi_awlock        , 
    output [3:0]		m_axi_awcache       , 
    output [2:0]		m_axi_awprot        , 
    output [3:0]		m_axi_awqos         , 
    output				m_axi_awvalid       ,  
    input				m_axi_awready       ,  
    // Mlave Interface Write Data Ports
    output [AXI_DW-1:0]		m_axi_wdata     ,  
    output [AXI_DW/8-1:0]	m_axi_wstrb     ,  
    output					m_axi_wlast     ,  
    output					m_axi_wvalid    ,  
    input					m_axi_wready    ,  
    // Mlave Interface Write Response Ports
    input [3:0]		m_axi_bid               ,  
    input [1:0]		m_axi_bresp             ,  
    input			m_axi_bvalid            ,  
    output			m_axi_bready            ,  
    // Mlave Interface Read Address Ports
    output [3:0]		m_axi_arid        	, 
    output [AXI_AW-1:0]	m_axi_araddr      	, 
    output [7:0]		m_axi_arlen       	, 
    output [2:0]		m_axi_arsize      	, 
    output [1:0]		m_axi_arburst     	, 
    output [0:0]		m_axi_arlock      	, 
    output [3:0]		m_axi_arcache     	, 
    output [2:0]		m_axi_arprot      	, 
    output [3:0]		m_axi_arqos       	, 
    output				m_axi_arvalid     	,  
    input				m_axi_arready     	,  
    // Mlave Interface Read Data Ports
    input [3:0]			m_axi_rid           ,  
    input [AXI_DW-1:0]	m_axi_rdata         ,  
    input [1:0]			m_axi_rresp         ,  
    input				m_axi_rlast         ,  
    input				m_axi_rvalid        ,  
    output				m_axi_rready        
  

);



wire [31:0] mb_ctrl;
wire [31:0] rd_wr_irq;
wire [31:0] soft_trigger_en;
wire [31:0] rd1_config_3;
wire [31:0] rd1_config_4;
wire [31:0] wr1_config_3;
wire [31:0] wr1_config_4;

//imagescaling_top控制接口
wire hog_start;
wire [31:0] absolute_addr;
wire [31:0] cross_row_offset;
wire [15:0] img0x;
wire [15:0] img0y;
wire [31:0] scale_x;
wire [31:0] scale_y;
wire [31:0] scale_n;
wire [31:0] test_mode;


//hog_top控制完成接口
//wire initial_cell_bram;//初始化hog_top中histogram用到的cell bram
wire write_feature_done;//hog_top特征提取完毕

//读imagescaling中的结果bram：bank0-3
wire  res_enb_0;
wire  res_enb_1;
wire  res_enb_2;
wire  res_enb_3;
wire [12 : 0] res_addrb_0;
wire [12 : 0] res_addrb_1;
wire [12 : 0] res_addrb_2;
wire [12 : 0] res_addrb_3;
wire [QN-1 : 0] res_doutb_0;
wire [QN-1 : 0] res_doutb_1;
wire [QN-1 : 0] res_doutb_2;
wire [QN-1 : 0] res_doutb_3;

//写原始数据到imagescaling中的bram：bank0-3
wire [31:0] row_signal;
wire initial_wea_0;
wire initial_wea_1;
wire initial_wea_2;
wire initial_wea_3;
wire initial_ena_0;
wire initial_ena_1;
wire initial_ena_2;
wire initial_ena_3;
wire [12:0] initial_addra_0;
wire [12:0] initial_addra_1;
wire [12:0] initial_addra_2;
wire [12:0] initial_addra_3;
wire [P_WIDTH-1:0] initial_dina_0;
wire [P_WIDTH-1:0] initial_dina_1;
wire [P_WIDTH-1:0] initial_dina_2;
wire [P_WIDTH-1:0] initial_dina_3;

	hog_ctrl #(
			.AXIL_AW(AXIL_AW),
			.AXIL_DW(AXIL_DW),
			.DELAY(DELAY)
		) inst_hog_ctrl (
			.aclk             (aclk),
			.arest_n          (arest_n),
			.s_axil_awaddr    (s_axil_awaddr),
			.s_axil_awprot    (s_axil_awprot),
			.s_axil_awvalid   (s_axil_awvalid),
			.s_axil_awready   (s_axil_awready),
			.s_axil_wdata     (s_axil_wdata),
			.s_axil_wstrb     (s_axil_wstrb),
			.s_axil_wvalid    (s_axil_wvalid),
			.s_axil_wready    (s_axil_wready),
			.s_axil_bresp     (s_axil_bresp),
			.s_axil_bvalid    (s_axil_bvalid),
			.s_axil_bready    (s_axil_bready),
			.s_axil_araddr    (s_axil_araddr),
			.s_axil_arprot    (s_axil_arprot),
			.s_axil_arvalid   (s_axil_arvalid),
			.s_axil_arready   (s_axil_arready),
			.s_axil_rdata     (s_axil_rdata),
			.s_axil_rresp     (s_axil_rresp),
			.s_axil_rvalid    (s_axil_rvalid),
			.s_axil_rready    (s_axil_rready),
			.mb_ctrl          (mb_ctrl),
			.rd_wr_irq        (rd_wr_irq),
			.soft_trigger_en  (soft_trigger_en),
			.rd1_config_3     (rd1_config_3),
			.rd1_config_4     (rd1_config_4),
			.wr1_config_3     (wr1_config_3),
			.wr1_config_4     (wr1_config_4),
			.hog_start        (hog_start),
			.img0x            (img0x),
			.img0y            (img0y),
			.absolute_addr    (absolute_addr),
			.cross_row_offset (cross_row_offset),
			.scale_x          (scale_x),
			.scale_y          (scale_y),
			.scale_n          (scale_n),
			.test_mode        (test_mode)
		);

	hog_trans #(
			.AXI_AW(AXI_AW),
			.AXI_DW(AXI_DW),
			.DELAY(DELAY),
			.QN(QN),
			.P_WIDTH(P_WIDTH)
		) inst_hog_trans (
			.aclk               (aclk),
			.arest_n            (arest_n),
			.m_axi_awid         (m_axi_awid),
			.m_axi_awaddr       (m_axi_awaddr),
			.m_axi_awlen        (m_axi_awlen),
			.m_axi_awsize       (m_axi_awsize),
			.m_axi_awburst      (m_axi_awburst),
			.m_axi_awlock       (m_axi_awlock),
			.m_axi_awcache      (m_axi_awcache),
			.m_axi_awprot       (m_axi_awprot),
			.m_axi_awqos        (m_axi_awqos),
			.m_axi_awvalid      (m_axi_awvalid),
			.m_axi_awready      (m_axi_awready),
			.m_axi_wdata        (m_axi_wdata),
			.m_axi_wstrb        (m_axi_wstrb),
			.m_axi_wlast        (m_axi_wlast),
			.m_axi_wvalid       (m_axi_wvalid),
			.m_axi_wready       (m_axi_wready),
			.m_axi_bid          (m_axi_bid),
			.m_axi_bresp        (m_axi_bresp),
			.m_axi_bvalid       (m_axi_bvalid),
			.m_axi_bready       (m_axi_bready),
			.m_axi_arid         (m_axi_arid),
			.m_axi_araddr       (m_axi_araddr),
			.m_axi_arlen        (m_axi_arlen),
			.m_axi_arsize       (m_axi_arsize),
			.m_axi_arburst      (m_axi_arburst),
			.m_axi_arlock       (m_axi_arlock),
			.m_axi_arcache      (m_axi_arcache),
			.m_axi_arprot       (m_axi_arprot),
			.m_axi_arqos        (m_axi_arqos),
			.m_axi_arvalid      (m_axi_arvalid),
			.m_axi_arready      (m_axi_arready),
			.m_axi_rid          (m_axi_rid),
			.m_axi_rdata        (m_axi_rdata),
			.m_axi_rresp        (m_axi_rresp),
			.m_axi_rlast        (m_axi_rlast),
			.m_axi_rvalid       (m_axi_rvalid),
			.m_axi_rready       (m_axi_rready),
			.rd1_config_3       (rd1_config_3),
			.rd1_config_4       (rd1_config_4),
			.wr1_config_3       (wr1_config_3),
			.wr1_config_4       (wr1_config_4),
			.hog_start          (hog_start),
			.img0x              (img0x),
			.img0y              (img0y),
			.absolute_addr      (absolute_addr),
			.cross_row_offset   (cross_row_offset),
			.scale_x            (scale_x),
			.scale_y            (scale_y),
			.scale_n            (scale_n),
			.test_mode 			(test_mode),
			.scaling_finish     (scaling_finish),
			.write_feature_done (write_feature_done),
			.res_enb_0          (res_enb_0),
			.res_enb_1          (res_enb_1),
			.res_enb_2          (res_enb_2),
			.res_enb_3          (res_enb_3),
			.res_addrb_0        (res_addrb_0),
			.res_addrb_1        (res_addrb_1),
			.res_addrb_2        (res_addrb_2),
			.res_addrb_3        (res_addrb_3),
			.res_doutb_0        (res_doutb_0),
			.res_doutb_1        (res_doutb_1),
			.res_doutb_2        (res_doutb_2),
			.res_doutb_3        (res_doutb_3),
			.row_signal         (row_signal),
			.initial_wea_0      (initial_wea_0),
			.initial_wea_1      (initial_wea_1),
			.initial_wea_2      (initial_wea_2),
			.initial_wea_3      (initial_wea_3),
			.initial_ena_0      (initial_ena_0),
			.initial_ena_1      (initial_ena_1),
			.initial_ena_2      (initial_ena_2),
			.initial_ena_3      (initial_ena_3),
			.initial_addra_0    (initial_addra_0),
			.initial_addra_1    (initial_addra_1),
			.initial_addra_2    (initial_addra_2),
			.initial_addra_3    (initial_addra_3),
			.initial_dina_0     (initial_dina_0),
			.initial_dina_1     (initial_dina_1),
			.initial_dina_2     (initial_dina_2),
			.initial_dina_3     (initial_dina_3),
			.rd1_wr1_done       (rd1_wr1_done)
		);

			hog_imagescaling_top #(
			.IMAGE_SIZE(IMAGE_SIZE),
			.IMAGE_WIDTH(IMAGE_WIDTH),
			.QN(QN),
			.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
			.P_WIDTH(P_WIDTH),
			.DELAY(DELAY),
			.PARAM_TRUNCATE(PARAM_TRUNCATE),
			.PARAM_GAMA(PARAM_GAMA),
			.IMGX(IMGX),
			.IMGY(IMGY)
		) inst_hog_imagescaling_top (
			.aclk               (aclk),
			.arest_n            (arest_n),
			.start              (hog_start),
			//.stallreq           (stallreq),
			.img0x              ({16'd0,img0x}),
			.img0y              ({16'd0,img0y}),
			.t_x                (scale_x),
			.t_y                (scale_y),
			.n                  (scale_n),
			.test_mode 			(test_mode),
			//.initial_cell_bram  (initial_cell_bram),
			//.hog_ready			(hog_ready),
			.scaling_finish		(scaling_finish),
			.write_feature_done (write_feature_done),
			.res_enb_0          (res_enb_0),
			.res_enb_1          (res_enb_1),
			.res_enb_2          (res_enb_2),
			.res_enb_3          (res_enb_3),
			.res_addrb_0        (res_addrb_0),
			.res_addrb_1        (res_addrb_1),
			.res_addrb_2        (res_addrb_2),
			.res_addrb_3        (res_addrb_3),
			.res_doutb_0        (res_doutb_0),
			.res_doutb_1        (res_doutb_1),
			.res_doutb_2        (res_doutb_2),
			.res_doutb_3        (res_doutb_3),
			.row_signal			(row_signal),
			.initial_wea_0      (initial_wea_0),
			.initial_wea_1      (initial_wea_1),
			.initial_wea_2      (initial_wea_2),
			.initial_wea_3      (initial_wea_3),
			.initial_ena_0      (initial_ena_0),
			.initial_ena_1      (initial_ena_1),
			.initial_ena_2      (initial_ena_2),
			.initial_ena_3      (initial_ena_3),
			.initial_addra_0    (initial_addra_0),
			.initial_addra_1    (initial_addra_1),
			.initial_addra_2    (initial_addra_2),
			.initial_addra_3    (initial_addra_3),
			.initial_dina_0     (initial_dina_0),
			.initial_dina_1     (initial_dina_1),
			.initial_dina_2     (initial_dina_2),
			.initial_dina_3     (initial_dina_3)
		);


endmodule