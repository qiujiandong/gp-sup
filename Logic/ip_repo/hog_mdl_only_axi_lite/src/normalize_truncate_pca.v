// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-10-18 15:22:56
// Author : Liman
// Email  : 944768976@qq.com
// File   : normalize_truncate_pca.v
// Description ：
// Revise : 2023-02-17 22:12:23
// Version:
// Revision:
// -----------------------------------------------------------------------------

`timescale 1ns/1ns

module normalize_truncate_pca #(
	parameter PARAM_TRUNCATE    = 35'd51,//int(0.2 << QN)
	parameter PARAM_GAMA		= 35'd60,//int(1/(根号18) << QN)
	parameter QN 				= 8,
	parameter TOTAL_BIT_WIDTH 	= 35,
	parameter DELAY 			= 1
	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low
	
	input window_valid,//3*3cell平方和窗口有效
	input [TOTAL_BIT_WIDTH-1:0] sos_reg1,
	input [TOTAL_BIT_WIDTH-1:0] sos_reg2,
	input [TOTAL_BIT_WIDTH-1:0] sos_reg3,
	input [TOTAL_BIT_WIDTH-1:0] sos_reg4,
	input [TOTAL_BIT_WIDTH-1:0] sos_reg5,
	input [TOTAL_BIT_WIDTH-1:0] sos_reg6,
	input [TOTAL_BIT_WIDTH-1:0] sos_reg7,
	input [TOTAL_BIT_WIDTH-1:0] sos_reg8,
	input [TOTAL_BIT_WIDTH-1:0] sos_reg9,

	output [12:0] normal_addrb_0,//bram_cell_bin b端口
	output [12:0] normal_addrb_1,
	output [12:0] normal_addrb_2,
	output [12:0] normal_addrb_3,
	input [TOTAL_BIT_WIDTH-1 : 0] doutb_0,
	input [TOTAL_BIT_WIDTH-1 : 0] doutb_1,
	input [TOTAL_BIT_WIDTH-1 : 0] doutb_2,
	input [TOTAL_BIT_WIDTH-1 : 0] doutb_3,

	output reg bin0_17_feature_valid,//最终输出结果
	output reg bin18_26_feature_valid,
	output reg bin27_30_feature_valid,
	output [QN-1:0] bin0_17,
	output [QN-1:0] bin18_26,
	output [QN-1:0] bin27_30
);

//计算四个block的和
localparam BLOCK_IDLE = 3'd0;
localparam BLOCK_RD = 3'd1;
localparam BLOCK_RU = 3'd2;
localparam BLOCK_LD = 3'd3;
localparam BLOCK_LU = 3'd4;

//逆平方根近似计算使用到的神奇数字
localparam MAGIC_NUM = 32'h5f37_59df;//神奇数字

//保存两组逆平方根
localparam ISR_IDLE = 2'd0;
localparam ISR_GROUP0 = 2'd1;
localparam ISR_GROUP1 = 2'd2;
localparam ISR_WAIT = 2'd3;


//reg0
reg [2:0] block_cstate,block_nstate;
reg block_valid;
reg [TOTAL_BIT_WIDTH-1:0] block_sos;//block中的四个cell的平方和
//reg1
wire int_to_f_tready;//fixed_to_float IP 用到的信号
wire f_result_tvalid;
wire [31:0] f_result_tdata;//输入的r的float值
reg [TOTAL_BIT_WIDTH-1:0] block_sos_r1;
//reg2
reg [31:0] y_float;//r的逆平方根的float值y
reg y_float_valid;
reg [TOTAL_BIT_WIDTH-1:0] block_sos_r2;
//reg3
wire f_to_int_tready;
wire y_int_tvalid;
wire [39:0] y_int;//float值y转为定点数int的值
reg [TOTAL_BIT_WIDTH-1:0] block_sos_r3;
//reg4
wire [TOTAL_BIT_WIDTH*2-1:0] y_square;//y_int*y_int
reg y_square_valid;
reg [TOTAL_BIT_WIDTH-1:0] block_sos_r4;
reg [TOTAL_BIT_WIDTH-1:0] y_int_r1;
//reg5
wire [TOTAL_BIT_WIDTH*2-1:0] y_y_r;//y_int*y_int*r
reg y_y_r_valid;
reg [TOTAL_BIT_WIDTH-1:0] y_int_r2;
//reg6
reg [TOTAL_BIT_WIDTH-1:0] _3_sub_yyr;//3-y_int*y_int*r
reg _3_sub_yyr_valid;
reg [TOTAL_BIT_WIDTH-1:0] y_int_r3;
//reg7
wire [TOTAL_BIT_WIDTH*2-1:0] inverse_sqre_root;//y_int*(3-y_int*y_int*r),然后>>(QN+1),即有效位：[TOTAL_BIT_WIDTH+QN:QN+1]
reg inverse_sqre_root_valid;

//reg8-11
reg [1:0] isr_cstate,isr_nstate;
reg [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_0_0;//右下
reg [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_0_1;//右上
reg [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_0_2;//左下
reg [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_0_3;//左上
reg [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_1_0;//右下
reg [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_1_1;//右上
reg [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_1_2;//左下
reg [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_1_3;//左上
reg isr_flag;//0时，将平方根保存在：缓存0 1时，将平方根保存在：缓存1
reg [11:0] isr_count;//计数出来逆平方根的个数
reg isr_valid;//启动信号，启动b端口读操作
//根据isr_flag选择
wire [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_0;//右下
wire [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_1;//右上
wire [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_2;//左下
wire [TOTAL_BIT_WIDTH-1:0] inverse_sqre_root_3;//左上

////reg10 开始从b端口读取bin值，进行normalize、pca
wire bin_data_valid;
wire [TOTAL_BIT_WIDTH-1:0] bin_data;

//reg12
wire [TOTAL_BIT_WIDTH*2-1:0] bin0_17_normal_0;
wire [TOTAL_BIT_WIDTH*2-1:0] bin0_17_normal_1;
wire [TOTAL_BIT_WIDTH*2-1:0] bin0_17_normal_2;
wire [TOTAL_BIT_WIDTH*2-1:0] bin0_17_normal_3;
reg bin0_17_normal_valid;

wire [TOTAL_BIT_WIDTH-1:0] bin0_17_truncate_0;
wire [TOTAL_BIT_WIDTH-1:0] bin0_17_truncate_1;
wire [TOTAL_BIT_WIDTH-1:0] bin0_17_truncate_2;
wire [TOTAL_BIT_WIDTH-1:0] bin0_17_truncate_3;

reg [TOTAL_BIT_WIDTH-1:0] bin_data_r1;
reg bin_data_count;

wire [TOTAL_BIT_WIDTH-1:0] bin_0_9_sum;
wire bin_0_9_sum_valid;
//reg13
reg [QN-1:0] bin0_17_pca;
reg bin0_17_pca_valid;

wire [TOTAL_BIT_WIDTH*2-1:0] bin18_26_normal_0;
wire [TOTAL_BIT_WIDTH*2-1:0] bin18_26_normal_1;
wire [TOTAL_BIT_WIDTH*2-1:0] bin18_26_normal_2;
wire [TOTAL_BIT_WIDTH*2-1:0] bin18_26_normal_3;
reg bin18_26_normal_valid;

wire [TOTAL_BIT_WIDTH-1:0] bin18_26_truncate_0;
wire [TOTAL_BIT_WIDTH-1:0] bin18_26_truncate_1;
wire [TOTAL_BIT_WIDTH-1:0] bin18_26_truncate_2;
wire [TOTAL_BIT_WIDTH-1:0] bin18_26_truncate_3;

reg [TOTAL_BIT_WIDTH-1:0] bin27_30_truncate_0;
reg [TOTAL_BIT_WIDTH-1:0] bin27_30_truncate_1;
reg [TOTAL_BIT_WIDTH-1:0] bin27_30_truncate_2;
reg [TOTAL_BIT_WIDTH-1:0] bin27_30_truncate_3;
reg bin27_30_truncate_valid;
reg [4:0] bin0_17_sum_count;//对于bin26——30，需要求和bin0-17的截断之后的值

//reg14
reg [QN-1:0] bin18_26_pca;
reg bin18_26_pca_valid;

wire [TOTAL_BIT_WIDTH*2-1:0] bin27_30_pca_0;
wire [TOTAL_BIT_WIDTH*2-1:0] bin27_30_pca_1;
wire [TOTAL_BIT_WIDTH*2-1:0] bin27_30_pca_2;
wire [TOTAL_BIT_WIDTH*2-1:0] bin27_30_pca_3;
reg bin27_30_pca_valid;

//产生hamming读地址
reg [4:0] cell_row;//目前cell所在的位置
reg [4:0] cell_col;
wire [3:0] hamming_row;//cell位置映射到hamming窗左上角的位置
wire [3:0] hamming_col;
wire [7:0] hamming_addr;
wire [QN-1:0] hamming_data;
reg [QN-1:0] hamming_data_r1;

reg [QN-1:0] bin27_30_pca_1_r1;//因为bin27-30同时有效，需要寄存，方便后续的feature计算和写入到bram
reg [QN-1:0] bin27_30_pca_2_r1;//因为bin27-30同时有效，需要寄存，方便后续的feature计算和写入到bram
reg [QN-1:0] bin27_30_pca_3_r1;//因为bin27-30同时有效，需要寄存，方便后续的feature计算和写入到bram

//最终结果
//reg bin0_17_feature_valid;
//reg bin18_26_feature_valid;
//reg bin27_30_feature_valid;
wire [QN*2-1:0] bin0_17_feature;
wire [QN*2-1:0] bin18_26_feature;
wire [QN*2-1:0] bin27_30_feature;
reg [1:0] bin27_30_count;//记录bin27-30有效的个数
reg [QN-1:0] bin27_30_pca;//通过bin27_30_count选择 bin27_30_pca_0-3


//////reg0
//产生四个block求和的r
//FSM
always @(posedge aclk)begin 
	if(!arest_n)begin 
		block_cstate <=#DELAY BLOCK_IDLE;
	end
	else begin 
		block_cstate <=#DELAY block_nstate;
	end
end

always @(*)begin 
	block_nstate = block_cstate;
	case(block_cstate)
		BLOCK_IDLE:begin 
			if(window_valid)begin 
				block_nstate = BLOCK_RD;
			end
			else begin 
				block_nstate = BLOCK_IDLE;
			end
		end
		BLOCK_RD:begin 
			block_nstate = BLOCK_RU;
		end
		BLOCK_RU:begin 
			block_nstate = BLOCK_LD;
		end
		BLOCK_LD:begin 
			block_nstate = BLOCK_LU;
		end
		BLOCK_LU:begin 
			block_nstate = BLOCK_IDLE;
		end
		default:begin 
			block_nstate = BLOCK_IDLE;
		end
	endcase // block_cstate
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		block_valid <=#DELAY 1'd0;
		block_sos <=#DELAY 'd0;
	end
	else begin 
		case(block_nstate)
			BLOCK_IDLE:begin 
				block_valid <=#DELAY 1'd0;
				block_sos <=#DELAY 'd0;
			end
			BLOCK_RD:begin //右下block求和，加上一个极小值1
				block_valid <=#DELAY 1'd1;
				block_sos <=#DELAY sos_reg1 + sos_reg2 + sos_reg4 + sos_reg5 + 1'd1;
			end
			BLOCK_RU:begin //右上block求和，加上一个极小值1
				block_valid <=#DELAY 1'd1;
				block_sos <=#DELAY sos_reg4 + sos_reg5 + sos_reg7 + sos_reg8 + 1'd1;
			end
			BLOCK_LD:begin 
				block_valid <=#DELAY 1'd1;
				block_sos <=#DELAY sos_reg2 + sos_reg3 + sos_reg5 + sos_reg6 + 1'd1;
			end
			BLOCK_LU:begin 
				block_valid <=#DELAY 1'd1;
				block_sos <=#DELAY sos_reg5 + sos_reg6 + sos_reg8 + sos_reg9 + 1'd1;
			end
			default:begin 
				block_valid <=#DELAY 1'd0;
				block_sos <=#DELAY 'd0;
			end
		endcase // block_nstate
	end
end

//////reg1
fixed_to_float int_to_float (
  .aclk(aclk),                                  // input wire aclk
  .aresetn(arest_n),                            // input wire aresetn
  .s_axis_a_tvalid(block_valid),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(int_to_f_tready),            // output wire s_axis_a_tready
  .s_axis_a_tdata({{64-TOTAL_BIT_WIDTH{1'd0}},block_sos}),              // input wire [63 : 0] s_axis_a_tdata
  .m_axis_result_tvalid(f_result_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(f_result_tdata)    // output wire [31 : 0] m_axis_result_tdata
);

always @(posedge aclk)begin 
	if(!arest_n)begin 
		block_sos_r1 <=#DELAY 'd0;
	end
	else begin 
		block_sos_r1 <=#DELAY block_sos;
	end
end
//////reg2
//神奇数字 - (float>>1) = y的float值
always @(posedge aclk)begin 
	if(!arest_n)begin 
		y_float_valid <=#DELAY 1'd0;
		y_float <=#DELAY 32'd0;
	end
	else begin 
		y_float <=#DELAY MAGIC_NUM - (f_result_tdata >> 1);
		y_float_valid <=#DELAY f_result_tvalid;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		block_sos_r2 <=#DELAY 'd0;
	end
	else begin 
		block_sos_r2 <=#DELAY block_sos_r1;
	end
end
//////reg3
//y的float值转为int值，并且保留小数后12bit，12bit = QN+QN/2; Qn = 10时，为15bit
/*
float32_to_point27_8 float_to_int (
  .aclk(aclk),                                  // input wire aclk
  .aresetn(arest_n),                            // input wire aresetn
  .s_axis_a_tvalid(y_float_valid),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(f_to_int_tready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(y_float),              // input wire [31 : 0] s_axis_a_tdata
  .m_axis_result_tvalid(y_int_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(y_int)    // output wire [39 : 0] m_axis_result_tdata
);*/
float32_to_point float_to_int (
  .aclk(aclk),                                  // input wire aclk
  .aresetn(arest_n),                            // input wire aresetn
  .s_axis_a_tvalid(y_float_valid),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(f_to_int_tready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(y_float),              // input wire [31 : 0] s_axis_a_tdata
  .m_axis_result_tvalid(y_int_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(y_int)    // output wire [39 : 0] m_axis_result_tdata
);

always @(posedge aclk)begin 
	if(!arest_n)begin 
		block_sos_r3 <=#DELAY 'd0;
	end
	else begin 
		block_sos_r3 <=#DELAY block_sos_r2;
	end
end

//////reg4
//y_int*y_int
always @(posedge aclk)begin 
	if(!arest_n)begin 
		y_square_valid <=#DELAY 1'd0;
	end
	else begin 
		y_square_valid <=#DELAY y_int_tvalid;
	end
end
mult_gen_0 y_int_mul_y_int (
  .CLK(aclk),  // input wire CLK
  .A(y_int[TOTAL_BIT_WIDTH-1:0]),      // input wire [34 : 0] A
  .B(y_int[TOTAL_BIT_WIDTH-1:0]),      // input wire [34 : 0] B
  .P(y_square)      // output wire [69 : 0] P
);

always @(posedge aclk)begin 
	if(!arest_n)begin 
		block_sos_r4 <=#DELAY 'd0;
	end
	else begin 
		block_sos_r4 <=#DELAY block_sos_r3;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		y_int_r1 <=#DELAY 'd0;
	end
	else begin 
		y_int_r1 <=#DELAY y_int[TOTAL_BIT_WIDTH-1:0];
	end
end
//////reg5
//y*y*r
always @(posedge aclk)begin 
	if(!arest_n)begin 
		y_y_r_valid <=#DELAY 1'd0;
	end
	else begin 
		y_y_r_valid <=#DELAY y_square_valid;
	end
end

mult_gen_0 y_square_mul_block_sos (
  .CLK(aclk),  // input wire CLK
  .A(y_square[TOTAL_BIT_WIDTH+QN-1:QN]),      // input wire [34 : 0] A
  .B(block_sos_r4),      // input wire [34 : 0] B
  .P(y_y_r)      // output wire [69 : 0] P
);

always @(posedge aclk)begin 
	if(!arest_n)begin 
		y_int_r2 <=#DELAY 'd0;
	end
	else begin 
		y_int_r2 <=#DELAY y_int_r1;
	end
end

//////reg6
//3-y*y*r
always @(posedge aclk)begin 
	if(!arest_n)begin 
		_3_sub_yyr_valid <=#DELAY 1'd0;
	end
	else begin 
		_3_sub_yyr_valid <=#DELAY y_y_r_valid;
	end
end

always @(posedge aclk)begin //3-y*y*r
	if(!arest_n)begin 
		_3_sub_yyr <=#DELAY 'd0;
	end
	else begin 
		_3_sub_yyr <=#DELAY (2'd3 << QN) - y_y_r[TOTAL_BIT_WIDTH+QN-1:QN];
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		y_int_r3 <=#DELAY 'd0;
	end
	else begin 
		y_int_r3 <=#DELAY y_int_r2;
	end
end

//////reg7
//y_int*(3-y_int*y_int*r)，得到inverse_sqre_root（需要>>(QN+1)）
always @(posedge aclk)begin 
	if(!arest_n)begin 
		inverse_sqre_root_valid <=#DELAY 1'd0;
	end
	else begin 
		inverse_sqre_root_valid <=#DELAY _3_sub_yyr_valid;
	end
end

mult_gen_0 get_isr (
  .CLK(aclk),  // input wire CLK
  .A(y_int_r3),      // input wire [34 : 0] A
  .B(_3_sub_yyr),      // input wire [34 : 0] B
  .P(inverse_sqre_root)      // output wire [69 : 0] P
);

//reg8-11
//保存逆平方根 inverse_sqre_root_0_0-3\inverse_sqre_root_1_0-3
//并且产生b端口读操作的启动信号isr_valid
//FSM
always @(posedge aclk)begin 
	if(!arest_n)begin 
		isr_cstate <=#DELAY ISR_IDLE;
	end
	else begin 
		isr_cstate <=#DELAY isr_nstate;
	end
end

always @(*)begin 
	isr_nstate = isr_cstate;
	case(isr_cstate)
		ISR_IDLE:begin 
			if(inverse_sqre_root_valid)begin //0,保存逆平方根至inverse_sqre_root_0_0-3
				isr_nstate = ISR_GROUP0;
			end
			else begin 
				isr_nstate = ISR_IDLE;
			end
		end
		ISR_GROUP0:begin 
			if(isr_count[1:0] == 2'd0)begin //本cell四个逆平方根保存至group0完毕
				isr_nstate = ISR_WAIT;
			end
			else begin 
				isr_nstate = ISR_GROUP0;
			end
		end
		ISR_GROUP1:begin 
			if(isr_count[1:0] == 2'd0)begin //本cell四个逆平方根保存至group1完毕
				isr_nstate = ISR_WAIT;
			end
			else begin 
				isr_nstate = ISR_GROUP1;
			end
		end
		ISR_WAIT:begin 
			if(isr_count == 12'd0)begin //所有逆平方根缓存完毕：32*32*4 = 4k
				isr_nstate = ISR_IDLE;
			end
			else begin 
				if(inverse_sqre_root_valid)begin 
					if(isr_flag)begin //1,保存逆平方根至inverse_sqre_root_1_0-3
						isr_nstate = ISR_GROUP1;
					end
					else begin //0,保存逆平方根至inverse_sqre_root_0_0-3
						isr_nstate = ISR_GROUP0;
					end
				end
				else begin 
					isr_nstate = ISR_WAIT;
				end
			end
		end
		default:begin 
			isr_nstate = ISR_IDLE;
		end
	endcase // isr_cstate
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		inverse_sqre_root_0_0 <=#DELAY 'd0;
		inverse_sqre_root_0_1 <=#DELAY 'd0;
		inverse_sqre_root_0_2 <=#DELAY 'd0;
		inverse_sqre_root_0_3 <=#DELAY 'd0;
		inverse_sqre_root_1_0 <=#DELAY 'd0;
		inverse_sqre_root_1_1 <=#DELAY 'd0;
		inverse_sqre_root_1_2 <=#DELAY 'd0;
		inverse_sqre_root_1_3 <=#DELAY 'd0;
		isr_flag <=#DELAY 1'd0;
		isr_count <=#DELAY 12'd0;
		isr_valid <=#DELAY 1'd0;
	end
	else begin 
		case(isr_nstate)
			ISR_IDLE:begin 
				inverse_sqre_root_0_0 <=#DELAY 'd0;
				inverse_sqre_root_0_1 <=#DELAY 'd0;
				inverse_sqre_root_0_2 <=#DELAY 'd0;
				inverse_sqre_root_0_3 <=#DELAY 'd0;
				inverse_sqre_root_1_0 <=#DELAY 'd0;
				inverse_sqre_root_1_1 <=#DELAY 'd0;
				inverse_sqre_root_1_2 <=#DELAY 'd0;
				inverse_sqre_root_1_3 <=#DELAY 'd0;
				isr_flag <=#DELAY 1'd0;
				isr_count <=#DELAY 12'd0;
				isr_valid <=#DELAY 1'd0;
			end
			ISR_GROUP0:begin 
				inverse_sqre_root_0_3 <=#DELAY inverse_sqre_root[TOTAL_BIT_WIDTH+QN:QN+1];
				inverse_sqre_root_0_2 <=#DELAY inverse_sqre_root_0_3;
				inverse_sqre_root_0_1 <=#DELAY inverse_sqre_root_0_2;
				inverse_sqre_root_0_0 <=#DELAY inverse_sqre_root_0_1;
				isr_count <=#DELAY isr_count + 12'd1;//逆平方根数量计数
				
				if(isr_count[1:0] == 2'd1)begin //与本cell中的第二个逆平方根有效同步
					isr_valid <=#DELAY 1'd1; //产生b端口读操作的启动信号
				end
				else begin 
					isr_valid <=#DELAY 1'd0;
				end

				if(isr_count[1:0] == 2'd3)begin 
					isr_flag <=#DELAY ~isr_flag;//与本cell中的最后一个逆平方根有效同步，为1：后续normalize使用group0值 为0：使用group1值
				end
			end
			ISR_GROUP1:begin 
				inverse_sqre_root_1_3 <=#DELAY inverse_sqre_root[TOTAL_BIT_WIDTH+QN:QN+1];
				inverse_sqre_root_1_2 <=#DELAY inverse_sqre_root_1_3;
				inverse_sqre_root_1_1 <=#DELAY inverse_sqre_root_1_2;
				inverse_sqre_root_1_0 <=#DELAY inverse_sqre_root_1_1;
				isr_count <=#DELAY isr_count + 12'd1;//逆平方根数量计数
				
				if(isr_count[1:0] == 2'd1)begin //与本cell中的第二个逆平方根有效同步
					isr_valid <=#DELAY 1'd1; //产生b端口读操作的启动信号
				end
				else begin 
					isr_valid <=#DELAY 1'd0;
				end

				if(isr_count[1:0] == 2'd3)begin 
					isr_flag <=#DELAY ~isr_flag;//与本cell中的最后一个逆平方根有效同步，为1：后续normalize使用group0值 为0：使用group1值
				end
			end
			ISR_WAIT:; //保持不变
			default:begin 
				inverse_sqre_root_0_0 <=#DELAY 'd0;
				inverse_sqre_root_0_1 <=#DELAY 'd0;
				inverse_sqre_root_0_2 <=#DELAY 'd0;
				inverse_sqre_root_0_3 <=#DELAY 'd0;
				inverse_sqre_root_1_0 <=#DELAY 'd0;
				inverse_sqre_root_1_1 <=#DELAY 'd0;
				inverse_sqre_root_1_2 <=#DELAY 'd0;
				inverse_sqre_root_1_3 <=#DELAY 'd0;
				isr_flag <=#DELAY 1'd0;
				isr_count <=#DELAY 12'd0;
				isr_valid <=#DELAY 1'd0;
			end
		endcase // isr_nstate
	end
end
//产生本cell需要的逆平方根值
assign inverse_sqre_root_0 = isr_flag ? inverse_sqre_root_0_0 : inverse_sqre_root_1_0;//右下
assign inverse_sqre_root_1 = isr_flag ? inverse_sqre_root_0_1 : inverse_sqre_root_1_1;//右上
assign inverse_sqre_root_2 = isr_flag ? inverse_sqre_root_0_2 : inverse_sqre_root_1_2;//左下
assign inverse_sqre_root_3 = isr_flag ? inverse_sqre_root_0_3 : inverse_sqre_root_1_3;//左上

//////当cell的4个逆平方根有效，从b端口读取对应cell的bin值，读取顺序bin0、9、1、10......bin8、17
//reg9：isr_valid有效
//reg10：b端口读操作
//reg11：b端口读数据有效
read_bport_cell_bin #(
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.DELAY(DELAY)
	) inst_read_bport_cell_bin (
		.aclk           (aclk),
		.arest_n        (arest_n),
		.normal_addr_0  (normal_addrb_0),
		.normal_addr_1  (normal_addrb_1),
		.normal_addr_2  (normal_addrb_2),
		.normal_addr_3  (normal_addrb_3),
		.dout_0         (doutb_0),
		.dout_1         (doutb_1),
		.dout_2         (doutb_2),
		.dout_3         (doutb_3),
		.isr_valid      (isr_valid),
		.bin_data_valid (bin_data_valid),
		.bin_data       (bin_data)
	);

//////reg12

//bin0-17:
//bin*逆平方根
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin0_17_normal_valid <=#DELAY 1'd0;
	end
	else begin 
		bin0_17_normal_valid <=#DELAY bin_data_valid;
	end
end

mult_gen_0 bin0_17_normalize_0 (
  .CLK(aclk),  // input wire CLK
  .A(bin_data),      // input wire [34 : 0] A
  .B(inverse_sqre_root_0),      // input wire [34 : 0] B
  .P(bin0_17_normal_0)      // output wire [69 : 0] P
);
mult_gen_0 bin0_17_normalize_1 (
  .CLK(aclk),  // input wire CLK
  .A(bin_data),      // input wire [34 : 0] A
  .B(inverse_sqre_root_1),      // input wire [34 : 0] B
  .P(bin0_17_normal_1)      // output wire [69 : 0] P
);
mult_gen_0 bin0_17_normalize_2 (
  .CLK(aclk),  // input wire CLK
  .A(bin_data),      // input wire [34 : 0] A
  .B(inverse_sqre_root_2),      // input wire [34 : 0] B
  .P(bin0_17_normal_2)      // output wire [69 : 0] P
);
mult_gen_0 bin0_17_normalize_3 (
  .CLK(aclk),  // input wire CLK
  .A(bin_data),      // input wire [34 : 0] A
  .B(inverse_sqre_root_3),      // input wire [34 : 0] B
  .P(bin0_17_normal_3)      // output wire [69 : 0] P
);

//计算截断，当normalize后大于0.2，截断为0.2
assign bin0_17_truncate_0 = (bin0_17_normal_0[TOTAL_BIT_WIDTH+QN-1:QN] < PARAM_TRUNCATE) ? bin0_17_normal_0[TOTAL_BIT_WIDTH+QN-1:QN] : PARAM_TRUNCATE;
assign bin0_17_truncate_1 = (bin0_17_normal_1[TOTAL_BIT_WIDTH+QN-1:QN] < PARAM_TRUNCATE) ? bin0_17_normal_1[TOTAL_BIT_WIDTH+QN-1:QN] : PARAM_TRUNCATE;
assign bin0_17_truncate_2 = (bin0_17_normal_2[TOTAL_BIT_WIDTH+QN-1:QN] < PARAM_TRUNCATE) ? bin0_17_normal_2[TOTAL_BIT_WIDTH+QN-1:QN] : PARAM_TRUNCATE;
assign bin0_17_truncate_3 = (bin0_17_normal_3[TOTAL_BIT_WIDTH+QN-1:QN] < PARAM_TRUNCATE) ? bin0_17_normal_3[TOTAL_BIT_WIDTH+QN-1:QN] : PARAM_TRUNCATE;

//bin18-26
always @(posedge aclk)begin //寄存bin0、bin2......
	if(!arest_n)begin 
		bin_data_r1 <=#DELAY 'd0;
	end
	else begin 
		bin_data_r1 <=#DELAY bin_data;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_data_count <=#DELAY 1'd0;
	end
	else begin 
		if(bin_data_valid)begin 
			bin_data_count <=#DELAY ~bin_data_count;//奇数个bin时为1，偶数个bin时为0
		end
	end
end

assign bin_0_9_sum = bin_data + bin_data_r1;//bin关于原点对称的两个bin相加
assign bin_0_9_sum_valid = bin_data_valid & bin_data_count;//两个bin相加有效
//////reg13

//bin0_17
//pca
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin0_17_pca_valid <=#DELAY 1'd0;
	end
	else begin 
		bin0_17_pca_valid <=#DELAY bin0_17_normal_valid;
	end
end

always @(posedge aclk)begin //最终结果需要 >> 1
	if(!arest_n)begin 
		bin0_17_pca <=#DELAY 'd0;
	end
	else begin 
		bin0_17_pca <=#DELAY bin0_17_truncate_0[QN-1:0] + bin0_17_truncate_1[QN-1:0] + bin0_17_truncate_2[QN-1:0] + bin0_17_truncate_3[QN-1:0];
	end
end

//bin27_30
//sum(pca)
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin0_17_sum_count <=#DELAY 5'd0;
		bin27_30_truncate_0 <=#DELAY 'd0;
		bin27_30_truncate_1 <=#DELAY 'd0;
		bin27_30_truncate_2 <=#DELAY 'd0;
		bin27_30_truncate_3 <=#DELAY 'd0;

	end
	else begin 
		if(bin0_17_normal_valid)begin //bin0-17数据有效
			if(bin0_17_sum_count == 5'd0)begin //求和第一个bin时，直接赋值
				bin27_30_truncate_0 <=#DELAY bin0_17_truncate_0;
				bin27_30_truncate_1 <=#DELAY bin0_17_truncate_1;
				bin27_30_truncate_2 <=#DELAY bin0_17_truncate_2;
				bin27_30_truncate_3 <=#DELAY bin0_17_truncate_3;
				//bin0_17_sum_count <=#DELAY bin0_17_sum_count + 5'd1;
			end
			else begin //求和后续bin时,需要累加
				bin27_30_truncate_0 <=#DELAY bin27_30_truncate_0 + bin0_17_truncate_0;
				bin27_30_truncate_1 <=#DELAY bin27_30_truncate_1 + bin0_17_truncate_1;
				bin27_30_truncate_2 <=#DELAY bin27_30_truncate_2 + bin0_17_truncate_2;
				bin27_30_truncate_3 <=#DELAY bin27_30_truncate_3 + bin0_17_truncate_3;
				//if(bin0_17_sum_count == 5'd17)begin //求和最后一个bin时，计数回到0
				//	bin0_17_sum_count <=#DELAY 5'd0;
				//end
				//else begin 
				//	bin0_17_sum_count <=#DELAY bin0_17_sum_count + 5'd1;
				//end
			end
			//求和的bin个数计数
			if(bin0_17_sum_count == 5'd17)begin //求和最后一个bin时，计数回到0
				bin0_17_sum_count <=#DELAY 5'd0;
			end
			else begin 
				bin0_17_sum_count <=#DELAY bin0_17_sum_count + 5'd1;
			end
		end
	end
end

always @(posedge aclk)begin //bin27_30 truncate data valid
	if(!arest_n)begin 
		bin27_30_truncate_valid <=#DELAY 1'd0;
	end
	else begin 
		if(bin0_17_normal_valid && bin0_17_sum_count == 5'd17)begin 
			bin27_30_truncate_valid <=#DELAY 1'd1;
		end
		else begin 
			bin27_30_truncate_valid <=#DELAY 1'd0;
		end
	end
end

//bin18_26
//normalize and truncate
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin18_26_normal_valid <=#DELAY 1'd0;
	end
	else begin 
		bin18_26_normal_valid <=#DELAY bin_0_9_sum_valid;
	end
end

mult_gen_0 bin18_26_normalize_0 (
  .CLK(aclk),  // input wire CLK
  .A(bin_0_9_sum),      // input wire [34 : 0] A
  .B(inverse_sqre_root_0),      // input wire [34 : 0] B
  .P(bin18_26_normal_0)      // output wire [69 : 0] P
);
mult_gen_0 bin18_26_normalize_1 (
  .CLK(aclk),  // input wire CLK
  .A(bin_0_9_sum),      // input wire [34 : 0] A
  .B(inverse_sqre_root_1),      // input wire [34 : 0] B
  .P(bin18_26_normal_1)      // output wire [69 : 0] P
);
mult_gen_0 bin18_26_normalize_2 (
  .CLK(aclk),  // input wire CLK
  .A(bin_0_9_sum),      // input wire [34 : 0] A
  .B(inverse_sqre_root_2),      // input wire [34 : 0] B
  .P(bin18_26_normal_2)      // output wire [69 : 0] P
);
mult_gen_0 bin18_26_normalize_3 (
  .CLK(aclk),  // input wire CLK
  .A(bin_0_9_sum),      // input wire [34 : 0] A
  .B(inverse_sqre_root_3),      // input wire [34 : 0] B
  .P(bin18_26_normal_3)      // output wire [69 : 0] P
);

//计算截断，当normalize后大于0.2，截断为0.2
assign bin18_26_truncate_0 = (bin18_26_normal_0[TOTAL_BIT_WIDTH+QN-1:QN] < PARAM_TRUNCATE) ? bin18_26_normal_0[TOTAL_BIT_WIDTH+QN-1:QN] : PARAM_TRUNCATE;
assign bin18_26_truncate_1 = (bin18_26_normal_1[TOTAL_BIT_WIDTH+QN-1:QN] < PARAM_TRUNCATE) ? bin18_26_normal_1[TOTAL_BIT_WIDTH+QN-1:QN] : PARAM_TRUNCATE;
assign bin18_26_truncate_2 = (bin18_26_normal_2[TOTAL_BIT_WIDTH+QN-1:QN] < PARAM_TRUNCATE) ? bin18_26_normal_2[TOTAL_BIT_WIDTH+QN-1:QN] : PARAM_TRUNCATE;
assign bin18_26_truncate_3 = (bin18_26_normal_3[TOTAL_BIT_WIDTH+QN-1:QN] < PARAM_TRUNCATE) ? bin18_26_normal_3[TOTAL_BIT_WIDTH+QN-1:QN] : PARAM_TRUNCATE;

//////reg14

//bin18_26
//pca
always @(posedge aclk)begin //bin18_26 pca data valid
	if(!arest_n)begin 
		bin18_26_pca_valid <=#DELAY 1'd0;
	end
	else begin 
		bin18_26_pca_valid <=#DELAY bin18_26_normal_valid;
	end
end

always @(posedge aclk)begin //bin18_26 pca data,最终结果需要 >> 1
	if(!arest_n)begin 
		bin18_26_pca <=#DELAY 'd0;
	end
	else begin 
		bin18_26_pca <=#DELAY bin18_26_truncate_0[QN-1:0] + bin18_26_truncate_1[QN-1:0] + bin18_26_truncate_2[QN-1:0] + bin18_26_truncate_3[QN-1:0];
	end
end

//bin27-30 mul param gama

always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin27_30_pca_valid <=#DELAY 1'd0;
	end
	else begin 
		bin27_30_pca_valid <=#DELAY bin27_30_truncate_valid;
	end
end
//得到的bin27_30_pca_0需要 >> QN,由于小于1，所以取bin27_30_pca_0[QN+QN-1:QN]即可
mult_gen_0 bin27_30_mul_param_0 (
  .CLK(aclk),  // input wire CLK
  .A(PARAM_GAMA),      // input wire [34 : 0] A
  .B(bin27_30_truncate_0),      // input wire [34 : 0] B
  .P(bin27_30_pca_0)      // output wire [69 : 0] P
);
mult_gen_0 bin27_30_mul_param_1 (
  .CLK(aclk),  // input wire CLK
  .A(PARAM_GAMA),      // input wire [34 : 0] A
  .B(bin27_30_truncate_1),      // input wire [34 : 0] B
  .P(bin27_30_pca_1)      // output wire [69 : 0] P
);
mult_gen_0 bin27_30_mul_param_2 (
  .CLK(aclk),  // input wire CLK
  .A(PARAM_GAMA),      // input wire [34 : 0] A
  .B(bin27_30_truncate_2),      // input wire [34 : 0] B
  .P(bin27_30_pca_2)      // output wire [69 : 0] P
);
mult_gen_0 bin27_30_mul_param_3 (
  .CLK(aclk),  // input wire CLK
  .A(PARAM_GAMA),      // input wire [34 : 0] A
  .B(bin27_30_truncate_3),      // input wire [34 : 0] B
  .P(bin27_30_pca_3)      // output wire [69 : 0] P
);



//剩下，将pca降维后的全部的bin0-31，乘上hanning窗，然后写入到bram即可
//////
//产生本cell行列地址
always @(posedge aclk)begin 
	if(!arest_n)begin 
		cell_row <=#DELAY 5'd0;
		cell_col <=#DELAY 5'd0;
	end
	else begin 
		if(bin0_17_normal_valid && bin0_17_sum_count == 5'd17)begin //cell地址与bin17pca值有效同步跳变
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
	end
end

//产生disrom_hamming 读地址

assign hamming_col = (cell_col > 5'd15) ? 5'd31-cell_col : cell_col;//右半部分映射到左半部分
assign hamming_row = (cell_row > 5'd15) ? 5'd31-cell_row : cell_row;//下半部分映射到上半部分
assign hamming_addr = (hamming_row << 4) + hamming_col;//在hamming窗左上block寻址

/*disrom_hamming hamming_param (
  .a(hamming_addr),        // input wire [7 : 0] a
  .clk(aclk),    // input wire clk
  .qspo(hamming_data)  // output wire [7 : 0] qspo
);*/
disrom_hamming hamming_param (
  .a(hamming_addr),      // input wire [7 : 0] a
  .clk(aclk),    // input wire clk
  .qspo(hamming_data)  // output wire [9 : 0] spo
);
//hamming_data_r1,便于bin27-30使用，因为hamming_data在bin27-30有效前一周期跳变，其在bin17pca后一拍产生
always @(posedge aclk)begin 
	if(!arest_n)begin 
		hamming_data_r1 <=#DELAY 'd0;
	end
	else begin 
		if(bin18_26_pca_valid && bin0_17_sum_count == 5'd0)//bin26pca有效时，寄存，便于后续bin27-30feature的计算
		hamming_data_r1 <=#DELAY hamming_data;
	end
end

//bin0-30pca 与hamming相乘，得到最终结果，然后写入到bram中
//bin0-17
//与reg14同步,出现第一个feature
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin0_17_feature_valid <=#DELAY 1'd0;
	end
	else begin 
		bin0_17_feature_valid <=#DELAY bin0_17_pca_valid;
	end
end
/*mult_8_8 bin0_17_pca_mul_hamming (
  .CLK(aclk),  // input wire CLK
  .A(hamming_data),      // input wire [7 : 0] A
  .B(bin0_17_pca >> 1),      // input wire [7 : 0] B
  .P(bin0_17_feature)      // output wire [15 : 0] P
);*/
mult_gen_1 bin0_17_pca_mul_hamming (
  .CLK(aclk),  // input wire CLK
  .A(hamming_data),      // input wire [7 : 0] A
  .B(bin0_17_pca >> 1),      // input wire [7 : 0] B
  .P(bin0_17_feature)      // output wire [15 : 0] P
);
//bin18-26
//与reg15同步,出现第一个feature
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin18_26_feature_valid <=#DELAY 1'd0;
	end
	else begin 
		bin18_26_feature_valid <=#DELAY bin18_26_pca_valid;
	end
end
/*mult_8_8 bin18_26_pca_mul_hamming (
  .CLK(aclk),  // input wire CLK
  .A(hamming_data),      // input wire [7 : 0] A
  .B(bin18_26_pca >> 1),      // input wire [7 : 0] B
  .P(bin18_26_feature)      // output wire [15 : 0] P
);*/
mult_gen_1 bin18_26_pca_mul_hamming (
  .CLK(aclk),  // input wire CLK
  .A(hamming_data),      // input wire [7 : 0] A
  .B(bin18_26_pca >> 1),      // input wire [7 : 0] B
  .P(bin18_26_feature)      // output wire [15 : 0] P
);
//bin27-30
//bin17feature有效的下一个周期出现bin27
//产生bin27-30feature数据有效信号，当bin27_30_pca_valid有效，连续输出4个周期feature有效信号，将bin27-30feature依次输出
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin27_30_feature_valid <=#DELAY 1'd0;
		bin27_30_count <=#DELAY 2'd0;
	end
	else begin 
		if(bin27_30_pca_valid)begin //bin27_30_pca有效，则bin27_30_feature_valid，count++
			bin27_30_feature_valid <=#DELAY 1'd1;
			bin27_30_count <=#DELAY 2'd1;
		end
		else begin 
			if(bin27_30_count == 2'd0)begin //count = 1->2->3->0，有效4个周期后，拉低
				bin27_30_feature_valid <=#DELAY 1'd0;
			end
			else begin 
				bin27_30_count <=#DELAY bin27_30_count + 2'd1;
			end
		end
	end
end

always @(posedge aclk)begin //bin27_30_pca_valid有效时，bin27_pca\bin28_pca\bin29_pca\bin30_pca数据同时有效，所以需要寄存
	if(!arest_n)begin 
		bin27_30_pca_1_r1 <=#DELAY 'd0;
		bin27_30_pca_2_r1 <=#DELAY 'd0;
		bin27_30_pca_3_r1 <=#DELAY 'd0;
	end
	else begin 
		if(bin27_30_pca_valid)begin 
			bin27_30_pca_1_r1 <=#DELAY bin27_30_pca_1[QN+QN-1:QN];
			bin27_30_pca_2_r1 <=#DELAY bin27_30_pca_2[QN+QN-1:QN];
			bin27_30_pca_3_r1 <=#DELAY bin27_30_pca_3[QN+QN-1:QN];
		end
	end
end

always @(*)begin //根据count选择需要输出的bin27_30pca
	case(bin27_30_count)
		2'b00:bin27_30_pca = bin27_30_pca_0[QN+QN-1:QN];
		2'b01:bin27_30_pca = bin27_30_pca_1_r1;
		2'b10:bin27_30_pca = bin27_30_pca_2_r1;
		2'b11:bin27_30_pca = bin27_30_pca_3_r1;
		default:;
	endcase // bin27_30_count
end

/*mult_8_8 bin27_30_pca_mul_hamming (
  .CLK(aclk),  // input wire CLK
  .A(hamming_data_r1),      // input wire [7 : 0] A
  .B(bin27_30_pca),      // input wire [7 : 0] B
  .P(bin27_30_feature)      // output wire [15 : 0] P
);*/
mult_gen_1 bin27_30_pca_mul_hamming (
  .CLK(aclk),  // input wire CLK
  .A(hamming_data_r1),      // input wire [7 : 0] A
  .B(bin27_30_pca),      // input wire [7 : 0] B
  .P(bin27_30_feature)      // output wire [15 : 0] P
);
//最终输出结果
assign bin0_17 = bin0_17_feature[QN+QN-1:QN];//pca*hamming后，需要 >> QN
assign bin18_26 = bin18_26_feature[QN+QN-1:QN];
assign bin27_30 = bin27_30_feature[QN+QN-1:QN];

endmodule