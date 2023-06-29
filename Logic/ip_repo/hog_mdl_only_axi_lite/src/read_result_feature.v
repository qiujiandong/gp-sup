// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-28 11:06:12
// Author : Liman
// Email  : 944768976@qq.com
// File   : read_result_feature.v
// Description ：
// Revise : 2023-02-19 13:42:18
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns
module read_result_feature #(
	parameter RAM_AW = 17,
	parameter QN = 8,
	parameter DELAY = 1,
	parameter AXI_DW = 512
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low
	
	//读启动信号，每次启动bram读操作执行16次，总共4bank读出512b数据。
	input res_start,//第一次启动使用start
	input test_mode,
	input w_handshake,//后续启动使用whandshake
	//完成信号
	input wr_done,
	//读imagescaling中的结果bram：bank0-3
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output  res_enb_0,//bank0
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output  res_enb_1,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output  res_enb_2,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output  res_enb_3,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output  [RAM_AW-1 : 0] res_addrb_0,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output  [RAM_AW-1 : 0] res_addrb_1,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output  [RAM_AW-1 : 0] res_addrb_2,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output  [RAM_AW-1 : 0] res_addrb_3,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)input [QN-1 : 0] res_doutb_0,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)input [QN-1 : 0] res_doutb_1,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)input [QN-1 : 0] res_doutb_2,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)input [QN-1 : 0] res_doutb_3,

	(* mark_debug="true" *)output reg [AXI_DW-1:0] res_data,
	(* mark_debug="true" *)output reg res_data_valid

);

//拼接数据
localparam STITCH_IDLE 		= 3'd0;
localparam STITCH_BIN0_17 	= 3'd1;
localparam STITCH_BIN18_26 	= 3'd2;
localparam STITCH_BIN27_30 	= 3'd3;
localparam STITCH_WAIT 		= 3'd4;

wire rd_en;//读使能
reg [RAM_AW-1:0] res_addrb;//读地址 
reg [4:0] bin_count;//bin计数，总共31个bin
reg [5:0] start_count;//每个bin需要启动64次，
reg [1:0] data_count;//每次启动，连续读取4次
reg doutb_valid;

reg [2:0] stitch_cstate,stitch_nstate;

//8bit定点数转为32bit浮点数
(* KEEP = "TRUE" *)(* mark_debug="true" *)reg [31:0] float_res_0;
(* KEEP = "TRUE" *)(* mark_debug="true" *)reg [31:0] float_res_1;
(* KEEP = "TRUE" *)(* mark_debug="true" *)reg [31:0] float_res_2;
(* KEEP = "TRUE" *)(* mark_debug="true" *)reg [31:0] float_res_3;

//启动信号：res_start、w_handshake && (start_count != 6'd0 || bin_count != 5'd0)（最后一次whandshake需要排除）
assign rd_en = res_start || (w_handshake && (start_count != 6'd0 || bin_count != 5'd0)) || data_count != 2'd0;


//启动后计数
always @(posedge aclk)begin 
	if(!arest_n)begin 
		data_count <=#DELAY 2'd0;
	end
	else begin 
		if(data_count != 2'd0)begin 
			data_count <=#DELAY data_count + 2'd1;
		end
		else begin 
			if(rd_en)begin //启动后
				data_count <=#DELAY 2'd1;
			end
		end
	end
end

//每个bin的启动次数计数
always @(posedge aclk)begin 
	if(!arest_n)begin 
		start_count <=#DELAY 6'd0;
	end
	else begin 
		if(data_count == 2'd3)begin 
			start_count <=#DELAY start_count + 6'd1;
		end
	end
end

//bin 计数
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_count <=#DELAY 5'd0;
	end
	else begin 
		if(data_count == 2'd3 && start_count == 6'd63)begin //上一个bin数据读取完毕
			if(bin_count == 5'd30)begin //所有bin读取完毕
				bin_count <=#DELAY 5'd0;
			end
			else begin 
				bin_count <=#DELAY bin_count + 5'd1;
			end
		end
	end
end

//读使能
assign res_enb_0 = rd_en;
assign res_enb_1 = rd_en;
assign res_enb_2 = rd_en;
assign res_enb_3 = rd_en;
//读地址
assign res_addrb_0 = res_addrb;
assign res_addrb_1 = res_addrb;
assign res_addrb_2 = res_addrb;
assign res_addrb_3 = res_addrb;

always @(posedge aclk)begin //读地址跳变
	if(!arest_n)begin 
		res_addrb <=#DELAY 'd0;
	end
	else begin 
		if(rd_en)begin 
			if(res_addrb == 13'd7935)begin //256*31-1
				res_addrb <=#DELAY 'd0;
			end
			else begin 
				res_addrb <=#DELAY res_addrb + 1'd1;
			end
		end
	end
end

always @(posedge aclk)begin //读数据有效
	if(!arest_n)begin 
		doutb_valid <=#DELAY 1'd0;
	end
	else begin 
		doutb_valid <=#DELAY rd_en;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		stitch_cstate <=#DELAY STITCH_IDLE;
	end
	else begin 
		stitch_cstate <=#DELAY stitch_nstate;
	end
end

always @(*)begin 
	stitch_nstate = stitch_cstate;
	case(stitch_cstate)
		STITCH_IDLE:begin 
			if(doutb_valid)begin //读出数据有效
				stitch_nstate = STITCH_BIN0_17;
			end
			else begin 
				stitch_nstate = STITCH_IDLE;
			end
		end
		STITCH_BIN0_17:begin 
			if(!doutb_valid)begin //16个数据读取完毕
				stitch_nstate = STITCH_WAIT;
			end
			else begin 
				stitch_nstate = STITCH_BIN0_17;
			end
		end
		STITCH_BIN18_26:begin //16个数据读取完毕
			if(!doutb_valid)begin 
				stitch_nstate = STITCH_WAIT;
			end
			else begin 
				stitch_nstate = STITCH_BIN18_26;
			end
		end
		STITCH_BIN27_30:begin //16个数据读取完毕
			if(!doutb_valid)begin 
				stitch_nstate = STITCH_WAIT;
			end
			else begin 
				stitch_nstate = STITCH_BIN27_30;
			end
		end
		STITCH_WAIT:begin 
			if(wr_done)begin //31个bin读取完毕,bin_count == 5'd0 && start_count == 6'd0
				stitch_nstate = STITCH_IDLE;
			end
			else begin 
				if(doutb_valid)begin //bin未读取完毕
					if(bin_count <= 5'd17)begin //bin0-17
						stitch_nstate = STITCH_BIN0_17;
					end
					else if(bin_count <= 5'd26)begin //bin18-26
						stitch_nstate = STITCH_BIN18_26;
					end
					else begin //bin27-30
						stitch_nstate = STITCH_BIN27_30;
					end
				end
				else begin 
					stitch_nstate = STITCH_WAIT;
				end
			end
		end
		default:begin 
			stitch_nstate = STITCH_IDLE;
		end
	endcase // stitch_cstate
end

//数据拼接暂且设为小端传输
always @(posedge aclk)begin 
	if(!arest_n)begin 
		res_data <=#DELAY 'd0;
		res_data_valid <=#DELAY 1'd0; 
	end
	else begin 
		case(stitch_nstate)
			STITCH_IDLE:begin 
				res_data <=#DELAY 'd0;
				res_data_valid <=#DELAY 1'd0; 
			end
			STITCH_BIN0_17:begin 
				if(data_count == 2'd3)begin 
					res_data_valid <=#DELAY 1'd1; 
				end
				else begin 
					res_data_valid <=#DELAY 1'd0;
				end
				if(test_mode)begin 
					res_data <=#DELAY {512{1'd1}};
				end
				else begin 
					res_data <=#DELAY {float_res_3,float_res_2,float_res_1,float_res_0,res_data[AXI_DW-1:128]};//bank0存储第一个像素
				end
			end
			STITCH_BIN18_26:begin 
				if(data_count == 2'd3)begin 
					res_data_valid <=#DELAY 1'd1; 
				end
				else begin 
					res_data_valid <=#DELAY 1'd0;
				end
				if(test_mode)begin 
					res_data <=#DELAY {512{1'd1}};
				end
				else begin 
					res_data <=#DELAY {float_res_0,float_res_3,float_res_2,float_res_1,res_data[AXI_DW-1:128]};//bank1存储第一个像素
				end
				
			end
			STITCH_BIN27_30:begin 
				if(data_count == 2'd3)begin 
					res_data_valid <=#DELAY 1'd1; 
				end
				else begin 
					res_data_valid <=#DELAY 1'd0;
				end
				if(test_mode)begin 
					res_data <=#DELAY {512{1'd1}};
				end
				else begin 
					res_data <=#DELAY {float_res_2,float_res_1,float_res_0,float_res_3,res_data[AXI_DW-1:128]};//bank3存储第一个像素
				end
				
			end
			STITCH_WAIT:;
			default:begin 
				res_data <=#DELAY 'd0;
				res_data_valid <=#DELAY 1'd0; 
			end
		endcase // stitch_nstate
	end
end


//将结果输出从8bit定点小数转为浮点数
always @(*)begin 
	casez(res_doutb_0)
	12'b1???_????_????:float_res_0 = {1'd0,8'd126,res_doutb_0[QN-2:0],{24-QN{1'b0}}};
	12'b01??_????_????:float_res_0 = {1'd0,8'd125,res_doutb_0[QN-3:0],{25-QN{1'b0}}};
	12'b001?_????_????:float_res_0 = {1'd0,8'd124,res_doutb_0[QN-4:0],{26-QN{1'b0}}};
	12'b0001_????_????:float_res_0 = {1'd0,8'd123,res_doutb_0[QN-5:0],{27-QN{1'b0}}};
	12'b0000_1???_????:float_res_0 = {1'd0,8'd122,res_doutb_0[QN-6:0],{28-QN{1'b0}}};
	12'b0000_01??_????:float_res_0 = {1'd0,8'd121,res_doutb_0[QN-7:0],{29-QN{1'b0}}};
	12'b0000_001?_????:float_res_0 = {1'd0,8'd120,res_doutb_0[QN-8:0],{30-QN{1'b0}}};
	12'b0000_0001_????:float_res_0 = {1'd0,8'd119,res_doutb_0[QN-9:0],{31-QN{1'b0}}};
	12'b0000_0000_1???:float_res_0 = {1'd0,8'd118,res_doutb_0[QN-10:0],{32-QN{1'b0}}};
	12'b0000_0000_01??:float_res_0 = {1'd0,8'd117,res_doutb_0[QN-11:0],{33-QN{1'b0}}};
	12'b0000_0000_001?:float_res_0 = {1'd0,8'd116,res_doutb_0[QN-12:0],{34-QN{1'b0}}};
	12'b0000_0000_0001:float_res_0 = {1'd0,8'd115,23'd0};
	12'b0000_0000_0000:float_res_0 = 32'd0;
	default:float_res_0 = 32'd0;
	endcase
end

always @(*)begin 
	casez(res_doutb_1)
	12'b1???_????_????:float_res_1 = {1'd0,8'd126,res_doutb_1[QN-2:0],{24-QN{1'b0}}};
	12'b01??_????_????:float_res_1 = {1'd0,8'd125,res_doutb_1[QN-3:0],{25-QN{1'b0}}};
	12'b001?_????_????:float_res_1 = {1'd0,8'd124,res_doutb_1[QN-4:0],{26-QN{1'b0}}};
	12'b0001_????_????:float_res_1 = {1'd0,8'd123,res_doutb_1[QN-5:0],{27-QN{1'b0}}};
	12'b0000_1???_????:float_res_1 = {1'd0,8'd122,res_doutb_1[QN-6:0],{28-QN{1'b0}}};
	12'b0000_01??_????:float_res_1 = {1'd0,8'd121,res_doutb_1[QN-7:0],{29-QN{1'b0}}};
	12'b0000_001?_????:float_res_1 = {1'd0,8'd120,res_doutb_1[QN-8:0],{30-QN{1'b0}}};
	12'b0000_0001_????:float_res_1 = {1'd0,8'd119,res_doutb_1[QN-9:0],{31-QN{1'b0}}};
	12'b0000_0000_1???:float_res_1 = {1'd0,8'd118,res_doutb_1[QN-10:0],{32-QN{1'b0}}};
	12'b0000_0000_01??:float_res_1 = {1'd0,8'd117,res_doutb_1[QN-11:0],{33-QN{1'b0}}};
	12'b0000_0000_001?:float_res_1 = {1'd0,8'd116,res_doutb_1[QN-12:0],{34-QN{1'b0}}};
	12'b0000_0000_0001:float_res_1 = {1'd0,8'd115,23'd0};
	12'b0000_0000_0000:float_res_1 = 32'd0;
	default:float_res_1 = 32'd0;
	endcase
end

always @(*)begin 
	casez(res_doutb_2)
	12'b1???_????_????:float_res_2 = {1'd0,8'd126,res_doutb_2[QN-2:0],{24-QN{1'b0}}};
	12'b01??_????_????:float_res_2 = {1'd0,8'd125,res_doutb_2[QN-3:0],{25-QN{1'b0}}};
	12'b001?_????_????:float_res_2 = {1'd0,8'd124,res_doutb_2[QN-4:0],{26-QN{1'b0}}};
	12'b0001_????_????:float_res_2 = {1'd0,8'd123,res_doutb_2[QN-5:0],{27-QN{1'b0}}};
	12'b0000_1???_????:float_res_2 = {1'd0,8'd122,res_doutb_2[QN-6:0],{28-QN{1'b0}}};
	12'b0000_01??_????:float_res_2 = {1'd0,8'd121,res_doutb_2[QN-7:0],{29-QN{1'b0}}};
	12'b0000_001?_????:float_res_2 = {1'd0,8'd120,res_doutb_2[QN-8:0],{30-QN{1'b0}}};
	12'b0000_0001_????:float_res_2 = {1'd0,8'd119,res_doutb_2[QN-9:0],{31-QN{1'b0}}};
	12'b0000_0000_1???:float_res_2 = {1'd0,8'd118,res_doutb_2[QN-10:0],{32-QN{1'b0}}};
	12'b0000_0000_01??:float_res_2 = {1'd0,8'd117,res_doutb_2[QN-11:0],{33-QN{1'b0}}};
	12'b0000_0000_001?:float_res_2 = {1'd0,8'd116,res_doutb_2[QN-12:0],{34-QN{1'b0}}};
	12'b0000_0000_0001:float_res_2 = {1'd0,8'd115,23'd0};
	12'b0000_0000_0000:float_res_2 = 32'd0;
	default:float_res_2 = 32'd0;
	endcase
end

always @(*)begin 
	casez(res_doutb_3)
	12'b1???_????_????:float_res_3 = {1'd0,8'd126,res_doutb_3[QN-2:0],{24-QN{1'b0}}};
	12'b01??_????_????:float_res_3 = {1'd0,8'd125,res_doutb_3[QN-3:0],{25-QN{1'b0}}};
	12'b001?_????_????:float_res_3 = {1'd0,8'd124,res_doutb_3[QN-4:0],{26-QN{1'b0}}};
	12'b0001_????_????:float_res_3 = {1'd0,8'd123,res_doutb_3[QN-5:0],{27-QN{1'b0}}};
	12'b0000_1???_????:float_res_3 = {1'd0,8'd122,res_doutb_3[QN-6:0],{28-QN{1'b0}}};
	12'b0000_01??_????:float_res_3 = {1'd0,8'd121,res_doutb_3[QN-7:0],{29-QN{1'b0}}};
	12'b0000_001?_????:float_res_3 = {1'd0,8'd120,res_doutb_3[QN-8:0],{30-QN{1'b0}}};
	12'b0000_0001_????:float_res_3 = {1'd0,8'd119,res_doutb_3[QN-9:0],{31-QN{1'b0}}};
	12'b0000_0000_1???:float_res_3 = {1'd0,8'd118,res_doutb_3[QN-10:0],{32-QN{1'b0}}};
	12'b0000_0000_01??:float_res_3 = {1'd0,8'd117,res_doutb_3[QN-11:0],{33-QN{1'b0}}};
	12'b0000_0000_001?:float_res_3 = {1'd0,8'd116,res_doutb_3[QN-12:0],{34-QN{1'b0}}};
	12'b0000_0000_0001:float_res_3 = {1'd0,8'd115,23'd0};
	12'b0000_0000_0000:float_res_3 = 32'd0;
	default:float_res_3 = 32'd0;
	endcase
end



endmodule