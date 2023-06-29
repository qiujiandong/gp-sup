// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-19 10:57:19
// Author : Liman
// Email  : 944768976@qq.com
// File   : read_bport_cell_bin.v
// Description ：
// Revise : 2023-02-17 22:12:36
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module read_bport_cell_bin #(
	parameter TOTAL_BIT_WIDTH 	= 35,
	parameter DELAY 			= 1
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low
	
	output reg [12:0] normal_addr_0,//归一化，读端口，读出bin值进行归一化操作
	output reg [12:0] normal_addr_1,
	output reg [12:0] normal_addr_2,
	output reg [12:0] normal_addr_3,
	input [TOTAL_BIT_WIDTH-1 : 0] dout_0,
	input [TOTAL_BIT_WIDTH-1 : 0] dout_1,
	input [TOTAL_BIT_WIDTH-1 : 0] dout_2,
	input [TOTAL_BIT_WIDTH-1 : 0] dout_3,

	input isr_valid,//当某个cell周围4个block，求得的逆平方根有效，开始读对应cell中的bin值

	output  bin_data_valid,//读出的bin数据有效
	output [TOTAL_BIT_WIDTH-1:0] bin_data//读出的bin数据

);

localparam RD_BIN_IDLE = 3'd0;
localparam RD_BIN_BANK0 = 3'd1;
localparam RD_BIN_BANK1 = 3'd2;
localparam RD_BIN_BANK2 = 3'd3;
localparam RD_BIN_BANK3 = 3'd4;
localparam RD_BIN_WAIT = 3'd5;//读到边界时，isr_valid会无效18*2个周期，需要等待


//按照逐行逐列顺序读取cell中bin0-17：先读bin0、bin9，bin1、bin10......
//reg0
reg [2:0] rd_bin_cstate,rd_bin_nstate;
reg [4:0] cell_row;//记录目前正在读出的cell row，起始为0，实际对应于34*34cell中的1
reg [4:0] cell_col;//记录目前正在读出的cell col，起始为0，实际对应于34*34cell中的1
reg [4:0] bin_count;//记录目前正在读出cell的bin值情况
reg bank_start_0;//bank0第一次读
reg bank_start_1;
reg bank_start_2;
reg bank_start_3;
reg bank_addr_valid_0;//bank0读有效
reg bank_addr_valid_1;
reg bank_addr_valid_2;
reg bank_addr_valid_3;
//reg1
reg data_valid_0;
reg data_valid_1;
reg data_valid_2;
reg data_valid_3;
//wire bin_data_valid;
//wire [TOTAL_BIT_WIDTH-1:0] bin_data;

//按照顺序读取cell中的bin值，34*34cell阵列，周围一圈无效，不读取，只读取内部32*32个cell
always @(posedge aclk)begin 
	if(!arest_n)begin 
		rd_bin_cstate <=#DELAY RD_BIN_IDLE;
	end
	else begin 
		rd_bin_cstate <=#DELAY rd_bin_nstate; 
	end
end


always @(*)begin 
	rd_bin_nstate = rd_bin_cstate;
	case(rd_bin_cstate)
		RD_BIN_IDLE:begin 
			if(isr_valid)begin 
				rd_bin_nstate = RD_BIN_BANK0;
			end
			else begin 
				rd_bin_nstate = RD_BIN_IDLE;
			end
		end
		RD_BIN_BANK0:begin //之后是bank1，
			if(bin_count == 5'd0)begin 
				rd_bin_nstate = RD_BIN_BANK1;
			end
			else begin 
				rd_bin_nstate = RD_BIN_BANK0;
			end
		end
		RD_BIN_BANK1:begin 
			if(bin_count == 5'd0)begin //bank1之后，可能继续bank0，也可能到达边界，需要暂停
				if(cell_col == 5'd0)begin //到达边界，需要暂停
					rd_bin_nstate = RD_BIN_WAIT;
				end
				else begin //继续bank0
					rd_bin_nstate = RD_BIN_BANK0;
				end
			end
			else begin 
				rd_bin_nstate = RD_BIN_BANK1;
			end
		end
		RD_BIN_BANK2:begin //bank2之后是bank3
			if(bin_count == 5'd0)begin 
				rd_bin_nstate = RD_BIN_BANK3;
			end
			else begin 
				rd_bin_nstate = RD_BIN_BANK2;
			end
		end
		RD_BIN_BANK3:begin ////bank3之后，可能继续bank2，也可能到达边界，需要暂停,也可能到达最后一个cell，需要回到初始状态
			if(bin_count == 5'd0)begin 
				if(cell_col == 5'd0)begin //可能到达边界，需要暂停,也可能到达最后一个cell，需要回到初始状态
					if(cell_row == 5'd0)begin //到达最后一个cell，需要回到初始状态
						rd_bin_nstate = RD_BIN_IDLE;
					end
					else begin //到达边界，需要暂停
						rd_bin_nstate = RD_BIN_WAIT;
					end
				end
				else begin //继续bank2
					rd_bin_nstate = RD_BIN_BANK2;
				end
			end
			else begin 
				rd_bin_nstate = RD_BIN_BANK3;
			end
		end
		RD_BIN_WAIT:begin 
			if(isr_valid)begin 
				if(cell_row[0] == 1'd1)begin //row== 0:31,当为奇列时，跳到bank2
					rd_bin_nstate = RD_BIN_BANK2;
				end
				else begin //当为偶列时，跳到bank0
					rd_bin_nstate = RD_BIN_BANK0;
				end
			end
			else begin 
				rd_bin_nstate = RD_BIN_WAIT;
			end
		end
		default:begin 
			rd_bin_nstate = RD_BIN_IDLE;
		end
	endcase // rd_bin_cstate
end

//第三段，注意每次跨行暂停后，bank起始地址的变化
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_count <=#DELAY 5'd0;
		cell_row <=#DELAY 5'd0;
		cell_col <=#DELAY 5'd0;
		normal_addr_0 <=#DELAY 13'd0;
		normal_addr_1 <=#DELAY 13'd0;
		normal_addr_2 <=#DELAY 13'd0;
		normal_addr_3 <=#DELAY 13'd0;
		bank_start_0 <=#DELAY 1'd0;
		bank_start_1 <=#DELAY 1'd0;
		bank_start_2 <=#DELAY 1'd0;
		bank_start_3 <=#DELAY 1'd0;
		bank_addr_valid_0 <=#DELAY 1'd0;
		bank_addr_valid_1 <=#DELAY 1'd0;
		bank_addr_valid_2 <=#DELAY 1'd0;
		bank_addr_valid_3 <=#DELAY 1'd0;
	end
	else begin 
		case(rd_bin_nstate)
			RD_BIN_IDLE:begin 
				bin_count <=#DELAY 5'd0;
				cell_row <=#DELAY 5'd0;
				cell_col <=#DELAY 5'd0;
				normal_addr_0 <=#DELAY 13'd0;
				normal_addr_1 <=#DELAY 13'd0;
				normal_addr_2 <=#DELAY 13'd0;
				normal_addr_3 <=#DELAY 13'd0;
				bank_start_0 <=#DELAY 1'd0;
				bank_start_1 <=#DELAY 1'd0;
				bank_start_2 <=#DELAY 1'd0;
				bank_start_3 <=#DELAY 1'd0;
				bank_addr_valid_0 <=#DELAY 1'd0;
				bank_addr_valid_1 <=#DELAY 1'd0;
				bank_addr_valid_2 <=#DELAY 1'd0;
				bank_addr_valid_3 <=#DELAY 1'd0;
			end
			RD_BIN_BANK0:begin 
				bank_addr_valid_0 <=#DELAY 1'd1;
				bank_addr_valid_1 <=#DELAY 1'd0;
				bank_addr_valid_2 <=#DELAY 1'd0;
				bank_addr_valid_3 <=#DELAY 1'd0;
				if(bank_start_0)begin //后续地址++
					if(bin_count[0] == 1'd1)begin//已读完奇数个bin
						normal_addr_0 <=#DELAY normal_addr_0 + 13'd9;
					end 
					else begin 
						if(bin_count == 5'd0)begin //本cell读取bin0时
							normal_addr_0 <=#DELAY normal_addr_0 + 13'd1;
						end
						else begin //已读完偶数个bin（除开第一次bin0）
							normal_addr_0 <=#DELAY normal_addr_0 - 13'd8;
						end
					end
				end
				else begin //未开始，即该bank第一次读取地址为0
					bank_start_0 <=#DELAY 1'd1;
					normal_addr_0 <=#DELAY 13'd0;
				end

				if(bin_count == 5'd17)begin //读取本cell中的第17bin
					bin_count <=#DELAY 5'd0;
					cell_col <=#DELAY cell_col + 5'd1;
				end
				else begin 
					bin_count <=#DELAY bin_count + 5'd1;
				end
			end
			RD_BIN_BANK1:begin 
				bank_addr_valid_0 <=#DELAY 1'd0;
				bank_addr_valid_1 <=#DELAY 1'd1;
				bank_addr_valid_2 <=#DELAY 1'd0;
				bank_addr_valid_3 <=#DELAY 1'd0;
				if(bank_start_1)begin //后续地址++
					if(bin_count[0] == 1'd1)begin//已读完奇数个bin
						normal_addr_1 <=#DELAY normal_addr_1 + 13'd9;
					end 
					else begin 
						if(bin_count == 5'd0)begin //本cell读取bin0时
							normal_addr_1 <=#DELAY normal_addr_1 + 13'd1;
						end
						else begin //已读完偶数个bin（除开第一次bin0）
							normal_addr_1 <=#DELAY normal_addr_1 - 13'd8;
						end
					end
				end
				else begin //未开始，即该bank第一次读取地址为18
					bank_start_1 <=#DELAY 1'd1;
					normal_addr_1 <=#DELAY 13'd18;
				end

				if(bin_count == 5'd17)begin //本cell最后一个bin
					bin_count <=#DELAY 5'd0;
					if(cell_col == 5'd31)begin //如果到边界，col = 0，row++
						cell_col <=#DELAY 5'd0;
						cell_row <=#DELAY cell_row + 5'd1;
					end
					else begin //否则col++
						cell_col <=#DELAY cell_col + 5'd1;
					end
				end
				else begin //不是最后一个bin
					bin_count <=#DELAY bin_count + 5'd1;
				end
			end
			RD_BIN_BANK2:begin 
				bank_addr_valid_0 <=#DELAY 1'd0;
				bank_addr_valid_1 <=#DELAY 1'd0;
				bank_addr_valid_2 <=#DELAY 1'd1;
				bank_addr_valid_3 <=#DELAY 1'd0;
				if(bank_start_2)begin //后续地址++
					if(bin_count[0] == 1'd1)begin//已读完奇数个bin
						normal_addr_2 <=#DELAY normal_addr_2 + 13'd9;
					end 
					else begin 
						if(bin_count == 5'd0)begin //本cell读取bin0时
							normal_addr_2 <=#DELAY normal_addr_2 + 13'd1;
						end
						else begin //已读完偶数个bin（除开第一次bin0）
							normal_addr_2 <=#DELAY normal_addr_2 - 13'd8;
						end
					end
				end
				else begin //未开始，即该bank第一次读取地址为306，即17*18
					bank_start_2 <=#DELAY 1'd1;
					normal_addr_2 <=#DELAY 13'd306;
				end

				if(bin_count == 5'd17)begin //本cell最后一个bin
					bin_count <=#DELAY 5'd0;
					cell_col <=#DELAY cell_col + 5'd1;
				end
				else begin 
					bin_count <=#DELAY bin_count + 5'd1;
				end
			end
			RD_BIN_BANK3:begin 
				bank_addr_valid_0 <=#DELAY 1'd0;
				bank_addr_valid_1 <=#DELAY 1'd0;
				bank_addr_valid_2 <=#DELAY 1'd0;
				bank_addr_valid_3 <=#DELAY 1'd1;
				if(bank_start_3)begin //后续地址++
					if(bin_count[0] == 1'd1)begin//已读完奇数个bin
						normal_addr_3 <=#DELAY normal_addr_3 + 13'd9;
					end 
					else begin 
						if(bin_count == 5'd0)begin //本cell读取bin0时
							normal_addr_3 <=#DELAY normal_addr_3 + 13'd1;
						end
						else begin //已读完偶数个bin（除开第一次bin0）
							normal_addr_3 <=#DELAY normal_addr_3 - 13'd8;
						end
					end
				end
				else begin //未开始，即该bank第一次读取地址为18*18
					bank_start_3 <=#DELAY 1'd1;
					normal_addr_3 <=#DELAY 13'd324;
				end

				if(bin_count == 5'd17)begin 
					bin_count <=#DELAY 5'd0;
					if(cell_col == 5'd31)begin
						cell_col <=#DELAY 5'd0; 
						if(cell_row == 5'd31)begin 
							cell_row <=#DELAY 5'd0;
						end
						else begin 
							cell_row <=#DELAY cell_row + 5'd1;
						end
					end
					else begin 
						cell_col <=#DELAY cell_col + 5'd1;
					end
				end
				else begin 
					bin_count <=#DELAY bin_count + 5'd1;
				end
			end
			RD_BIN_WAIT:begin 
				bank_addr_valid_0 <=#DELAY 1'd0;
				bank_addr_valid_1 <=#DELAY 1'd0;
				bank_addr_valid_2 <=#DELAY 1'd0;
				bank_addr_valid_3 <=#DELAY 1'd0;
				if(rd_bin_cstate == RD_BIN_BANK1)begin 
					normal_addr_0 <=#DELAY normal_addr_0 + 13'd18;
					normal_addr_1 <=#DELAY normal_addr_1 + 13'd18;
				end
				if(rd_bin_cstate == RD_BIN_BANK3)begin 
					normal_addr_2 <=#DELAY normal_addr_2 + 13'd18;
					normal_addr_3 <=#DELAY normal_addr_3 + 13'd18;
				end
			end
			default:begin 
				bin_count <=#DELAY 5'd0;
				cell_row <=#DELAY 5'd0;
				cell_col <=#DELAY 5'd0;
				normal_addr_0 <=#DELAY 13'd0;
				normal_addr_1 <=#DELAY 13'd0;
				normal_addr_2 <=#DELAY 13'd0;
				normal_addr_3 <=#DELAY 13'd0;
				bank_start_0 <=#DELAY 1'd0;
				bank_start_1 <=#DELAY 1'd0;
				bank_start_2 <=#DELAY 1'd0;
				bank_start_3 <=#DELAY 1'd0;
				bank_addr_valid_0 <=#DELAY 1'd0;
				bank_addr_valid_1 <=#DELAY 1'd0;
				bank_addr_valid_2 <=#DELAY 1'd0;
				bank_addr_valid_3 <=#DELAY 1'd0;
			end
		endcase // rd_bin_nstate
	end
end
/////reg1
//bin数据有效
always @(posedge aclk)begin 
	if(!arest_n)begin 
		data_valid_0 <=#DELAY 1'd0;
		data_valid_1 <=#DELAY 1'd0;
		data_valid_2 <=#DELAY 1'd0;
		data_valid_3 <=#DELAY 1'd0;
	end
	else begin 
		data_valid_0 <=#DELAY bank_addr_valid_0;
		data_valid_1 <=#DELAY bank_addr_valid_1;
		data_valid_2 <=#DELAY bank_addr_valid_2;
		data_valid_3 <=#DELAY bank_addr_valid_3;
	end
end

assign bin_data_valid = data_valid_0 | data_valid_1 | data_valid_2 | data_valid_3;
assign bin_data = (data_valid_0) ? dout_0 : ((data_valid_1) ? dout_1 : ((data_valid_2) ? dout_2 : ((data_valid_3) ? dout_3 : 'd0)));

endmodule