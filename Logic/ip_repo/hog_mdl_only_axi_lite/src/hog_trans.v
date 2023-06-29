// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-27 11:12:49
// Author : Liman
// Email  : 944768976@qq.com
// File   : hog_trans.v
// Description ：
// Revise : 2023-02-18 17:36:04
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module hog_trans #(
		parameter RAM_AW = 17,
		parameter AXI_AW = 31,
		parameter AXI_DW = 512,
		parameter DELAY = 1,
		parameter QN = 8,
		parameter P_WIDTH = 8
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low

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
    output				m_axi_rready    	,

//ctrl-reg 
	//input [1:0] 	master_start_stop,//01-start 10stop
	//input [31:0]	rd_wr_irq,//bit0 == 1 == rd1; bit1 == 1 == wr1 
	//input [31:0]	soft_trigger_en,//软件触发使能
	
	input [31:0] rd1_config_3,//source addr
	input [31:0] rd1_config_4,//data_length
	input [31:0] wr1_config_3,//dest addr
	input [31:0] wr1_config_4,//data_length

//from hog_imagescaling_top
	//imagescaling_top控制接口
	//output start,

	input hog_start,//emif
	input [15:0] img0x,
	input [15:0] img0y,
	input [31:0] absolute_addr,
	input [31:0] cross_row_offset,
	input [31:0] scale_x,
	input [31:0] scale_y,
	input [31:0] scale_n,
	input [31:0] test_mode,

	//(* mark_debug="true" *)output reg [15:0] img0x_r,
	//(* mark_debug="true" *)output reg [15:0] img0y_r,
	//(* mark_debug="true" *)output reg [31:0] scale_x_r,
	//(* mark_debug="true" *)output reg [31:0] scale_y_r,
	//(* mark_debug="true" *)output reg [31:0] scale_n_r,
	//(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [31:0] test_mode_r,

	input scaling_finish,
	//hog_top控制完成接口
	//output initial_cell_bram,//初始化hog_top中histogram用到的cell bram
	input histogram_done,
	input write_feature_done,//hog_top特征提取完毕
	

	//读imagescaling中的结果bram：bank0-3
	output  res_enb_0,//bank0
	output  res_enb_1,
	output  res_enb_2,
	output  res_enb_3,
	output [RAM_AW-1 : 0] res_addrb_0,
	output [RAM_AW-1 : 0] res_addrb_1,
	output [RAM_AW-1 : 0] res_addrb_2,
	output [RAM_AW-1 : 0] res_addrb_3,
	input [QN-1 : 0] res_doutb_0,
	input [QN-1 : 0] res_doutb_1,
	input [QN-1 : 0] res_doutb_2,
	input [QN-1 : 0] res_doutb_3,

	//写原始数据到imagescaling中的bram：bank0-3
	output [31:0] row_signal,
	(* mark_debug="true" *)output reg initial_wea_0,
	(* mark_debug="true" *)output reg initial_wea_1,
	(* mark_debug="true" *)output reg initial_wea_2,
	(* mark_debug="true" *)output reg initial_wea_3,
	output initial_ena_0,
	output initial_ena_1,
	output initial_ena_2,
	output initial_ena_3,
	(* mark_debug="true" *)output reg [RAM_AW-1:0] initial_addra_0,
	(* mark_debug="true" *)output reg [RAM_AW-1:0] initial_addra_1,
	(* mark_debug="true" *)output reg [RAM_AW-1:0] initial_addra_2,
	(* mark_debug="true" *)output reg [RAM_AW-1:0] initial_addra_3,
	(* mark_debug="true" *)output reg [P_WIDTH-1:0] initial_dina_0,
	(* mark_debug="true" *)output reg [P_WIDTH-1:0] initial_dina_1,
	(* mark_debug="true" *)output reg [P_WIDTH-1:0] initial_dina_2,
	(* mark_debug="true" *)output reg [P_WIDTH-1:0] initial_dina_3,

//output irq
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [1:0] rd1_wr1_done, //rd1、wr1通道传输完成
	//(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [1:0] rd1_wr1_req//软件触发请求
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output [31:0] axi_status,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output [4:0] circuit_busy
);

//req 主动写结果请求
localparam REQ_IDLE 	= 2'd0;
localparam REQ_READY 	= 2'd1;
localparam REQ_RD 		= 2'd2;
localparam REQ_WR 		= 2'd3;

//aw
localparam AW_IDLE 	= 3'd0;
localparam AW_HEAD 	= 3'd1;
localparam AW_QWN 	= 3'd2;
localparam AW_WAIT 	= 3'd3;
localparam AW_DONE 	= 3'd4;

//w
localparam W_IDLE 		= 3'd0; 
localparam W_WAIT_DATA 	= 3'd1;
localparam W_QWN 		= 3'd2; 
localparam W_LAST 		= 3'd3;
localparam W_WAIT 		= 3'd4; 
localparam W_DONE 		= 3'd5;

//ar
localparam AR_IDLE		= 3'd0;
localparam AR_HEAD		= 3'd1;
localparam AR_COL_END	= 3'd2;
localparam AR_QWN		= 3'd3;
localparam AR_WAIT		= 3'd4;
localparam AR_DONE		= 3'd5;

//r
localparam R_IDLE		= 4'd0;
localparam R_WAIT		= 4'd1;
localparam R_12			= 4'd2;
localparam R_21			= 4'd3;
localparam R_1_END		= 4'd4;
localparam R_2_END		= 4'd5;
localparam R_12_END		= 4'd6;
localparam R_21_END		= 4'd7;
localparam R_34			= 4'd8;
localparam R_43			= 4'd9;
localparam R_3_END		= 4'd10;
localparam R_4_END		= 4'd11;
localparam R_34_END		= 4'd12;
localparam R_43_END		= 4'd13;
localparam R_END		= 4'd14;


//AXI
reg [AXI_AW-1:0] reg_awaddr;
reg 			 reg_awvalid;
//reg [AXI_DW-1:0] reg_wdata;
reg 			 reg_wlast;
reg 			 reg_wvalid;
reg [AXI_AW-1:0] reg_araddr;
reg [7:0] 		 reg_arlen;
reg 			 reg_arvalid;

wire aw_handshake;
wire w_handshake;
wire ar_handshake;
wire r_handshake;
wire b_handshake;

//wr
wire  wr_done;//地址和数据传输完成
reg wr_done_r1;
wire [31:0] wr_burst_time;//axi写操作所需突发次数，配置进来的wr1_config_4为字节数，每次突发传输数据大小为4kB，所以突发次数为>>12.
//aw
reg [2:0] aw_cstate,aw_nstate;
reg [31:0] aw_burst_count;//突发次数计数
reg  aw_done;//地址传输完成

//w
reg [2:0] w_cstate,w_nstate;
reg [31:0] w_burst_count;//写数据通道突发次数计数
reg [7:0] w_data_count;//1次写数据突发传输中的数据传输次数
reg  w_done;


////rd
wire [31:0]	rd_wr_irq;
(* mark_debug="true" *)wire [15:0] img0x_r;
(* mark_debug="true" *)wire [15:0] img0y_r;
(* mark_debug="true" *)wire [31:0] scale_x_r;
(* mark_debug="true" *)wire [31:0] scale_y_r;
(* mark_debug="true" *)wire [31:0] scale_n_r;
(* KEEP = "TRUE" *)(* mark_debug="true" *)wire [31:0] test_mode_r;

(* mark_debug="true" *)wire [31:0] absolute_addr_r;
(* mark_debug="true" *)wire [31:0] cross_row_offset_r;
//reg hog_start_r1;//跨时钟域处理,emif_clk->aclk
//(* mark_debug="true" *)reg hog_start_r2;
//(* mark_debug="true" *)reg hog_start_r3;
wire rd_done;
reg rd_done_r1;
////ar
reg [15:0] ar_col_remain;//当前突发请求后，当前col剩余未突发的Byte数
reg [31:0] ar_fst_addr;//每行首地址
reg [15:0] ar_row_count;//
reg ar_done;
//wire [12:0] length_head1;//每行第一次突发传输长度计算
//wire [12:0] length_head2;

reg [2:0] ar_cstate,ar_nstate;

////r
reg r_done;
reg [3:0] r_cstate,r_nstate;
reg reg_rready;
reg [31:0] r_fst_addr;
reg [15:0] r_row_count;//已接收row行数
reg flag_1;//0-奇数行写到偶数列
reg flag_2;//0-偶数行写到奇数列
reg [8:0] byte_en;//512bit中数据有效使能
reg [15:0] r_col_remain;//本行剩余byte数
reg [6:0] byte_count;//本次握手传输中，剩余byte数

reg [511:0] r_data_r1;

//reg  rd_done;
//reg [31:0] ar_burst_time;//配置进来的rd1_config_4、rd2_config_4、rd3_config_4为字节数，每次突发传输数据大小为4kB，所以突发次数为>>12.
////reg [2:0] ar_channel_num;//用于标记目前ar传输的通道，便于产生对应的rd_done
//
//reg [31:0] rd_addr_cnt;
//reg [2:0] ar_cstate,ar_nstate;


//req
//reg rd1_wr1_req_count;//用于计数，使得rd1_wr1_req为2周期脉冲
//reg [1:0] req_cstate,req_nstate;

//read data from hog_imagescaling_top module
wire res_data_valid;
wire [AXI_DW-1:0] res_data;

//add 增加电路状态，输出到axi-lite接口，提供给dsp或者上位机查询
//busy


reg read_busy;//hog启动，拉高；读原始图像数据完成，拉低
reg scaling_busy;//hog启动，拉高,scaling_finish,拉低
reg histogram_busy;//hog启动，拉高,histogram_done,拉低
reg feature_busy;////hog启动，拉高,write_feature_done 拉低
reg write_busy;//write_feature_done，拉高；结果写入到外部指定地址完成，拉低
assign circuit_busy = {write_busy,feature_busy,histogram_busy,scaling_busy,read_busy};
assign axi_status = {{1'd0,w_nstate},{1'd0,w_cstate},{1'd0,aw_nstate},{1'd0,aw_cstate},r_nstate,r_cstate,{1'd0,ar_nstate},{1'd0,ar_cstate}};



//add
assign rd_wr_irq = {30'd0,write_feature_done,hog_start};
//r
assign row_signal = {16'd0,r_row_count};
assign initial_ena_0 = initial_wea_0;
assign initial_ena_1 = initial_wea_1;
assign initial_ena_2 = initial_wea_2;
assign initial_ena_3 = initial_wea_3;

assign img0x_r = img0x;
assign img0y_r = img0y;
assign scale_x_r = scale_x;
assign scale_y_r = scale_y;
assign scale_n_r = scale_n;
assign absolute_addr_r = absolute_addr;
assign cross_row_offset_r = cross_row_offset;
assign test_mode_r = test_mode;
/*always @(posedge aclk)begin 
	if(!arest_n)begin 
		img0x_r <=#DELAY 16'd0;
		img0y_r <=#DELAY 16'd0;
		scale_x_r <=#DELAY 32'd0;
		scale_y_r <=#DELAY 32'd0;
		scale_n_r <=#DELAY 32'd0;
		absolute_addr_r <=#DELAY 32'd0;
		cross_row_offset_r <=#DELAY 32'd0;
		test_mode_r <=#DELAY 32'd0;
	end
	else begin 
		if(hog_start_r2 && !hog_start_r3)begin 
			img0x_r <=#DELAY img0x_eclk;
			img0y_r <=#DELAY img0y_eclk;
			scale_x_r <=#DELAY scale_x_eclk;
			scale_y_r <=#DELAY scale_y_eclk;
			scale_n_r <=#DELAY scale_n_eclk;
			absolute_addr_r <=#DELAY absolute_addr_eclk;
			cross_row_offset_r <=#DELAY cross_row_offset_eclk;
			test_mode_r <=#DELAY test_mode_eclk;
		end
	end
end
*/
//axi_master aw_channel

assign m_axi_awid = 4'b0000;
assign m_axi_awaddr = reg_awaddr;
assign m_axi_awlen = 8'd63;//突发长度64
assign m_axi_awsize = 3'b110;//突发宽度512b
assign m_axi_awburst = 2'b01;
assign m_axi_awlock = 1'b0;
assign m_axi_awcache = 4'b0011;
assign m_axi_awprot = 3'b010;//Non-secure access
assign m_axi_awqos = 4'b0000;
assign m_axi_awvalid = reg_awvalid;

//axi_master w_channel
assign m_axi_wdata = res_data;
assign m_axi_wstrb = 64'hFFFF_FFFF_FFFF_FFFF;//high means data valid
assign m_axi_wlast = reg_wlast;
assign m_axi_wvalid = reg_wvalid;

//axi_master b_channel

assign m_axi_bready = m_axi_bvalid;

//axi_master ar_channel

assign m_axi_arid = 4'b0000;
assign m_axi_araddr = reg_araddr;
assign m_axi_arlen = reg_arlen;
assign m_axi_arsize = 3'b110;
assign m_axi_arburst = 2'b01;
assign m_axi_arlock = 1'b0;
assign m_axi_arcache = 4'b0011;
assign m_axi_arprot = 3'b010;
assign m_axi_arqos = 4'b0000;
assign m_axi_arvalid = reg_arvalid;

//axi_master r_channel

assign m_axi_rready = reg_rready;
//end axi-master

//hanadshake
assign aw_handshake = m_axi_awvalid&m_axi_awready;
assign w_handshake = m_axi_wvalid&m_axi_wready;
assign ar_handshake = m_axi_arvalid&m_axi_arready;
assign r_handshake = m_axi_rvalid&m_axi_rready;
assign b_handshake = m_axi_bvalid&m_axi_bready;

//wr burst time
assign wr_burst_time = wr1_config_4 >> 12;//每次突发4kB数据

//done,2周期完成信号
assign wr_done = aw_done & w_done;
assign rd_done = ar_done & r_done;

always @(posedge aclk)begin 
	if(!arest_n)begin 
		wr_done_r1 <=#DELAY 1'd0;
		rd_done_r1 <=#DELAY 1'd0;
	end
	else begin 
		wr_done_r1 <=#DELAY wr_done;
		rd_done_r1 <=#DELAY rd_done;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		rd1_wr1_done <=#DELAY 2'd0;
	end
	else begin 
		rd1_wr1_done <=#DELAY {wr_done | wr_done_r1,rd_done | rd_done_r1};
	end
end

//写feature_result到
//req 主动写结果请求
/*always @(posedge aclk)begin 
	if(!arest_n)begin 
		req_cstate <=#DELAY REQ_IDLE;
	end
	else begin 
		req_cstate <=#DELAY req_nstate;
	end
end

always @(*)begin 
	req_nstate = req_cstate;
	if(master_start_stop[1] == 1'd1)begin //cpu停止命令
		req_nstate = REQ_IDLE;
	end
	else begin 
		case(req_cstate)
			REQ_IDLE:begin 
				if(master_start_stop[0] == 1'd1)begin //cpu启动命令
					req_nstate = REQ_READY;
				end
				else begin 
					req_nstate = REQ_IDLE;
				end
			end
			REQ_READY:begin 
				if(hog_start)begin //主动写使能 & hog启动上跳沿
					req_nstate = REQ_RD;
				end
				else if(write_feature_done)begin //主动写使能 & 特征值就绪
					req_nstate = REQ_WR;
				end
				else begin 
					req_nstate = REQ_READY;
				end
			end
			REQ_RD:begin 
				if(rd1_wr1_req_count == 1'd0)begin//产生2周期脉冲
					req_nstate = REQ_READY;
				end
				else begin 
					req_nstate = REQ_RD;
				end
			end
			REQ_WR:begin 
				if(rd1_wr1_req_count == 1'd0)begin//产生2周期脉冲
					req_nstate = REQ_READY;
				end
				else begin 
					req_nstate = REQ_WR;
				end
			end
			default:begin 
				req_nstate = REQ_IDLE;
			end
		endcase // req_cstate
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		rd1_wr1_req <=#DELAY 2'b00;
		rd1_wr1_req_count <=#DELAY 1'd0;
	end
	else begin 
		case(req_nstate)
			REQ_IDLE:begin 
				rd1_wr1_req <=#DELAY 2'b00;
				rd1_wr1_req_count <=#DELAY 1'd0;
			end
			REQ_READY:begin 
				rd1_wr1_req <=#DELAY 2'b00;
				rd1_wr1_req_count <=#DELAY 1'd0;
			end
			REQ_RD:begin //bit0:rd请求 bit1：wr请求
				rd1_wr1_req <=#DELAY 2'b01;
				rd1_wr1_req_count <=#DELAY ~rd1_wr1_req_count;
			end
			REQ_WR:begin //bit0:rd请求 bit1：wr请求
				rd1_wr1_req <=#DELAY 2'b10;
				rd1_wr1_req_count <=#DELAY ~rd1_wr1_req_count;
			end
			default:begin 
				rd1_wr1_req <=#DELAY 2'b00;
				rd1_wr1_req_count <=#DELAY 1'd0;
			end
		endcase // req_nstate
	end
end
*/
//AXI写操作

//aw
always @(posedge aclk)begin 
	if(!arest_n)begin 
		aw_cstate <=#DELAY AW_IDLE;
	end
	else begin 
		aw_cstate <=#DELAY aw_nstate;
	end
end

always @(*)begin 
	aw_nstate = aw_cstate;
	case(aw_cstate)
		AW_IDLE:begin 
			if(rd_wr_irq[1] == 1'b1)
				aw_nstate = AW_HEAD;
			else
				aw_nstate = AW_IDLE;
		end
		AW_HEAD:begin 
			if(aw_handshake == 1'b1)begin 
				if(aw_burst_count < wr_burst_time)
					aw_nstate = AW_QWN;
				else
					aw_nstate = AW_DONE;
			end
			else
				aw_nstate = AW_WAIT;
		end
		AW_QWN:begin 
			if(aw_handshake == 1'b1)begin 
				if(aw_burst_count < wr_burst_time)
					aw_nstate = AW_QWN;
				else
					aw_nstate = AW_DONE;
			end
			else
				aw_nstate = AW_WAIT;
		end
		AW_WAIT:begin 
			if(aw_handshake == 1'b1)begin 
				if(aw_burst_count < wr_burst_time)
					aw_nstate = AW_QWN;
				else
					aw_nstate = AW_DONE;
			end
			else
				aw_nstate = AW_WAIT;
		end
		AW_DONE:begin 
			if(w_done == 1'b1)
				aw_nstate = AW_IDLE;
			else
				aw_nstate = AW_DONE;
		end
		default:aw_nstate = AW_IDLE;
	endcase // aw_cstate
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		reg_awaddr <=#DELAY 31'd0;
		reg_awvalid <=#DELAY 1'b0;
		aw_burst_count <=#DELAY 32'd0;
		aw_done <=#DELAY 1'd0;


	end
	else begin 
		case(aw_nstate)
			AW_IDLE:begin 
				reg_awaddr <=#DELAY 31'd0;
				reg_awvalid <=#DELAY 1'b0;
				aw_burst_count <=#DELAY 32'd0;
				aw_done <=#DELAY 1'd0;
			end
			AW_HEAD:begin 
				reg_awaddr <=#DELAY wr1_config_3[30:0];
				reg_awvalid <=#DELAY 1'b1;
				aw_burst_count <=#DELAY aw_burst_count + 32'd1;
			end
			AW_QWN:begin 
				reg_awaddr <=#DELAY reg_awaddr + 31'h0000_1000;//加4k地址
				reg_awvalid <=#DELAY 1'b1;
				aw_burst_count <=#DELAY aw_burst_count + 32'd1;
			end
			AW_WAIT:;
			AW_DONE:begin 
				aw_done <=#DELAY 1'b1;
				reg_awaddr <=#DELAY 31'd0;
				reg_awvalid <=#DELAY 1'b0;
				aw_burst_count <=#DELAY 32'd0;
			end
			default:begin 
				reg_awaddr <=#DELAY 31'd0;
				reg_awvalid <=#DELAY 1'b0;
				aw_burst_count <=#DELAY 32'd0;
				aw_done <=#DELAY 1'd0;
			end
		endcase // aw_nstate
	end
end

//w
always @(posedge aclk)begin 
	if(!arest_n)begin 
		w_cstate <=#DELAY W_IDLE;
	end
	else begin 
		w_cstate <=#DELAY w_nstate;
	end
end

always @(*)begin 
	w_nstate = w_cstate;
	case(w_cstate)
		W_IDLE:begin 
			if(rd_wr_irq[1] == 1'd1)begin 
				w_nstate = W_WAIT_DATA;
			end
			else begin 
				w_nstate = W_IDLE;
			end
		end
		W_WAIT_DATA:begin 
			if(res_data_valid)begin //数据准备就绪
				if(w_data_count < m_axi_awlen)begin // 非本次突发传输中的最后一个数据
					w_nstate = W_QWN;
				end
				else begin //本次突发传输中的最后一个数据
					w_nstate = W_LAST;
				end
			end
			else begin //数据未准备就绪
				w_nstate = W_WAIT_DATA;
			end
		end
		W_QWN:begin 
			if(w_handshake)begin //w握手
				w_nstate = W_WAIT_DATA;
			end
			else begin //w没有握手
				w_nstate = W_WAIT;
			end
		end
		W_LAST:begin 
			if(w_handshake)begin 
				if(w_burst_count < wr_burst_time)begin //非最后一次突发
					w_nstate = W_WAIT_DATA;
				end
				else begin //最后一次突发
					w_nstate = W_DONE;
				end
			end
			else begin 
				w_nstate = W_WAIT;
			end
		end
		W_WAIT:begin 
			if(w_handshake)begin 
				if(w_burst_count < wr_burst_time)begin //非最后一次突发
					w_nstate = W_WAIT_DATA;
				end
				else begin //最后一次突发
					w_nstate = W_DONE;
				end
			end
			else begin 
				w_nstate = W_WAIT;
			end
		end
		W_DONE:begin 
			if(aw_done)begin //aw\w都完成
				w_nstate = W_IDLE;
			end
			else begin 
				w_nstate = W_DONE;
			end
		end
		default:begin 
			w_nstate = W_IDLE;
		end
	endcase // aw_nstate
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		reg_wlast <=#DELAY 1'd0;
		reg_wvalid <=#DELAY 1'd0;
		w_burst_count <=#DELAY 32'd0;
		w_data_count <=#DELAY 8'd0;
		w_done <=#DELAY 1'd0;

	end
	else begin 
		case(w_nstate)
			W_IDLE:begin 
				reg_wlast <=#DELAY 1'd0;
				reg_wvalid <=#DELAY 1'd0;
				w_burst_count <=#DELAY 32'd0;
				w_data_count <=#DELAY 8'd0;
				w_done <=#DELAY 1'd0;
			end
			W_WAIT_DATA:begin 
				reg_wlast <=#DELAY 1'd0;
				reg_wvalid <=#DELAY 1'd0;
			end
			W_QWN:begin //本次突发传输中，数据传输周期数++
				reg_wvalid <=#DELAY 1'd1;
				w_data_count <=#DELAY w_data_count + 8'd1;
			end
			W_LAST:begin //突发次数++，数据传输周期清零
				reg_wlast <=#DELAY 1'd1;
				reg_wvalid <=#DELAY 1'd1;
				w_data_count <=#DELAY 8'd0;
				w_burst_count <=#DELAY w_burst_count + 32'd1;
			end
			W_WAIT:;
			W_DONE:begin 
				w_done <=#DELAY 1'd1;
				reg_wlast <=#DELAY 1'd0;
				reg_wvalid <=#DELAY 1'd0;
				w_burst_count <=#DELAY 32'd0;
				w_data_count <=#DELAY 8'd0;
				
			end
			default:begin 
				reg_wlast <=#DELAY 1'd0;
				reg_wvalid <=#DELAY 1'd0;
				w_burst_count <=#DELAY 32'd0;
				w_data_count <=#DELAY 8'd0;
				w_done <=#DELAY 1'd0;
			end
		endcase // w_nstate
	end
end

	read_result_feature #(
			.RAM_AW(RAM_AW),
			.QN(QN),
			.DELAY(DELAY),
			.AXI_DW(AXI_DW)
		) inst_read_result_feature (
			.aclk           (aclk),
			.arest_n        (arest_n),
			.res_start      (rd_wr_irq[1]),
			.test_mode 		(test_mode_r[0]),
			.w_handshake    (w_handshake),
			.wr_done 		(wr_done),
			.res_enb_0      (res_enb_0),
			.res_enb_1      (res_enb_1),
			.res_enb_2      (res_enb_2),
			.res_enb_3      (res_enb_3),
			.res_addrb_0    (res_addrb_0),
			.res_addrb_1    (res_addrb_1),
			.res_addrb_2    (res_addrb_2),
			.res_addrb_3    (res_addrb_3),
			.res_doutb_0    (res_doutb_0),
			.res_doutb_1    (res_doutb_1),
			.res_doutb_2    (res_doutb_2),
			.res_doutb_3    (res_doutb_3),
			.res_data       (res_data),
			.res_data_valid (res_data_valid)
		);

//rd

/*//hog_start跨时钟域处理
always @(posedge aclk)begin 
	if(!arest_n)begin 
		hog_start_r1 <=#DELAY 1'd0;
		hog_start_r2 <=#DELAY 1'd0;
		hog_start_r3 <=#DELAY 1'd0;
	end
	else begin 
		hog_start_r1 <=#DELAY hog_start_eclk;
		hog_start_r2 <=#DELAY hog_start_r1;
		hog_start_r3 <=#DELAY hog_start_r2;
	end
end
*/


////////////ar
//assign length_head1 = 13'h1000 - absolute_addr_r[11:0];//第一行第一次突发传输
//assign length_head2 = 13'h1000 - ar_fst_addr[11:0];//后续行第一次突发传输

always @(posedge aclk)begin 
	if(!arest_n)begin 
		ar_cstate <=#DELAY AR_IDLE;
	end
	else begin 
		ar_cstate <=#DELAY ar_nstate;
	end
end

always @(*)begin 
	ar_nstate = ar_cstate;
	case(ar_cstate)
		AR_IDLE:begin 
			if(rd_wr_irq[0] == 1'd1)begin //启动读地址请求
				if(absolute_addr_r[11:0] + img0y_r > 13'h1000)begin //列数需要多个突发请求内完成
					ar_nstate = AR_HEAD;
				end
				else begin //列数可在一次突发请求内完成
					ar_nstate = AR_COL_END;
				end
			end
			else begin 
				ar_nstate = AR_IDLE;
			end
		end
		AR_HEAD:begin 
			if(ar_handshake == 1'd1)begin //握手
				if(ar_col_remain > 13'h1000)begin //剩下的列数，大于一次突发
					ar_nstate = AR_QWN;
				end
				else begin //剩下列数在1次突发以内
					ar_nstate = AR_COL_END;
				end
			end
			else begin //没有握手
				ar_nstate = AR_WAIT;
			end
		end
		AR_COL_END:begin 
			if(ar_handshake == 1'd1)begin //握手
				if(ar_row_count == img0x_r)begin //最后一行完成
					ar_nstate = AR_DONE;
				end
				else begin 
					if(ar_fst_addr[11:0] + img0y_r > 13'h1000)begin //列数需要多个突发请求内完成
						ar_nstate = AR_HEAD;
					end
					else begin //列数可在一次突发请求内完成
						ar_nstate = AR_COL_END;
					end
				end
			end
			else begin //没有握手
				ar_nstate = AR_WAIT;
			end
		end
		AR_QWN:begin 
			if(ar_handshake == 1'd1)begin //握手
				if(ar_col_remain > 13'h1000)begin //剩下的列数，大于一次突发
					ar_nstate = AR_QWN;
				end
				else begin //剩下列数在1次突发以内
					ar_nstate = AR_COL_END;
				end
			end
			else begin //没有握手
				ar_nstate = AR_WAIT;
			end
		end
		AR_WAIT:begin 
			if(ar_handshake == 1'd1)begin //握手
				if(ar_row_count == img0x_r)begin //最后一行读地址完毕
					ar_nstate = AR_DONE;
				end
				else begin 
					if(ar_col_remain > 13'h1000)begin //列数需要多个突发请求
						ar_nstate = AR_QWN;
					end
					else begin 
						if(ar_col_remain > 16'd0)begin //列数需要1个突发请求
							ar_nstate = AR_COL_END;
						end
						else begin //remain == 0
							if(ar_fst_addr[11:0] + img0y_r > 13'h1000)begin //列数需要多个突发请求内完成
								ar_nstate = AR_HEAD;
							end
							else begin //列数可在一次突发请求内完成
								ar_nstate = AR_COL_END;
							end
						end
					end
				end
			end
			else begin 
				ar_nstate = AR_WAIT;
			end
		end
		AR_DONE:begin //等待r、ar结束
			if(r_done == 1'd1)begin 
				ar_nstate = AR_IDLE;
			end
			else begin 
				ar_nstate = AR_DONE;
			end
		end
		default:begin 
			ar_nstate = AR_IDLE;
		end
	endcase // ar_cstate
end
always @(posedge aclk)begin 
	if(!arest_n)begin 
		ar_col_remain <=#DELAY 16'd0;
		ar_fst_addr <=#DELAY 32'd0;
		ar_row_count <=#DELAY 16'd0;
		ar_done <=#DELAY 1'd0;
		reg_araddr <=#DELAY 'd0;
		reg_arvalid <=#DELAY 1'd0;
		reg_arlen <=#DELAY 8'd0;
	end
	else begin 
		case(ar_nstate)
			AR_IDLE:begin 
				ar_col_remain <=#DELAY 16'd0;
				ar_fst_addr <=#DELAY 32'd0;
				ar_row_count <=#DELAY 16'd0;
				ar_done <=#DELAY 1'd0;
				reg_araddr <=#DELAY 'd0;
				reg_arvalid <=#DELAY 1'd0;
				reg_arlen <=#DELAY 8'd0;
			end
			AR_HEAD:begin 
				reg_arvalid <=#DELAY 1'd1;
				if(rd_wr_irq[0] == 1'd1)begin //第一行启动
					reg_araddr <=#DELAY absolute_addr_r[30:0];//第一行初地址
					ar_col_remain <=#DELAY img0y_r + absolute_addr_r[11:0] - 13'h1000;//本行剩下字节数
					if(absolute_addr_r[5:0] == 6'd0)begin //512bit对齐
						reg_arlen <=#DELAY ((13'h1000 - absolute_addr_r[11:0]) >> 6) - 1; 
					end
					else begin //512bit非对齐
						reg_arlen <=#DELAY (13'h1000 - absolute_addr_r[11:0]) >> 6;
					end
				end
				else begin //后续行启动
					reg_araddr <=#DELAY ar_fst_addr[30:0];//第一行初地址
					ar_col_remain <=#DELAY img0y_r + ar_fst_addr[11:0] - 13'h1000;//本行剩下字节数
					if(ar_fst_addr[5:0] == 6'd0)begin //512bit对齐
						reg_arlen <=#DELAY ((13'h1000 - ar_fst_addr[11:0]) >> 6) - 1; 
					end
					else begin //512bit非对齐
						reg_arlen <=#DELAY (13'h1000 - ar_fst_addr[11:0]) >> 6;
					end
				end
			end
			AR_COL_END:begin 
				reg_arvalid <=#DELAY 1'd1;
				ar_row_count <=#DELAY ar_row_count + 16'd1;
				ar_col_remain <=#DELAY 16'd0;
				if(ar_col_remain == 16'd0)begin //情况1：cstate=idle;情况2：cstate=col_end;情况3：cstate=wait;
					if(rd_wr_irq[0] == 1'd1)begin //cstate=idle
						reg_araddr <=#DELAY absolute_addr_r[30:0];//第一行起始地址
						ar_fst_addr <=#DELAY absolute_addr_r + cross_row_offset_r;//下一行起始地址
						if(absolute_addr_r[5:0] + img0y_r[5:0] == 6'd0)begin //512bit对齐
							reg_arlen <=#DELAY ((absolute_addr_r[5:0] + img0y_r) >> 6) - 1;
						end
						else begin //512bit没有对齐
							reg_arlen <=#DELAY (absolute_addr_r[5:0] + img0y_r) >> 6;
						end
					end
					else begin //cstate = col_end | wait
						reg_araddr <=#DELAY ar_fst_addr[30:0];//后续行起始地址
						ar_fst_addr <=#DELAY ar_fst_addr + cross_row_offset_r;
						if(ar_fst_addr[5:0] + img0y_r[5:0] == 6'd0)begin //512bit对齐
							reg_arlen <=#DELAY ((ar_fst_addr[5:0] + img0y_r) >> 6) - 1;
						end
						else begin //512bit没有对齐
							reg_arlen <=#DELAY (ar_fst_addr[5:0] + img0y_r) >> 6;
						end
					end
				end
				else begin //cstate = qwn
					reg_araddr <=#DELAY {reg_araddr[30:12],12'd0} + 13'h1000;//每行最后一次突发传输地址
					ar_fst_addr <=#DELAY ar_fst_addr + cross_row_offset_r;
					if(ar_col_remain[5:0] == 6'd0)begin //512bit对齐
						reg_arlen <=#DELAY ar_col_remain[13:6] - 1;
					end
					else begin 
						reg_arlen <=#DELAY ar_col_remain[13:6];
					end
				end
			end
			AR_QWN:begin 
				reg_arvalid <=#DELAY 1'd1;
				reg_araddr <=#DELAY {reg_araddr[30:12],12'd0} + 13'h1000;//对齐，每次传输4kB数据
				reg_arlen <=#DELAY 8'd63;
				ar_col_remain <=#DELAY ar_col_remain - 13'h1000;
			end
			AR_WAIT:;
			AR_DONE:begin 
				reg_arvalid <=#DELAY 1'd0;
				ar_done <=#DELAY 1'd1;
			end
			default:begin 
				ar_col_remain <=#DELAY 16'd0;
				ar_fst_addr <=#DELAY 32'd0;
				ar_row_count <=#DELAY 16'd0;
				ar_done <=#DELAY 1'd0;
				reg_araddr <=#DELAY 'd0;
				reg_arvalid <=#DELAY 1'd0;
				reg_arlen <=#DELAY 8'd0;
			end
		endcase // ar_nstate
	end
end

///////////r
/////根据读取的图像块大小，突发长度以及非对齐突发、处理
always @(posedge aclk)begin 
	if(!arest_n)begin 
		r_cstate <=#DELAY R_IDLE;
	end
	else begin 
		r_cstate <=#DELAY r_nstate;
	end
end

always @(*)begin 
	r_nstate = r_cstate;
	case(r_cstate)
		R_IDLE:begin 
			if(rd_wr_irq[0] == 1'd1)begin //启动读原始数据
				r_nstate = R_WAIT;
			end
			else begin 
				r_nstate = R_IDLE;
			end
		end
		R_WAIT:begin 
			if(r_handshake == 1'd1)begin //数据有效
				if(byte_count > 7'd2)begin //超过2Byte
					if(r_row_count[0] == 1'd0)begin //写到偶数行
						if(flag_1 == 1'd0)begin //写道偶数列
							r_nstate = R_12;
						end
						else begin 
							r_nstate = R_21;
						end
					end
					else begin //写道奇数行
						if(flag_2 == 1'd0)begin //写到偶数列
							r_nstate = R_34;
						end
						else begin 
							r_nstate = R_43;
						end
					end
				end
				else if(byte_count == 7'd2)begin //正好剩下2Byte
					if(r_row_count[0] == 1'd0)begin //写到偶数行
						if(flag_1 == 1'd0)begin //写道偶数列
							r_nstate = R_12_END;
						end
						else begin 
							r_nstate = R_21_END;
						end
					end
					else begin //写道奇数行
						if(flag_2 == 1'd0)begin //写到偶数列
							r_nstate = R_34_END;
						end
						else begin 
							r_nstate = R_43_END;
						end
					end
				end
				else begin //剩下1Byte
					if(r_row_count[0] == 1'd0)begin //写到偶数行
						if(flag_1 == 1'd0)begin //写道偶数列
							r_nstate = R_1_END;
						end
						else begin 
							r_nstate = R_2_END;
						end
					end
					else begin //写道奇数行
						if(flag_2 == 1'd0)begin //写到偶数列
							r_nstate = R_3_END;
						end
						else begin 
							r_nstate = R_4_END;
						end
					end
				end
			end
			else begin 
				r_nstate = R_WAIT;
			end
		end
		R_12:begin 
			if(byte_count > 7'd2)begin 
				r_nstate = R_12;
			end
			else if(byte_count == 7'd2)begin 
				r_nstate = R_12_END;
			end
			else begin 
				r_nstate = R_1_END;
			end
		end
		R_21:begin 
			if(byte_count > 7'd2)begin 
				r_nstate = R_21;
			end
			else if(byte_count == 7'd2)begin 
				r_nstate = R_21_END;
			end
			else begin 
				r_nstate = R_2_END;
			end
		end
		R_1_END:begin 
			if(reg_rready == 1'd1)begin //还有数据
				if(m_axi_rvalid == 1'd1)begin //r握手
					if(byte_count > 7'd2)begin //超过2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_21;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_34;
							end
							else begin 
								r_nstate = R_43;
							end
						end
					end
					else if(byte_count == 7'd2)begin //正好剩下2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_21_END;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_34_END;
							end
							else begin 
								r_nstate = R_43_END;
							end
						end
					end
					else begin //剩下1Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_2_END;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_3_END;
							end
							else begin 
								r_nstate = R_4_END;
							end
						end
					end
				end
				else begin 
					r_nstate = R_WAIT;//等待握手
				end
			end
			else begin //读数据传输完毕，等待图像缩放完成
				r_nstate = R_END;
			end
		end
		R_2_END:begin 
			if(reg_rready == 1'd1)begin //还有数据
				if(m_axi_rvalid == 1'd1)begin //r握手
					if(byte_count > 7'd2)begin //超过2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_12;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_34;
							end
							else begin 
								r_nstate = R_43;
							end
						end
					end
					else if(byte_count == 7'd2)begin //正好剩下2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_12_END;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_34_END;
							end
							else begin 
								r_nstate = R_43_END;
							end
						end
					end
					else begin //剩下1Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_1_END;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_3_END;
							end
							else begin 
								r_nstate = R_4_END;
							end
						end
					end
				end
				else begin 
					r_nstate = R_WAIT;//等待握手
				end
			end
			else begin //读数据传输完毕，等待图像缩放完成
				r_nstate = R_END;
			end
		end
		R_12_END:begin 
			if(reg_rready == 1'd1)begin //还有数据
				if(m_axi_rvalid == 1'd1)begin //r握手
					if(byte_count > 7'd2)begin //超过2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_12;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_34;
							end
							else begin 
								r_nstate = R_43;
							end
						end
					end
					else if(byte_count == 7'd2)begin //正好剩下2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_12_END;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_34_END;
							end
							else begin 
								r_nstate = R_43_END;
							end
						end
					end
					else begin //剩下1Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_1_END;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_3_END;
							end
							else begin 
								r_nstate = R_4_END;
							end
						end
					end
				end
				else begin 
					r_nstate = R_WAIT;//等待握手
				end
			end
			else begin //读数据传输完毕，等待图像缩放完成
				r_nstate = R_END;
			end
		end
		R_21_END:begin 
			if(reg_rready == 1'd1)begin //还有数据
				if(m_axi_rvalid == 1'd1)begin //r握手
					if(byte_count > 7'd2)begin //超过2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_21;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_34;
							end
							else begin 
								r_nstate = R_43;
							end
						end
					end
					else if(byte_count == 7'd2)begin //正好剩下2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_21_END;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_34_END;
							end
							else begin 
								r_nstate = R_43_END;
							end
						end
					end
					else begin //剩下1Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							r_nstate = R_2_END;
						end
						else begin //写道奇数行
							if(flag_2 == 1'd0)begin //写到偶数列
								r_nstate = R_3_END;
							end
							else begin 
								r_nstate = R_4_END;
							end
						end
					end
				end
				else begin 
					r_nstate = R_WAIT;//等待握手
				end
			end
			else begin //读数据传输完毕，等待图像缩放完成
				r_nstate = R_END;
			end
		end
		R_34:begin 
			if(byte_count > 7'd2)begin 
				r_nstate = R_34;
			end
			else if(byte_count == 7'd2)begin 
				r_nstate = R_34_END;
			end
			else begin 
				r_nstate = R_3_END;
			end
		end
		R_43:begin 
			if(byte_count > 7'd2)begin 
				r_nstate = R_43;
			end
			else if(byte_count == 7'd2)begin 
				r_nstate = R_43_END;
			end
			else begin 
				r_nstate = R_4_END;
			end
		end
		R_3_END:begin 
			if(reg_rready == 1'd1)begin //还有数据
				if(m_axi_rvalid == 1'd1)begin //r握手
					if(byte_count > 7'd2)begin //超过2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_12;
							end
							else begin 
								r_nstate = R_21;
							end
						end
						else begin //写道奇数行
							r_nstate = R_43;
						end
					end
					else if(byte_count == 7'd2)begin //正好剩下2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_12_END;
							end
							else begin 
								r_nstate = R_21_END;
							end
						end
						else begin //写道奇数行
							r_nstate = R_43_END;
						end
					end
					else begin //剩下1Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_1_END;
							end
							else begin 
								r_nstate = R_2_END;
							end
						end
						else begin //写道奇数行
							r_nstate = R_4_END;
						end
					end
				end
				else begin 
					r_nstate = R_WAIT;//等待握手
				end
			end
			else begin //读数据传输完毕，等待图像缩放完成
				r_nstate = R_END;
			end
		end
		R_4_END:begin 
			if(reg_rready == 1'd1)begin //还有数据
				if(m_axi_rvalid == 1'd1)begin //r握手
					if(byte_count > 7'd2)begin //超过2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_12;
							end
							else begin 
								r_nstate = R_21;
							end
						end
						else begin //写道奇数行
							r_nstate = R_34;
						end
					end
					else if(byte_count == 7'd2)begin //正好剩下2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_12_END;
							end
							else begin 
								r_nstate = R_21_END;
							end
						end
						else begin //写道奇数行
							r_nstate = R_34_END;
						end
					end
					else begin //剩下1Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_1_END;
							end
							else begin 
								r_nstate = R_2_END;
							end
						end
						else begin //写道奇数行
							r_nstate = R_3_END;
						end
					end
				end
				else begin 
					r_nstate = R_WAIT;//等待握手
				end
			end
			else begin //读数据传输完毕，等待图像缩放完成
				r_nstate = R_END;
			end
		end
		R_34_END:begin 
			if(reg_rready == 1'd1)begin //还有数据
				if(m_axi_rvalid == 1'd1)begin //r握手
					if(byte_count > 7'd2)begin //超过2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_12;
							end
							else begin 
								r_nstate = R_21;
							end
						end
						else begin //写道奇数行
							r_nstate = R_34;
						end
					end
					else if(byte_count == 7'd2)begin //正好剩下2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_12_END;
							end
							else begin 
								r_nstate = R_21_END;
							end
						end
						else begin //写道奇数行
							r_nstate = R_34_END;
						end
					end
					else begin //剩下1Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_1_END;
							end
							else begin 
								r_nstate = R_2_END;
							end
						end
						else begin //写道奇数行
							r_nstate = R_3_END;
						end
					end
				end
				else begin 
					r_nstate = R_WAIT;//等待握手
				end
			end
			else begin //读数据传输完毕，等待图像缩放完成
				r_nstate = R_END;
			end
		end
		R_43_END:begin 
			if(reg_rready == 1'd1)begin //还有数据
				if(m_axi_rvalid == 1'd1)begin //r握手
					if(byte_count > 7'd2)begin //超过2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_12;
							end
							else begin 
								r_nstate = R_21;
							end
						end
						else begin //写道奇数行
							r_nstate = R_43;
						end
					end
					else if(byte_count == 7'd2)begin //正好剩下2Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_12_END;
							end
							else begin 
								r_nstate = R_21_END;
							end
						end
						else begin //写道奇数行
							r_nstate = R_43_END;
						end
					end
					else begin //剩下1Byte
						if(r_row_count[0] == 1'd0)begin //写到偶数行
							if(flag_1 == 1'd0)begin 
								r_nstate = R_1_END;
							end
							else begin 
								r_nstate = R_2_END;
							end
						end
						else begin //写道奇数行
							r_nstate = R_4_END;
						end
					end
				end
				else begin 
					r_nstate = R_WAIT;//等待握手
				end
			end
			else begin //读数据传输完毕，等待图像缩放完成
				r_nstate = R_END;
			end
		end
		R_END:begin 
			if(scaling_finish == 1'd1)begin 
				r_nstate = R_IDLE;
			end
			else begin 
				r_nstate = R_END;
			end
		end
		default:begin 
			r_nstate = R_IDLE;
		end
	endcase // r_cstate
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
	reg_rready <=#DELAY 1'd0;
	r_fst_addr <=#DELAY 32'd0;
	r_row_count <=#DELAY 16'd0;
	flag_1 <=#DELAY 1'd0;
	flag_2 <=#DELAY 1'd0;
	byte_en <=#DELAY 9'd0;
	r_col_remain <=#DELAY 16'd0;
	byte_count <=#DELAY 7'd0;
	r_done <=#DELAY 1'd0;

	r_data_r1 <=#DELAY 512'd0;//当r_handshake时将r_data寄存
	//写bram
	initial_wea_0 <=#DELAY 1'd0;
	initial_wea_1 <=#DELAY 1'd0;
	initial_wea_2 <=#DELAY 1'd0;
	initial_wea_3 <=#DELAY 1'd0;
	initial_addra_0 <=#DELAY 'd0;
	initial_addra_1 <=#DELAY 'd0;
	initial_addra_2 <=#DELAY 'd0;
	initial_addra_3 <=#DELAY 'd0;
	initial_dina_0 <=#DELAY 'd0;
	initial_dina_1 <=#DELAY 'd0;
	initial_dina_2 <=#DELAY 'd0;
	initial_dina_3 <=#DELAY 'd0;
	end
	else begin 
		case(r_nstate)
			R_IDLE:begin 
				reg_rready <=#DELAY 1'd0;
				r_fst_addr <=#DELAY 32'd0;
				r_row_count <=#DELAY 16'd0;
				flag_1 <=#DELAY 1'd0;
				flag_2 <=#DELAY 1'd0;
				byte_en <=#DELAY 9'd0;
				r_col_remain <=#DELAY 16'd0;
				byte_count <=#DELAY 7'd0;
				r_done <=#DELAY 1'd0;
				r_data_r1 <=#DELAY 512'd0;
				//写bram
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_0 <=#DELAY {RAM_AW{1'd1}};//写地址全1，不断++
				initial_addra_1 <=#DELAY {RAM_AW{1'd1}};
				initial_addra_2 <=#DELAY {RAM_AW{1'd1}};
				initial_addra_3 <=#DELAY {RAM_AW{1'd1}};
				initial_dina_0 <=#DELAY 'd0;
				initial_dina_1 <=#DELAY 'd0;
				initial_dina_2 <=#DELAY 'd0;
				initial_dina_3 <=#DELAY 'd0;
			end
			R_WAIT:begin 
				if(byte_count == 7'd0)begin //第一次读数据请求
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY {3'd0,absolute_addr_r[5:0]};//字节有效位
					r_fst_addr <=#DELAY absolute_addr_r + cross_row_offset_r;//下一行起始地址
					if(img0y_r > 7'd64 - absolute_addr_r[5:0])begin //超过一个周期
						byte_count <=#DELAY 7'd64 - absolute_addr_r[5:0];
						r_col_remain <=#DELAY img0y_r + absolute_addr_r[5:0] - 7'd64;
					end
					else begin 
						byte_count <=#DELAY img0y_r;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
			end
			R_12:begin 
				reg_rready <=#DELAY 1'd0;//暂停握手
				byte_en <=#DELAY byte_en + 9'd2;
				byte_count <=#DELAY byte_count - 7'd2;
				//写bram
				initial_wea_0 <=#DELAY 1'd1;
				initial_wea_1 <=#DELAY 1'd1;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_0 <=#DELAY initial_addra_0 + 1'd1;//写地址++
				initial_addra_1 <=#DELAY initial_addra_1 + 1'd1;
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_0 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_1 <=#DELAY m_axi_rdata[((byte_en + 1) << 3) +: 8];
				end
				else begin 
					initial_dina_0 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_1 <=#DELAY r_data_r1[((byte_en + 1) << 3) +: 8];
				end
				
			end
			R_21:begin 
				reg_rready <=#DELAY 1'd0;//暂停握手
				byte_en <=#DELAY byte_en + 9'd2;
				byte_count <=#DELAY byte_count - 7'd2;
				//写bram
				initial_wea_0 <=#DELAY 1'd1;
				initial_wea_1 <=#DELAY 1'd1;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_0 <=#DELAY initial_addra_0 + 1'd1;//写地址++
				initial_addra_1 <=#DELAY initial_addra_1 + 1'd1;
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_1 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_0 <=#DELAY m_axi_rdata[((byte_en + 1) << 3) +: 8];
				end
				else begin 
					initial_dina_1 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_0 <=#DELAY r_data_r1[((byte_en + 1) << 3) +: 8];
				end
			end
			R_1_END:begin 
				if(r_col_remain != 16'd0)begin //本行还有数据未握手
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY 9'd0;
					if(r_col_remain > 16'd64)begin //大于1周期，64B
						byte_count <=#DELAY 7'd64;
						r_col_remain <=#DELAY r_col_remain - 7'd64;
					end
					else begin 
						byte_count <=#DELAY r_col_remain;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				else begin //本行结束
					r_row_count <=#DELAY r_row_count + 16'd1;
					if(r_row_count == (img0x_r - 16'd1))begin //最后一行传输完毕
						reg_rready <=#DELAY 1'd0;
					end
					else begin 
						reg_rready <=#DELAY 1'd1;
						byte_en <=#DELAY {3'd0,r_fst_addr[5:0]};//字节有效位
						r_fst_addr <=#DELAY r_fst_addr + cross_row_offset_r;//下一行起始地址
						if(img0y_r > 7'd64 - r_fst_addr[5:0])begin //超过一个周期
							byte_count <=#DELAY 7'd64 - r_fst_addr[5:0];
							r_col_remain <=#DELAY img0y_r + r_fst_addr[5:0] - 7'd64;
						end
						else begin 
							byte_count <=#DELAY img0y_r;
							r_col_remain <=#DELAY 16'd0;
						end
					end
				end
				//写bram
				flag_1 <=#DELAY ~flag_1;
				initial_wea_0 <=#DELAY 1'd1;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_0 <=#DELAY initial_addra_0 + 1'd1;//写地址++
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_0 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
				end 
				else begin 
					initial_dina_0 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
				end
			end
			R_2_END:begin 
				if(r_col_remain != 16'd0)begin //本行还有数据未握手
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY 9'd0;
					if(r_col_remain > 16'd64)begin //大于1周期，64B
						byte_count <=#DELAY 7'd64;
						r_col_remain <=#DELAY r_col_remain - 7'd64;
					end
					else begin 
						byte_count <=#DELAY r_col_remain;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				else begin //本行结束
					r_row_count <=#DELAY r_row_count + 16'd1;
					if(r_row_count == (img0x_r - 16'd1))begin //最后一行传输完毕
						reg_rready <=#DELAY 1'd0;
					end
					else begin 
						reg_rready <=#DELAY 1'd1;
						byte_en <=#DELAY {3'd0,r_fst_addr[5:0]};//字节有效位
						r_fst_addr <=#DELAY r_fst_addr + cross_row_offset_r;//下一行起始地址
						if(img0y_r > 7'd64 - r_fst_addr[5:0])begin //超过一个周期
							byte_count <=#DELAY 7'd64 - r_fst_addr[5:0];
							r_col_remain <=#DELAY img0y_r + r_fst_addr[5:0] - 7'd64;
						end
						else begin 
							byte_count <=#DELAY img0y_r;
							r_col_remain <=#DELAY 16'd0;
						end
					end
				end
				//写bram
				flag_1 <=#DELAY ~flag_1;
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd1;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_1 <=#DELAY initial_addra_1 + 1'd1;//写地址++
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_1 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
				end 
				else begin 
					initial_dina_1 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
				end
			end
			R_12_END:begin 
				if(r_col_remain != 16'd0)begin //本行还有数据未握手
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY 9'd0;
					if(r_col_remain > 16'd64)begin //大于1周期，64B
						byte_count <=#DELAY 7'd64;
						r_col_remain <=#DELAY r_col_remain - 7'd64;
					end
					else begin 
						byte_count <=#DELAY r_col_remain;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				else begin //本行结束
					r_row_count <=#DELAY r_row_count + 16'd1;
					if(r_row_count == (img0x_r - 16'd1))begin //最后一行传输完毕
						reg_rready <=#DELAY 1'd0;
					end
					else begin 
						reg_rready <=#DELAY 1'd1;
						byte_en <=#DELAY {3'd0,r_fst_addr[5:0]};//字节有效位
						r_fst_addr <=#DELAY r_fst_addr + cross_row_offset_r;//下一行起始地址
						if(img0y_r > 7'd64 - r_fst_addr[5:0])begin //超过一个周期
							byte_count <=#DELAY 7'd64 - r_fst_addr[5:0];
							r_col_remain <=#DELAY img0y_r + r_fst_addr[5:0] - 7'd64;
						end
						else begin 
							byte_count <=#DELAY img0y_r;
							r_col_remain <=#DELAY 16'd0;
						end
					end
				end
				//写bram
				initial_wea_0 <=#DELAY 1'd1;
				initial_wea_1 <=#DELAY 1'd1;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_0 <=#DELAY initial_addra_0 + 1'd1;//写地址++
				initial_addra_1 <=#DELAY initial_addra_1 + 1'd1;
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_0 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_1 <=#DELAY m_axi_rdata[((byte_en + 1) << 3) +: 8];
				end 
				else begin 
					initial_dina_0 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_1 <=#DELAY r_data_r1[((byte_en + 1) << 3) +: 8];
				end
			end
			R_21_END:begin 
				if(r_col_remain != 16'd0)begin //本行还有数据未握手
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY 9'd0;
					if(r_col_remain > 16'd64)begin //大于1周期，64B
						byte_count <=#DELAY 7'd64;
						r_col_remain <=#DELAY r_col_remain - 7'd64;
					end
					else begin 
						byte_count <=#DELAY r_col_remain;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				else begin //本行结束
					r_row_count <=#DELAY r_row_count + 16'd1;
					if(r_row_count == (img0x_r - 16'd1))begin //最后一行传输完毕
						reg_rready <=#DELAY 1'd0;
					end
					else begin 
						reg_rready <=#DELAY 1'd1;
						byte_en <=#DELAY {3'd0,r_fst_addr[5:0]};//字节有效位
						r_fst_addr <=#DELAY r_fst_addr + cross_row_offset_r;//下一行起始地址
						if(img0y_r > 7'd64 - r_fst_addr[5:0])begin //超过一个周期
							byte_count <=#DELAY 7'd64 - r_fst_addr[5:0];
							r_col_remain <=#DELAY img0y_r + r_fst_addr[5:0] - 7'd64;
						end
						else begin 
							byte_count <=#DELAY img0y_r;
							r_col_remain <=#DELAY 16'd0;
						end
					end
				end
				//写bram
				initial_wea_0 <=#DELAY 1'd1;
				initial_wea_1 <=#DELAY 1'd1;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_0 <=#DELAY initial_addra_0 + 1'd1;//写地址++
				initial_addra_1 <=#DELAY initial_addra_1 + 1'd1;
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_1 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_0 <=#DELAY m_axi_rdata[((byte_en + 1) << 3) +: 8];
				end
				else begin 
					initial_dina_1 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_0 <=#DELAY r_data_r1[((byte_en + 1) << 3) +: 8];
				end
			end
			R_34:begin 
				reg_rready <=#DELAY 1'd0;//暂停握手
				byte_en <=#DELAY byte_en + 9'd2;
				byte_count <=#DELAY byte_count - 7'd2;
				//写bram
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd1;
				initial_wea_3 <=#DELAY 1'd1;
				initial_addra_2 <=#DELAY initial_addra_2 + 1'd1;//写地址++
				initial_addra_3 <=#DELAY initial_addra_3 + 1'd1;
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_2 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_3 <=#DELAY m_axi_rdata[((byte_en + 1) << 3) +: 8];
				end
				else begin 
					initial_dina_2 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_3 <=#DELAY r_data_r1[((byte_en + 1) << 3) +: 8];
				end
			end
			R_43:begin 
				reg_rready <=#DELAY 1'd0;//暂停握手
				byte_en <=#DELAY byte_en + 9'd2;
				byte_count <=#DELAY byte_count - 7'd2;
				//写bram
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd1;
				initial_wea_3 <=#DELAY 1'd1;
				initial_addra_2 <=#DELAY initial_addra_2 + 1'd1;//写地址++
				initial_addra_3 <=#DELAY initial_addra_3 + 1'd1;
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_3 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_2 <=#DELAY m_axi_rdata[((byte_en + 1) << 3) +: 8];
				end 
				else begin 
					initial_dina_3 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_2 <=#DELAY r_data_r1[((byte_en + 1) << 3) +: 8];
				end
			end
			R_3_END:begin 
				if(r_col_remain != 16'd0)begin //本行还有数据未握手
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY 9'd0;
					if(r_col_remain > 16'd64)begin //大于1周期，64B
						byte_count <=#DELAY 7'd64;
						r_col_remain <=#DELAY r_col_remain - 7'd64;
					end
					else begin 
						byte_count <=#DELAY r_col_remain;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				else begin //本行结束
					r_row_count <=#DELAY r_row_count + 16'd1;
					if(r_row_count == (img0x_r - 16'd1))begin //最后一行传输完毕
						reg_rready <=#DELAY 1'd0;
					end
					else begin 
						reg_rready <=#DELAY 1'd1;
						byte_en <=#DELAY {3'd0,r_fst_addr[5:0]};//字节有效位
						r_fst_addr <=#DELAY r_fst_addr + cross_row_offset_r;//下一行起始地址
						if(img0y_r > 7'd64 - r_fst_addr[5:0])begin //超过一个周期
							byte_count <=#DELAY 7'd64 - r_fst_addr[5:0];
							r_col_remain <=#DELAY img0y_r + r_fst_addr[5:0] - 7'd64;
						end
						else begin 
							byte_count <=#DELAY img0y_r;
							r_col_remain <=#DELAY 16'd0;
						end
					end
				end
				//写bram
				flag_2 <=#DELAY ~flag_2;
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd1;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_2 <=#DELAY initial_addra_2 + 1'd1;//写地址++
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_2 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
				end 
				else begin 
					initial_dina_2 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
				end
			end
			R_4_END:begin 
				if(r_col_remain != 16'd0)begin //本行还有数据未握手
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY 9'd0;
					if(r_col_remain > 16'd64)begin //大于1周期，64B
						byte_count <=#DELAY 7'd64;
						r_col_remain <=#DELAY r_col_remain - 7'd64;
					end
					else begin 
						byte_count <=#DELAY r_col_remain;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				else begin //本行结束
					r_row_count <=#DELAY r_row_count + 16'd1;
					if(r_row_count == (img0x_r - 16'd1))begin //最后一行传输完毕
						reg_rready <=#DELAY 1'd0;
					end
					else begin 
						reg_rready <=#DELAY 1'd1;
						byte_en <=#DELAY {3'd0,r_fst_addr[5:0]};//字节有效位
						r_fst_addr <=#DELAY r_fst_addr + cross_row_offset_r;//下一行起始地址
						if(img0y_r > 7'd64 - r_fst_addr[5:0])begin //超过一个周期
							byte_count <=#DELAY 7'd64 - r_fst_addr[5:0];
							r_col_remain <=#DELAY img0y_r + r_fst_addr[5:0] - 7'd64;
						end
						else begin 
							byte_count <=#DELAY img0y_r;
							r_col_remain <=#DELAY 16'd0;
						end
					end
				end
				//写bram
				flag_2 <=#DELAY ~flag_2;
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd1;
				initial_addra_3 <=#DELAY initial_addra_3 + 1'd1;//写地址++
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_3 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
				end
				else begin 
					initial_dina_3 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
				end
			end
			R_34_END:begin 
				if(r_col_remain != 16'd0)begin //本行还有数据未握手
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY 9'd0;
					if(r_col_remain > 16'd64)begin //大于1周期，64B
						byte_count <=#DELAY 7'd64;
						r_col_remain <=#DELAY r_col_remain - 7'd64;
					end
					else begin 
						byte_count <=#DELAY r_col_remain;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				else begin //本行结束
					r_row_count <=#DELAY r_row_count + 16'd1;
					if(r_row_count == (img0x_r - 16'd1))begin //最后一行传输完毕
						reg_rready <=#DELAY 1'd0;
					end
					else begin 
						reg_rready <=#DELAY 1'd1;
						byte_en <=#DELAY {3'd0,r_fst_addr[5:0]};//字节有效位
						r_fst_addr <=#DELAY r_fst_addr + cross_row_offset_r;//下一行起始地址
						if(img0y_r > 7'd64 - r_fst_addr[5:0])begin //超过一个周期
							byte_count <=#DELAY 7'd64 - r_fst_addr[5:0];
							r_col_remain <=#DELAY img0y_r + r_fst_addr[5:0] - 7'd64;
						end
						else begin 
							byte_count <=#DELAY img0y_r;
							r_col_remain <=#DELAY 16'd0;
						end
					end
				end
				//写bram
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd1;
				initial_wea_3 <=#DELAY 1'd1;
				initial_addra_2 <=#DELAY initial_addra_2 + 1'd1;//写地址++
				initial_addra_3 <=#DELAY initial_addra_3 + 1'd1;
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_2 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_3 <=#DELAY m_axi_rdata[((byte_en + 1) << 3) +: 8];
				end 
				else begin 
					initial_dina_2 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_3 <=#DELAY r_data_r1[((byte_en + 1) << 3) +: 8];
				end
			end
			R_43_END:begin 
				if(r_col_remain != 16'd0)begin //本行还有数据未握手
					reg_rready <=#DELAY 1'd1;
					byte_en <=#DELAY 9'd0;
					if(r_col_remain > 16'd64)begin //大于1周期，64B
						byte_count <=#DELAY 7'd64;
						r_col_remain <=#DELAY r_col_remain - 7'd64;
					end
					else begin 
						byte_count <=#DELAY r_col_remain;
						r_col_remain <=#DELAY 16'd0;
					end
				end
				else begin //本行结束
					r_row_count <=#DELAY r_row_count + 16'd1;
					if(r_row_count == (img0x_r - 16'd1))begin //最后一行传输完毕
						reg_rready <=#DELAY 1'd0;
					end
					else begin 
						reg_rready <=#DELAY 1'd1;
						byte_en <=#DELAY {3'd0,r_fst_addr[5:0]};//字节有效位
						r_fst_addr <=#DELAY r_fst_addr + cross_row_offset_r;//下一行起始地址
						if(img0y_r > 7'd64 - r_fst_addr[5:0])begin //超过一个周期
							byte_count <=#DELAY 7'd64 - r_fst_addr[5:0];
							r_col_remain <=#DELAY img0y_r + r_fst_addr[5:0] - 7'd64;
						end
						else begin 
							byte_count <=#DELAY img0y_r;
							r_col_remain <=#DELAY 16'd0;
						end
					end
				end
				//写bram
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd1;
				initial_wea_3 <=#DELAY 1'd1;
				initial_addra_2 <=#DELAY initial_addra_2 + 1'd1;//写地址++
				initial_addra_3 <=#DELAY initial_addra_3 + 1'd1;
				if(r_handshake)begin 
					r_data_r1 <=#DELAY m_axi_rdata;
					initial_dina_3 <=#DELAY m_axi_rdata[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_2 <=#DELAY m_axi_rdata[((byte_en + 1) << 3) +: 8];
				end
				else begin 
					initial_dina_3 <=#DELAY r_data_r1[(byte_en << 3) +: 8];//根据byte_en来选择数据
					initial_dina_2 <=#DELAY r_data_r1[((byte_en + 1) << 3) +: 8];
				end
			end
			R_END:begin 
				reg_rready <=#DELAY 1'd0;
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				r_done <=#DELAY 1'd1;
			end
			default:begin 
				reg_rready <=#DELAY 1'd0;
				r_fst_addr <=#DELAY 32'd0;
				r_row_count <=#DELAY 16'd0;
				flag_1 <=#DELAY 1'd0;
				flag_2 <=#DELAY 1'd0;
				byte_en <=#DELAY 9'd0;
				r_col_remain <=#DELAY 16'd0;
				byte_count <=#DELAY 7'd0;
				r_done <=#DELAY 1'd0;
				r_data_r1 <=#DELAY 512'd0;
				//写bram
				initial_wea_0 <=#DELAY 1'd0;
				initial_wea_1 <=#DELAY 1'd0;
				initial_wea_2 <=#DELAY 1'd0;
				initial_wea_3 <=#DELAY 1'd0;
				initial_addra_0 <=#DELAY 'd0;
				initial_addra_1 <=#DELAY 'd0;
				initial_addra_2 <=#DELAY 'd0;
				initial_addra_3 <=#DELAY 'd0;
				initial_dina_0 <=#DELAY 'd0;
				initial_dina_1 <=#DELAY 'd0;
				initial_dina_2 <=#DELAY 'd0;
				initial_dina_3 <=#DELAY 'd0;
			end
		endcase // r_nstate
	end
end
//各个阶段的busy状态
always @(posedge aclk)begin 
	if(!arest_n)begin 
		read_busy <=#DELAY 1'd0;
		scaling_busy <=#DELAY 1'd0;
		histogram_busy <=#DELAY 1'd0;
		feature_busy <=#DELAY 1'd0;
		write_busy <=#DELAY 1'd0;
	end
	else begin 
		if(hog_start)begin //hog启动时，进入busy状态
			read_busy <=#DELAY 1'd1;
			scaling_busy <=#DELAY 1'd1;
			histogram_busy <=#DELAY 1'd1;
			feature_busy <=#DELAY 1'd1;
			write_busy <=#DELAY 1'd1;
		end
		else begin 
			//read busy
			if(rd1_wr1_done[0])begin 
				read_busy <=#DELAY 1'd0;
			end
			//scaling_busy
			if(scaling_finish)begin 
				scaling_busy <=#DELAY 1'd0;
			end
			//histogram_busy
			if(histogram_done)begin 
				histogram_busy <=#DELAY 1'd0;
			end
			//feature_busy
			if(write_feature_done)begin 
				feature_busy <=#DELAY 1'd0;
			end
			//write_busy
			if(rd1_wr1_done[1])begin 
				write_busy <=#DELAY 1'd0;
			end
		end
	end
end


/*//测试test，将目标图像数据保存至 target_image.txt
integer handle1;
integer i;
integer j;
initial begin
	handle1 = $fopen("C:/Users/LinMian/Desktop/HOG_20220902/rtl_tb_1/target_image_0.txt");
	wait(rd_wr_irq[0] == 1'd1);//等待读通道启动
	while(!r_done)begin 
		@(posedge aclk);
		//wait(initial_wea_0 | initial_wea_1 | initial_wea_2 | initial_wea_3);
		if(r_cstate == R_12 || r_cstate == R_1_END || r_cstate == R_12_END)begin 
			if(initial_wea_0)begin 
				$fdisplay(handle1,"%h",initial_dina_0);
			end
			if(initial_wea_1)begin 
				$fdisplay(handle1,"%h",initial_dina_1);
			end
		end
		else begin 
			if(initial_wea_1)begin 
				$fdisplay(handle1,"%h",initial_dina_1);
			end
			if(initial_wea_0)begin 
				$fdisplay(handle1,"%h",initial_dina_0);
			end
		end
		
		if(r_cstate == R_34 || r_cstate == R_3_END || r_cstate == R_34_END)begin 
			if(initial_wea_2)begin 
				$fdisplay(handle1,"%h",initial_dina_2);
			end
			if(initial_wea_3)begin 
				$fdisplay(handle1,"%h",initial_dina_3);
			end
		end
		else begin 
			if(initial_wea_3)begin 
				$fdisplay(handle1,"%h",initial_dina_3);
			end
			if(initial_wea_2)begin 
				$fdisplay(handle1,"%h",initial_dina_2);
			end
		end
		
	end
	$fclose(handle1);
end
*/
/*//测试test，将目标图像数据保存至 reg [7:0] target_image[640*512-1:0]
reg [7:0] target_image[640*512-1:0];
integer i;
integer j;
initial begin
	while(1)begin
		wait(rd_wr_irq[0] == 1'd1);//等待读通道启动
		i = 0;
		while(!r_done)begin 
			@(posedge aclk);
			//wait(initial_wea_0 | initial_wea_1 | initial_wea_2 | initial_wea_3);
			if(r_cstate == R_12 || r_cstate == R_1_END || r_cstate == R_12_END)begin 
				if(initial_wea_0)begin 
					target_image[i] = initial_dina_0;
					i = i + 1;
				end
				if(initial_wea_1)begin 
					target_image[i] = initial_dina_1;
					i = i + 1;
				end
			end
			else begin 
				if(initial_wea_1)begin 
					target_image[i] = initial_dina_1;
					i = i + 1;
				end
				if(initial_wea_0)begin 
					target_image[i] = initial_dina_0;
					i = i + 1;
				end
			end
			
			if(r_cstate == R_34 || r_cstate == R_3_END || r_cstate == R_34_END)begin 
				if(initial_wea_2)begin 
					target_image[i] = initial_dina_2;
					i = i + 1;
				end
				if(initial_wea_3)begin 
					target_image[i] = initial_dina_3;
					i = i + 1;
				end
			end
			else begin 
				if(initial_wea_3)begin 
					target_image[i] = initial_dina_3;
					i = i + 1;
				end
				if(initial_wea_2)begin 
					target_image[i] = initial_dina_2;
					i = i + 1;
				end
			end
			
		end
	end
end
*/

/*//测试test，将提取特征值保存至feature_image.txt
integer handle2;
integer m;
integer n;
initial begin
	handle2 = $fopen("C:/Users/LinMian/Desktop/HOG_20220902/rtl_tb_1/feature_image_0.txt");
	wait(rd_wr_irq[1] == 1'd1);//等待写通道启动
	while(!w_done)begin 
		@(posedge aclk);
		if(w_handshake == 1'd1)begin 
			for(n = 0; n < 16; n = n + 1)begin 
				$fdisplay(handle2,"%h",m_axi_wdata[n*32+:32]);
			end
		end
	end
	
	$fclose(handle2);
end
*/
endmodule
