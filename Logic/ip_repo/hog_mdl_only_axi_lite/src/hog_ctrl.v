// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-27 11:11:46
// Author : Liman
// Email  : 944768976@qq.com
// File   : hog_ctrl.v
// Description ：
// Revise : 2023-02-17 22:10:07
// Version:
// Revision:
// -----------------------------------------------------------------------------
`timescale 1ns/1ns
module hog_ctrl #(
	parameter AXIL_AW = 7,
	parameter AXIL_DW = 32,
	parameter DELAY = 1 
	)(
		input aclk,    // Clock
		input arest_n,  // Asynchronous reset active low


		//AXI-Lite
	 	input [AXIL_AW-1:0] 	s_axil_awaddr,
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

	    input [AXIL_AW-1:0] 	s_axil_araddr,
	    input [2:0] 			s_axil_arprot,
	    input 					s_axil_arvalid,
	    output 					s_axil_arready,

	    output [AXIL_DW-1:0] 	s_axil_rdata,
	    output [1:0] 			s_axil_rresp,
	    output 					s_axil_rvalid,
	    input 					s_axil_rready,	

	// ctrl reg 
		(*mark_debug="true"*)(*keep = "true"*)output reg [AXIL_DW-1:0] mb_ctrl,//bit0 == 1 == start master; bit1 == 1 == stop master ;230315:增加软件复位，bit2 == 1 == rst_n
		(*mark_debug="true"*)(*keep = "true"*)output reg [AXIL_DW-1:0] rd_wr_irq,//bit0 == 1 == rd1; bit1 == 1 == wr1 
		
		(*mark_debug="true"*)(*keep = "true"*)output reg [AXIL_DW-1:0] soft_trigger_en,

		(*mark_debug="true"*)(*keep = "true"*)output reg [AXIL_DW-1:0] rd1_config_3,//source addr
		(*mark_debug="true"*)(*keep = "true"*)output reg [AXIL_DW-1:0] rd1_config_4,//data_length
		
		output reg [AXIL_DW-1:0] wr1_config_3,//dest addr
		output reg [AXIL_DW-1:0] wr1_config_4,//data_length

		(*mark_debug="true"*)(*keep = "true"*)output hog_start_irq,
		output reg [15:0] img0x,
		output reg [15:0] img0y,
		output reg [31:0] absolute_addr,
		output reg [31:0] cross_row_offset,
		output reg [31:0] scale_x,
		output reg [31:0] scale_y,
		output reg [31:0] scale_n,
		output reg [31:0] test_mode,
		input [3:0] img_status,
		input [31:0] axi_status,
		input [4:0]	circuit_busy,
		input [1:0] rd1_wr1_done
	
);


reg [31:0] rd1_config_1;
reg [31:0] rd1_config_2;
//reg [31:0] rd1_config_3;
//reg [31:0] rd1_config_4;
reg [31:0] rd1_config_5;


reg [31:0] wr1_config_1;
reg [31:0] wr1_config_2;
//reg [31:0] wr1_config_3;
//reg [31:0] wr1_config_4;
reg [31:0] wr1_config_5;

reg hog_start;
reg hog_start_r1;
reg [31:0] default_data;




reg reg_awready;
reg reg_wready;
reg reg_bvalid;
reg reg_arready;
reg [AXIL_DW-1:0] reg_rdata;
reg reg_rvalid;

reg wr_en;//用于确保此次写传输完成

wire b_handshake;

reg [2:0] int_cnt;//用于产生中断脉冲宽度计数

reg rd_en;//用于确保读传输完成

//AXIL
assign s_axil_awready = reg_awready;

assign s_axil_wready = reg_wready;

assign s_axil_bresp = 2'b00;
assign s_axil_bvalid = reg_bvalid;

assign s_axil_arready = reg_arready;

assign s_axil_rdata = reg_rdata;
assign s_axil_rresp = 2'b00;
assign s_axil_rvalid = reg_rvalid;
//

assign b_handshake = s_axil_bready & s_axil_bvalid;

//aw 
always @(posedge aclk)begin 
 if(!arest_n)begin 
 	reg_awready <=#DELAY 1'b0;
 	wr_en <=#DELAY 1'b1;
 end
 else begin 
 	if(!reg_awready && s_axil_awvalid && s_axil_wvalid && wr_en)begin 
 		reg_awready <=#DELAY 1'b1;
 		wr_en <=#DELAY 1'b0;
 	end
 	else if(b_handshake == 1'b1)begin 
 		reg_awready <=#DELAY 1'b0;
 		wr_en <=#DELAY 1'b1;
 	end
 	else begin 
 		reg_awready <=#DELAY 1'b0;
 	end
 end
end

//w
always @(posedge aclk)begin 
	if(!arest_n)begin 
		reg_wready <=#DELAY 1'b0;
	end
	else begin 
		if(!reg_wready && s_axil_awvalid && s_axil_wvalid && wr_en)begin
			reg_wready <=#DELAY 1'b1;
		end
		else begin 
			reg_wready <=#DELAY 1'b0;
		end
	end
end

//b 
always @(posedge aclk)begin 
	if(!arest_n)begin 
		reg_bvalid <=#DELAY 1'b0;
	end
	else begin 
		if(!reg_bvalid && s_axil_awvalid && s_axil_awready && s_axil_wvalid && s_axil_wready)begin 
			reg_bvalid <=#DELAY 1'b1;
		end
		else begin 
			if(b_handshake == 1'b1 || reg_bvalid == 1'b0)
				reg_bvalid <=#DELAY 1'b0;
			else
				reg_bvalid <=#DELAY 1'b1;
		end
	end
end

//write data to reg or clearning reg

 always @(posedge aclk)begin 
 	if(!arest_n)begin 
 		mb_ctrl <=#DELAY 32'd0;
		rd_wr_irq <=#DELAY 32'd0;
		soft_trigger_en <=#DELAY 32'd0;

		rd1_config_1 <=#DELAY 32'd0;
		rd1_config_2 <=#DELAY 32'd0;
		rd1_config_3 <=#DELAY 32'd0;
		rd1_config_4 <=#DELAY 32'd0;
		rd1_config_5 <=#DELAY 32'd0;

		wr1_config_1 <=#DELAY 32'd0;
		wr1_config_2 <=#DELAY 32'd0;
		wr1_config_3 <=#DELAY 32'd0;
		wr1_config_4 <=#DELAY 32'd0;
		wr1_config_5 <=#DELAY 32'd0;

 		hog_start <=#DELAY 1'd0;
		img0x <=#DELAY 16'd0; 
		img0y <=#DELAY 16'd0; 
		absolute_addr <=#DELAY 32'd0; 
		cross_row_offset <=#DELAY 32'd0; 
		scale_x <=#DELAY 32'd0; 
		scale_y <=#DELAY 32'd0; 
		scale_n <=#DELAY 32'd0; 
		test_mode <=#DELAY 32'd0;
		default_data <=#DELAY 32'd0;

 	end
 	else begin 
 		if(s_axil_awvalid && s_axil_awready &&s_axil_wvalid && s_axil_wready)begin 
 			case(s_axil_awaddr[AXIL_AW-1:2])
 				5'd0:mb_ctrl <=#DELAY s_axil_wdata;
 				5'd1:rd_wr_irq <=#DELAY s_axil_wdata;

 				5'd3:soft_trigger_en <=#DELAY s_axil_wdata;

 				5'd5:rd1_config_1 <=#DELAY s_axil_wdata;
 				5'd6:rd1_config_2 <=#DELAY s_axil_wdata;
 				5'd7:rd1_config_3 <=#DELAY s_axil_wdata;
				5'd8:rd1_config_4 <=#DELAY s_axil_wdata;
				5'd9:rd1_config_5 <=#DELAY s_axil_wdata;

				5'd10:wr1_config_1 <=#DELAY s_axil_wdata;
				5'd11:wr1_config_2 <=#DELAY s_axil_wdata;
				5'd12:wr1_config_3 <=#DELAY s_axil_wdata;//dest addr
				5'd13:wr1_config_4 <=#DELAY s_axil_wdata;//data_length
				5'd14:wr1_config_5 <=#DELAY s_axil_wdata;

				5'd15:hog_start <=#DELAY s_axil_wdata[0];//从字节地址60开始,加上上面的两个
				5'd16:begin 
					img0x <=#DELAY s_axil_wdata[15:0];
					img0y <=#DELAY s_axil_wdata[31:16];
				end
				5'd17:absolute_addr <=#DELAY s_axil_wdata;
				5'd18:cross_row_offset <=#DELAY s_axil_wdata;
				5'd19:scale_x <=#DELAY s_axil_wdata;
				5'd20:scale_y <=#DELAY s_axil_wdata;
				5'd21:scale_n <=#DELAY s_axil_wdata;
				5'd22:test_mode <=#DELAY s_axil_wdata;


 				default:default_data <=#DELAY 32'd0;
 			endcase // s_axil_awaddr
 		end
 		else begin 
 			mb_ctrl <=#DELAY 32'd0;
			rd_wr_irq <=#DELAY 32'd0;
			if(rd1_wr1_done[1])begin 
				hog_start <=#DELAY 1'd0;
			end
 		end
 	end
 end


//ar
always @(posedge aclk)begin 
	if(!arest_n)begin 
		reg_arready <=#DELAY 1'b0;
		rd_en <=#DELAY 1'b1;
	end
	else begin 
		if(!reg_arready && s_axil_arvalid && rd_en)begin 
			reg_arready <=#DELAY 1'b1;
			rd_en <=#DELAY 1'b0;
		end
		else begin 
			if(s_axil_rready && s_axil_rvalid)begin 
				rd_en <=#DELAY 1'b1;
				reg_arready <=#DELAY 1'b0;
			end
			else 
				reg_arready <=#DELAY 1'b0;
		end
	end
end

//r
always @(posedge aclk)begin 
	if(!arest_n)begin 
		reg_rdata <=#DELAY 32'd0;
		reg_rvalid <=#DELAY 1'b0;
	end
	else begin 
		if(!reg_rvalid && s_axil_arvalid && s_axil_arready)begin 
			case(s_axil_araddr[AXIL_AW-1:2])
				5'd0:reg_rdata <=#DELAY mb_ctrl;
				5'd1:reg_rdata <=#DELAY rd_wr_irq;

				5'd3:reg_rdata <=#DELAY soft_trigger_en;

				5'd5:reg_rdata <=#DELAY rd1_config_1;
				5'd6:reg_rdata <=#DELAY rd1_config_2;
				5'd7:reg_rdata <=#DELAY rd1_config_3;
				5'd8:reg_rdata <=#DELAY rd1_config_4;
				5'd9:reg_rdata <=#DELAY rd1_config_5;

				5'd10:reg_rdata <=#DELAY wr1_config_1;
				5'd11:reg_rdata <=#DELAY wr1_config_2;
				5'd12:reg_rdata <=#DELAY wr1_config_3;
				5'd13:reg_rdata <=#DELAY wr1_config_4;
				5'd14:reg_rdata <=#DELAY wr1_config_5;

				5'd15:reg_rdata <=#DELAY {30'd0,hog_start};
				5'd16:reg_rdata <=#DELAY {img0y,img0x};
				5'd17:reg_rdata <=#DELAY absolute_addr;
				5'd18:reg_rdata <=#DELAY cross_row_offset;
				5'd19:reg_rdata <=#DELAY scale_x;
				5'd20:reg_rdata <=#DELAY scale_y;
				5'd21:reg_rdata <=#DELAY scale_n;
				5'd22:reg_rdata <=#DELAY test_mode;
				//status,提供给dsp或者上位机读取内部电路状态
				5'd23:reg_rdata <=#DELAY {28'd0,img_status};//{next_state,state}
				5'd24:reg_rdata <=#DELAY axi_status;//{{1'd0,w_nstate},{1'd0,w_cstate},{1'd0,aw_nstate},{1'd0,aw_cstate},r_nstate,r_cstate,{1'd0,ar_nstate},{1'd0,ar_cstate}}
				5'd25:reg_rdata <=#DELAY {27'd0,circuit_busy};//{write_busy,feature_busy,histogram_busy,scaling_busy,read_busy}

				default:reg_rdata <=#DELAY default_data;
			endcase // s_axil_araddr[AXIL_AW-1:2]
			reg_rvalid <=#DELAY 1'b1;
		end
		else begin 
			if(s_axil_rvalid && s_axil_rready)
				reg_rvalid <=#DELAY 1'b0;
		end
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		hog_start_r1 <=#DELAY 1'd0;
	end
	else begin 
		hog_start_r1 <=#DELAY hog_start;
	end
end

assign hog_start_irq = hog_start & (!hog_start_r1);


endmodule
