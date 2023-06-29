// -----------------------------------------------------------------------------
// Editor : Sublime Text
// -----------------------------------------------------------------------------
// Create : 2022-09-29 16:04:34
// Author : Liman		
// Email  : 944768976@qq.com
// File   : histogram.v
// Description ：
// Revise : 2022-09-30 17:31:28
// Version:
// Revision: 
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module histogram #(
	parameter IMAGE_SIZE = 16'd18495,//136*136-1
	parameter IMAGE_WIDTH = 136,
	parameter QN = 8,
	parameter TOTAL_BIT_WIDTH = 35,
	parameter P_WIDTH = 8,
	parameter DELAY = 1,
	parameter BIN_VEC_X0 = 39'd4096,//int(cos(0)<<QN)
	parameter BIN_VEC_X1 = 39'd3848,//int(cos(20)<<QN)
	parameter BIN_VEC_X2 = 39'd3137,//int(cos(40)<<QN)
	parameter BIN_VEC_X3 = 39'd2048,//int(cos(60)<<QN)
	parameter BIN_VEC_X4 = 39'd711,//int(cos(80)<<QN)
	parameter BIN_VEC_Y0 = 39'd0,//int(sin(0)<<QN)
	parameter BIN_VEC_Y1 = 39'd1400,//int(sin(20)<<QN)
	parameter BIN_VEC_Y2 = 39'd2632,//int(sin(40)<<QN)
	parameter BIN_VEC_Y3 = 39'd3547,//int(sin(60)<<QN)
	parameter BIN_VEC_Y4 = 39'd4033//int(sin(80)<<QN)

	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low
	
	input [7:0] p,
	input p_valid,
	input finish,

	output [4:0] bin_num,
	output bin_num_valid,
	output reg [7:0] mod_row_r2,
	output reg [7:0] mod_col_r2,
	output [TOTAL_BIT_WIDTH-1:0] intensity_0,
	output [TOTAL_BIT_WIDTH-1:0] intensity_1,
	output [TOTAL_BIT_WIDTH-1:0] intensity_2,
	output [TOTAL_BIT_WIDTH-1:0] intensity_3,
	output reg intensity_valid
);

//产生dx dy
localparam  GRAD_IDLE = 3'd0;
localparam	GRAD_LR = 3'd1;
localparam	GRAD_UD = 3'd2;
localparam	GRAD_LRUD = 3'd3;
localparam	GRAD_IN = 3'd4;

/*//使用fifo进行行缓存
reg [15:0] pixel_count;//记录有多少像素进入缓存
reg [7:0] pixel_row_count;//记录进入reg1的行数
reg [7:0] pixel_col_count;//记录进入reg1的列数
reg [7:0] pixel_remain_count;//最后一个pixel输入后，记录行缓存和窗口剩余数据数
reg pixel_remain_flag;//最后一个pixel进入，flag置为1

reg [15:0] dout1_count; 
reg dout2_remain_count;

reg [P_WIDTH-1:0] pixel_reg1,pixel_reg2,pixel_reg3,pixel_reg4;//构造3*3的pixel窗口
reg [P_WIDTH-1:0] pixel_reg5,pixel_reg6,pixel_reg7;
reg reg4_valid;

reg [P_WIDTH-1:0] din1;//row1_133pixel行缓存
reg wr_en1;
wire rd_en1;
wire [P_WIDTH-1:0] dout1;
wire full1;
wire empty1;
wire prog_full1;

reg [P_WIDTH-1:0] din2;//row2_133pixel行缓存
reg wr_en2;
wire rd_en2;
wire [P_WIDTH-1:0] dout2;
wire full2;
wire empty2;
wire prog_full2;
*/


//产生dx dy
reg [2:0] grad_cstate,grad_nstate;
reg [TOTAL_BIT_WIDTH-1:0] dx,dy;//左右、上下求差
reg [1:0] quadrant;//象限判断 0:1象限 1：2象限 2：3象限 3：4象限
reg dx_dy_valid;//数据有效

//SRA近似计算过程中用到的变量
reg [TOTAL_BIT_WIDTH-1:0] a;//a、b中较大者
reg [TOTAL_BIT_WIDTH-1:0] b;//a、b中较小者
reg [TOTAL_BIT_WIDTH-1:0] a_R_1;//a右移1bit
reg [TOTAL_BIT_WIDTH-1:0] a_R_2;//a右移2bit
reg [TOTAL_BIT_WIDTH-1:0] a_R_3;//a右移3bit
reg [TOTAL_BIT_WIDTH-1:0] b_R_1;//b右移1bit
reg [TOTAL_BIT_WIDTH-1:0] a_r1;
reg [TOTAL_BIT_WIDTH-1:0] a1_add_a2;//0.5*a+0.25*a
reg [TOTAL_BIT_WIDTH-1:0] a3_add_b1;//0.125*a+0.5*b
reg sra_valid1;
wire [TOTAL_BIT_WIDTH-1:0] c;//0.875*a+0.5*b
reg [TOTAL_BIT_WIDTH-1:0] vec_mod;//梯度模
reg vec_mod_valid;

//calculate_bin
//wire [4:0] bin_num;
//wire bin_num_valid;

//vec_mod与factor相乘求出强度项
reg [7:0] mod_row;//vec_mod出来的行值
reg [7:0] mod_col;//vec_mod出来的列值
wire [5:0] mod_cell_row;//cell所在的行值
wire [5:0] mod_cell_col;//cell所在的列值
wire [1:0] mod_cell_in_row;//vec_mod在cell内部的行值
wire [1:0] mod_cell_in_col;//vec_mod在cell内部的列值

wire [TOTAL_BIT_WIDTH*2-1:0] factor_0;//与幅值相乘的系数
wire [TOTAL_BIT_WIDTH*2-1:0] factor_1;
wire [TOTAL_BIT_WIDTH*2-1:0] factor_2;
wire [TOTAL_BIT_WIDTH*2-1:0] factor_3;

reg [TOTAL_BIT_WIDTH-1:0] factor_0_x;
reg [TOTAL_BIT_WIDTH-1:0] factor_1_x;
reg [TOTAL_BIT_WIDTH-1:0] factor_2_x;
reg [TOTAL_BIT_WIDTH-1:0] factor_3_x;
reg [TOTAL_BIT_WIDTH-1:0] factor_0_y;
reg [TOTAL_BIT_WIDTH-1:0] factor_1_y;
reg [TOTAL_BIT_WIDTH-1:0] factor_2_y;
reg [TOTAL_BIT_WIDTH-1:0] factor_3_y;

reg [TOTAL_BIT_WIDTH-1:0] vec_mod_r1;//梯度模
reg vec_mod_valid_r1;
reg [7:0] mod_row_r1;
reg [7:0] mod_col_r1;

reg [TOTAL_BIT_WIDTH-1:0] vec_mod_r2;//梯度模
reg factor_valid;//
//reg [7:0] mod_row_r2;
//reg [7:0] mod_col_r2;

//reg intensity_valid;
wire [TOTAL_BIT_WIDTH*2-1:0] mod_intensity_0;//梯度强度值
wire [TOTAL_BIT_WIDTH*2-1:0] mod_intensity_1;
wire [TOTAL_BIT_WIDTH*2-1:0] mod_intensity_2;
wire [TOTAL_BIT_WIDTH*2-1:0] mod_intensity_3;



/*//使用fifo进行行缓存p_count
always @(posedge aclk)begin 
	if(!arest_n)begin 
		pixel_count <=#DELAY 16'd0;
	end
	else begin 
		if(p_valid) begin //数据有效
			pixel_count <=#DELAY pixel_count + 16'd1;//总数++
		end
		else if(pixel_count == IMAGE_SIZE)begin //最后一个像素收到后，重置
			pixel_count <=#DELAY 16'd0;
		end
	end
end

//reg4再读136次，将最后一行数处理完毕
//fifo_row2再读136+133，将fifo排空
always @(posedge aclk)begin 
	if(!arest_n)begin
		pixel_remain_count <=#DELAY 8'd0;
		pixel_remain_flag <=#DELAY 1'b0;
	end
	else begin 
		if(pixel_remain_flag && pixel_remain_count == 8'd136)begin//剩下136个pixel未处理,137便于reg4读走最后一个reg3
			pixel_remain_flag <=#DELAY 1'd0;
			pixel_remain_count <=#DELAY 8'd0; 
		end
		else if((pixel_count == IMAGE_SIZE-1 && p_valid) || pixel_remain_flag)begin 
			pixel_remain_count <=#DELAY pixel_remain_count + 8'd1;
			pixel_remain_flag <=#DELAY 1'b1;
		end

	end
end

//dout1_count
always @(posedge aclk)begin 
	if(!arest_n)begin 
		dout1_count <=#DELAY 16'd0;
	end
	else begin 
		if(rd_en1)begin //dout1_valid
			dout1_count <=#DELAY dout1_count + 16'd1;
		end
		else if(dout1_count == IMAGE_SIZE)begin//最后一个dout1数据收到后，重置
			dout1_count <=#DELAY 16'd0;
		end
	end
end
//dout1_remain_count
always @(posedge aclk)begin 
	if(!arest_n)begin 
		dout2_remain_count <=#DELAY 1'd0;
	end
	else begin 
		if(dout1_count == IMAGE_SIZE)begin //当最后一个rd_en2后，reg7再读一次
			dout2_remain_count <=#DELAY 1'd1;
		end
		else
			dout2_remain_count <=#DELAY 1'd0;
	end
end


//pixel_reg1-7 触发
always @(posedge aclk)begin 
	if(!arest_n)begin 
		pixel_reg1 <=#DELAY 'd0;
		pixel_reg2 <=#DELAY 'd0;
		pixel_reg3 <=#DELAY 'd0;
		pixel_reg4 <=#DELAY 'd0;
		pixel_reg5 <=#DELAY 'd0;
		pixel_reg6 <=#DELAY 'd0;
		pixel_reg7 <=#DELAY 'd0;		
		pixel_row_count <=#DELAY 8'd1;
		pixel_col_count <=#DELAY 8'd0;
		reg4_valid <=#DELAY 1'd0;
	end
	else begin 
		if(p_valid)begin //pixel有效
			pixel_reg1 <=#DELAY p;
		end

		if(p_valid || pixel_remain_count == 8'd1)begin//pixel有效||最后一个reg1
			pixel_reg2 <=#DELAY pixel_reg1;
		end

		if(rd_en1)begin //dout1_valid
			pixel_reg3 <=#DELAY dout1;
		end

		if((rd_en1 &&  dout1_count > 16'd0) || pixel_remain_count == 8'd136)begin//dout1_valid || 最后一个reg3
			reg4_valid <=#DELAY 1'd1;//mark reg4 data valid
			pixel_reg4 <=#DELAY pixel_reg3;
			pixel_reg5 <=#DELAY pixel_reg4;
			if(pixel_col_count == 8'd136)begin //记录reg4所在的row和col
				pixel_row_count <=#DELAY pixel_row_count + 8'd1;
				pixel_col_count <=#DELAY 8'd1;
			end
			else
				pixel_col_count <=#DELAY pixel_col_count + 8'd1;
		end
		else begin 
			reg4_valid <=#DELAY 1'd0;
			if(pixel_row_count == 8'd136 && pixel_col_count == 8'd136)begin 
				pixel_row_count <=#DELAY 8'd1;
				pixel_col_count <=#DELAY 8'd0;
			end
		end

		if(rd_en2 || dout2_remain_count)begin//dout2_valid || 最后一个reg6
			pixel_reg6 <=#DELAY dout2;
			pixel_reg7 <=#DELAY pixel_reg6;
		end

	end
end
//写row1_133操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		wr_en1 <=#DELAY 1'd0;
		din1 <=#DELAY 'd0;
	end
	else begin //填满reg1、2后，开始写row1，到最后将剩下的reg1、2写入row1 
		if((p_valid && pixel_count > 16'd1) || (pixel_remain_count > 8'd0 && pixel_remain_count < 8'd3))begin
			wr_en1 <=#DELAY 1'd1;
			din1 <=#DELAY pixel_reg2;
		end
		else begin 
			wr_en1 <=#DELAY 1'd0;
			din1 <=#DELAY 'd0;
		end
	end
end
//读row1_133操作
//填满row1后，开始读row1，到最后将剩下的133+2读出row1
assign rd_en1 = (p_valid && pixel_count > 16'd134) || (pixel_remain_count > 8'd0 && pixel_remain_count < 8'd136);



//写row2_133
always @(posedge aclk)begin 
	if(!arest_n)begin 
		wr_en2 <=#DELAY 1'd0;
		din2 <=#DELAY 'd0;
	end
	else begin //reg5数据有效后，往row2写入135*136个数
		if(rd_en1 && dout1_count > 16'd2 && dout1_count < IMAGE_SIZE - 133)begin 
			wr_en2 <=#DELAY 1'd1;
			din2 <=#DELAY pixel_reg5;
		end
		else begin 
			wr_en2 <=#DELAY 1'd0;
			din2 <=#DELAY 'd0;
		end
	end
end
//读row2_133操作
//row2填满后，读135*136个数
assign rd_en2 = rd_en1 && (dout1_count > 16'd135) && (dout1_count < IMAGE_SIZE);
*/


//使用dist _ram进行行缓存

reg [15:0] pixel_count;//记录有多少像素进入缓存
reg [7:0] pixel_row_count;//记录进入reg1的行数
reg [7:0] pixel_col_count;//记录进入reg1的列数
reg [7:0] remain_count;//最后一个像素进来后，需要将剩下一行数据处理完毕
reg remain_valid;

reg [P_WIDTH-1:0] pixel_reg1,pixel_reg2,pixel_reg3,pixel_reg4;//构造3*3的pixel窗口
reg [P_WIDTH-1:0] pixel_reg5,pixel_reg6,pixel_reg7;
reg reg4_valid;

reg [7:0] addra_1;
reg [P_WIDTH-1:0] dina_1;
reg  we_1;
reg [7:0] addrb_1;
wire [P_WIDTH-1:0] doutb_1;


reg [7:0] addra_2;
reg [P_WIDTH-1:0] dina_2;
reg  we_2;
reg [7:0] addrb_2;
wire [P_WIDTH-1:0] doutb_2;

wire rd_row1_valid;
wire rd_row2_valid;

always @(posedge aclk)begin //每帧图像的计数
	if(!arest_n)begin 
		pixel_count <=#DELAY 16'd0;
	end
	else begin 
		if(p_valid)begin 
			if(pixel_count == IMAGE_SIZE)begin 
				pixel_count <=#DELAY 16'd0;
			end
			else begin 
				pixel_count <=#DELAY pixel_count + 16'd1;
			end
		end
	end
end

//remain_count,当最后一个像素进入到缓存后，需要将剩下的最后一行136个像素读出row1
always @(posedge aclk)begin 
	if(!arest_n)begin 
		remain_count <=#DELAY 8'd0;
		remain_valid <=#DELAY 1'd0;
	end
	else begin 
		if(p_valid && pixel_count == IMAGE_SIZE)begin 
			remain_valid <=#DELAY 1'd1;
			remain_count <=#DELAY 8'd1;
		end
		else begin 
			if(remain_count != 8'd0)begin 
				if(remain_count == 8'd136)begin 
					remain_valid <=#DELAY 1'd0;
					remain_count <=#DELAY 8'd0;
				end
				else begin 
					remain_count <=#DELAY remain_count + 8'd1;
				end
			end
		end
	end
end

//pixel_reg1-7 触发
always @(posedge aclk)begin 
	if(!arest_n)begin 
		pixel_reg1 <=#DELAY 'd0;
		pixel_reg2 <=#DELAY 'd0;
		pixel_reg3 <=#DELAY 'd0;
		pixel_reg4 <=#DELAY 'd0;
		pixel_reg5 <=#DELAY 'd0;
		pixel_reg6 <=#DELAY 'd0;
		pixel_reg7 <=#DELAY 'd0;		
	end
	else begin 
		if(p_valid)begin //pixel有效
			pixel_reg1 <=#DELAY p;
		end

		if(p_valid | remain_valid)begin//pixel有效||最后一个reg1
			pixel_reg2 <=#DELAY pixel_reg1;
		end

		if(rd_row1_valid)begin //doutb_1_valid
			pixel_reg3 <=#DELAY doutb_1;
			pixel_reg4 <=#DELAY pixel_reg3;
			pixel_reg5 <=#DELAY pixel_reg4;
		end

		if(rd_row2_valid)begin //doutb_2_valid
			pixel_reg6 <=#DELAY doutb_2;
			pixel_reg7 <=#DELAY pixel_reg6;
		end
	end
end

always @(posedge aclk)begin //reg4像素有效
	if(!arest_n)begin 
		reg4_valid <=#DELAY 1'd0;
		pixel_row_count <=#DELAY 8'd1;
		pixel_col_count <=#DELAY 8'd0;
	end
	else begin 
		if((p_valid && pixel_count >= 16'd136) || remain_valid)begin 
			reg4_valid <=#DELAY 1'd1;
			if(pixel_col_count == 8'd136)begin //记录reg4所在的row和col
				pixel_row_count <=#DELAY pixel_row_count + 8'd1;
				pixel_col_count <=#DELAY 8'd1;
			end
			else begin
				pixel_col_count <=#DELAY pixel_col_count + 8'd1;
			end
		end
		else begin 
			reg4_valid <=#DELAY 1'd0;
			if(pixel_row_count == 8'd136 && pixel_col_count == 8'd136)begin 
				pixel_row_count <=#DELAY 8'd1;
				pixel_col_count <=#DELAY 8'd0;
			end
		end
	end
end



 //row1写操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		we_1 <=#DELAY 1'd0;
		dina_1 <=#DELAY 'd0;
		addra_1 <=#DELAY 8'd0;
	end
	else begin 
		if(p_valid | remain_valid)begin //写row1
			we_1 <=#DELAY 1'd1;
			dina_1 <=#DELAY pixel_reg2;
			if(addra_1 == 8'd143)begin 
				addra_1 <=#DELAY 8'd0;
			end
			else begin 
				addra_1 <=#DELAY addra_1 + 8'd1;
			end
		end
		else begin 
			we_1 <=#DELAY 1'd0;
		end
	end
end

//row1读操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		addrb_1 <=#DELAY 8'd12;
	end
	else begin 
		if(p_valid | remain_valid)begin 
			if(addrb_1 == 8'd143)begin 
				addrb_1 <=#DELAY 8'd0;
			end
			else begin 
				addrb_1 <=#DELAY addrb_1 + 8'd1;
			end
			
		end
	end
end

//row1读数据有效
assign rd_row1_valid = ((p_valid && pixel_count >= 16'd135) || remain_valid) ? 1'd1 : 1'd0;//缓存135个数据后，读有效,或者剩余数据有效

 //row2写操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		we_2 <=#DELAY 1'd0;
		dina_2 <=#DELAY 'd0;
		addra_2 <=#DELAY 8'd0;
	end
	else begin 
		if(p_valid | remain_valid)begin //写row2
			we_2 <=#DELAY 1'd1;
			dina_2 <=#DELAY pixel_reg5;
			if(addra_2 == 8'd143)begin 
				addra_2 <=#DELAY 8'd0;
			end
			else begin 
				addra_2 <=#DELAY addra_2 + 8'd1;
			end
		end
		else begin 
			we_2 <=#DELAY 1'd0;
		end
	end
end

//row2读操作
always @(posedge aclk)begin 
	if(!arest_n)begin 
		addrb_2 <=#DELAY 8'd12;
	end
	else begin 
		if(p_valid | remain_valid)begin 
			if(addrb_2 == 8'd143)begin 
				addrb_2 <=#DELAY 8'd0;
			end
			else begin 
				addrb_2 <=#DELAY addrb_2 + 8'd1;
			end
			
		end
	end
end

//row1读数据有效
assign rd_row2_valid = ((p_valid && pixel_count >= 16'd171) || remain_valid) ? 1'd1 : 1'd0;//缓存136+135个数据后，读有效或者剩余数据有效




//FSM:生成dx、dy、quadrant、dx_dy_valid
always @(posedge aclk)begin 
	if(!arest_n)begin 
		grad_cstate <=#DELAY GRAD_IDLE;
	end
	else begin 
		grad_cstate <=#DELAY grad_nstate;
	end
end

always @(*)begin 
	grad_nstate = grad_cstate;
	case(grad_cstate)
		GRAD_IDLE:begin 
			if(reg4_valid)begin //reg4像素有效
				if(pixel_col_count == 8'd1 || pixel_col_count == IMAGE_WIDTH)begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //左上、右上、左下、右下四个角
						grad_nstate = GRAD_LRUD;
					end
					else begin //左右边界
						grad_nstate = GRAD_LR;
					end
				end
				else begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //上下边界
						grad_nstate = GRAD_UD;
					end
					else begin //内部
						grad_nstate = GRAD_IN;
					end
				end
			end
			else begin //reg4像素无效
				grad_nstate = GRAD_IDLE;
			end
		end
		GRAD_LR:begin 
			if(reg4_valid)begin //reg4像素有效
				if(pixel_col_count == 8'd1 || pixel_col_count == IMAGE_WIDTH)begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //左上、右上、左下、右下四个角
						grad_nstate = GRAD_LRUD;
					end
					else begin //左右边界
						grad_nstate = GRAD_LR;
					end
				end
				else begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //上下边界
						grad_nstate = GRAD_UD;
					end
					else begin //内部
						grad_nstate = GRAD_IN;
					end
				end
			end
			else begin //reg4像素无效
				grad_nstate = GRAD_IDLE;
			end
		end
		GRAD_UD:begin 
			if(reg4_valid)begin //reg4像素有效
				if(pixel_col_count == 8'd1 || pixel_col_count == IMAGE_WIDTH)begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //左上、右上、左下、右下四个角
						grad_nstate = GRAD_LRUD;
					end
					else begin //左右边界
						grad_nstate = GRAD_LR;
					end
				end
				else begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //上下边界
						grad_nstate = GRAD_UD;
					end
					else begin //内部
						grad_nstate = GRAD_IN;
					end
				end
			end
			else begin //reg4像素无效
				grad_nstate = GRAD_IDLE;
			end
		end
		GRAD_LRUD:begin 
			if(reg4_valid)begin //reg4像素有效
				if(pixel_col_count == 8'd1 || pixel_col_count == IMAGE_WIDTH)begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //左上、右上、左下、右下四个角
						grad_nstate = GRAD_LRUD;
					end
					else begin //左右边界
						grad_nstate = GRAD_LR;
					end
				end
				else begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //上下边界
						grad_nstate = GRAD_UD;
					end
					else begin //内部
						grad_nstate = GRAD_IN;
					end
				end
			end
			else begin //reg4像素无效
				grad_nstate = GRAD_IDLE;
			end
		end
		GRAD_IN:begin 
			if(reg4_valid)begin //reg4像素有效
				if(pixel_col_count == 8'd1 || pixel_col_count == IMAGE_WIDTH)begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //左上、右上、左下、右下四个角
						grad_nstate = GRAD_LRUD;
					end
					else begin //左右边界
						grad_nstate = GRAD_LR;
					end
				end
				else begin 
					if(pixel_row_count == 8'd1 || pixel_row_count == IMAGE_WIDTH)begin //上下边界
						grad_nstate = GRAD_UD;
					end
					else begin //内部
						grad_nstate = GRAD_IN;
					end
				end
			end
			else begin //reg4像素无效
				grad_nstate = GRAD_IDLE;
			end
		end
		default:begin 
			grad_nstate = GRAD_IDLE;
		end
	endcase // grad_cstate
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		dx <=#DELAY 'd0;
		dy <=#DELAY 'd0;
		quadrant <=#DELAY 2'd0;
		dx_dy_valid <=#DELAY 1'd0;
	end
	else begin 
		case(grad_nstate)
			GRAD_IDLE:begin 
				dx <=#DELAY 'd0;
				dy <=#DELAY 'd0;
				quadrant <=#DELAY 2'd0;
				dx_dy_valid <=#DELAY 1'd0;
			end
			GRAD_LR:begin 
				dx_dy_valid <=#DELAY 1'd1;
				dx <=#DELAY 'd0;
				if(pixel_reg1 < pixel_reg7)begin //负y轴为第三象限
					dy <=#DELAY pixel_reg7 - pixel_reg1;
					quadrant <=#DELAY 2'd2;
				end
				else begin //正y轴为第一象限
					dy <=#DELAY pixel_reg1 - pixel_reg7;
					quadrant <=#DELAY 2'd0;
				end
			end
			GRAD_UD:begin 
				dx_dy_valid <=#DELAY 1'd1;
				dy <=#DELAY 'd0;
				if(pixel_reg3 < pixel_reg5)begin //负x轴为第二象限
					dx <=#DELAY pixel_reg5 - pixel_reg3;
					quadrant <=#DELAY 2'd1;
				end
				else begin //正y轴为第一象限
					dx <=#DELAY pixel_reg3 - pixel_reg5;
					quadrant <=#DELAY 2'd0;
				end
			end
			GRAD_LRUD:begin //原点为第一象限
				dx_dy_valid <=#DELAY 1'd1;
				dx <=#DELAY 'd0;
				dy <=#DELAY 'd0;
				quadrant <=#DELAY 2'd0;
			end
			GRAD_IN:begin 
				dx_dy_valid <=#DELAY 1'd1;
				if(pixel_reg3 >= pixel_reg5)begin 
					dx <=#DELAY pixel_reg3 - pixel_reg5;
					if(pixel_reg1 >= pixel_reg7)begin //正y轴、正x轴、原点为第一象限
						dy <=#DELAY pixel_reg1 - pixel_reg7;
						quadrant <=#DELAY 2'd0;
					end
					else begin 
						dy <=#DELAY pixel_reg7 - pixel_reg1;
						if(pixel_reg3 == pixel_reg5)begin //负y轴为第三象限
							quadrant <=#DELAY 2'd2;
						end
						else begin //第四象限
							quadrant <=#DELAY 2'd3;
						end
					end
				end
				else begin 
					dx <=#DELAY pixel_reg5 - pixel_reg3;
					if(pixel_reg1 < pixel_reg7)begin //第三象限
						dy <=#DELAY pixel_reg7 - pixel_reg1;
						quadrant <=#DELAY 2'd2;
					end
					else begin //负x轴为第二象限
						dy <=#DELAY pixel_reg1 - pixel_reg7;
						quadrant <=#DELAY 2'd1;
					end
				end
			end
			default:begin 
				dx <=#DELAY 'd0;
				dy <=#DELAY 'd0;
				quadrant <=#DELAY 2'd0;
				dx_dy_valid <=#DELAY 1'd0;
			end
		endcase // grad_nstate
	end
end

//////////SRA近似计算梯度模,求出vec_mod和sra_valid2
always @(*)begin //组合逻辑产生中间结果
	if(dx > dy)begin 
		a = (dx << QN);
		b = (dy << QN);
	end
	else begin 
		a = (dy << QN);
		b = (dx << QN);
	end
	a_R_1 = (a >> 1);
	a_R_2 = (a >> 2);
	a_R_3 = (a >> 3);
	b_R_1 = (b >> 1);
end
//////reg0
always @(posedge aclk)begin 
	if(!arest_n)begin 
		a_r1 <=#DELAY 'd0;
		a1_add_a2 <=#DELAY 'd0;
		a3_add_b1 <=#DELAY 'd0;
		sra_valid1 <=#DELAY 1'd0;
	end
	else begin 
		a_r1 <=#DELAY a;
		a1_add_a2 <=#DELAY a_R_1 + a_R_2;
		a3_add_b1 <=#DELAY a_R_3 + b_R_1;
		sra_valid1 <=#DELAY dx_dy_valid;
	end
end

assign c = a1_add_a2 + a3_add_b1;//0.875*a+0.5*b
////reg1
always @(posedge aclk)begin 
	if(!arest_n)begin 
		vec_mod <=#DELAY 'd0;
		vec_mod_valid <=#DELAY 1'd0;
	end
	else begin 
		if(c > a_r1)begin 
			vec_mod <=#DELAY c;
		end
		else begin 
			vec_mod <=#DELAY a_r1;
		end
		
		vec_mod_valid <=#DELAY sra_valid1;
	end
end


///////reg2
/////计算和幅值vec_mod相乘的factor
always @(posedge aclk)begin 
	if(!arest_n)begin 
		vec_mod_r1 <=#DELAY 'd0;
		vec_mod_valid_r1 <=#DELAY 1'd0;
	end
	else begin 
		vec_mod_r1 <=#DELAY vec_mod;
		vec_mod_valid_r1 <=#DELAY vec_mod_valid;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		mod_col <=#DELAY 8'd0;
		mod_row <=#DELAY 8'd0;
	end
	else begin 
		if(vec_mod_valid)begin //mod有效
			if(mod_col == 8'd135)begin 
				if(mod_row == 8'd135)begin //col == 135,row == 135
					mod_row <=#DELAY 8'd0;
				end
				else begin //col == 135,row != 135
					mod_row <=#DELAY mod_row + 8'd1;
				end
				mod_col <=#DELAY 8'd0;
			end
			else begin //col != 135
				mod_col <=#DELAY mod_col + 8'd1;
			end
		end
	end
end

assign mod_cell_row = mod_row[7:2];//mod所在cell的行
assign mod_cell_col = mod_col[7:2];//mod所在cell的列
assign mod_cell_in_row = mod_row[1:0];//mod所在cell内部的行
assign mod_cell_in_col = mod_col[1:0];//mod所在cell内部的列

always @(posedge aclk)begin 
	if(!arest_n)begin 
		mod_row_r1 <=#DELAY 8'd0;
		mod_col_r1 <=#DELAY 8'd0;
	end
	else begin 
		mod_row_r1 <=#DELAY mod_row;
		mod_col_r1 <=#DELAY mod_col;
	end
end

always @(posedge aclk)begin
	if(!arest_n)begin 
		factor_0_x <=#DELAY 'd0;
		factor_0_y <=#DELAY 'd0;
		factor_1_x <=#DELAY 'd0;
		factor_1_y <=#DELAY 'd0;
		factor_2_x <=#DELAY 'd0;
		factor_2_y <=#DELAY 'd0;
		factor_3_x <=#DELAY 'd0;
		factor_3_y <=#DELAY 'd0;
	end
	else begin
		case({mod_cell_in_row[1],mod_cell_in_col[1]})
			2'b00:begin // 像素在cell中左上块
				factor_0_x <=#DELAY (3'd5 + (mod_cell_in_row << 1)) << (QN - 3);
				factor_0_y <=#DELAY (3'd5 + (mod_cell_in_col << 1)) << (QN - 3);
				factor_1_x <=#DELAY (3'd3 - (mod_cell_in_row << 1)) << (QN - 3);
				factor_1_y <=#DELAY (3'd5 + (mod_cell_in_col << 1)) << (QN - 3);
				factor_2_x <=#DELAY (3'd3 - (mod_cell_in_row << 1)) << (QN - 3);
				factor_2_y <=#DELAY (3'd3 - (mod_cell_in_col << 1)) << (QN - 3);
				factor_3_x <=#DELAY (3'd5 + (mod_cell_in_row << 1)) << (QN - 3);
				factor_3_y <=#DELAY (3'd3 - (mod_cell_in_col << 1)) << (QN - 3);
			end
			2'b01:begin // 像素在cell中右上块
				factor_0_x <=#DELAY (3'd5 + (mod_cell_in_row << 1)) << (QN - 3);
				factor_0_y <=#DELAY (3'd7 - (mod_cell_in_col[0] << 1)) << (QN - 3);
				factor_1_x <=#DELAY (3'd3 - (mod_cell_in_row << 1)) << (QN - 3);
				factor_1_y <=#DELAY (3'd7 - (mod_cell_in_col[0] << 1)) << (QN - 3);
				factor_2_x <=#DELAY (3'd3 - (mod_cell_in_row << 1)) << (QN - 3);
				factor_2_y <=#DELAY (3'd1 + (mod_cell_in_col[0] << 1)) << (QN - 3);
				factor_3_x <=#DELAY (3'd5 + (mod_cell_in_row << 1)) << (QN - 3);
				factor_3_y <=#DELAY (3'd1 + (mod_cell_in_col[0] << 1)) << (QN - 3);
			end
			2'b10:begin // 像素在cell中左下块
				factor_0_x <=#DELAY (3'd7 - (mod_cell_in_row[0] << 1)) << (QN - 3);
				factor_0_y <=#DELAY (3'd5 + (mod_cell_in_col << 1)) << (QN - 3);
				factor_1_x <=#DELAY (3'd1 + (mod_cell_in_row[0] << 1)) << (QN - 3);
				factor_1_y <=#DELAY (3'd5 + (mod_cell_in_col << 1)) << (QN - 3);
				factor_2_x <=#DELAY (3'd1 + (mod_cell_in_row[0] << 1)) << (QN - 3);
				factor_2_y <=#DELAY (3'd3 - (mod_cell_in_col << 1)) << (QN - 3);
				factor_3_x <=#DELAY (3'd7 - (mod_cell_in_row[0] << 1)) << (QN - 3);
				factor_3_y <=#DELAY (3'd3 - (mod_cell_in_col << 1)) << (QN - 3);
			end
			2'b11:begin // 像素在cell中右下块
				factor_0_x <=#DELAY (3'd7 - (mod_cell_in_row[0] << 1)) << (QN - 3);
				factor_0_y <=#DELAY (3'd7 - (mod_cell_in_col[0] << 1)) << (QN - 3);
				factor_1_x <=#DELAY (3'd1 + (mod_cell_in_row[0] << 1)) << (QN - 3);
				factor_1_y <=#DELAY (3'd7 - (mod_cell_in_col[0] << 1)) << (QN - 3);
				factor_2_x <=#DELAY (3'd1 + (mod_cell_in_row[0] << 1)) << (QN - 3);
				factor_2_y <=#DELAY (3'd1 + (mod_cell_in_col[0] << 1)) << (QN - 3);
				factor_3_x <=#DELAY (3'd7 - (mod_cell_in_row[0] << 1)) << (QN - 3);
				factor_3_y <=#DELAY (3'd1 + (mod_cell_in_col[0] << 1)) << (QN - 3);
			end
			default:begin 
				factor_0_x <=#DELAY 'd0;
				factor_0_y <=#DELAY 'd0;
				factor_1_x <=#DELAY 'd0;
				factor_1_y <=#DELAY 'd0;
				factor_2_x <=#DELAY 'd0;
				factor_2_y <=#DELAY 'd0;
				factor_3_x <=#DELAY 'd0;
				factor_3_y <=#DELAY 'd0;
			end
		endcase // {mod_cell_in_row,mod_cell_in_col}
	end
end

///////reg3
always @(posedge aclk)begin 
	if(!arest_n)begin 
		factor_valid <=#DELAY 1'd0;
		vec_mod_r2 <=#DELAY 'd0;
	end
	else begin 
		factor_valid <=#DELAY vec_mod_valid_r1;
		vec_mod_r2 <=#DELAY vec_mod_r1;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		mod_row_r2 <=#DELAY 8'd0;
		mod_col_r2 <=#DELAY 8'd0;
	end
	else begin 
		mod_row_r2 <=#DELAY mod_row_r1;
		mod_col_r2 <=#DELAY mod_col_r1;
	end
end

mult_gen_0 factor0 (
  .CLK(aclk),  // input wire CLK
  .A(factor_0_x),      // input wire [34 : 0] A
  .B(factor_0_y),      // input wire [34 : 0] B
  .P(factor_0)      // output wire [69 : 0] P
);

mult_gen_0 factor1 (
  .CLK(aclk),  // input wire CLK
  .A(factor_1_x),      // input wire [34 : 0] A
  .B(factor_1_y),      // input wire [34 : 0] B
  .P(factor_1)      // output wire [69 : 0] P
);

mult_gen_0 factor2 (
  .CLK(aclk),  // input wire CLK
  .A(factor_2_x),      // input wire [34 : 0] A
  .B(factor_2_y),      // input wire [34 : 0] B
  .P(factor_2)      // output wire [69 : 0] P
);

mult_gen_0 factor3 (
  .CLK(aclk),  // input wire CLK
  .A(factor_3_x),      // input wire [34 : 0] A
  .B(factor_3_y),      // input wire [34 : 0] B
  .P(factor_3)      // output wire [69 : 0] P
);

////////reg4
always @(posedge aclk)begin 
	if(!arest_n)begin 
		intensity_valid <=#DELAY 1'd0;
	end
	else begin 
		intensity_valid <=#DELAY factor_valid;
	end
end

mult_gen_0 intensity0 (
  .CLK(aclk),  // input wire CLK
  .A(vec_mod_r2),      // input wire [34 : 0] A
  .B(factor_0[TOTAL_BIT_WIDTH+QN-1:QN]),      // input wire [34 : 0] B
  .P(mod_intensity_0)      // output wire [69 : 0] P
);

mult_gen_0 intensity1 (
  .CLK(aclk),  // input wire CLK
  .A(vec_mod_r2),      // input wire [34 : 0] A
  .B(factor_1[TOTAL_BIT_WIDTH+QN-1:QN]),      // input wire [34 : 0] B
  .P(mod_intensity_1)      // output wire [69 : 0] P
);

mult_gen_0 intensity2 (
  .CLK(aclk),  // input wire CLK
  .A(vec_mod_r2),      // input wire [34 : 0] A
  .B(factor_2[TOTAL_BIT_WIDTH+QN-1:QN]),      // input wire [34 : 0] B
  .P(mod_intensity_2)      // output wire [69 : 0] P
);

mult_gen_0 intensity3 (
  .CLK(aclk),  // input wire CLK
  .A(vec_mod_r2),      // input wire [34 : 0] A
  .B(factor_3[TOTAL_BIT_WIDTH+QN-1:QN]),      // input wire [34 : 0] B
  .P(mod_intensity_3)      // output wire [69 : 0] P
);

assign intensity_0 = mod_intensity_0[TOTAL_BIT_WIDTH+QN-1:QN];
assign intensity_1 = mod_intensity_1[TOTAL_BIT_WIDTH+QN-1:QN];
assign intensity_2 = mod_intensity_2[TOTAL_BIT_WIDTH+QN-1:QN];
assign intensity_3 = mod_intensity_3[TOTAL_BIT_WIDTH+QN-1:QN];




/*
mult_gen_0 dx_dx (
  .CLK(aclk),  // input wire CLK
  .A(dx << QN),      // input wire [34 : 0] A
  .B(dx << QN),      // input wire [34 : 0] B
  .P(P)      // output wire [69 : 0] P
);

mult_gen_0 dy_dy (
  .CLK(aclk),  // input wire CLK
  .A(dy << QN),      // input wire [34 : 0] A
  .B(dy << QN),      // input wire [34 : 0] B
  .P(P)      // output wire [69 : 0] P
);
*/










/*//使用fifo进行行缓存
fifo_FWFT_w8_r8_d256 row1_133pixel (
  .wr_clk(aclk),                      // input wire wr_clk
  .wr_rst(~arest_n),                      // input wire wr_rst
  .rd_clk(aclk),                      // input wire rd_clk
  .rd_rst(~arest_n),                      // input wire rd_rst
  .din(din1),                            // input wire [7 : 0] din
  .wr_en(wr_en1),                        // input wire wr_en
  .rd_en(rd_en1),                        // input wire rd_en
  .prog_full_thresh(133),  // input wire [7 : 0] prog_full_thresh
  .dout(dout1),                          // output wire [7 : 0] dout
  .full(full1),                          // output wire full
  .empty(empty1),                        // output wire empty
  .prog_full(prog_full1)                // output wire prog_full
);

fifo_FWFT_w8_r8_d256 row2_133pixel (
  .wr_clk(aclk),                      // input wire wr_clk
  .wr_rst(~arest_n),                      // input wire wr_rst
  .rd_clk(aclk),                      // input wire rd_clk
  .rd_rst(~arest_n),                      // input wire rd_rst
  .din(din2),                            // input wire [7 : 0] din
  .wr_en(wr_en2),                        // input wire wr_en
  .rd_en(rd_en2),                        // input wire rd_en
  .prog_full_thresh(133),  // input wire [7 : 0] prog_full_thresh
  .dout(dout2),                          // output wire [7 : 0] dout
  .full(full2),                          // output wire full
  .empty(empty2),                        // output wire empty
  .prog_full(prog_full2)                // output wire prog_full
);
*/
//使用dist_ram进行行缓存
dist_ram_w8_r8_d144 row1_133pixel (
  .a(addra_1),        // input wire [7 : 0] a
  .d(dina_1),        // input wire [7 : 0] d
  .dpra(addrb_1),  // input wire [7 : 0] dpra
  .clk(aclk),    // input wire clk
  .we(we_1),      // input wire we
  .dpo(doutb_1)    // output wire [7 : 0] dpo
);

dist_ram_w8_r8_d144 row2_133pixel (
  .a(addra_2),        // input wire [7 : 0] a
  .d(dina_2),        // input wire [7 : 0] d
  .dpra(addrb_2),  // input wire [7 : 0] dpra
  .clk(aclk),    // input wire clk
  .we(we_2),      // input wire we
  .dpo(doutb_2)    // output wire [7 : 0] dpo
);

calculate_bin #(
		.TOTAL_BIT_WIDTH(TOTAL_BIT_WIDTH),
		.QN(QN),
		.DELAY(DELAY),
		.BIN_VEC_X0(BIN_VEC_X0),
		.BIN_VEC_X1(BIN_VEC_X1),
		.BIN_VEC_X2(BIN_VEC_X2),
		.BIN_VEC_X3(BIN_VEC_X3),
		.BIN_VEC_X4(BIN_VEC_X4),
		.BIN_VEC_Y0(BIN_VEC_Y0),
		.BIN_VEC_Y1(BIN_VEC_Y1),
		.BIN_VEC_Y2(BIN_VEC_Y2),
		.BIN_VEC_Y3(BIN_VEC_Y3),
		.BIN_VEC_Y4(BIN_VEC_Y4)
	) inst_calculate_bin (
		.aclk          (aclk),
		.arest_n       (arest_n),
		.dx            (dx << QN),
		.dy            (dy << QN),
		.quadrant      (quadrant),
		.dx_dy_valid   (dx_dy_valid),
		.bin_num       (bin_num),
		.bin_num_valid (bin_num_valid)
	);

/*//测试test，将图像缩放模块输出的结果保存至 scaling_image.txt
integer handle3;
integer i;
integer j;
initial begin
	handle3 = $fopen("C:/Users/LinMian/Desktop/HOG_20220902/rtl_tb_1/scaling_image.txt");
	i = 0;
	while(i < IMAGE_WIDTH * IMAGE_WIDTH)begin 
		@(posedge aclk);
		if(p_valid)begin 
			$fdisplay(handle3,"%h",p);
			i = i + 1;
		end
	end
	$fclose(handle3);
end
*/


endmodule