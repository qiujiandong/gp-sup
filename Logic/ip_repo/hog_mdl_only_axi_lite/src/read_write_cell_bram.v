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
// File   : read_write_cell_bram.v
// Create : 2022-10-12 16:21:25
// Revise : 2023-04-25 11:34:21
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module read_write_cell_bram #(
	parameter TOTAL_BIT_WIDTH = 35,
	parameter DELAY = 1
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low
	
	input [4:0] bin_num,
	input bin_num_valid,
	
	input [7:0] mod_row,
	input [7:0] mod_col,

	input [TOTAL_BIT_WIDTH-1:0] intensity_0,
	input [TOTAL_BIT_WIDTH-1:0] intensity_1,
	input [TOTAL_BIT_WIDTH-1:0] intensity_2,
	input [TOTAL_BIT_WIDTH-1:0] intensity_3,
	input intensity_valid,

	input [12:0] normal_addra_0,
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
	output [TOTAL_BIT_WIDTH-1 : 0] doutb_3,

	//input initial_cell_bram,//上电和每次特征图结果写入到输入缓存后，对直方图bram初始化
	input write_feature_done,//写特征图到缓存后，开始初始化直方图bram
	output reg hog_ready,//直方图bram初始化ready，图像缩放可以开始新一帧操作
	output reg histogram_done//当最后一次写操作将intensity写入b端口，产生1周期done信号

);

wire  wea_0;
wire [12 : 0] addra_0;
wire [TOTAL_BIT_WIDTH-1 : 0] dina_0;
//wire [TOTAL_BIT_WIDTH-1 : 0] douta_0;
wire  web_0;
wire [12 : 0] addrb_0;
wire [TOTAL_BIT_WIDTH-1 : 0] dinb_0;
//wire [TOTAL_BIT_WIDTH-1 : 0] doutb_0;

wire  wea_1;
wire [12 : 0] addra_1;
wire [TOTAL_BIT_WIDTH-1 : 0] dina_1;
//wire [TOTAL_BIT_WIDTH-1 : 0] douta_1;
wire  web_1;
wire [12 : 0] addrb_1;
wire [TOTAL_BIT_WIDTH-1 : 0] dinb_1;
//wire [TOTAL_BIT_WIDTH-1 : 0] doutb_1;

wire  wea_2;
wire [12 : 0] addra_2;
wire [TOTAL_BIT_WIDTH-1 : 0] dina_2;
//wire [TOTAL_BIT_WIDTH-1 : 0] douta_2;
wire  web_2;
wire [12 : 0] addrb_2;
wire [TOTAL_BIT_WIDTH-1 : 0] dinb_2;
//wire [TOTAL_BIT_WIDTH-1 : 0] doutb_2;

wire  wea_3;
wire [12 : 0] addra_3;
wire [TOTAL_BIT_WIDTH-1 : 0] dina_3;
//wire [TOTAL_BIT_WIDTH-1 : 0] douta_3;
wire  web_3;
wire [12 : 0] addrb_3;
wire [TOTAL_BIT_WIDTH-1 : 0] dinb_3;
//wire [TOTAL_BIT_WIDTH-1 : 0] doutb_3;

reg addra_valid_0;
reg addra_valid_1;
reg addra_valid_2;
reg addra_valid_3;

reg addra_valid_0_r1;
reg addra_valid_1_r1;
reg addra_valid_2_r1;
reg addra_valid_3_r1;

//临时存储
//reg [12:0] addr_0;
//reg [12:0] addr_1;
//reg [12:0] addr_2;
//reg [12:0] addr_3;
//reg addr_valid_0;
//reg addr_valid_1;
//reg addr_valid_2;
//reg addr_valid_3;
reg [12:0] addr1;
reg [12:0] addr2;
reg [12:0] addr3;
reg [12:0] addr4;
reg [12:0] addr5;
reg [12:0] addr6;
reg [12:0] addr7;
reg [12:0] addr8;
reg [12:0] addr9;
reg [12:0] addr_temp;

wire  addr1_valid;
wire  addr2_valid;
wire  addr3_valid;
wire  addr4_valid;
wire  addr5_valid;
wire  addr6_valid;
wire  addr7_valid;
wire  addr8_valid;
wire  addr9_valid;
//histogram 下a端口的读地址
reg [12:0] hist_addra_0;
reg [12:0] hist_addra_1;
reg [12:0] hist_addra_2;
reg [12:0] hist_addra_3;

//hsitogram下b端口的写地址

reg [12:0] hist_addrb_0;
reg [12:0] hist_addrb_1;
reg [12:0] hist_addrb_2;
reg [12:0] hist_addrb_3;

reg [TOTAL_BIT_WIDTH-1:0] hist_dinb_0;
reg [TOTAL_BIT_WIDTH-1:0] hist_dinb_1;
reg [TOTAL_BIT_WIDTH-1:0] hist_dinb_2;
reg [TOTAL_BIT_WIDTH-1:0] hist_dinb_3;

wire [5:0] mod_cell_row;//cell所在的行值
wire [5:0] mod_cell_col;//cell所在的列值
wire [1:0] mod_cell_in_row;//vec_mod在cell内部的行值
wire [1:0] mod_cell_in_col;//vec_mod在cell内部的列值

reg [5:0] mod_cell_row_r1;//cell所在的行值r1
reg [5:0] mod_cell_col_r1;//cell所在的列值r1
//initial cell bram,当置1时，将cell bram 初始化为0
reg initial_bram;
//reg [12:0] initial_count;
reg [12:0] initial_addrb;
reg [12:0] initial_addra;

//
reg initial_cell_bram;

//230220 add bram bypass，当同一周期对bram的a、b端口进行读写时，需要旁路
reg bram_bypass_en;
reg [12:0] hist_addrb_0_r1;
reg [12:0] hist_addrb_1_r1;
reg [12:0] hist_addrb_2_r1;
reg [12:0] hist_addrb_3_r1;
reg [TOTAL_BIT_WIDTH-1:0] hist_dinb_0_r1;
reg [TOTAL_BIT_WIDTH-1:0] hist_dinb_1_r1;
reg [TOTAL_BIT_WIDTH-1:0] hist_dinb_2_r1;
reg [TOTAL_BIT_WIDTH-1:0] hist_dinb_3_r1;



//进行histogram时，a作为读端口，b作为写端口
//进行normallization时，a作为读端口，b作为读端口
//进行初始化时，ab都作为写端口
assign wea_0 = initial_bram ? 1'd1 : 1'd0;
assign wea_1 = initial_bram ? 1'd1 : 1'd0;
assign wea_2 = initial_bram ? 1'd1 : 1'd0;
assign wea_3 = initial_bram ? 1'd1 : 1'd0;

assign dina_0 = 'd0;
assign dina_1 = 'd0;
assign dina_2 = 'd0;
assign dina_3 = 'd0;

assign addra_0 = initial_bram ? initial_addra : (bin_num_valid ? hist_addra_0 : normal_addra_0);
assign addra_1 = initial_bram ? initial_addra : (bin_num_valid ? hist_addra_1 : normal_addra_1);
assign addra_2 = initial_bram ? initial_addra : (bin_num_valid ? hist_addra_2 : normal_addra_2);
assign addra_3 = initial_bram ? initial_addra : (bin_num_valid ? hist_addra_3 : normal_addra_3);
//b端口写使能：初始化bram或者进行histogram
assign web_0 = (intensity_valid | initial_bram) ? 1'd1 : 1'd0;
assign web_1 = (intensity_valid | initial_bram) ? 1'd1 : 1'd0;
assign web_2 = (intensity_valid | initial_bram) ? 1'd1 : 1'd0;
assign web_3 = (intensity_valid | initial_bram) ? 1'd1 : 1'd0;
//b端口地址：写地址：初始化或者histogram 读地址：normalization
assign addrb_0 = initial_bram ? initial_addrb : (intensity_valid ? hist_addrb_0 : normal_addrb_0);
assign addrb_1 = initial_bram ? initial_addrb : (intensity_valid ? hist_addrb_1 : normal_addrb_1);
assign addrb_2 = initial_bram ? initial_addrb : (intensity_valid ? hist_addrb_2 : normal_addrb_2);
assign addrb_3 = initial_bram ? initial_addrb : (intensity_valid ? hist_addrb_3 : normal_addrb_3);
//b端口写数据：初始化或者histogram
assign dinb_0 = initial_bram ? 'd0 : hist_dinb_0;
assign dinb_1 = initial_bram ? 'd0 : hist_dinb_1;
assign dinb_2 = initial_bram ? 'd0 : hist_dinb_2;
assign dinb_3 = initial_bram ? 'd0 : hist_dinb_3;

//产生读取bank的地址

assign mod_cell_row = mod_row[7:2];//mod所在cell的行
assign mod_cell_col = mod_col[7:2];//mod所在cell的列
assign mod_cell_in_row = mod_row[1:0];//mod所在cell内部的行
assign mod_cell_in_col = mod_col[1:0];//mod所在cell内部的列

/////////////产生a读端口的addra
//方法2
//求出pixel所在cell以及周围一圈总共9个cell的地址
always @(*)begin 
	addr_temp = (mod_cell_row[5:1] << 4) + mod_cell_row[5:1] + mod_cell_col[5:1];
	addr5 = (addr_temp << 4) + (addr_temp << 1) + bin_num;//本身cell

	case({mod_cell_row[0],mod_cell_col[0]})//判断本身额所在cell的odd、even
		2'b00:begin //even,even
			addr1 = addr5 - 13'd18;//1cell
			addr2 = addr5;
			addr3 = addr5;
			addr4 = addr5 - 13'd18;//1cell
			addr6 = addr5;
			addr7 = addr5 - 13'd324;//17+1 cell
			addr8 = addr5 - 13'd306;//17cell
			addr9 = addr5 - 13'd306;//17cell
		end
		2'b01:begin //even,odd
			addr1 = addr5;
			addr2 = addr5;
			addr3 = addr5 + 13'd18;//1cell
			addr4 = addr5;
			addr6 = addr5 + 13'd18;//1cell
			addr7 = addr5 - 13'd306;//17cell
			addr8 = addr5 - 13'd306;//17cell
			addr9 = addr5 - 13'd288;//16cell
		end
		2'b10:begin //odd,even
			addr1 = addr5 + 13'd288;//16cell
			addr2 = addr5 + 13'd306;//17cell
			addr3 = addr5 + 13'd306;//17cell
			addr4 = addr5 - 13'd18;//1cell
			addr6 = addr5;
			addr7 = addr5 - 13'd18;//1cell
			addr8 = addr5;
			addr9 = addr5;
		end
		2'b11:begin //odd,odd
			addr1 = addr5 + 13'd306;//17cell
			addr2 = addr5 + 13'd306;//17cell
			addr3 = addr5 + 13'd324;//18cell
			addr4 = addr5;
			addr6 = addr5 + 13'd18;//1cell
			addr7 = addr5;
			addr8 = addr5;
			addr9 = addr5 + 13'd18;//1cell
		end
		default:begin 
			addr1 = 13'd0;
			addr2 = 13'd0;
			addr3 = 13'd0;
			addr4 = 13'd0;
			addr6 = 13'd0;
			addr7 = 13'd0;
			addr8 = 13'd0;
			addr9 = 13'd0;
		end
	endcase // mod_cell_row[0],mod_cell_col[0]
end

//考虑边界情况，判断pixel所在cell周围的8个cell地址是否有效
assign addr1_valid = (mod_cell_row < 6'd33 && mod_cell_col > 0) ? 1'd1 : 1'd0;
assign addr2_valid = (mod_cell_row < 6'd33) ? 1'd1 : 1'd0;
assign addr3_valid = (mod_cell_row < 6'd33 && mod_cell_col < 6'd33) ? 1'd1 : 1'd0;
assign addr4_valid = (mod_cell_col > 6'd0) ? 1'd1 : 1'd0;
assign addr5_valid = 1'd1;
assign addr6_valid = (mod_cell_col < 6'd33) ? 1'd1 : 1'd0;
assign addr7_valid = (mod_cell_row > 6'd0 && mod_cell_col > 6'd0) ? 1'd1 : 1'd0;
assign addr8_valid = (mod_cell_row > 6'd0) ? 1'd1 : 1'd0;
assign addr9_valid = (mod_cell_row > 6'd0 && mod_cell_col < 6'd33) ? 1'd1 : 1'd0;


//产生histogram_addra
always @(*)begin 
	case({mod_cell_in_row[1],mod_cell_in_col[1]})//判断pixel在cell内部的哪个角
		2'b00:begin //左上角
			case({mod_cell_row[0],mod_cell_col[0]})//判断cell：4、5、7、8归属哪个bank
				2'b00:begin 
					addra_valid_0 = addr7_valid;
					hist_addra_0 = addr7;

					addra_valid_1 = addr8_valid;
					hist_addra_1 = addr8;

					addra_valid_2 = addr4_valid;
					hist_addra_2 = addr4;

					addra_valid_3 = addr5_valid;
					hist_addra_3 = addr5;

				end
				2'b01:begin 
					addra_valid_0 = addr8_valid;
					hist_addra_0 = addr8;

					addra_valid_1 = addr7_valid;
					hist_addra_1 = addr7;

					addra_valid_2 = addr5_valid;
					hist_addra_2 = addr5;

					addra_valid_3 = addr4_valid;
					hist_addra_3 = addr4;
				end
				2'b10:begin 
					addra_valid_0 = addr4_valid;
					hist_addra_0 = addr4;

					addra_valid_1 = addr5_valid;
					hist_addra_1 = addr5;

					addra_valid_2 = addr7_valid;
					hist_addra_2 = addr7;

					addra_valid_3 = addr8_valid;
					hist_addra_3 = addr8;
				end
				2'b11:begin 
					addra_valid_0 = addr5_valid;
					hist_addra_0 = addr5;

					addra_valid_1 = addr4_valid;
					hist_addra_1 = addr4;

					addra_valid_2 = addr8_valid;
					hist_addra_2 = addr8;

					addra_valid_3 = addr7_valid;
					hist_addra_3 = addr7;
				end
				default:begin 
					hist_addra_0 = 13'd0;
					addra_valid_0 = 1'd0;
					hist_addra_1 = 13'd0;
					addra_valid_1 = 1'd0;
					hist_addra_2 = 13'd0;
					addra_valid_2 = 1'd0;
					hist_addra_3 = 13'd0;
					addra_valid_3 = 1'd0;
				end
			endcase // {mod_cell_row[0],mod_cell_col[0]}
		end
		2'b01:begin //右上角
			case({mod_cell_row[0],mod_cell_col[0]})//判断cell：5、6、8、9归属哪个bank
				2'b00:begin 
					addra_valid_0 = addr9_valid;
					hist_addra_0 = addr9;

					addra_valid_1 = addr8_valid;
					hist_addra_1 = addr8;

					addra_valid_2 = addr6_valid;
					hist_addra_2 = addr6;

					addra_valid_3 = addr5_valid;
					hist_addra_3 = addr5;

				end
				2'b01:begin 
					addra_valid_0 = addr8_valid;
					hist_addra_0 = addr8;

					addra_valid_1 = addr9_valid;
					hist_addra_1 = addr9;

					addra_valid_2 = addr5_valid;
					hist_addra_2 = addr5;

					addra_valid_3 = addr6_valid;
					hist_addra_3 = addr6;
				end
				2'b10:begin 
					addra_valid_0 = addr6_valid;
					hist_addra_0 = addr6;

					addra_valid_1 = addr5_valid;
					hist_addra_1 = addr5;

					addra_valid_2 = addr9_valid;
					hist_addra_2 = addr9;

					addra_valid_3 = addr8_valid;
					hist_addra_3 = addr8;
				end
				2'b11:begin 
					addra_valid_0 = addr5_valid;
					hist_addra_0 = addr5;

					addra_valid_1 = addr6_valid;
					hist_addra_1 = addr6;

					addra_valid_2 = addr8_valid;
					hist_addra_2 = addr8;

					addra_valid_3 = addr9_valid;
					hist_addra_3 = addr9;
				end
				default:begin 
					hist_addra_0 = 13'd0;
					addra_valid_0 = 1'd0;
					hist_addra_1 = 13'd0;
					addra_valid_1 = 1'd0;
					hist_addra_2 = 13'd0;
					addra_valid_2 = 1'd0;
					hist_addra_3 = 13'd0;
					addra_valid_3 = 1'd0;
				end
			endcase // {mod_cell_row[0],mod_cell_col[0]}
		end
		2'b10:begin //左下角
			case({mod_cell_row[0],mod_cell_col[0]})//判断cell：1、2、4、5归属哪个bank
				2'b00:begin 
					addra_valid_0 = addr1_valid;
					hist_addra_0 = addr1;

					addra_valid_1 = addr2_valid;
					hist_addra_1 = addr2;

					addra_valid_2 = addr4_valid;
					hist_addra_2 = addr4;

					addra_valid_3 = addr5_valid;
					hist_addra_3 = addr5;

				end
				2'b01:begin 
					addra_valid_0 = addr2_valid;
					hist_addra_0 = addr2;

					addra_valid_1 = addr1_valid;
					hist_addra_1 = addr1;

					addra_valid_2 = addr5_valid;
					hist_addra_2 = addr5;

					addra_valid_3 = addr4_valid;
					hist_addra_3 = addr4;
				end
				2'b10:begin 
					addra_valid_0 = addr4_valid;
					hist_addra_0 = addr4;

					addra_valid_1 = addr5_valid;
					hist_addra_1 = addr5;

					addra_valid_2 = addr1_valid;
					hist_addra_2 = addr1;

					addra_valid_3 = addr2_valid;
					hist_addra_3 = addr2;
				end
				2'b11:begin 
					addra_valid_0 = addr5_valid;
					hist_addra_0 = addr5;

					addra_valid_1 = addr4_valid;
					hist_addra_1 = addr4;

					addra_valid_2 = addr2_valid;
					hist_addra_2 = addr2;

					addra_valid_3 = addr1_valid;
					hist_addra_3 = addr1;
				end
				default:begin 
					hist_addra_0 = 13'd0;
					addra_valid_0 = 1'd0;
					hist_addra_1 = 13'd0;
					addra_valid_1 = 1'd0;
					hist_addra_2 = 13'd0;
					addra_valid_2 = 1'd0;
					hist_addra_3 = 13'd0;
					addra_valid_3 = 1'd0;
				end
			endcase // {mod_cell_row[0],mod_cell_col[0]}
		end
		2'b11:begin //右下角
			case({mod_cell_row[0],mod_cell_col[0]})//判断cell：2、3、5、6归属哪个bank
				2'b00:begin 
					addra_valid_0 = addr3_valid;
					hist_addra_0 = addr3;

					addra_valid_1 = addr2_valid;
					hist_addra_1 = addr2;

					addra_valid_2 = addr6_valid;
					hist_addra_2 = addr6;

					addra_valid_3 = addr5_valid;
					hist_addra_3 = addr5;

				end
				2'b01:begin 
					addra_valid_0 = addr2_valid;
					hist_addra_0 = addr2;

					addra_valid_1 = addr3_valid;
					hist_addra_1 = addr3;

					addra_valid_2 = addr5_valid;
					hist_addra_2 = addr5;

					addra_valid_3 = addr6_valid;
					hist_addra_3 = addr6;
				end
				2'b10:begin 
					addra_valid_0 = addr6_valid;
					hist_addra_0 = addr6;

					addra_valid_1 = addr5_valid;
					hist_addra_1 = addr5;

					addra_valid_2 = addr3_valid;
					hist_addra_2 = addr3;

					addra_valid_3 = addr2_valid;
					hist_addra_3 = addr2;
				end
				2'b11:begin 
					addra_valid_0 = addr5_valid;
					hist_addra_0 = addr5;

					addra_valid_1 = addr6_valid;
					hist_addra_1 = addr6;

					addra_valid_2 = addr2_valid;
					hist_addra_2 = addr2;

					addra_valid_3 = addr3_valid;
					hist_addra_3 = addr3;
				end
				default:begin 
					hist_addra_0 = 13'd0;
					addra_valid_0 = 1'd0;
					hist_addra_1 = 13'd0;
					addra_valid_1 = 1'd0;
					hist_addra_2 = 13'd0;
					addra_valid_2 = 1'd0;
					hist_addra_3 = 13'd0;
					addra_valid_3 = 1'd0;
				end
			endcase // {mod_cell_row[0],mod_cell_col[0]}
		end
	endcase // {mod_cell_in_row[1],mod_cell_in_col[1]}
end

/*方法1
always @(*)begin 
	case({mod_cell_in_row[1],mod_cell_in_col[1]})//判断mod在cell内部的位置
		2'b00:begin //左上角
			addr_0 = (mod_cell_row[5:1] * 5'd17 + mod_cell_col[5:1]) * 5'd18 + bin_num;//本身cell
			addr_valid_0 = 1'd1;

			if(mod_cell_row > 6'd0)begin // 上cell
				addr_1 = (((mod_cell_row - 6'd1) >> 1) * 5'd17 + mod_cell_col[5:1]) * 5'd18 + bin_num;
				addr_valid_1 = 1'd1;
			end
			else begin 
				addr_1 = 13'd0;
				addr_valid_1 = 1'd0;
			end

			if(mod_cell_row > 6'd0 && mod_cell_col > 6'd0)begin // 左上cell
				addr_2 = (((mod_cell_row - 6'd1) >> 1 ) * 5'd17 + ((mod_cell_col - 6'd1) >> 1)) * 5'd18 + bin_num;
				addr_valid_2 = 1'd1;
			end
			else begin 
				addr_2 = 13'd0;
				addr_valid_2 = 1'd0;
			end

			if(mod_cell_col > 6'd0)begin //左cell
				addr_3 = (mod_cell_row[5:1] * 5'd17 + ((mod_cell_col - 6'd1) >> 1)) * 5'd18 + bin_num;
				addr_valid_3 = 1'd1;
			end
			else begin 
				addr_3 = 13'd0;
				addr_valid_3 = 1'd0;
			end
		end
		2'b01:begin //右上角
			addr_0 = (mod_cell_row[5:1] * 5'd17 + mod_cell_col[5:1]) * 5'd18 + bin_num;//本身cell
			addr_valid_0 = 1'd1;

			if(mod_cell_row > 6'd0)begin // 上cell
				addr_1 = (((mod_cell_row - 6'd1) >> 1) * 5'd17 + mod_cell_col[5:1]) * 5'd18 + bin_num;
				addr_valid_1 = 1'd1;
			end
			else begin 
				addr_1 = 13'd0;
				addr_valid_1 = 1'd0;
			end

			if(mod_cell_row > 6'd0 && mod_cell_col < 6'd33)begin // 右上cell
				addr_2 = (((mod_cell_row - 6'd1) >> 1 ) * 5'd17 + ((mod_cell_col + 6'd1) >> 1)) * 5'd18 + bin_num;
				addr_valid_2 = 1'd1;
			end
			else begin 
				addr_2 = 13'd0;
				addr_valid_2 = 1'd0;
			end

			if(mod_cell_col < 6'd33)begin //右cell
				addr_3 = (mod_cell_row[5:1] * 5'd17 + ((mod_cell_col + 6'd1) >> 1)) * 5'd18 + bin_num;
				addr_valid_3 = 1'd1;
			end
			else begin 
				addr_3 = 13'd0;
				addr_valid_3 = 1'd0;
			end
		end
		2'b10:begin //左下角
			addr_0 = (mod_cell_row[5:1] * 5'd17 + mod_cell_col[5:1]) * 5'd18 + bin_num;//本身cell
			addr_valid_0 = 1'd1;

			if(mod_cell_row < 6'd33)begin // 下cell
				addr_1 = (((mod_cell_row + 6'd1) >> 1) * 5'd17 + mod_cell_col[5:1]) * 5'd18 + bin_num;
				addr_valid_1 = 1'd1;
			end
			else begin 
				addr_1 = 13'd0;
				addr_valid_1 = 1'd0;
			end

			if(mod_cell_row < 6'd33 && mod_cell_col > 6'd0)begin // 左下cell
				addr_2 = (((mod_cell_row + 6'd1) >> 1 ) * 5'd17 + ((mod_cell_col - 6'd1) >> 1)) * 5'd18 + bin_num;
				addr_valid_2 = 1'd1;
			end
			else begin 
				addr_2 = 13'd0;
				addr_valid_2 = 1'd0;
			end

			if(mod_cell_col > 6'd0)begin //左cell
				addr_3 = (mod_cell_row[5:1] * 5'd17 + ((mod_cell_col - 6'd1) >> 1)) * 5'd18 + bin_num;
				addr_valid_3 = 1'd1;
			end
			else begin 
				addr_3 = 13'd0;
				addr_valid_3 = 1'd0;
			end
		end
		2'b11:begin //右下角
			addr_0 = (mod_cell_row[5:1] * 5'd17 + mod_cell_col[5:1]) * 5'd18 + bin_num;//本身cell
			addr_valid_0 = 1'd1;

			if(mod_cell_row < 6'd33)begin // 下cell
				addr_1 = (((mod_cell_row + 6'd1) >> 1) * 5'd17 + mod_cell_col[5:1]) * 5'd18 + bin_num;
				addr_valid_1 = 1'd1;
			end
			else begin 
				addr_1 = 13'd0;
				addr_valid_1 = 1'd0;
			end

			if(mod_cell_row < 6'd33 && mod_cell_col < 6'd33)begin // 右下cell
				addr_2 = (((mod_cell_row + 6'd1) >> 1 ) * 5'd17 + ((mod_cell_col + 6'd1) >> 1)) * 5'd18 + bin_num;
				addr_valid_2 = 1'd1;
			end
			else begin 
				addr_2 = 13'd0;
				addr_valid_2 = 1'd0;
			end

			if(mod_cell_col < 6'd33)begin //右cell
				addr_3 = (mod_cell_row[5:1] * 5'd17 + ((mod_cell_col + 6'd1) >> 1)) * 5'd18 + bin_num;
				addr_valid_3 = 1'd1;
			end
			else begin 
				addr_3 = 13'd0;
				addr_valid_3 = 1'd0;
			end
		end
		default:begin 
			addr_0 = 13'd0;
			addr_valid_0 = 1'd0;
			addr_1 = 13'd0;
			addr_valid_1 = 1'd0;
			addr_2 = 13'd0;
			addr_valid_2 = 1'd0;
			addr_3 = 13'd0;
			addr_valid_3 = 1'd0;
		end
	endcase // {mod_cell_in_row[1],mod_cell_in_col[1]}

	case({mod_cell_row[0],mod_cell_col[0]})//判断本身额所在cell的odd、even
		2'b00:begin //even，even
			hist_addra_3 = addr_0;
			addra_valid_3 = addr_valid_0;

			hist_addra_1 = addr_1;
			addra_valid_1 = addr_valid_1;

			hist_addra_0 = addr_2;
			addra_valid_0 = addr_valid_2;

			hist_addra_2 = addr_3;
			addra_valid_2 = addr_valid_3;
		end
		2'b01:begin //even，odd
			hist_addra_2 = addr_0;
			addra_valid_2 = addr_valid_0;

			hist_addra_0 = addr_1;
			addra_valid_0 = addr_valid_1;

			hist_addra_1 = addr_2;
			addra_valid_1 = addr_valid_2;

			hist_addra_3 = addr_3;
			addra_valid_3 = addr_valid_3;
		end
		2'b10:begin //odd，even
			hist_addra_1 = addr_0;
			addra_valid_1 = addr_valid_0;

			hist_addra_3 = addr_1;
			addra_valid_3 = addr_valid_1;

			hist_addra_2 = addr_2;
			addra_valid_2 = addr_valid_2;

			hist_addra_0 = addr_3;
			addra_valid_0 = addr_valid_3;
		end
		2'b11:begin //odd，odd
			hist_addra_0 = addr_0;
			addra_valid_0 = addr_valid_0;

			hist_addra_2 = addr_1;
			addra_valid_2 = addr_valid_1;

			hist_addra_3 = addr_2;
			addra_valid_3 = addr_valid_2;

			hist_addra_1 = addr_3;
			addra_valid_1 = addr_valid_3;
		end
		default:begin 
			hist_addra_0 = 13'd0;
			addra_valid_0 = 1'd0;
			hist_addra_1 = 13'd0;
			addra_valid_1 = 1'd0;
			hist_addra_2 = 13'd0;
			addra_valid_2 = 1'd0;
			hist_addra_3 = 13'd0;
			addra_valid_3 = 1'd0;
		end
	endcase // {mod_cell_row[0],mod_cell_col[0]}
end
*/


//230220 add bram bypass，当同一周期对bram的a、b端口进行读写时，需要旁路


always @(posedge aclk)begin 
	if(!arest_n)begin 
		bram_bypass_en <=#DELAY 1'd0;
		hist_addrb_0_r1 <=#DELAY 13'd0;
		hist_addrb_1_r1 <=#DELAY 13'd0;
		hist_addrb_2_r1 <=#DELAY 13'd0;
		hist_addrb_3_r1 <=#DELAY 13'd0;
		hist_dinb_0_r1 <=#DELAY 'd0;
		hist_dinb_1_r1 <=#DELAY 'd0;
		hist_dinb_2_r1 <=#DELAY 'd0;
		hist_dinb_3_r1 <=#DELAY 'd0;
	end
	else begin 
		bram_bypass_en <=#DELAY intensity_valid;
		hist_addrb_0_r1 <=#DELAY hist_addrb_0;
		hist_addrb_1_r1 <=#DELAY hist_addrb_1;
		hist_addrb_2_r1 <=#DELAY hist_addrb_2;
		hist_addrb_3_r1 <=#DELAY hist_addrb_3;
		hist_dinb_0_r1 <=#DELAY hist_dinb_0;
		hist_dinb_1_r1 <=#DELAY hist_dinb_1;
		hist_dinb_2_r1 <=#DELAY hist_dinb_2;
		hist_dinb_3_r1 <=#DELAY hist_dinb_3;
	end
end










///////reg0

always @(posedge aclk)begin //产生b端口写地址
	if(!arest_n)begin 
		hist_addrb_0 <=#DELAY 13'd0;
		hist_addrb_1 <=#DELAY 13'd0;
		hist_addrb_2 <=#DELAY 13'd0;
		hist_addrb_3 <=#DELAY 13'd0;
	end
	else begin 
		hist_addrb_0 <=#DELAY hist_addra_0;
		hist_addrb_1 <=#DELAY hist_addra_1;
		hist_addrb_2 <=#DELAY hist_addra_2;
		hist_addrb_3 <=#DELAY hist_addra_3;
	end
end

always @(posedge aclk)begin //a端口读出的数据是否需要加上intensity项（因为有的cell位于边界）
	if(!arest_n)begin 
		addra_valid_0_r1 <=#DELAY 1'd0;
		addra_valid_1_r1 <=#DELAY 1'd0;
		addra_valid_2_r1 <=#DELAY 1'd0;
		addra_valid_3_r1 <=#DELAY 1'd0;
	end
	else begin 
		addra_valid_0_r1 <=#DELAY addra_valid_0;
		addra_valid_1_r1 <=#DELAY addra_valid_1;
		addra_valid_2_r1 <=#DELAY addra_valid_2;
		addra_valid_3_r1 <=#DELAY addra_valid_3;
	end
end

always @(posedge aclk)begin //用于判断intensity0-3 归属到哪个bank的b端口写入
	if(!arest_n)begin 
		mod_cell_row_r1 <=#DELAY 6'd0;
		mod_cell_col_r1 <=#DELAY 6'd0;
	end
	else begin 
		mod_cell_row_r1 <=#DELAY mod_cell_row;
		mod_cell_col_r1 <=#DELAY mod_cell_col;
	end
end
/*
always @(*)begin 
	case({mod_cell_row_r1[0],mod_cell_col_r1[0]})//确定intensity0-3 归属于哪个bank的b端口,或者cell位于边界，部分intensity不归属
		2'b00:begin 
			hist_dinb_3 = douta_3 + intensity_0;

			if(addra_valid_1_r1)begin 
				hist_dinb_1 = douta_1 + intensity_1;
			end
			else begin 
				hist_dinb_1 = douta_1;
			end

			if(addra_valid_0_r1)begin 
				hist_dinb_0 = douta_0 + intensity_2;
			end
			else begin 
				hist_dinb_0 = douta_0;
			end

			if(addra_valid_2_r1)begin 
				hist_dinb_2 = douta_2 + intensity_3;
			end
			else begin 
				hist_dinb_2 = douta_2;
			end
		end
		2'b01:begin 
			hist_dinb_2 = douta_2 + intensity_0;

			if(addra_valid_0_r1)begin 
				hist_dinb_0 = douta_0 + intensity_1;
			end
			else begin 
				hist_dinb_0 = douta_0;
			end

			if(addra_valid_1_r1)begin 
				hist_dinb_1 = douta_1 + intensity_2;
			end
			else begin 
				hist_dinb_1 = douta_1;
			end

			if(addra_valid_3_r1)begin 
				hist_dinb_3 = douta_3 + intensity_3;
			end
			else begin 
				hist_dinb_3 = douta_3;
			end
		end
		2'b10:begin 
			hist_dinb_1 = douta_1 + intensity_0;

			if(addra_valid_3_r1)begin 
				hist_dinb_3 = douta_3 + intensity_1;
			end
			else begin 
				hist_dinb_3 = douta_3;
			end

			if(addra_valid_2_r1)begin 
				hist_dinb_2 = douta_2 + intensity_2;
			end
			else begin 
				hist_dinb_2 = douta_2;
			end

			if(addra_valid_0_r1)begin 
				hist_dinb_0 = douta_0 + intensity_3;
			end
			else begin 
				hist_dinb_0 = douta_0;
			end
		end
		2'b11:begin 
			hist_dinb_0 = douta_0 + intensity_0;

			if(addra_valid_2_r1)begin 
				hist_dinb_2 = douta_2 + intensity_1;
			end
			else begin 
				hist_dinb_2 = douta_2;
			end

			if(addra_valid_3_r1)begin 
				hist_dinb_3 = douta_3 + intensity_2;
			end
			else begin 
				hist_dinb_3 = douta_3;
			end

			if(addra_valid_1_r1)begin 
				hist_dinb_1 = douta_1 + intensity_3;
			end
			else begin 
				hist_dinb_1 = douta_1;
			end
		end
		default:begin 
			hist_dinb_0 = 'd0;
			hist_dinb_1 = 'd0;
			hist_dinb_2 = 'd0;
			hist_dinb_3 = 'd0;
		end
	endcase // {mod_cell_row_r1[0],mod_cell_col_r1[0]}
end
*/
//加入旁路
always @(*)begin 
	case({mod_cell_row_r1[0],mod_cell_col_r1[0]})//确定intensity0-3 归属于哪个bank的b端口,或者cell位于边界，部分intensity不归属
		2'b00:begin 
			if(bram_bypass_en && hist_addrb_3 == hist_addrb_3_r1)begin 
				hist_dinb_3 = hist_dinb_3_r1 + intensity_0;
			end
			else begin 
				hist_dinb_3 = douta_3 + intensity_0;
			end
			

			if(addra_valid_1_r1)begin 
				if(bram_bypass_en && hist_addrb_1 == hist_addrb_1_r1)begin 
					hist_dinb_1 = hist_dinb_1_r1 + intensity_1;
				end
				else begin 
					hist_dinb_1 = douta_1 + intensity_1;
				end
				
			end
			else begin 
				if(bram_bypass_en && hist_addrb_1 == hist_addrb_1_r1)begin 
					hist_dinb_1 = hist_dinb_1_r1;
				end
				else begin 
					hist_dinb_1 = douta_1;
				end
				
			end

			if(addra_valid_0_r1)begin 
				if(bram_bypass_en && hist_addrb_0 == hist_addrb_0_r1)begin 
					hist_dinb_0 = hist_dinb_0_r1 + intensity_2;
				end
				else begin 
					hist_dinb_0 = douta_0 + intensity_2;
				end
				
			end
			else begin 
				if(bram_bypass_en && hist_addrb_0 == hist_addrb_0_r1)begin 
					hist_dinb_0 = hist_dinb_0_r1;
				end
				else begin 
					hist_dinb_0 = douta_0;
				end
				
			end

			if(addra_valid_2_r1)begin 
				if(bram_bypass_en && hist_addrb_2 == hist_addrb_2_r1)begin 
					hist_dinb_2 = hist_dinb_2_r1 + intensity_3;
				end
				else begin 
					hist_dinb_2 = douta_2 + intensity_3;
				end
			end
			else begin 
				if(bram_bypass_en && hist_addrb_2 == hist_addrb_2_r1)begin 
					hist_dinb_2 = hist_dinb_2_r1;
				end
				else begin 
					hist_dinb_2 = douta_2;
				end

				
			end
		end
		2'b01:begin 
			if(bram_bypass_en && hist_addrb_2 == hist_addrb_2_r1)begin 
				hist_dinb_2 = hist_dinb_2_r1 + intensity_0;
			end
			else begin 
				hist_dinb_2 = douta_2 + intensity_0;
			end

			if(addra_valid_0_r1)begin 
				if(bram_bypass_en && hist_addrb_0 == hist_addrb_0_r1)begin 
					hist_dinb_0 = hist_dinb_0_r1 + intensity_1;
				end
				else begin 
					hist_dinb_0 = douta_0 + intensity_1;
				end
				
			end
			else begin 
				if(bram_bypass_en && hist_addrb_0 == hist_addrb_0_r1)begin 
					hist_dinb_0 = hist_dinb_0_r1;
				end
				else begin 
					hist_dinb_0 = douta_0;
				end
				
			end

			if(addra_valid_1_r1)begin 
				if(bram_bypass_en && hist_addrb_1 == hist_addrb_1_r1)begin 
					hist_dinb_1 = hist_dinb_1_r1 + intensity_2;
				end
				else begin 
					hist_dinb_1 = douta_1 + intensity_2;
				end
				
			end
			else begin 
				if(bram_bypass_en && hist_addrb_1 == hist_addrb_1_r1)begin 
					hist_dinb_1 = hist_dinb_1_r1;
				end
				else begin 
					hist_dinb_1 = douta_1;
				end
				
			end

			

			if(addra_valid_3_r1)begin 
				if(bram_bypass_en && hist_addrb_3 == hist_addrb_3_r1)begin 
					hist_dinb_3 = hist_dinb_3_r1 + intensity_3;
				end
				else begin 
					hist_dinb_3 = douta_3 + intensity_3;
				end
			end
			else begin 
				if(bram_bypass_en && hist_addrb_3 == hist_addrb_3_r1)begin 
					hist_dinb_3 = hist_dinb_3_r1;
				end
				else begin 
					hist_dinb_3 = douta_3;
				end
				
			end
		end
		2'b10:begin 
			if(bram_bypass_en && hist_addrb_1 == hist_addrb_1_r1)begin 
				hist_dinb_1 = hist_dinb_1_r1 + intensity_0;
			end
			else begin 
				hist_dinb_1 = douta_1 + intensity_0;
			end

			if(addra_valid_3_r1)begin 
				if(bram_bypass_en && hist_addrb_3 == hist_addrb_3_r1)begin 
					hist_dinb_3 = hist_dinb_3_r1 + intensity_1;
				end
				else begin 
					hist_dinb_3 = douta_3 + intensity_1;
				end
			end
			else begin 
				if(bram_bypass_en && hist_addrb_3 == hist_addrb_3_r1)begin 
					hist_dinb_3 = hist_dinb_3_r1;
				end
				else begin 
					hist_dinb_3 = douta_3;
				end
				
			end

			if(addra_valid_2_r1)begin 
				if(bram_bypass_en && hist_addrb_2 == hist_addrb_2_r1)begin 
					hist_dinb_2 = hist_dinb_2_r1 + intensity_2;
				end
				else begin 
					hist_dinb_2 = douta_2 + intensity_2;
				end
			end
			else begin 
				if(bram_bypass_en && hist_addrb_2 == hist_addrb_2_r1)begin 
					hist_dinb_2 = hist_dinb_2_r1;
				end
				else begin 
					hist_dinb_2 = douta_2;
				end

				
			end

			if(addra_valid_0_r1)begin 
				if(bram_bypass_en && hist_addrb_0 == hist_addrb_0_r1)begin 
					hist_dinb_0 = hist_dinb_0_r1 + intensity_3;
				end
				else begin 
					hist_dinb_0 = douta_0 + intensity_3;
				end
				
			end
			else begin 
				if(bram_bypass_en && hist_addrb_0 == hist_addrb_0_r1)begin 
					hist_dinb_0 = hist_dinb_0_r1;
				end
				else begin 
					hist_dinb_0 = douta_0;
				end
				
			end

		end
		2'b11:begin 
			if(bram_bypass_en && hist_addrb_0 == hist_addrb_0_r1)begin 
					hist_dinb_0 = hist_dinb_0_r1 + intensity_0;
				end
				else begin 
					hist_dinb_0 = douta_0 + intensity_0;
				end
			
			if(addra_valid_2_r1)begin 
				if(bram_bypass_en && hist_addrb_2 == hist_addrb_2_r1)begin 
					hist_dinb_2 = hist_dinb_2_r1 + intensity_1;
				end
				else begin 
					hist_dinb_2 = douta_2 + intensity_1;
				end
			end
			else begin 
				if(bram_bypass_en && hist_addrb_2 == hist_addrb_2_r1)begin 
					hist_dinb_2 = hist_dinb_2_r1;
				end
				else begin 
					hist_dinb_2 = douta_2;
				end

				
			end

			if(addra_valid_3_r1)begin 
				if(bram_bypass_en && hist_addrb_3 == hist_addrb_3_r1)begin 
					hist_dinb_3 = hist_dinb_3_r1 + intensity_2;
				end
				else begin 
					hist_dinb_3 = douta_3 + intensity_2;
				end
			end
			else begin 
				if(bram_bypass_en && hist_addrb_3 == hist_addrb_3_r1)begin 
					hist_dinb_3 = hist_dinb_3_r1;
				end
				else begin 
					hist_dinb_3 = douta_3;
				end
				
			end

			if(addra_valid_1_r1)begin 
				if(bram_bypass_en && hist_addrb_1 == hist_addrb_1_r1)begin 
					hist_dinb_1 = hist_dinb_1_r1 + intensity_3;
				end
				else begin 
					hist_dinb_1 = douta_1 + intensity_3;
				end
				
			end
			else begin 
				if(bram_bypass_en && hist_addrb_1 == hist_addrb_1_r1)begin 
					hist_dinb_1 = hist_dinb_1_r1;
				end
				else begin 
					hist_dinb_1 = douta_1;
				end
				
			end

		end
		default:begin 
			hist_dinb_0 = 'd0;
			hist_dinb_1 = 'd0;
			hist_dinb_2 = 'd0;
			hist_dinb_3 = 'd0;
		end
	endcase // {mod_cell_row_r1[0],mod_cell_col_r1[0]}
end


////histogram done
always @(posedge aclk)begin 
	if(!arest_n)begin 
		histogram_done <=#DELAY 1'd0;
	end
	else begin 
		if(bin_num_valid && mod_row == 8'd135 && mod_col == 8'd135)begin
			histogram_done <=#DELAY 1'd1;
		end
		else begin 
			histogram_done <=#DELAY 1'd0;
		end
	end
end
//初始化initial_cell_bram,上电或者特征图写入到输入缓存完毕
always @(posedge aclk)begin 
	if(!arest_n)begin 
		initial_cell_bram <=#DELAY 1'd1;
	end
	else begin 
		if(write_feature_done)begin 
			initial_cell_bram <=#DELAY 1'd1;
		end
		else begin 
			initial_cell_bram <=#DELAY 1'd0;
		end
	end
end


//initial cell bram
always @(posedge aclk)begin 
	if(!arest_n)begin 
		initial_bram <=#DELAY 1'd0;//初始化写使能和写地址
		initial_addrb <=#DELAY 13'd0;
		initial_addra <=#DELAY 13'd1;
		hog_ready <=#DELAY 1'd0;
	end
	else begin 
		if(initial_cell_bram)begin //初始化启动信号有效
			initial_bram <=#DELAY 1'd1;
			initial_addrb <=#DELAY 13'd2;
			initial_addra <=#DELAY 13'd3;
			hog_ready <=#DELAY 1'd0;
		end
		else begin 
			if(initial_addrb == 13'd0)begin //初始化操作从地址1-5201-0，然后停止初始化
				initial_bram <=#DELAY 1'd0;
				hog_ready <=#DELAY 1'd1;
			end
			else begin 
				if(initial_addrb == 13'd5200)begin 
					initial_addrb <=#DELAY 13'd0;
					initial_addra <=#DELAY 13'd1;
				end
				else begin 
					initial_addrb <=#DELAY initial_addrb + 13'd2;
					initial_addra <=#DELAY initial_addra + 13'd2;
				end
			end
		end
	end
end

bram_w37_r37_d5202 bank0_odd_row_odd_col (
  .clka(aclk),    // input wire clka
  .wea(wea_0),      // input wire [0 : 0] wea
  .addra(addra_0),  // input wire [12 : 0] addra
  .dina(dina_0),    // input wire [34 : 0] dina
  .douta(douta_0),  // output wire [34 : 0] douta
  .clkb(aclk),    // input wire clkb
  .web(web_0),      // input wire [0 : 0] web
  .addrb(addrb_0),  // input wire [12 : 0] addrb
  .dinb(dinb_0),    // input wire [34 : 0] dinb
  .doutb(doutb_0)  // output wire [34 : 0] doutb
);
bram_w37_r37_d5202 bank1_odd_row_even_col (
  .clka(aclk),    // input wire clka
  .wea(wea_1),      // input wire [0 : 0] wea
  .addra(addra_1),  // input wire [12 : 0] addra
  .dina(dina_1),    // input wire [34 : 0] dina
  .douta(douta_1),  // output wire [34 : 0] douta
  .clkb(aclk),    // input wire clkb
  .web(web_1),      // input wire [0 : 0] web
  .addrb(addrb_1),  // input wire [12 : 0] addrb
  .dinb(dinb_1),    // input wire [34 : 0] dinb
  .doutb(doutb_1)  // output wire [34 : 0] doutb
);
bram_w37_r37_d5202 bank2_even_row_odd_col (
  .clka(aclk),    // input wire clka
  .wea(wea_2),      // input wire [0 : 0] wea
  .addra(addra_2),  // input wire [12 : 0] addra
  .dina(dina_2),    // input wire [34 : 0] dina
  .douta(douta_2),  // output wire [34 : 0] douta
  .clkb(aclk),    // input wire clkb
  .web(web_2),      // input wire [0 : 0] web
  .addrb(addrb_2),  // input wire [12 : 0] addrb
  .dinb(dinb_2),    // input wire [34 : 0] dinb
  .doutb(doutb_2)  // output wire [34 : 0] doutb
);
bram_w37_r37_d5202 bank3_even_row_even_col (
  .clka(aclk),    // input wire clka
  .wea(wea_3),      // input wire [0 : 0] wea
  .addra(addra_3),  // input wire [12 : 0] addra
  .dina(dina_3),    // input wire [34 : 0] dina
  .douta(douta_3),  // output wire [34 : 0] douta
  .clkb(aclk),    // input wire clkb
  .web(web_3),      // input wire [0 : 0] web
  .addrb(addrb_3),  // input wire [12 : 0] addrb
  .dinb(dinb_3),    // input wire [34 : 0] dinb
  .doutb(doutb_3)  // output wire [34 : 0] doutb
);

/*
bram_w35_r35_d5202 bank0_odd_row_odd_col (
  .clka(aclk),    // input wire clka
  .wea(wea_0),      // input wire [0 : 0] wea
  .addra(addra_0),  // input wire [12 : 0] addra
  .dina(dina_0),    // input wire [34 : 0] dina
  .douta(douta_0),  // output wire [34 : 0] douta
  .clkb(aclk),    // input wire clkb
  .web(web_0),      // input wire [0 : 0] web
  .addrb(addrb_0),  // input wire [12 : 0] addrb
  .dinb(dinb_0),    // input wire [34 : 0] dinb
  .doutb(doutb_0)  // output wire [34 : 0] doutb
);
bram_w35_r35_d5202 bank1_odd_row_even_col (
  .clka(aclk),    // input wire clka
  .wea(wea_1),      // input wire [0 : 0] wea
  .addra(addra_1),  // input wire [12 : 0] addra
  .dina(dina_1),    // input wire [34 : 0] dina
  .douta(douta_1),  // output wire [34 : 0] douta
  .clkb(aclk),    // input wire clkb
  .web(web_1),      // input wire [0 : 0] web
  .addrb(addrb_1),  // input wire [12 : 0] addrb
  .dinb(dinb_1),    // input wire [34 : 0] dinb
  .doutb(doutb_1)  // output wire [34 : 0] doutb
);
bram_w35_r35_d5202 bank2_even_row_odd_col (
  .clka(aclk),    // input wire clka
  .wea(wea_2),      // input wire [0 : 0] wea
  .addra(addra_2),  // input wire [12 : 0] addra
  .dina(dina_2),    // input wire [34 : 0] dina
  .douta(douta_2),  // output wire [34 : 0] douta
  .clkb(aclk),    // input wire clkb
  .web(web_2),      // input wire [0 : 0] web
  .addrb(addrb_2),  // input wire [12 : 0] addrb
  .dinb(dinb_2),    // input wire [34 : 0] dinb
  .doutb(doutb_2)  // output wire [34 : 0] doutb
);
bram_w35_r35_d5202 bank3_even_row_even_col (
  .clka(aclk),    // input wire clka
  .wea(wea_3),      // input wire [0 : 0] wea
  .addra(addra_3),  // input wire [12 : 0] addra
  .dina(dina_3),    // input wire [34 : 0] dina
  .douta(douta_3),  // output wire [34 : 0] douta
  .clkb(aclk),    // input wire clkb
  .web(web_3),      // input wire [0 : 0] web
  .addrb(addrb_3),  // input wire [12 : 0] addrb
  .dinb(dinb_3),    // input wire [34 : 0] dinb
  .doutb(doutb_3)  // output wire [34 : 0] doutb
);
*/
endmodule