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
// File   : sos_cache.v
// Create : 2022-10-17 17:30:41
// Revise : 2023-04-25 11:46:11
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module sos_cache #(
	parameter TOTAL_BIT_WIDTH 	= 35,
	parameter DELAY 			= 1
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low
	
	input sos_valid,
	input [TOTAL_BIT_WIDTH-1:0] sum_of_squares,
	
	output reg window_valid,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg1,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg2,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg3,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg4,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg5,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg6,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg7,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg8,
	output reg [TOTAL_BIT_WIDTH-1:0] sos_reg9
);

//reg [TOTAL_BIT_WIDTH-1:0] sos_reg1;
//reg [TOTAL_BIT_WIDTH-1:0] sos_reg2;
//reg [TOTAL_BIT_WIDTH-1:0] sos_reg3;
//reg [TOTAL_BIT_WIDTH-1:0] sos_reg4;
//reg [TOTAL_BIT_WIDTH-1:0] sos_reg5;
//reg [TOTAL_BIT_WIDTH-1:0] sos_reg6;
//reg [TOTAL_BIT_WIDTH-1:0] sos_reg7;
//reg [TOTAL_BIT_WIDTH-1:0] sos_reg8;
//reg [TOTAL_BIT_WIDTH-1:0] sos_reg9;
/*//使用fifo来实现行缓存
reg [10:0] sos_count;

reg [TOTAL_BIT_WIDTH-1:0] din1;
reg wr_en1;
wire rd_en1;
wire[TOTAL_BIT_WIDTH-1:0] dout1;
wire full1;
wire empty1;
wire prog_full1;

reg [TOTAL_BIT_WIDTH-1:0] din2;
reg wr_en2;
wire rd_en2;
wire[TOTAL_BIT_WIDTH-1:0] dout2;
wire full2;
wire empty2;
wire prog_full2;

reg [5:0] sos_reg4_col;
reg [5:0] sos_reg5_col;

//清空row1和row2
reg clear_row;
reg [5:0] clear_count;

//sos_reg1-9
always @(posedge aclk)begin 
	if(!arest_n)begin 
		sos_reg1 <=#DELAY 'd0;
		sos_reg2 <=#DELAY 'd0;
		sos_reg3 <=#DELAY 'd0;
		sos_reg4 <=#DELAY 'd0;
		sos_reg5 <=#DELAY 'd0;
		sos_reg6 <=#DELAY 'd0;
		sos_reg7 <=#DELAY 'd0;
		sos_reg8 <=#DELAY 'd0;
		sos_reg9 <=#DELAY 'd0;
	end
	else begin 
		if(sos_valid)begin //reg1-3输入端数据有效：sos_valid有效
			sos_reg1 <=#DELAY sum_of_squares;
			sos_reg2 <=#DELAY sos_reg1;
			sos_reg3 <=#DELAY sos_reg2;
		end

		if(rd_en1)begin //reg4-6输入端数据有效：rd_en1有效，表明行缓存row1已满，读端口读出数据有效
			sos_reg4 <=#DELAY dout1;
			sos_reg5 <=#DELAY sos_reg4;
			sos_reg6 <=#DELAY sos_reg5;
		end

		if(rd_en2)begin 
			sos_reg7 <=#DELAY dout2;
			sos_reg8 <=#DELAY sos_reg7;
			sos_reg9 <=#DELAY sos_reg8;
		end
	end
end

always @(posedge aclk)begin //sos_valid计数
	if(!arest_n)begin 
		sos_count <=#DELAY 11'd0;
	end
	else begin 
		if(sos_valid)begin 
			if(sos_count == 11'd1155)begin//34*34 = 1156
				sos_count <=#DELAY 11'd0;
			end
			else begin 
				sos_count <=#DELAY sos_count + 11'd1;
			end
		end
	end
end
//row1写操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		wr_en1 <=#DELAY 1'd0;
		din1 <=#DELAY 'd0;
	end
	else begin 
		if(sos_valid && sos_count > 11'd2)begin //当reg1-3填满后，写row1
			wr_en1 <=#DELAY 1'd1;
			din1 <=#DELAY sos_reg3;
		end
		else begin 
			wr_en1 <=#DELAY 1'd0;
			din1 <=#DELAY 'd0;
		end
	end
end
//row1读操作
assign rd_en1 = ((sos_valid && sos_count > 11'd33) || clear_row) ? 1'd1 : 1'd0;//当reg1-3、row1填满后

//reg4所在cell——sos col:1-33、0
always @(posedge aclk)begin 
	if(!arest_n)begin 
		sos_reg4_col <=#DELAY 6'd0;
	end
	else begin 
		if(rd_en1 && !clear_row)begin 
			if(sos_reg4_col == 6'd33)begin 
				sos_reg4_col <=#DELAY 6'd0;
			end
			else begin 
				sos_reg4_col <=#DELAY sos_reg4_col + 6'd1;
			end
		end
	end
end
//reg5中sos所在的col
always @(posedge aclk)begin 
	if(!arest_n)begin 
		sos_reg5_col <=#DELAY 6'd0;
	end
	else begin 
		if(rd_en1 && !clear_row)begin 
			sos_reg5_col <=#DELAY sos_reg4_col;
		end
	end
end

//row2写操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		wr_en2 <=#DELAY 1'd0;
		din2 <=#DELAY 'd0;
	end
	else begin 
		if(sos_valid && sos_count > 11'd36)begin //当reg1-6、row1填满后，写row2
			wr_en2 <=#DELAY 1'd1;
			din2 <=#DELAY sos_reg6;
		end
		else begin 
			wr_en2 <=#DELAY 1'd0;
			din2 <=#DELAY 'd0;
		end
	end
end
//row2读操作
assign rd_en2 = ((sos_valid && sos_count > 11'd67) || clear_row)  ? 1'd1 : 1'd0;//当reg1-6、row1、row2填满后

//window_valid
always @(posedge aclk)begin 
	if(!arest_n)begin 
		window_valid <=#DELAY 1'd0;
	end
	else begin 
		if(sos_valid && sos_count > 11'd69 && sos_reg5_col != 6'd33 && sos_reg5_col != 6'd0)begin //当reg1-8、row1、row2填满，下一个新数据有效
			window_valid <=#DELAY 1'd1;																//并且reg5_col不在左右边界
		end
		else begin 
			window_valid <=#DELAY 1'd0;
		end
	end
end

//前一帧图像处理完毕后，需要清空row1和row2

always @(posedge aclk)begin 
	if(!arest_n)begin 
		clear_count <=#DELAY 6'd0;
	end
	else begin 
		if(sos_valid && sos_count == 11'd1155)begin 
			clear_count <=#DELAY 5'd1;
		end
		else begin 
			if(clear_count != 6'd0)begin 
				if(clear_count == 6'd41)begin 
					clear_count <=#DELAY 6'd0;
				end
				else begin 
					clear_count <=#DELAY clear_count + 6'd1;
				end
			end
		end
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		clear_row <=#DELAY 1'd0;
	end
	else begin 
		if(clear_count >= 6'd10 && clear_count <= 6'd40)begin 
			clear_row <=#DELAY 1'd1;
		end
		else begin 
			clear_row <=#DELAY 1'd0;
		end
	end
end







fifo_FWFT_w35_r35_d32 row1_31sos (
  .wr_clk(aclk),                      // input wire wr_clk
  .wr_rst(~arest_n),                      // input wire wr_rst
  .rd_clk(aclk),                      // input wire rd_clk
  .rd_rst(~arest_n),                      // input wire rd_rst
  .din(din1),                            // input wire [34 : 0] din
  .wr_en(wr_en1),                        // input wire wr_en
  .rd_en(rd_en1),                        // input wire rd_en
  .prog_full_thresh(31),  // input wire [4 : 0] prog_full_thresh
  .dout(dout1),                          // output wire [34 : 0] dout
  .full(full1),                          // output wire full
  .empty(empty1),                        // output wire empty
  .prog_full(prog_full1)                // output wire prog_full
);

fifo_FWFT_w35_r35_d32 row2_31sos (
  .wr_clk(aclk),                      // input wire wr_clk
  .wr_rst(~arest_n),                      // input wire wr_rst
  .rd_clk(aclk),                      // input wire rd_clk
  .rd_rst(~arest_n),                      // input wire rd_rst
  .din(din2),                            // input wire [34 : 0] din
  .wr_en(wr_en2),                        // input wire wr_en
  .rd_en(rd_en2),                        // input wire rd_en
  .prog_full_thresh(31),  // input wire [4 : 0] prog_full_thresh
  .dout(dout2),                          // output wire [34 : 0] dout
  .full(full2),                          // output wire full
  .empty(empty2),                        // output wire empty
  .prog_full(prog_full2)                // output wire prog_full
);
*/

//使用dist_ram实现行缓存
reg [4:0] addra_1;
reg [TOTAL_BIT_WIDTH-1:0] dina_1;
reg  we_1;
reg [4:0] addrb_1;
wire [TOTAL_BIT_WIDTH-1:0] doutb_1;


reg [4:0] addra_2;
reg [TOTAL_BIT_WIDTH-1:0] dina_2;
reg  we_2;
reg [4:0] addrb_2;
wire [TOTAL_BIT_WIDTH-1:0] doutb_2;

wire rd_row1_valid;
wire rd_row2_valid;

reg [10:0] sos_count;//总cell数计数
reg [5:0] sos_reg4_col;//reg4所在列计数：1-33-0
reg [5:0] sos_reg5_col;


//sos_reg1-9
always @(posedge aclk)begin 
	if(!arest_n)begin 
		sos_reg1 <=#DELAY 'd0;
		sos_reg2 <=#DELAY 'd0;
		sos_reg3 <=#DELAY 'd0;
		sos_reg4 <=#DELAY 'd0;
		sos_reg5 <=#DELAY 'd0;
		sos_reg6 <=#DELAY 'd0;
		sos_reg7 <=#DELAY 'd0;
		sos_reg8 <=#DELAY 'd0;
		sos_reg9 <=#DELAY 'd0;
	end
	else begin 
		if(sos_valid)begin //reg1-3输入端数据有效：sos_valid有效
			sos_reg1 <=#DELAY sum_of_squares;
			sos_reg2 <=#DELAY sos_reg1;
			sos_reg3 <=#DELAY sos_reg2;
		end

		if(rd_row1_valid)begin //表明行缓存row1已满，读端口读出数据有效
			sos_reg4 <=#DELAY doutb_1;
			sos_reg5 <=#DELAY sos_reg4;
			sos_reg6 <=#DELAY sos_reg5;
		end

		if(rd_row2_valid)begin //表明行缓存row2已满，读端口读出数据有效
			sos_reg7 <=#DELAY doutb_2;
			sos_reg8 <=#DELAY sos_reg7;
			sos_reg9 <=#DELAY sos_reg8;
		end
	end
end


always @(posedge aclk)begin //sos_valid计数
	if(!arest_n)begin 
		sos_count <=#DELAY 11'd0;
	end
	else begin 
		if(sos_valid)begin 
			if(sos_count == 11'd1155)begin//34*34 = 1156
				sos_count <=#DELAY 11'd0;
			end
			else begin 
				sos_count <=#DELAY sos_count + 11'd1;
			end
		end
	end
end

//row1写操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		we_1 <=#DELAY 1'd0;
		dina_1 <=#DELAY 'd0;
		addra_1 <=#DELAY 5'd0;
	end
	else begin 
		if(sos_valid)begin //写row1
			we_1 <=#DELAY 1'd1;
			dina_1 <=#DELAY sos_reg3;
			addra_1 <=#DELAY addra_1 + 5'd1;
		end
		else begin 
			we_1 <=#DELAY 1'd0;
		end
	end
end

//row1读操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		addrb_1 <=#DELAY 5'd2;
	end
	else begin 
		if(sos_valid)begin 
			addrb_1 <=#DELAY addrb_1 + 5'd1;
		end
	end
end

//row1读数据有效
assign rd_row1_valid = (sos_valid && sos_count >= 11'd34) ? 1'd1 : 1'd0;//缓存34个数据后，读有效

//row2写操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		we_2 <=#DELAY 1'd0;
		dina_2 <=#DELAY 'd0;
		addra_2 <=#DELAY 5'd0;
	end
	else begin 
		if(sos_valid)begin //写row2
			we_2 <=#DELAY 1'd1;
			dina_2 <=#DELAY sos_reg6;
			addra_2 <=#DELAY addra_2 + 5'd1;
		end
		else begin 
			we_2 <=#DELAY 1'd0;
		end
	end
end

//row2读操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		addrb_2 <=#DELAY 5'd2;
	end
	else begin 
		if(sos_valid)begin 
			addrb_2 <=#DELAY addrb_2 + 5'd1;
		end
	end
end

//row2读数据有效
assign rd_row2_valid = (sos_valid && sos_count >= 11'd68) ? 1'd1 : 1'd0;//缓存34个数据后，读有效

//reg4所在cell——sos col:1-33、0
always @(posedge aclk)begin 
	if(!arest_n)begin 
		sos_reg4_col <=#DELAY 6'd0;
	end
	else begin 
		if(rd_row1_valid)begin 
			if(sos_reg4_col == 6'd33)begin 
				sos_reg4_col <=#DELAY 6'd0;
			end
			else begin 
				sos_reg4_col <=#DELAY sos_reg4_col + 6'd1;
			end
		end
	end
end
//reg5中sos所在的col
always @(posedge aclk)begin 
	if(!arest_n)begin 
		sos_reg5_col <=#DELAY 6'd0;
	end
	else begin 
		if(rd_row1_valid)begin 
			sos_reg5_col <=#DELAY sos_reg4_col;
		end
	end
end
//3*3窗口reg1-9有效
//window_valid
always @(posedge aclk)begin 
	if(!arest_n)begin 
		window_valid <=#DELAY 1'd0;
	end
	else begin 
		if(sos_valid && sos_count >= 11'd70 && sos_reg5_col != 6'd33 && sos_reg5_col != 6'd0)begin //当reg1-8、row1、row2填满，下一个新数据有效
			window_valid <=#DELAY 1'd1;																//并且reg5_col不在左右边界
		end
		else begin 
			window_valid <=#DELAY 1'd0;
		end
	end
end



dist_ram_d32 row1_31sos (
  .a(addra_1),        // input wire [4 : 0] a
  .d(dina_1),        // input wire [34 : 0] d
  .dpra(addrb_1),  // input wire [4 : 0] dpra
  .clk(aclk),    // input wire clk
  .we(we_1),      // input wire we
  .dpo(doutb_1)    // output wire [34 : 0] dpo
);

dist_ram_d32 row2_31sos (
  .a(addra_2),        // input wire [4 : 0] a
  .d(dina_2),        // input wire [34 : 0] d
  .dpra(addrb_2),  // input wire [4 : 0] dpra
  .clk(aclk),    // input wire clk
  .we(we_2),      // input wire we
  .dpo(doutb_2)    // output wire [34 : 0] dpo
);

/*
dist_ram_w35_r35_d32 row1_31sos (
  .a(addra_1),        // input wire [4 : 0] a
  .d(dina_1),        // input wire [34 : 0] d
  .dpra(addrb_1),  // input wire [4 : 0] dpra
  .clk(aclk),    // input wire clk
  .we(we_1),      // input wire we
  .dpo(doutb_1)    // output wire [34 : 0] dpo
);

dist_ram_w35_r35_d32 row2_31sos (
  .a(addra_2),        // input wire [4 : 0] a
  .d(dina_2),        // input wire [34 : 0] d
  .dpra(addrb_2),  // input wire [4 : 0] dpra
  .clk(aclk),    // input wire clk
  .we(we_2),      // input wire we
  .dpo(doutb_2)    // output wire [34 : 0] dpo
);
*/

/*//tb
integer i;
integer handle0;
initial begin 
	i = 0;
	handle0 = $fopen("C:/Users/LinMian/Desktop/HOG_20220902/rtl_tb/mod_square_qyw1_tb.txt");//打开文件句柄
	for(i = 0;i < 2312;i = i + 1)begin //34*34,保留2次
		wait(sos_valid);
		//@(posedge aclk iff(sos_valid));
		$fdisplay(handle0,"%h",sum_of_squares);
		#21;
	end
	$fclose(handle0);
	//文件输出结束
end
//tb结束
*/

endmodule