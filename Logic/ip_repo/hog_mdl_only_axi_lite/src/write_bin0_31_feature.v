// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-21 09:19:15
// Author : Liman
// Email  : 944768976@qq.com
// File   : write_bin0_31_feature.v
// Description ：
// Revise : 2023-02-19 13:51:03
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module write_bin0_31_feature #(
	parameter QN 				= 8,
	parameter DELAY 			= 1
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low
	
	//最终输出结果
	input bin0_17_feature_valid,
	input bin18_26_feature_valid,
	input bin27_30_feature_valid,
	input [QN-1:0] bin0_17,
	input [QN-1:0] bin18_26,
	input [QN-1:0] bin27_30,

	//最终结果存放位置，图像缩放部分的bram bank0-3可以分时复用，存入最终的32*32*31*8bit的特征图，每个bank可存放8张特征图
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [12:0]  res_addra_0,//最终特征图结果写入地址
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [12:0]  res_addra_1,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [12:0]  res_addra_2,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [12:0]  res_addra_3,
    (* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [QN-1:0]  res_dina_0,//最终特征图结果写入数据
    (* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [QN-1:0]  res_dina_1,
    (* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [QN-1:0]  res_dina_2,
    (* KEEP = "TRUE" *)(* mark_debug="true" *)output reg [QN-1:0]  res_dina_3,
    output ena_0,
    output ena_1,
    output ena_2,
    output ena_3, 
    (* KEEP = "TRUE" *)(* mark_debug="true" *)output reg wea_0,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg wea_1,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg wea_2,
	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg wea_3,

	(* KEEP = "TRUE" *)(* mark_debug="true" *)output reg write_feature_done//写特征完成

);




localparam WRITE_IDLE 			= 5'd0; 		
localparam WRITE_BANK0 			= 5'd1; 		
localparam WRITE_BANK0_1 		= 5'd2; 	
localparam WRITE_BANK1_3 		= 5'd3; 	
localparam WRITE_BANK1_2_3 		= 5'd4; 	
localparam WRITE_BANK1 			= 5'd5;  	
localparam WRITE_BANK1_2 		= 5'd6; 	
localparam WRITE_BANK2_0 		= 5'd7;
localparam WRITE_BANK2_3_0 		= 5'd8;
localparam WRITE_BANK2 			= 5'd9;
localparam WRITE_BANK2_3 		= 5'd10;
localparam WRITE_BANK3_1 		= 5'd11;
localparam WRITE_BANK3_0_1 		= 5'd12;
localparam WRITE_BANK3 			= 5'd13;
localparam WRITE_BANK3_0 		= 5'd14;
localparam WRITE_BANK0_2 		= 5'd15;
localparam WRITE_BANK0_1_2 		= 5'd16;
//localparam WRITE_BANK3_BIN27_30 = 5'd17;
//localparam WRITE_BANK0_BIN27_30 = 5'd18;
//localparam WRITE_BANK1_BIN27_30 = 5'd19;
localparam WRITE_BANK2_BIN27_30 = 5'd17;
localparam WRITE_WAIT 			= 5'd18;




//cell位于边界时，无feature输出
reg [4:0] bin_count;//记录本cell bin0-17输入个数
reg [9:0] cell_count; //记录输入的cell个数
reg [9:0] cell_count_r1;

reg [4:0] write_cstate,write_nstate;
reg [1:0] bin27_30_count;//记录bin27-30写入的个数

//本cell输入bin0-17个数
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_count <=#DELAY 5'd0;
	end
	else begin 
		if(bin0_17_feature_valid)begin 
			if(bin_count == 5'd17)begin //bin0_17_feature_valid有效，bin_count++，最大为17
				bin_count <=#DELAY 5'd0;
			end   
			else begin 
				bin_count <=#DELAY bin_count + 5'd1;
			end
		end
	end
end

//cell个数
always @(posedge aclk)begin 
	if(!arest_n)begin 
		cell_count <=#DELAY 10'd0;
	end
	else begin 
		if(bin0_17_feature_valid && bin_count == 5'd17)begin //bin17有效时，cell_count++,最大为1023
			cell_count <=#DELAY cell_count + 10'd1;
		end
	end
end

//cell_count跳变时，寄存一级，便于生成bin27-30写地址
always @(posedge aclk)begin 
	if(!arest_n)begin 
		cell_count_r1 <=#DELAY 10'd0;
	end
	else begin 
		if(write_feature_done)begin 
			cell_count_r1 <=#DELAY 10'd0;
		end
		else begin
			if(bin0_17_feature_valid && bin_count == 5'd17)begin 
				cell_count_r1 <=#DELAY cell_count;		
			end
		end
	end
end

assign ena_0 = wea_0;//使能信号与wea同步，同为1时写有效
assign ena_1 = wea_1;
assign ena_2 = wea_2;
assign ena_3 = wea_3;

//FSM
always @(posedge aclk)begin 
	if(!arest_n)begin 
		write_cstate <=#DELAY WRITE_IDLE;
	end
	else begin 
		write_cstate <=#DELAY write_nstate;
	end
end


always @(*)begin 
	write_nstate = write_cstate;
	case(write_cstate)
		WRITE_IDLE:begin 
			if(bin0_17_feature_valid)begin //第一个cell的bin0有效
				write_nstate = WRITE_BANK0;
			end
			else begin 
				write_nstate = WRITE_IDLE;
			end
		end
		WRITE_BANK0:begin 
			write_nstate = WRITE_BANK0_1;
		end
		WRITE_BANK0_1:begin 
			if(bin_count == 5'd0)begin //bin17和bin26写入完毕
				//if(bin0_17_feature_valid)begin //cell不位于右边界
				//	write_nstate = WRITE_BANK1_3;
				//end
				//else begin //cell位于右边界
				//	write_nstate = WRITE_BANK3_BIN27_30;
				//end
				write_nstate = WRITE_BANK1_3;
			end
			else begin //bin17和bin26还未写入
				write_nstate = WRITE_BANK0;
			end
		end
		WRITE_BANK1_3:begin 
			write_nstate = WRITE_BANK1_2_3;
		end
		WRITE_BANK1_2_3:begin 
			if(bin27_30_count == 2'd0)begin //bin30写入完毕
				write_nstate = WRITE_BANK1;
			end
			else begin //bin30还未写入
				write_nstate = WRITE_BANK1_3;
			end
		end
		WRITE_BANK1:begin 
			write_nstate = WRITE_BANK1_2;
		end
		WRITE_BANK1_2:begin 
			if(bin_count == 5'd0)begin //bin17和bin26写入完毕
				//if(bin0_17_feature_valid)begin //cell不位于右边界
				//	write_nstate = WRITE_BANK2_0;
				//end
				//else begin //cell位于右边界
				//	write_nstate = WRITE_BANK0_BIN27_30;
				//end
				write_nstate = WRITE_BANK2_0;
			end
			else begin //bin17和bin26还未写入
				write_nstate = WRITE_BANK1;
			end
		end
		WRITE_BANK2_0:begin 
			write_nstate = WRITE_BANK2_3_0;
		end
		WRITE_BANK2_3_0:begin 
			if(bin27_30_count == 2'd0)begin //bin30写入完毕
				write_nstate = WRITE_BANK2;
			end
			else begin //bin30还未写入
				write_nstate = WRITE_BANK2_0;
			end
		end
		WRITE_BANK2:begin 
			write_nstate = WRITE_BANK2_3;
		end
		WRITE_BANK2_3:begin 
			if(bin_count == 5'd0)begin //bin17和bin26写入完毕
				//if(bin0_17_feature_valid)begin //cell不位于右边界
				//	write_nstate = WRITE_BANK3_1;
				//end
				//else begin //cell位于右边界
				//	write_nstate = WRITE_BANK1_BIN27_30;
				//end
				write_nstate = WRITE_BANK3_1;
			end
			else begin //bin17和bin26还未写入
				write_nstate = WRITE_BANK2;
			end
		end
		WRITE_BANK3_1:begin 
			write_nstate = WRITE_BANK3_0_1;
		end
		WRITE_BANK3_0_1:begin 
			if(bin27_30_count == 2'd0)begin //bin30写入完毕
				write_nstate = WRITE_BANK3;
			end
			else begin //bin30还未写入
				write_nstate = WRITE_BANK3_1;
			end
		end
		WRITE_BANK3:begin 
			write_nstate = WRITE_BANK3_0;
		end
		WRITE_BANK3_0:begin 
			if(bin_count == 5'd0)begin //bin17和bin26写入完毕
				if(bin0_17_feature_valid)begin //cell不位于右边界
					write_nstate = WRITE_BANK0_2;
				end
				else begin //cell位于右边界
					write_nstate = WRITE_BANK2_BIN27_30;
				end
			end
			else begin //bin17和bin26还未写入
				write_nstate = WRITE_BANK3;
			end
		end
		WRITE_BANK0_2:begin 
			write_nstate = WRITE_BANK0_1_2;
		end
		WRITE_BANK0_1_2:begin 
			if(bin27_30_count == 2'd0)begin //bin30写入完毕
				write_nstate = WRITE_BANK0;
			end
			else begin //bin30还未写入
				write_nstate = WRITE_BANK0_2;
			end
		end
		//WRITE_BANK3_BIN27_30:begin 
		//	if(bin27_30_count == 2'd0)begin //cell位于右边界，并且当bin27-30传输完毕
		//		write_nstate = WRITE_WAIT;
		//	end
		//	else begin //cell位于右边界，并且当bin27-30未传输完成
		//		write_nstate = WRITE_BANK3_BIN27_30;
		//	end
		//end
		//WRITE_BANK0_BIN27_30:begin 
		//	if(bin27_30_count == 2'd0)begin //cell位于右边界，并且当bin27-30传输完毕
		//		write_nstate = WRITE_WAIT;
		//	end
		//	else begin //cell位于右边界，并且当bin27-30未传输完成
		//		write_nstate = WRITE_BANK0_BIN27_30;
		//	end
		//end
		//WRITE_BANK1_BIN27_30:begin 
		//	if(bin27_30_count == 2'd0)begin //cell位于右边界，并且当bin27-30传输完毕
		//		write_nstate = WRITE_WAIT;
		//	end
		//	else begin //cell位于右边界，并且当bin27-30未传输完成
		//		write_nstate = WRITE_BANK1_BIN27_30;
		//	end
		//end
		WRITE_BANK2_BIN27_30:begin 
			if(bin27_30_count == 2'd0)begin //cell位于右边界，并且当bin27-30传输完毕
				write_nstate = WRITE_WAIT;
			end
			else begin //cell位于右边界，并且当bin27-30未传输完成
				write_nstate = WRITE_BANK2_BIN27_30;
			end
		end
		WRITE_WAIT:begin 
			if(cell_count == 10'd0)begin //所有cell中的bin传输完毕
				write_nstate = WRITE_IDLE;
			end
			else begin //cell传输未完成
				if(bin0_17_feature_valid)begin //bin0有效
					write_nstate = WRITE_BANK0;
				end
				else begin 
					write_nstate = WRITE_WAIT;
				end
			end
		end
		default:begin 
			write_nstate = WRITE_IDLE;
		end
	endcase // write_cstate
end


always @(posedge aclk)begin 
	if(!arest_n)begin 
		wea_0 <=#DELAY 1'd0;
		wea_1 <=#DELAY 1'd0;
		wea_2 <=#DELAY 1'd0;
		wea_3 <=#DELAY 1'd0;
		res_addra_0 <=#DELAY 13'd0;
		res_addra_1 <=#DELAY 13'd0;
		res_addra_2 <=#DELAY 13'd0;
		res_addra_3 <=#DELAY 13'd0;
		res_dina_0 <=#DELAY 'd0;
		res_dina_1 <=#DELAY 'd0;
		res_dina_2 <=#DELAY 'd0;
		res_dina_3 <=#DELAY 'd0;
		bin27_30_count <=#DELAY 2'd0;
		write_feature_done <=#DELAY 1'd0;
	end
	else begin 
		case(write_nstate)
			WRITE_IDLE:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd0;
				res_addra_0 <=#DELAY 13'd0;
				res_addra_1 <=#DELAY 13'd0;
				res_addra_2 <=#DELAY 13'd0;
				res_addra_3 <=#DELAY 13'd0;
				res_dina_0 <=#DELAY 'd0;
				res_dina_1 <=#DELAY 'd0;
				res_dina_2 <=#DELAY 'd0;
				res_dina_3 <=#DELAY 'd0;
				bin27_30_count <=#DELAY 2'd0;
				write_feature_done <=#DELAY 1'd0;
			end
			WRITE_BANK0:begin 
				wea_0 <=#DELAY 1'd1;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd0;
				if(bin_count == 5'd0)begin 
					res_addra_0 <=#DELAY cell_count[9:2];//bin0
				end
				else begin 
					res_addra_0 <=#DELAY res_addra_0 - 12'h800;//256*8
				end
				res_dina_0 <=#DELAY bin0_17;
			end

			WRITE_BANK0_1:begin 
				wea_0 <=#DELAY 1'd1;
				wea_1 <=#DELAY 1'd1;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd0;
				res_addra_0 <=#DELAY res_addra_0 + 12'h900;//256*9
				res_dina_0 <=#DELAY bin0_17;

				if(bin_count == 5'd1)begin 
					res_addra_1 <=#DELAY cell_count[9:2] + 13'h1200;//256*18
				end
				else begin 
					res_addra_1 <=#DELAY res_addra_1 + 13'h100;//256
				end
				res_dina_1 <=#DELAY bin18_26;
			end
			WRITE_BANK1_3:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd1;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd1;
				if(bin_count == 5'd0)begin 
					res_addra_1 <=#DELAY cell_count[9:2];//bin0
					res_addra_3 <=#DELAY cell_count_r1[9:2] + 13'h1b00;//bin27,初始地址
				end
				else begin 
					res_addra_1 <=#DELAY res_addra_1 - 12'h800;//256*8
					res_addra_3 <=#DELAY res_addra_3 + 13'h100;//256
				end
				res_dina_1 <=#DELAY bin0_17;
				res_dina_3 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
				
			end
			WRITE_BANK1_2_3:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd1;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd1;
				if(bin_count == 5'd1)begin 
					res_addra_2 <=#DELAY cell_count[9:2] + 13'h1200;//bin18
				end
				else begin 
					res_addra_2 <=#DELAY res_addra_2 + 13'h100;//256
				end
				res_addra_1 <=#DELAY res_addra_1 + 12'h900;//256*9
				res_addra_3 <=#DELAY res_addra_3 + 13'h100;//256

				res_dina_1 <=#DELAY bin0_17;
				res_dina_2 <=#DELAY bin18_26;
				res_dina_3 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
			WRITE_BANK1:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd1;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd0;
				if(bin_count == 5'd0)begin 
					res_addra_1 <=#DELAY cell_count[9:2];//bin0
				end
				else begin 
					res_addra_1 <=#DELAY res_addra_1 - 12'h800;//256*8
				end
				res_dina_1 <=#DELAY bin0_17;
			end
			WRITE_BANK1_2:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd1;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd0;
				res_addra_1 <=#DELAY res_addra_1 + 12'h900;//256*9
				res_dina_1 <=#DELAY bin0_17;

				if(bin_count == 5'd1)begin 
					res_addra_2 <=#DELAY cell_count[9:2] + 13'h1200;//256*18
				end
				else begin 
					res_addra_2 <=#DELAY res_addra_2 + 13'h100;//256
				end
				res_dina_2 <=#DELAY bin18_26;
			end
			WRITE_BANK2_0:begin 
				wea_0 <=#DELAY 1'd1;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd0;
				if(bin_count == 5'd0)begin 
					res_addra_2 <=#DELAY cell_count[9:2];//bin0
					res_addra_0 <=#DELAY cell_count_r1[9:2] + 13'h1b00;//bin27,初始地址
				end
				else begin 
					res_addra_2 <=#DELAY res_addra_2 - 12'h800;//256*8
					res_addra_0 <=#DELAY res_addra_0 + 13'h100;//256
				end
				res_dina_2 <=#DELAY bin0_17;
				res_dina_0 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
			WRITE_BANK2_3_0:begin 
				wea_0 <=#DELAY 1'd1;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd1;
				if(bin_count == 5'd1)begin 
					res_addra_3 <=#DELAY cell_count[9:2] + 13'h1200;//bin18
				end
				else begin 
					res_addra_3 <=#DELAY res_addra_3 + 13'h100;//256
				end
				res_addra_2 <=#DELAY res_addra_2 + 12'h900;//256*9
				res_addra_0 <=#DELAY res_addra_0 + 13'h100;//256

				res_dina_2 <=#DELAY bin0_17;
				res_dina_3 <=#DELAY bin18_26;
				res_dina_0 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
			WRITE_BANK2:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd0;
				if(bin_count == 5'd0)begin 
					res_addra_2 <=#DELAY cell_count[9:2];//bin0
				end
				else begin 
					res_addra_2 <=#DELAY res_addra_2 - 12'h800;//256*8
				end
				res_dina_2 <=#DELAY bin0_17;
			end
			WRITE_BANK2_3:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd1;
				res_addra_2 <=#DELAY res_addra_2 + 12'h900;//256*9
				res_dina_2 <=#DELAY bin0_17;

				if(bin_count == 5'd1)begin 
					res_addra_3 <=#DELAY cell_count[9:2] + 13'h1200;//256*18
				end
				else begin 
					res_addra_3 <=#DELAY res_addra_3 + 13'h100;//256
				end
				res_dina_3 <=#DELAY bin18_26;
			end
			WRITE_BANK3_1:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd1;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd1;
				if(bin_count == 5'd0)begin 
					res_addra_3 <=#DELAY cell_count[9:2];//bin0
					res_addra_1 <=#DELAY cell_count_r1[9:2] + 13'h1b00;//bin27,初始地址
				end
				else begin 
					res_addra_3 <=#DELAY res_addra_3 - 12'h800;//256*8
					res_addra_1 <=#DELAY res_addra_1 + 13'h100;//256
				end
				res_dina_3 <=#DELAY bin0_17;
				res_dina_1 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
			WRITE_BANK3_0_1:begin 
				wea_0 <=#DELAY 1'd1;
				wea_1 <=#DELAY 1'd1;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd1;
				if(bin_count == 5'd1)begin 
					res_addra_0 <=#DELAY cell_count[9:2] + 13'h1200;//bin18
				end
				else begin 
					res_addra_0 <=#DELAY res_addra_0 + 13'h100;//256
				end
				res_addra_3 <=#DELAY res_addra_3 + 12'h900;//256*9
				res_addra_1 <=#DELAY res_addra_1 + 13'h100;//256

				res_dina_3 <=#DELAY bin0_17;
				res_dina_0 <=#DELAY bin18_26;
				res_dina_1 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
			WRITE_BANK3:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd1;
				if(bin_count == 5'd0)begin 
					res_addra_3 <=#DELAY cell_count[9:2];//bin0
				end
				else begin 
					res_addra_3 <=#DELAY res_addra_3 - 12'h800;//256*8
				end
				res_dina_3 <=#DELAY bin0_17;
			end
			WRITE_BANK3_0:begin 
				wea_0 <=#DELAY 1'd1;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd1;
				res_addra_3 <=#DELAY res_addra_3 + 12'h900;//256*9
				res_dina_3 <=#DELAY bin0_17;

				if(bin_count == 5'd1)begin 
					res_addra_0 <=#DELAY cell_count[9:2] + 13'h1200;//256*18
				end
				else begin 
					res_addra_0 <=#DELAY res_addra_0 + 13'h100;//256
				end
				res_dina_0 <=#DELAY bin18_26;
			end
			WRITE_BANK0_2:begin 
				wea_0 <=#DELAY 1'd1;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd0;
				if(bin_count == 5'd0)begin 
					res_addra_0 <=#DELAY cell_count[9:2];//bin0
					res_addra_2 <=#DELAY cell_count_r1[9:2] + 13'h1b00;//bin27,初始地址
				end
				else begin 
					res_addra_0 <=#DELAY res_addra_0 - 12'h800;//256*8
					res_addra_2 <=#DELAY res_addra_2 + 13'h100;//256
				end
				res_dina_0 <=#DELAY bin0_17;
				res_dina_2 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
			WRITE_BANK0_1_2:begin 
				wea_0 <=#DELAY 1'd1;
				wea_1 <=#DELAY 1'd1;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd0;
				if(bin_count == 5'd1)begin 
					res_addra_1 <=#DELAY cell_count[9:2] + 13'h1200;//bin18
				end
				else begin 
					res_addra_1 <=#DELAY res_addra_1 + 13'h100;//256
				end
				res_addra_0 <=#DELAY res_addra_0 + 12'h900;//256*9
				res_addra_2 <=#DELAY res_addra_2 + 13'h100;//256

				res_dina_0 <=#DELAY bin0_17;
				res_dina_1 <=#DELAY bin18_26;
				res_dina_2 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
			WRITE_BANK2_BIN27_30:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd1;
				wea_3 <=#DELAY 1'd0;
				if(bin27_30_count == 2'd0)begin 
					res_addra_2 <=#DELAY cell_count_r1[9:2] + 13'h1b00;//bin27,初始地址
				end
				else begin 
					res_addra_2 <=#DELAY res_addra_2 + 13'h100;//256
				end
				res_dina_2 <=#DELAY bin27_30;
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
			WRITE_WAIT:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd0;
				if(cell_count == 10'd0)begin 
					write_feature_done <=#DELAY 1'd1;
				end
			end
			default:begin 
				wea_0 <=#DELAY 1'd0;
				wea_1 <=#DELAY 1'd0;
				wea_2 <=#DELAY 1'd0;
				wea_3 <=#DELAY 1'd0;
				res_addra_0 <=#DELAY 13'd0;
				res_addra_1 <=#DELAY 13'd0;
				res_addra_2 <=#DELAY 13'd0;
				res_addra_3 <=#DELAY 13'd0;
				res_dina_0 <=#DELAY 'd0;
				res_dina_1 <=#DELAY 'd0;
				res_dina_2 <=#DELAY 'd0;
				res_dina_3 <=#DELAY 'd0;
				bin27_30_count <=#DELAY 2'd0;
				write_feature_done <=#DELAY 1'd0;
			end
		endcase // write_nstate
	end
end





endmodule