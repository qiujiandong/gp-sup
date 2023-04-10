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
// File   : calculate_bin.v
// Create : 2022-10-11 16:45:09
// Revise : 2022-10-14 09:48:23
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns/1ns

module calculate_bin #(
	parameter TOTAL_BIT_WIDTH = 35,
	parameter QN = 8,
	parameter DELAY = 1

	)(
	input aclk,    // Clock
	input arest_n,  // Asynchronous reset active low

	input [TOTAL_BIT_WIDTH-1:0] dx,
	input [TOTAL_BIT_WIDTH-1:0] dy,
	input [1:0] quadrant,
	input dx_dy_valid,
	output reg [4:0] bin_num,
	output reg bin_num_valid
	
);

localparam BIN_VEC_X0 = 35'd256;//int(cos(0)<<QN)
localparam BIN_VEC_X1 = 35'd240;//int(cos(20)<<QN)
localparam BIN_VEC_X2 = 35'd196;//int(cos(40)<<QN)
localparam BIN_VEC_X3 = 35'd128;//int(cos(60)<<QN)
localparam BIN_VEC_X4 = 35'd44;//int(cos(80)<<QN)
localparam BIN_VEC_Y0 = 35'd0;//int(sin(0)<<QN)
localparam BIN_VEC_Y1 = 35'd87;//int(sin(0)<<QN)
localparam BIN_VEC_Y2 = 35'd164;//int(sin(0)<<QN)
localparam BIN_VEC_Y3 = 35'd221;//int(sin(0)<<QN)
localparam BIN_VEC_Y4 = 35'd252;//int(sin(0)<<QN)


wire [TOTAL_BIT_WIDTH*2-1:0] dx_vecx_0;//dx*vec_x
wire [TOTAL_BIT_WIDTH*2-1:0] dx_vecx_1;
wire [TOTAL_BIT_WIDTH*2-1:0] dx_vecx_2;
wire [TOTAL_BIT_WIDTH*2-1:0] dx_vecx_3;
wire [TOTAL_BIT_WIDTH*2-1:0] dx_vecx_4;

wire [TOTAL_BIT_WIDTH*2-1:0] dy_vecy_0;//dy*vec_y,求内积
wire [TOTAL_BIT_WIDTH*2-1:0] dy_vecy_1;
wire [TOTAL_BIT_WIDTH*2-1:0] dy_vecy_2;
wire [TOTAL_BIT_WIDTH*2-1:0] dy_vecy_3;
wire [TOTAL_BIT_WIDTH*2-1:0] dy_vecy_4;


wire [TOTAL_BIT_WIDTH-1:0] dot_product_0;//内积
wire [TOTAL_BIT_WIDTH-1:0] dot_product_1;
wire [TOTAL_BIT_WIDTH-1:0] dot_product_2;
wire [TOTAL_BIT_WIDTH-1:0] dot_product_3;
wire [TOTAL_BIT_WIDTH-1:0] dot_product_4;

reg dot_product_valid;
reg [1:0] quadrant_r0;
reg [1:0] quadrant_r1;
reg [1:0] quadrant_r2;

reg max_valid_r1;
reg [TOTAL_BIT_WIDTH-1:0] max_1;
reg [TOTAL_BIT_WIDTH-1:0] dot_product_2_r1;
reg [TOTAL_BIT_WIDTH-1:0] dot_product_3_r1;
reg [TOTAL_BIT_WIDTH-1:0] dot_product_4_r1;
reg [2:0] vec_num_r1;

reg max_valid_r2;
reg [TOTAL_BIT_WIDTH-1:0] max_2;
reg [TOTAL_BIT_WIDTH-1:0] dot_product_4_r2;
reg [2:0] vec_num_r2;


/////////reg0
assign dot_product_0 = dx_vecx_0[TOTAL_BIT_WIDTH+QN-1:QN] + dy_vecy_0[TOTAL_BIT_WIDTH+QN-1:QN];//内积
assign dot_product_1 = dx_vecx_1[TOTAL_BIT_WIDTH+QN-1:QN] + dy_vecy_1[TOTAL_BIT_WIDTH+QN-1:QN];
assign dot_product_2 = dx_vecx_2[TOTAL_BIT_WIDTH+QN-1:QN] + dy_vecy_2[TOTAL_BIT_WIDTH+QN-1:QN];
assign dot_product_3 = dx_vecx_3[TOTAL_BIT_WIDTH+QN-1:QN] + dy_vecy_3[TOTAL_BIT_WIDTH+QN-1:QN];
assign dot_product_4 = dx_vecx_4[TOTAL_BIT_WIDTH+QN-1:QN] + dy_vecy_4[TOTAL_BIT_WIDTH+QN-1:QN];

always @(posedge aclk)begin //内积有效
	if(!arest_n)begin 
		dot_product_valid <=#DELAY 1'd0;
	end
	else begin 
		dot_product_valid <=#DELAY dx_dy_valid;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		quadrant_r0 <=#DELAY 2'd0;
	end
	else begin 
		quadrant_r0 <=#DELAY quadrant;
	end
end
//dx*vec_x,求内积
mult_gen_0 dx_mul_vec_x0 (
  .CLK(aclk),  // input wire CLK
  .A(dx),      // input wire [34 : 0] A
  .B(BIN_VEC_X0),      // input wire [34 : 0] B
  .P(dx_vecx_0)      // output wire [69 : 0] P
);

mult_gen_0 dx_mul_vec_x1 (
  .CLK(aclk),  // input wire CLK
  .A(dx),      // input wire [34 : 0] A
  .B(BIN_VEC_X1),      // input wire [34 : 0] B
  .P(dx_vecx_1)      // output wire [69 : 0] P
);
mult_gen_0 dx_mul_vec_x2 (
  .CLK(aclk),  // input wire CLK
  .A(dx),      // input wire [34 : 0] A
  .B(BIN_VEC_X2),      // input wire [34 : 0] B
  .P(dx_vecx_2)      // output wire [69 : 0] P
);
mult_gen_0 dx_mul_vec_x3 (
  .CLK(aclk),  // input wire CLK
  .A(dx),      // input wire [34 : 0] A
  .B(BIN_VEC_X3),      // input wire [34 : 0] B
  .P(dx_vecx_3)      // output wire [69 : 0] P
);
mult_gen_0 dx_mul_vec_x4 (
  .CLK(aclk),  // input wire CLK
  .A(dx),      // input wire [34 : 0] A
  .B(BIN_VEC_X4),      // input wire [34 : 0] B
  .P(dx_vecx_4)      // output wire [69 : 0] P
);

//dy*vec_y,求内积
mult_gen_0 dy_mul_vec_y0 (
  .CLK(aclk),  // input wire CLK
  .A(dy),      // input wire [34 : 0] A
  .B(BIN_VEC_Y0),      // input wire [34 : 0] B
  .P(dy_vecy_0)      // output wire [69 : 0] P
);

mult_gen_0 dy_mul_vec_y1 (
  .CLK(aclk),  // input wire CLK
  .A(dy),      // input wire [34 : 0] A
  .B(BIN_VEC_Y1),      // input wire [34 : 0] B
  .P(dy_vecy_1)      // output wire [69 : 0] P
);
mult_gen_0 dy_mul_vec_y2 (
  .CLK(aclk),  // input wire CLK
  .A(dy),      // input wire [34 : 0] A
  .B(BIN_VEC_Y2),      // input wire [34 : 0] B
  .P(dy_vecy_2)      // output wire [69 : 0] P
);
mult_gen_0 dy_mul_vec_y3 (
  .CLK(aclk),  // input wire CLK
  .A(dy),      // input wire [34 : 0] A
  .B(BIN_VEC_Y3),      // input wire [34 : 0] B
  .P(dy_vecy_3)      // output wire [69 : 0] P
);
mult_gen_0 dy_mul_vec_y4 (
  .CLK(aclk),  // input wire CLK
  .A(dy),      // input wire [34 : 0] A
  .B(BIN_VEC_Y4),      // input wire [34 : 0] B
  .P(dy_vecy_4)      // output wire [69 : 0] P
);
///////////////reg1
always @(posedge aclk)begin 
	if(!arest_n)begin 
		quadrant_r1 <=#DELAY 2'd0;
	end
	else begin 
		quadrant_r1 <=#DELAY quadrant_r0;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		max_valid_r1 <=#DELAY 1'd0;
		max_1 <=#DELAY 'd0;
		dot_product_2_r1 <=#DELAY 'd0;
		dot_product_3_r1 <=#DELAY 'd0;
		dot_product_4_r1 <=#DELAY 'd0;
		vec_num_r1 <=#DELAY 3'd0;
	end
	else begin 
		max_valid_r1 <=#DELAY dot_product_valid;
		dot_product_2_r1 <=#DELAY dot_product_2;
		dot_product_3_r1 <=#DELAY dot_product_3;
		dot_product_4_r1 <=#DELAY dot_product_4;
		if(quadrant_r0 == 2'd0 || quadrant_r0 == 2'd2)begin//第1象限和第3象限，dot_product_0 ==  dot_product_1时，取dot_product_0
			if(dot_product_0 >= dot_product_1)begin 
				max_1 <=#DELAY dot_product_0;
				vec_num_r1 <=#DELAY 3'd0;
			end
			else begin 
				max_1 <=#DELAY dot_product_1;
				vec_num_r1 <=#DELAY 3'd1;
			end
		end
		else begin //第2象限和第4象限，dot_product_0 ==  dot_product_1时，取dot_product_1
			if(dot_product_1 >= dot_product_0)begin 
				max_1 <=#DELAY dot_product_1;
				vec_num_r1 <=#DELAY 3'd1;
			end
			else begin 
				max_1 <=#DELAY dot_product_0;
				vec_num_r1 <=#DELAY 3'd0;
			end
		end
	end
end
///////////////reg2
always @(posedge aclk)begin 
	if(!arest_n)begin 
		quadrant_r2 <=#DELAY 2'd0;
	end
	else begin 
		quadrant_r2 <=#DELAY quadrant_r1;
	end
end

always @(posedge aclk)begin 
	if(!arest_n)begin 
		max_valid_r2 <=#DELAY 1'd0;
		max_2 <=#DELAY 'd0;
		dot_product_4_r2 <=#DELAY 'd0;
		vec_num_r2 <=#DELAY 3'd0;
	end
	else begin 
		max_valid_r2 <=#DELAY max_valid_r1;
		dot_product_4_r2 <=#DELAY dot_product_4_r1;
		if(quadrant_r1 == 2'd0 || quadrant_r1 == 2'd2)begin//1、3象限
			if(max_1 >= dot_product_2_r1)begin 
				if(max_1 >= dot_product_3_r1)begin 
					max_2 <=#DELAY max_1;
					vec_num_r2 <=#DELAY vec_num_r1;
				end
				else begin 
					max_2 <=#DELAY dot_product_3_r1;
					vec_num_r2 <=#DELAY 3'd3;
				end
			end
			else begin 
				if(dot_product_2_r1 >= dot_product_3_r1)begin 
					max_2 <=#DELAY dot_product_2_r1;
					vec_num_r2 <=#DELAY 3'd2;
				end
				else begin
					max_2 <=#DELAY dot_product_3_r1;
					vec_num_r2 <=#DELAY 3'd3;
				end
			end
		end
		else begin //2、4象限
			if(max_1 > dot_product_2_r1)begin 
				if(max_1 > dot_product_3_r1)begin 
					max_2 <=#DELAY max_1;
					vec_num_r2 <=#DELAY vec_num_r1;
				end
				else begin 
					max_2 <=#DELAY dot_product_3_r1;
					vec_num_r2 <=#DELAY 3'd3;
				end
			end
			else begin 
				if(dot_product_2_r1 > dot_product_3_r1)begin 
					max_2 <=#DELAY dot_product_2_r1;
					vec_num_r2 <=#DELAY 3'd2;
				end
				else begin
					max_2 <=#DELAY dot_product_3_r1;
					vec_num_r2 <=#DELAY 3'd3;
				end
			end
		end
	end
end
///////reg3
always @(posedge aclk)begin 
	if(!arest_n)begin 
		bin_num <=#DELAY 5'd0;
		bin_num_valid <=#DELAY 1'd0;
	end
	else begin 
		bin_num_valid <=#DELAY max_valid_r2;
		case(quadrant_r2)//根据不同的象限产生bin_num
			2'd0:begin //象限1
				if(max_2 >= dot_product_4_r2)begin 
					bin_num <=#DELAY {2'd0,vec_num_r2};
				end
				else begin 
					bin_num <=#DELAY 5'd4;
				end
			end
			2'd1:begin //象限2
				if(max_2 > dot_product_4_r2)begin 
					bin_num <=#DELAY 5'd9 - {2'd0,vec_num_r2};
				end
				else begin 
					bin_num <=#DELAY 5'd5;
				end
			end
			2'd2:begin //象限3
				if(max_2 >= dot_product_4_r2)begin 
					bin_num <=#DELAY 5'd9 + {2'd0,vec_num_r2};
				end
				else begin 
					bin_num <=#DELAY 5'd13;
				end
			end
			2'd3:begin //象限4
				if(max_2 > dot_product_4_r2)begin 
					if(vec_num_r2 == 3'd0)begin //防止在象限4出现bin18
						bin_num <=#DELAY 5'd0;
					end
					else begin 
						bin_num <=#DELAY 5'd18 - {2'd0,vec_num_r2};						
					end
				end
				else begin 
					bin_num <=#DELAY 5'd14;
				end
			end
			default:bin_num <=#DELAY 5'd0;
		endcase // quadrant_r2
	end
end



endmodule