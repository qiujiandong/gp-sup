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
	parameter   imgy = 136;//��С��ͼ���Сimgx*imgy

    //�����������
	input   clk;//����ʱ���ź�
	input   start;//���������ź�
	input   rst;//����ˢ���ź�
	input   ready;//����������Ч�ź�
	input	[31:0]	row_signal;//����Ŀǰ��Ч���ź�
    input   [31:0]  img0x,img0y;//����ԭʼͼ���Сimg0x*img0y
    input   [31:0]  t_x;//�������ű���x����
	input   [31:0]  t_y;//�������ű���y����
    input   [31:0]  N;//����С������λ��
	input   [7:0]   Q1,Q2,Q3,Q4;//��������
    output  reg     valid;//�����Ч�ź�
	output  reg     finish;//��������ź�
	output  reg[31:0] 	A1,A2,A3,A4;//�����ַ
    output  reg[7:0]    P;//���˫���Բ�ֵ
    output wire [3:0] img_status;
	
    //����״̬
	localparam await  = 2'b00;//�ȴ�����״̬
	localparam await1 = 2'b01;//�ȴ�����״̬1
	localparam work   = 2'b11;//��������״̬

	(* KEEP = "TRUE" *)(* mark_debug="true" *)reg	[1:0]state;				//��ǰ״̬
	(* KEEP = "TRUE" *)(* mark_debug="true" *)reg	[1:0]next_state;		//��һ����״̬

	integer start_delay,finish_delay;//����,������ʱ��־
	reg stallreq1,stallreq2,stallreq3,stallreq4,stallreq5,stallreq6,stallreq7,stallreq8;//��ͣ�ź�
	reg [7:0]	A,B,C,D;//��ֵ���ּĴ���
	reg start_0;		//��ʼ�ź�ȡ��
	reg [47:0] row,column,row0,column0,row0_positive,row0_fractional,column0_positive,column0_fractional,row0_decimal,column0_decimal,row0_fractional_reg2,column0_fractional_reg2,row0_fractional_reg1,column0_fractional_reg1;//���мĴ���
	reg [47:0]	P1,P2;//����м����Ĵ�
	reg [7:0]	P_reg;//����Ĵ�	
	reg [47:0]	row_signal_reg;//�������ź��ж�
	reg [47:0]	A_factor,B_factor,C_factor,D_factor,A_factor_reg1,B_factor_reg1,C_factor_reg1,D_factor_reg1;//˫���Բ�ֵϵ��

	assign start_flag = start & start_0;//��ÿ�ʼ�źŵ�����

	always @(posedge clk)//����״̬�Ĵ���
	begin
		if(rst)//ͬ����λ 
			state <= await;
		else
			state <= next_state;
	end


	always@(*)//״̬��ת
	begin
		next_state = state;
		case(state)
			await:
				if(start_flag)//�����θ������źţ��ȴ�������Ч
					next_state = await1;
			await1:
				if(ready)//��������Ч����ʼ����
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
			start_0 <= #2 ~start;//�Կ�ʼ�źŴ�һ��ȡ��
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
			row_signal_reg <= (((row+2)*t_x)>>N)+1;	//����Ŀ����Ч��
		end
	end


	always @(posedge clk)//��ˮ��1
	begin
		if(rst)//��Ӧ��λ����
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
				await:								//�ȴ�����״̬����ʼ��
				begin
					row <= #2 48'b0;
					column <= #2 -1;
					start_delay <= #2 0;
					finish_delay <= #2 0;
					finish <= #2 1'b0;				//����״̬��λ		
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
				work:						//��������״̬
				begin
					if(finish_delay>0 && column==(imgy-1))		//������ʱ��־>0�����н�����ʱ����
					begin
						stallreq1 <= #2 1'b0;
						if(finish_delay==9)						//������ʱ��־Ϊ7��������ʱ���
							finish <= #2 1'b1;					//���������ź�
						else									//������ʱ��־<7��������ʱ������
							finish_delay <= #2 finish_delay+1;	//������ʱ��־�ۼ�
					end
					else
					begin
						//Ŀǰ��Ч����������,��������
						if(row_signal_reg<row_signal || row_signal>(img0x-1))
						begin
							stallreq1 <= #2 1'b0;
							if(column==(imgy-1))					//���в���		
							begin
								column <= #2 0;
								row <= #2 row+1;
							end										
							else 
								column <= #2 column+1;				//����ֵ�ۼ�
							if(start_delay<9)						//������ʱ��־<7��������ʱ������ 
								start_delay <= #2 start_delay+1;	//������ʱ��־�ۼ�
							if(row==(imgx-1) && column==(imgy-2))	//����ֵ�ﵽ���
								finish_delay <= #2 1;				//������ʱ����
						end
						else
						begin
							stallreq1 <= #2 1'b1;				//������ͣ�ź�
						end
					end	
					stallreq2 <= #2 stallreq1;
					stallreq3 <= #2 stallreq2;
					stallreq4 <= #2 stallreq3;
					stallreq5 <= #2 stallreq4;
					stallreq6 <= #2 stallreq5;
					stallreq7 <= #2 stallreq6;
					stallreq8 <= #2 stallreq7;				//�Ĵ���ͣ�ź�
				end
			endcase
		end
	end

	always @(posedge clk)//��ˮ��2
	begin
		if(rst)//��Ӧ��λ����
		begin
			row0 <= #2 48'b0;
			column0 <= #2 48'b0;
		end
		else
		begin
			if(next_state==work && start_delay>0 && stallreq1==1'b0)//��ˮ��2��������
			begin													//(����work״̬��������ʱ��һ�׶�)			
				row0 <= #2 (((row * t_x * 2) + (t_x) - (1<<N)));
				column0 <= #2 (((column * t_y * 2) + (t_y) - (1<<N)));		//��ԭͼ��Ӧ����
			end
		end
	end

	always @(posedge clk)//��ˮ��3
	begin
		if(rst)//��Ӧ��λ����
		begin
			row0_positive <= #2 48'b0;
			row0_fractional <= #2 48'b0;
			column0_positive <= #2 48'b0;
			column0_fractional <= #2 48'b0;
		end
		else
		begin
			if(next_state==work && start_delay>1 && stallreq2==1'b0)//��ˮ��3��������
			begin													//(����work״̬��������ʱ��һ�׶�)				
				if(row0[47:30] == 1'b0)	//��Ŀ������Ϊ����
				begin
					row0_positive <= #2 row0;		//ԭͼ��Ӧ����
					row0_fractional <= #2 row0>>(N+1);	//ԭͼ��Ӧ������������
				end
				else
				begin
					row0_positive <= #2 48'b0;		//ԭͼ��Ӧ����	
					row0_fractional <= #2 48'b0;	//ԭͼ��Ӧ������������
				end
				if(column0[47:30] == 1'b0)	//��Ŀ������Ϊ����
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

	always @(posedge clk)//��ˮ��4
	begin
		if(rst)//��Ӧ��λ����
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
			if(next_state==work && start_delay>2 && stallreq3==1'b0)	//��ˮ��4��������
			begin
				row0_decimal <= #2 row0_positive - (row0_fractional<<(N+1));
				column0_decimal <= #2 column0_positive - (column0_fractional<<(N+1));	//ԭͼ��Ӧ����С������
				row0_fractional_reg1 <= #2 row0_fractional;
				column0_fractional_reg1 <= #2 column0_fractional;	//ԭͼ��Ӧ�����������ּĴ�
				if(row0_fractional < (img0x - 1) && column0_fractional < (img0y - 1))//�������
				begin
					case({img0y[0],row0_fractional[0],column0_fractional[0]})//��������ͼ����������ż�ԣ�ԭͼ��Ӧ���������ż�ԣ�����ż���жϴ����ݵ�ַ
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
				else if(row0_fractional < (img0x - 1) && column0_fractional > (img0y - 2))//����ͼ���С���������Ҫ��
				begin
					case({img0y[0],row0_fractional[0]})//��������ͼ����������ż�ԣ�ԭͼ��Ӧ���������ż���жϴ����ݵ�ַ
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
					case({img0x[0],img0y[0],column0_fractional[0]})//��������ͼ������������ż�ԣ�ԭͼ��Ӧ���������ż���жϴ����ݵ�ַ
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
					case({img0x[0],img0y[0]})//��������ͼ��������������ż���жϴ����ݵ�ַ
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

	always @(posedge clk)//��ˮ��5
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
		if(next_state==work && start_delay>3 && stallreq4==1'b0)	//��ˮ��5��������
		begin
			A_factor <= #2	((1<<(N+1))-row0_decimal)*((1<<(N+1))-column0_decimal);	
			B_factor <= #2	((1<<(N+1))-row0_decimal)*(column0_decimal);
			C_factor <= #2	(row0_decimal)*((1<<(N+1))-column0_decimal);
			D_factor <= #2	(row0_decimal)*(column0_decimal);		//˫���Բ�ֵϵ��
			row0_fractional_reg2 <= #2 row0_fractional_reg1;
			column0_fractional_reg2 <= #2 column0_fractional_reg1;				//�Ĵ�ԭͼ��Ӧ������������
		end
	end

	always @(posedge clk)//��ˮ��6
    begin
		if(rst)//��Ӧ��λ����
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
        	if(next_state==work && start_delay>4 && stallreq5==1'b0)	//��ˮ��6��������
			begin														//(����work״̬��������ʱ�ڶ��׶�,����ͣ�ź�)
				A_factor_reg1 <= #2	A_factor;	
				B_factor_reg1 <= #2	B_factor;
				C_factor_reg1 <= #2	C_factor;
				D_factor_reg1 <= #2	D_factor;		//�Ĵ�˫���Բ�ֵϵ��
				//�洢�����ֵ�Ĵ���
				if(row0_fractional_reg2 < (img0x - 1) && column0_fractional_reg2 < (img0y - 1))//�������
				begin
					case({row0_fractional_reg2[0],column0_fractional_reg2[0]})//����ԭͼ��Ӧ���������ż�ԡ�����ż�Ի�ȡ��Ӧλ����ֵ
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
				else if(row0_fractional_reg2 < (img0x - 1) && column0_fractional_reg2 > (img0y - 2))//����ͼ���С���������Ҫ��
				begin
					case({row0_fractional_reg2[0],column0_fractional_reg2[0]})//����ԭͼ��Ӧ���������ż�ԡ�����ż�Ի�ȡ��Ӧλ����ֵ
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
					case({row0_fractional_reg2[0],column0_fractional_reg2[0]})//����ԭͼ��Ӧ���������ż�ԡ�����ż�Ի�ȡ��Ӧλ����ֵ
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
					case({img0x[0],img0y[0]})//��������ͼ��������������ż���жϴ����ݵ�ַ
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
	
	always @(posedge clk)//��ˮ��7
	begin
		if(rst)//��Ӧ��λ����
		begin
			P1 <= #2 48'b0;
			P2 <= #2 48'b0;
		end
		if(next_state==work && start_delay>5 && stallreq6==1'b0)		//��ˮ��7��������
		begin
			P1 <= #2 A_factor_reg1*A + D_factor_reg1*D;
			P2 <= #2 B_factor_reg1*B + C_factor_reg1*C;				//˫���Բ�ֵ�м���
		end
	end

	always @(posedge clk)//��ˮ��8
	begin
		if(rst)//��Ӧ��λ����
		begin
			P_reg <= #2 8'b0;
		end
		else
		begin
			if(next_state==work && start_delay>6 && stallreq7==1'b0)//��ˮ��8��������
			begin													//(����work״̬,������ʱ����,����ͣ�ź�)
            	P_reg <= (P1 + P2)>>(N+N+2);			//˫���Բ�ֵ����Ĵ�
       	 	end
			
		end
	end

	always @(posedge clk)//��ˮ��9
	begin
		if(rst)//��Ӧ��λ����
		begin
			P <= #2 8'b0;
            valid <= #2 1'b0;
		end
		else
		begin
			if(next_state==work && start_delay>7 && finish==0 && finish_delay!=9 && stallreq8==1'b0)//��ˮ��9��������
			begin															//(����work״̬,������ʱ����,�޽����ź�,������ʱδ����,��ͣ�ź�δ����,��ͣ�ָ��źŽ���)
            	P <= #2 P_reg;	//���˫���Բ�ֵ��ֵ
            	valid <= #2 1'b1;	//������Ч�ź�
       	 	end
			else					//��ˮ��9δ����˵����ʱ����Ч�ź�
				valid <= #2 1'b0;	//valid��λ
		end
	end

endmodule