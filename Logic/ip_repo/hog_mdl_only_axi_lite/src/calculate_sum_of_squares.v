// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : yongchan jeon (Kris) poucotm@gmail.com
// File   : calculate_sum_of_squares.v
// Create : 2022-10-17 09:24:21
// Revise : 2022-10-18 09:49:31
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module calculate_sum_of_squares #(
	parameter QN 				= 8,
	parameter TOTAL_BIT_WIDTH 	= 35,
	parameter DELAY 			= 1
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low

	output [12:0] normal_addra_0,//归一化，a读端口，读出bin值进行平方和累加
	output [12:0] normal_addra_1,
	output [12:0] normal_addra_2,
	output [12:0] normal_addra_3,
	input [TOTAL_BIT_WIDTH-1 : 0] douta_0,
	input [TOTAL_BIT_WIDTH-1 : 0] douta_1,
	input [TOTAL_BIT_WIDTH-1 : 0] douta_2,
	input [TOTAL_BIT_WIDTH-1 : 0] douta_3,


	//output [12:0] normal_addrb_0,//归一化，b读端口，读出bin值进行归一化、pca降维的计算，四路累加得到最终的特征值
	//output [12:0] normal_addrb_1,
	//output [12:0] normal_addrb_2,
	//output [12:0] normal_addrb_3,
	//input [TOTAL_BIT_WIDTH-1 : 0] doutb_0,
	//input [TOTAL_BIT_WIDTH-1 : 0] doutb_1,
	//input [TOTAL_BIT_WIDTH-1 : 0] doutb_2,
	//input [TOTAL_BIT_WIDTH-1 : 0] doutb_3,

	input histogram_done,//当最后一次写操作将intensity写入b端口，产生1周期done信号

	output reg sos_valid,//每个cell中的bin18-26的平方和有效
	output reg [TOTAL_BIT_WIDTH-1:0] sum_of_squares//每个cell中的bin18-26的平方和
	////最终结果存放位置，图像缩放部分的bram bank0-3可以分时复用，存入最终的32*32*31*8bit的特征图，每个bank可存放8张特征图
	//output   [12:0]  res_addra_0,//最终特征图结果写入地址
	//output   [12:0]  res_addra_1,
	//output   [12:0]  res_addra_2,
	//output   [12:0]  res_addra_3,
    //output   [7:0]  res_dina_0,//最终特征图结果写入数据
    //output   [7:0]  res_dina_1,
    //output   [7:0]  res_dina_2,
    //output   [7:0]  res_dina_3,
    //output   ena_0,
    //output   ena_1,
    //output   ena_2,
    //output   ena_3,
    //output   wea_0,
	//output   wea_1,
	//output   wea_2,
	//output   wea_3
	
);


//localparam RD_BIN_IDLE = 3'd0;
//localparam RD_BIN_BANK0 = 3'd1;
//localparam RD_BIN_BANK1 = 3'd2;
//localparam RD_BIN_BANK2 = 3'd3;
//localparam RD_BIN_BANK3 = 3'd4;


//按照逐行逐列顺序读取cell中bin0-17：先读bin0、bin9，bin1、bin10......
//reg0
//reg [2:0] rd_bin_cstate,rd_bin_nstate;
//reg [5:0] cell_row;//记录目前正在读出的cell row
//reg [5:0] cell_col;//记录目前正在读出的cell col
//reg [4:0] bin_count;//记录目前正在读出cell的bin值情况
//reg bank_start_0;//bank0第一次读
//reg bank_start_1;
//reg bank_start_2;
//reg bank_start_3;
//reg bank_addr_valid_0;//bank0读有效
//reg bank_addr_valid_1;
//reg bank_addr_valid_2;
//reg bank_addr_valid_3;

//reg1
//reg data_valid_0;
//reg data_valid_1;
//reg data_valid_2;
//reg data_valid_3;
wire bin_data_valid;
wire [TOTAL_BIT_WIDTH-1:0] bin_data;
//reg0、reg1封装成read_cell_bin.v

//reg2
reg bin_data_valid_count;
reg [TOTAL_BIT_WIDTH-1:0] bin_data_r1;
wire bin_0_9_add_valid;//当bin0-17中，与原点对称的两个bin_data都读出时，有效
//reg3
reg bin_18_26_valid;//对称的两个bin_data相加后有效
reg [TOTAL_BIT_WIDTH-1:0] bin_18_26_data;
//reg4
reg bin_mul_valid;//bin_data18-26 * bin_data18-26
wire [TOTAL_BIT_WIDTH*2-1:0] bin_data_mul;
//reg5 
reg [3:0] add_sos_count;//平方和累加计数
//reg [TOTAL_BIT_WIDTH-1:0] sum_of_squares;
//reg sos_valid;//9次平方和累加数据有效
//reg6进行行缓存，构建3*3窗口




//////reg0、reg1
//按照顺序读取cell中的bin值
read_aport_cell_bin #(
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.DELAY(DELAY)
	) inst_read_cell_bin (
		.aclk           (aclk),
		.arest_n        (arest_n),
		.normal_addr_0 (normal_addra_0),
		.normal_addr_1 (normal_addra_1),
		.normal_addr_2 (normal_addra_2),
		.normal_addr_3 (normal_addra_3),
		.dout_0        (douta_0),
		.dout_1        (douta_1),
		.dout_2        (douta_2),
		.dout_3        (douta_3),
		.histogram_done     (histogram_done),
		.bin_data_valid (bin_data_valid),
		.bin_data       (bin_data)
	);



//////reg2
always @(posedge aclk)begin //寄存bin_data,用于后续的关于原点对称的bin相加
	if(!arest_n)begin 
		bin_data_r1 <=#DELAY 'd0;
	end
	else begin 
		bin_data_r1 <=#DELAY bin_data;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_data_valid_count <=#DELAY 1'd0;
	end
	else begin 
		if(bin_data_valid)begin //bin_data有效，奇数次bin_data_valid_count为1，偶数次bin_data_valid_count为0
			bin_data_valid_count <=#DELAY ~bin_data_valid_count;
		end
	end
end

assign bin_0_9_add_valid = bin_data_valid & bin_data_valid_count;

//////reg3
//得到bin18——26
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_18_26_valid <=#DELAY 1'd0;
	end
	else begin 
		bin_18_26_valid <=#DELAY bin_0_9_add_valid;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_18_26_data <=#DELAY 'd0;
	end
	else begin 
		bin_18_26_data <=#DELAY bin_data_r1 + bin_data;
	end
end
//////reg4
//求bin18-26的平方
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_mul_valid <=#DELAY 1'd0;
	end
	else begin 
		bin_mul_valid <=#DELAY bin_18_26_valid;
	end
end

mult_gen_0 bin18_26_data_mul (
  .CLK(aclk),  // input wire CLK
  .A(bin_18_26_data),      // input wire [34 : 0] A
  .B(bin_18_26_data),      // input wire [34 : 0] B
  .P(bin_data_mul)      // output wire [69 : 0] P
);
//////reg5
//求bin18-26的平方和
always @(posedge aclk)begin 
	if(!arest_n)begin 
		add_sos_count <=#DELAY 4'd0;
		sum_of_squares <=#DELAY 'd0;
	end
	else begin 
		if(bin_mul_valid)begin 
			if(add_sos_count == 4'd0)begin //当求和对象为本cell中的bin18时
				sum_of_squares <=#DELAY bin_data_mul[TOTAL_BIT_WIDTH+QN-1:QN];
				add_sos_count <=#DELAY add_sos_count + 4'd1;
			end
			else begin //不是bin18，则累加
				sum_of_squares <=#DELAY sum_of_squares + bin_data_mul[TOTAL_BIT_WIDTH+QN-1:QN];
				if(add_sos_count == 4'd8)begin //累计次数计数，当为第9次时，归零
					add_sos_count <=#DELAY 4'd0;
				end
				else begin //不是第9次时，add_sos_count++
					add_sos_count <=#DELAY add_sos_count + 4'd1;
				end
			end
		end
	end
end

always @(posedge aclk)begin //产生bin18-26平方和数据有效
	if(!arest_n)begin 
		sos_valid <=#DELAY 1'd0;
	end
	else begin 
		if(bin_mul_valid && add_sos_count == 4'd8)begin 
			sos_valid <=#DELAY 1'd1;
		end
		else begin 
			sos_valid <=#DELAY 1'd0;
		end
	end
end

//////reg6
//写入寄存器与行缓存，构造3*3窗口





endmodule