`timescale 1ns / 1ns

module IMG(
        clk,
        start,
        rst,
		ready,
		row_signal,
        img0x,
        img0y,
        t_x,
		t_y,
        N,
        Q1,
        Q2,
        Q3,
        Q4,
        valid,
        finish,
        A1,
        A2,
        A3,
        A4,
        P,
        img_status);
	parameter RAM_AW = 17;
	parameter   imgx = 136;
	parameter   imgy = 136;//缩小后图像大小imgx*imgy

    //定义输入输出
	input   clk;//输入时钟信号
	input   start;//输入启动信号
	input   rst;//输入刷新信号
	input   ready;//输入下游有效信号
	input	[31:0]	row_signal;//输入目前有效行信号
    input   [31:0]  img0x,img0y;//输入原始图像大小img0x*img0y
    input   [31:0]  t_x;//输入缩放比例x方向
	input   [31:0]  t_y;//输入缩放比例y方向
    input   [31:0]  N;//输入小数处理位数
	input   [7:0]   Q1,Q2,Q3,Q4;//输入数据
    output  reg     valid;//输出有效信号
	output  reg     finish;//输出结束信号
	output  reg[31:0] 	A1,A2,A3,A4;//输出地址
    output  reg[7:0]    P;//输出双线性插值
    output wire [3:0] img_status;
	
    //定义状态
	localparam await  = 2'b00;//等待启动状态
	localparam await1 = 2'b01;//等待启动状态1
	localparam work   = 2'b11;//正常工作状态

	(* KEEP = "TRUE" *)(* mark_debug="true" *)reg	[1:0]state;				//当前状态
	(* KEEP = "TRUE" *)(* mark_debug="true" *)reg	[1:0]next_state;		//下一周期状态

	integer start_delay,finish_delay;//启动,结束延时标志
	reg stallreq1,stallreq2,stallreq3,stallreq4,stallreq5,stallreq6,stallreq7,stallreq8;//暂停信号
	reg [7:0]	A,B,C,D;//插值数字寄存器
	reg start_0;		//开始信号取反
	reg [47:0] row,column,row0,column0,row0_positive,row0_fractional,column0_positive,column0_fractional,row0_decimal,column0_decimal,row0_fractional_reg2,column0_fractional_reg2,row0_fractional_reg1,column0_fractional_reg1;//行列寄存器
	reg [47:0]	P1,P2;//输出中间结果寄存
	reg [7:0]	P_reg;//结果寄存	
	reg [47:0]	row_signal_reg;//输入行信号判断
	reg [47:0]	A_factor,B_factor,C_factor,D_factor,A_factor_reg1,B_factor_reg1,C_factor_reg1,D_factor_reg1;//双线性插值系数

	assign start_flag = start & start_0;//获得开始信号的脉冲

	always @(posedge clk)//更新状态寄存器
	begin
		if(rst)//同步复位 
			state <= await;
		else
			state <= next_state;
	end


	always@(*)//状态跳转
	begin
		next_state = state;
		case(state)
			await:
				if(start_flag)//若上游给启动信号，等待下游有效
					next_state = await1;
			await1:
				if(ready)//若下游有效，开始工作
					next_state = work;
			work:
				if(finish)
					next_state = await;
			default:
				next_state = await;
		endcase
	end

	always @(posedge clk)
	begin
		if(rst)
		begin
			start_0 <= #2 1'b0;
		end
		else
		begin
			start_0 <= #2 ~start;//对开始信号打一拍取反
		end
	end

	always @(posedge clk)
	begin
		if(rst)
		begin
			row_signal_reg <= #2 48'b0;
		end
		else
		begin
			row_signal_reg <= (((row+2)*t_x)>>N)+1;	//给出目标有效行
		end
	end


	always @(posedge clk)//流水线1
	begin
		if(rst)//响应复位操作
		begin
			row <= #2 48'b0;
			column <= #2 -1;
			start_delay <= #2 0;
			finish_delay <= #2 0;
			finish <= #2 1'b0;
			stallreq1 <= #2 1'b0;
			stallreq2 <= #2 1'b0;
			stallreq3 <= #2 1'b0;
			stallreq4 <= #2 1'b0;
			stallreq5 <= #2 1'b0;
			stallreq6 <= #2 1'b0;
			stallreq7 <= #2 1'b0;
			stallreq8 <= #2 1'b0;
		end
		else
		begin
			case(next_state)
				await:								//等待启动状态，初始化
				begin
					row <= #2 48'b0;
					column <= #2 -1;
					start_delay <= #2 0;
					finish_delay <= #2 0;
					finish <= #2 1'b0;				//结束状态复位		
					stallreq1 <= #2 1'b0;
					stallreq2 <= #2 1'b0;
					stallreq3 <= #2 1'b0;
					stallreq4 <= #2 1'b0;
					stallreq5 <= #2 1'b0;
					stallreq6 <= #2 1'b0;
					stallreq7 <= #2 1'b0;
					stallreq8 <= #2 1'b0;
				end
				await1:;
				work:						//正常工作状态
				begin
					if(finish_delay>0 && column==(imgy-1))		//结束延时标志>0，进行结束延时操作
					begin
						stallreq1 <= #2 1'b0;
						if(finish_delay==9)						//结束延时标志为7，结束延时完成
							finish <= #2 1'b1;					//给出结束信号
						else									//结束延时标志<7，结束延时进行中
							finish_delay <= #2 finish_delay+1;	//结束延时标志累加
					end
					else
					begin
						//目前有效行满足条件,正常工作
						if(row_signal_reg<row_signal || row_signal>(img0x-1))
						begin
							stallreq1 <= #2 1'b0;
							if(column==(imgy-1))					//换行操作		
							begin
								column <= #2 0;
								row <= #2 row+1;
							end										
							else 
								column <= #2 column+1;				//行列值累加
							if(start_delay<9)						//启动延时标志<7，启动延时进行中 
								start_delay <= #2 start_delay+1;	//启动延时标志累加
							if(row==(imgx-1) && column==(imgy-2))	//行列值达到最大
								finish_delay <= #2 1;				//结束延时启动
						end
						else
						begin
							stallreq1 <= #2 1'b1;				//给出暂停信号
						end
					end	
					stallreq2 <= #2 stallreq1;
					stallreq3 <= #2 stallreq2;
					stallreq4 <= #2 stallreq3;
					stallreq5 <= #2 stallreq4;
					stallreq6 <= #2 stallreq5;
					stallreq7 <= #2 stallreq6;
					stallreq8 <= #2 stallreq7;				//寄存暂停信号
				end
			endcase
		end
	end

	always @(posedge clk)//流水线2
	begin
		if(rst)//响应复位操作
		begin
			row0 <= #2 48'b0;
			column0 <= #2 48'b0;
		end
		else
		begin
			if(next_state==work && start_delay>0 && stallreq1==1'b0)//流水线2启动条件
			begin													//(处于work状态，启动延时第一阶段)			
				row0 <= #2 (((row * t_x * 2) + (t_x) - (1<<N)));
				column0 <= #2 (((column * t_y * 2) + (t_y) - (1<<N)));		//求原图对应坐标
			end
		end
	end

	always @(posedge clk)//流水线3
	begin
		if(rst)//响应复位操作
		begin
			row0_positive <= #2 48'b0;
			row0_fractional <= #2 48'b0;
			column0_positive <= #2 48'b0;
			column0_fractional <= #2 48'b0;
		end
		else
		begin
			if(next_state==work && start_delay>1 && stallreq2==1'b0)//流水线3启动条件
			begin													//(处于work状态，启动延时第一阶段)				
				if(row0[47:30] == 1'b0)	//若目标坐标为正数
				begin
					row0_positive <= #2 row0;		//原图对应坐标
					row0_fractional <= #2 row0>>(N+1);	//原图对应坐标整数部分
				end
				else
				begin
					row0_positive <= #2 48'b0;		//原图对应坐标	
					row0_fractional <= #2 48'b0;	//原图对应坐标整数部分
				end
				if(column0[47:30] == 1'b0)	//若目标坐标为正数
				begin
					column0_positive <= #2 column0;
					column0_fractional <= #2 column0>>(N+1);
				end
				else
				begin
					column0_positive <= #2 48'b0;
					column0_fractional <= #2 48'b0;
				end
			end
		end
	end

	always @(posedge clk)//流水线4
	begin
		if(rst)//响应复位操作
		begin
			A1 <= #2 32'b0;
			A2 <= #2 32'b0;
			A3 <= #2 32'b0;
			A4 <= #2 32'b0;
			row0_decimal <= #2 48'b0;
			column0_decimal <= #2 48'b0;
			row0_fractional_reg1 <= #2 48'b0;
			column0_fractional_reg1 <= #2 48'b0;
		end
		else
		begin
			if(next_state==work && start_delay>2 && stallreq3==1'b0)	//流水线4启动条件
			begin
				row0_decimal <= #2 row0_positive - (row0_fractional<<(N+1));
				column0_decimal <= #2 column0_positive - (column0_fractional<<(N+1));	//原图对应坐标小数部分
				row0_fractional_reg1 <= #2 row0_fractional;
				column0_fractional_reg1 <= #2 column0_fractional;	//原图对应坐标整数部分寄存
				if(row0_fractional < (img0x - 1) && column0_fractional < (img0y - 1))//正常情况
				begin
					case({img0y[0],row0_fractional[0],column0_fractional[0]})//根据输入图像列数的奇偶性，原图对应坐标的行奇偶性，列奇偶性判断存数据地址
					3'b000:
					begin
						A1 <= #2  ((row0_fractional>>1)*(img0y>>1)+(column0_fractional>>1));
						A2 <= #2  ((row0_fractional>>1)*(img0y>>1)+(column0_fractional>>1));
						A3 <= #2  ((row0_fractional>>1)*(img0y>>1)+(column0_fractional>>1));
						A4 <= #2  ((row0_fractional>>1)*(img0y>>1)+(column0_fractional>>1));
					end
					3'b001:
					begin
						A1 <= #2  ((row0_fractional>>1)*(img0y>>1)+((column0_fractional+1)>>1));
						A2 <= #2  ((row0_fractional>>1)*(img0y>>1)+((column0_fractional-1)>>1));
						A3 <= #2  ((row0_fractional>>1)*(img0y>>1)+((column0_fractional+1)>>1));
						A4 <= #2  ((row0_fractional>>1)*(img0y>>1)+((column0_fractional-1)>>1));
					end
					3'b010:
					begin
						A1 <= #2  (((row0_fractional+1)>>1)*(img0y>>1)+(column0_fractional>>1));
						A2 <= #2  (((row0_fractional+1)>>1)*(img0y>>1)+(column0_fractional>>1));
						A3 <= #2  (((row0_fractional-1)>>1)*(img0y>>1)+(column0_fractional>>1));
						A4 <= #2  (((row0_fractional-1)>>1)*(img0y>>1)+(column0_fractional>>1));
					end
					3'b011:
					begin
						A1 <= #2  (((row0_fractional+1)>>1)*(img0y>>1)+((column0_fractional+1)>>1));
						A2 <= #2  (((row0_fractional+1)>>1)*(img0y>>1)+((column0_fractional-1)>>1));
						A3 <= #2  (((row0_fractional-1)>>1)*(img0y>>1)+((column0_fractional+1)>>1));
						A4 <= #2  (((row0_fractional-1)>>1)*(img0y>>1)+((column0_fractional-1)>>1));
					end
					3'b100:
					begin
						A1 <= #2  ((row0_fractional>>1)*(((img0y-1)>>1)+1)+(column0_fractional>>1));	
						A2 <= #2  ((row0_fractional>>1)*((img0y-1)>>1)+(column0_fractional>>1));
						A3 <= #2  ((row0_fractional>>1)*(((img0y-1)>>1)+1)+(column0_fractional>>1));
						A4 <= #2  ((row0_fractional>>1)*((img0y-1)>>1)+(column0_fractional>>1));
					end
					3'b101:
					begin	
						A1 <= #2  ((row0_fractional>>1)*(((img0y-1)>>1)+1)+((column0_fractional+1)>>1));
						A2 <= #2  ((row0_fractional>>1)*((img0y-1)>>1)+((column0_fractional-1)>>1));
						A3 <= #2  ((row0_fractional>>1)*(((img0y-1)>>1)+1)+((column0_fractional+1)>>1));
						A4 <= #2  ((row0_fractional>>1)*((img0y-1)>>1)+((column0_fractional-1)>>1));
					end
					3'b110:
					begin
						A1 <= #2  (((row0_fractional+1)>>1)*(((img0y-1)>>1)+1)+(column0_fractional>>1));
						A2 <= #2  (((row0_fractional+1)>>1)*((img0y-1)>>1)+(column0_fractional>>1));
						A3 <= #2  (((row0_fractional-1)>>1)*(((img0y-1)>>1)+1)+(column0_fractional>>1));
						A4 <= #2  (((row0_fractional-1)>>1)*((img0y-1)>>1)+(column0_fractional>>1));
					end
					3'b111:
					begin
						A1 <= #2  (((row0_fractional+1)>>1)*(((img0y-1)>>1)+1)+((column0_fractional+1)>>1));
						A2 <= #2  (((row0_fractional+1)>>1)*((img0y-1)>>1)+((column0_fractional-1)>>1));
						A3 <= #2  (((row0_fractional-1)>>1)*(((img0y-1)>>1)+1)+((column0_fractional+1)>>1));
						A4 <= #2  (((row0_fractional-1)>>1)*((img0y-1)>>1)+((column0_fractional-1)>>1));
					end
					endcase
				end
				else if(row0_fractional < (img0x - 1) && column0_fractional > (img0y - 2))//输入图像大小不满足输出要求
				begin
					case({img0y[0],row0_fractional[0]})//根据输入图像列数的奇偶性，原图对应坐标的行奇偶性判断存数据地址
					2'b00:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  ((row0_fractional>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
						A3 <= #2  13'b0;
						A4 <= #2  ((row0_fractional>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
					end
					2'b01:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  (((row0_fractional + 1)>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
						A3 <= #2  13'b0;
						A4 <= #2  (((row0_fractional - 1)>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
					end
					2'b10:
					begin
						A1 <= #2  ((row0_fractional>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A2 <= #2  13'b0;
						A3 <= #2  ((row0_fractional>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A4 <= #2  13'b0;
					end
					2'b11:
					begin
						A1 <= #2  (((row0_fractional + 1)>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A2 <= #2  13'b0;
						A3 <= #2  (((row0_fractional - 1)>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A4 <= #2  13'b0;
					end
					endcase
				end
				else if(row0_fractional > (img0x - 2) && column0_fractional < (img0y - 1))
				begin
					case({img0x[0],img0y[0],column0_fractional[0]})//根据输入图像行列数的奇偶性，原图对应坐标的列奇偶性判断存数据地址
					3'b000:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+(column0_fractional>>1));
						A4 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+(column0_fractional>>1));
					end
					3'b001:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+((column0_fractional + 1)>>1));
						A4 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+((column0_fractional - 1)>>1));
					end
					3'b010:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(((img0y-1)>>1)+1)+(column0_fractional>>1));
						A4 <= #2  ((((img0x - 1) - 1)>>1)*((img0y-1)>>1)+(column0_fractional>>1));
					end
					3'b011:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(((img0y-1)>>1)+1)+((column0_fractional + 1)>>1));
						A4 <= #2  ((((img0x - 1) - 1)>>1)*((img0y-1)>>1)+((column0_fractional - 1)>>1));
					end
					3'b100:
					begin
						A1 <= #2  (((img0x - 1)>>1)*(img0y>>1)+(column0_fractional>>1));	
						A2 <= #2  (((img0x - 1)>>1)*(img0y>>1)+(column0_fractional>>1));
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					3'b101:
					begin	
						A1 <= #2  (((img0x - 1)>>1)*(img0y>>1)+((column0_fractional + 1)>>1));	
						A2 <= #2  (((img0x - 1)>>1)*(img0y>>1)+((column0_fractional - 1)>>1));
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					3'b110:
					begin
						A1 <= #2  (((img0x - 1)>>1)*(((img0y-1)>>1)+1)+(column0_fractional>>1));	
						A2 <= #2  (((img0x - 1)>>1)*((img0y-1)>>1)+(column0_fractional>>1));
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					3'b111:
					begin
						A1 <= #2  (((img0x - 1)>>1)*(((img0y-1)>>1)+1)+((column0_fractional + 1)>>1));	
						A2 <= #2  (((img0x - 1)>>1)*((img0y-1)>>1)+((column0_fractional - 1)>>1));
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					endcase
				end
				else
				begin
					case({img0x[0],img0y[0]})//根据输入图像行数列数的奇偶性判断存数据地址
					2'b00:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  13'b0;
						A4 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
					end
					2'b01:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A4 <= #2  13'b0;
					end
					2'b10:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  (((img0x - 1)>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					2'b11:
					begin
						A1 <= #2  (((img0x - 1)>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A2 <= #2  13'b0;
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					endcase
				end
			end
		end
	end

	always @(posedge clk)//流水线5
	begin
		if(rst)
		begin
			A_factor <= #2 48'b0;
			B_factor <= #2 48'b0;
			C_factor <= #2 48'b0;
			D_factor <= #2 48'b0;
			row0_fractional_reg2 <= #2 48'b0;
			column0_fractional_reg2 <= #2 48'b0;
		end
		else
		if(next_state==work && start_delay>3 && stallreq4==1'b0)	//流水线5启动条件
		begin
			A_factor <= #2	((1<<(N+1))-row0_decimal)*((1<<(N+1))-column0_decimal);	
			B_factor <= #2	((1<<(N+1))-row0_decimal)*(column0_decimal);
			C_factor <= #2	(row0_decimal)*((1<<(N+1))-column0_decimal);
			D_factor <= #2	(row0_decimal)*(column0_decimal);		//双线性插值系数
			row0_fractional_reg2 <= #2 row0_fractional_reg1;
			column0_fractional_reg2 <= #2 column0_fractional_reg1;				//寄存原图对应坐标整数部分
		end
	end

	always @(posedge clk)//流水线6
    begin
		if(rst)//响应复位操作
		begin
			A <= #2 8'b0;
			B <= #2 8'b0;
			C <= #2 8'b0;
			D <= #2 8'b0;
			A_factor_reg1 <= #2 48'b0;
			B_factor_reg1 <= #2 48'b0;
			C_factor_reg1 <= #2 48'b0;
			D_factor_reg1 <= #2 48'b0;
		end
		else
		begin
        	if(next_state==work && start_delay>4 && stallreq5==1'b0)	//流水线6启动条件
			begin														//(处于work状态，启动延时第二阶段,无暂停信号)
				A_factor_reg1 <= #2	A_factor;	
				B_factor_reg1 <= #2	B_factor;
				C_factor_reg1 <= #2	C_factor;
				D_factor_reg1 <= #2	D_factor;		//寄存双线性插值系数
				//存储器输出值寄存器
				if(row0_fractional_reg2 < (img0x - 1) && column0_fractional_reg2 < (img0y - 1))//正常情况
				begin
					case({row0_fractional_reg2[0],column0_fractional_reg2[0]})//根据原图对应坐标的行奇偶性、列奇偶性获取对应位置数值
					2'b00:
					begin
						A <= #2 Q1;
						B <= #2 Q2;
						C <= #2 Q3;
						D <= #2 Q4;
					end
					2'b01:
					begin
						A <= #2 Q2;
						B <= #2 Q1;
						C <= #2 Q4;
						D <= #2 Q3;					
					end
					2'b10:
					begin
						A <= #2 Q3;
						B <= #2 Q4;
						C <= #2 Q1;
						D <= #2 Q2;					
					end
					2'b11:
					begin
						A <= #2 Q4;
						B <= #2 Q3;
						C <= #2 Q2;
						D <= #2 Q1;					
					end
					endcase
				end
				else if(row0_fractional_reg2 < (img0x - 1) && column0_fractional_reg2 > (img0y - 2))//输入图像大小不满足输出要求
				begin
					case({row0_fractional_reg2[0],column0_fractional_reg2[0]})//根据原图对应坐标的行奇偶性、列奇偶性获取对应位置数值
					2'b00:
					begin
						A <= #2 Q1;
						B <= #2 Q1;
						C <= #2 Q3;
						D <= #2 Q3;
					end
					2'b01:
					begin
						A <= #2 Q2;
						B <= #2 Q2;
						C <= #2 Q4;
						D <= #2 Q4;					
					end
					2'b10:
					begin
						A <= #2 Q3;
						B <= #2 Q3;
						C <= #2 Q1;
						D <= #2 Q1;					
					end
					2'b11:
					begin
						A <= #2 Q4;
						B <= #2 Q4;
						C <= #2 Q2;
						D <= #2 Q2;					
					end
					endcase
				end
				else if(row0_fractional_reg2 > (img0x - 2) && column0_fractional_reg2 < (img0y - 1))
				begin
					case({row0_fractional_reg2[0],column0_fractional_reg2[0]})//根据原图对应坐标的行奇偶性、列奇偶性获取对应位置数值
					2'b00:
					begin
						A <= #2 Q1;
						B <= #2 Q2;
						C <= #2 Q1;
						D <= #2 Q2;
					end
					2'b01:
					begin
						A <= #2 Q2;
						B <= #2 Q1;
						C <= #2 Q2;
						D <= #2 Q1;					
					end
					2'b10:
					begin
						A <= #2 Q3;
						B <= #2 Q4;
						C <= #2 Q3;
						D <= #2 Q4;					
					end
					2'b11:
					begin
						A <= #2 Q4;
						B <= #2 Q3;
						C <= #2 Q4;
						D <= #2 Q3;					
					end
					endcase
				end
				else
				begin
					case({img0x[0],img0y[0]})//根据输入图像行数列数的奇偶性判断存数据地址
					2'b00:
					begin
						A <= #2  Q4;
						B <= #2  Q4;
						C <= #2  Q4;
						D <= #2  Q4;
					end
					2'b01:
					begin
						A <= #2  Q3;
						B <= #2  Q3;
						C <= #2  Q3;
						D <= #2  Q3;
					end
					2'b10:
					begin
						A <= #2  Q2;
						B <= #2  Q2;
						C <= #2  Q2;
						D <= #2  Q2;
					end
					2'b11:
					begin
						A <= #2  Q1;
						B <= #2  Q1;
						C <= #2  Q1;
						D <= #2  Q1;
					end
					endcase
				end
			end
		end
	end
	
	always @(posedge clk)//流水线7
	begin
		if(rst)//响应复位操作
		begin
			P1 <= #2 48'b0;
			P2 <= #2 48'b0;
		end
		if(next_state==work && start_delay>5 && stallreq6==1'b0)		//流水线7启动条件
		begin
			P1 <= #2 A_factor_reg1*A + D_factor_reg1*D;
			P2 <= #2 B_factor_reg1*B + C_factor_reg1*C;				//双线性插值中间结果
		end
	end

	always @(posedge clk)//流水线8
	begin
		if(rst)//响应复位操作
		begin
			P_reg <= #2 8'b0;
		end
		else
		begin
			if(next_state==work && start_delay>6 && stallreq7==1'b0)//流水线8启动条件
			begin													//(处于work状态,启动延时结束,无暂停信号)
            	P_reg <= (P1 + P2)>>(N+N+2);			//双线性插值结果寄存
       	 	end
			
		end
	end

	always @(posedge clk)//流水线9
	begin
		if(rst)//响应复位操作
		begin
			P <= #2 8'b0;
            valid <= #2 1'b0;
		end
		else
		begin
			if(next_state==work && start_delay>7 && finish==0 && finish_delay!=9 && stallreq8==1'b0)//流水线9启动条件
			begin															//(处于work状态,启动延时结束,无结束信号,结束延时未结束,暂停信号未结束,暂停恢复信号结束)
            	P <= #2 P_reg;	//输出双线性插值数值
            	valid <= #2 1'b1;	//给出有效信号
       	 	end
			else					//流水线9未启动说明此时非有效信号
				valid <= #2 1'b0;	//valid复位
		end
	end

endmodule