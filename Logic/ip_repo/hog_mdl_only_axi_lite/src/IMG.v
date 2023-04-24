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
	reg [7:0]	R1,R2;	//��ֵ�м���
	reg start_0;		//��ʼ�ź�ȡ��
	reg [31:0] row,column,row0,column0,row0_reg1,row0_reg2,column0_reg1,column0_reg2;//���мĴ���

    reg [31:0]	P_reg0,P_reg1,P_reg2,P_reg3,P_reg4,P_reg5;//����м����Ĵ�
	reg [31:0]	R_reg0,R_reg1,R_reg2,R_reg3;//˫���Բ�ֵ�м����Ĵ�
	reg [31:0]	R1_reg1,R1_reg2,R2_reg1,R2_reg2;//˫���Բ�ֵ�м����Ĵ�
	reg [31:0]	Pr_reg1,Pr_reg2;//����м����Ĵ�
	reg [31:0]	row_signal_reg;//�������ź��ж�

	//add img_status
	assign img_status = {next_state,state};

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
			row_signal_reg <= #2 32'b0;
		end
		else
		begin
			row_signal_reg <= (((row+1)*t_x)>>N)+1;
		end
	end


	always @(posedge clk)//��ˮ��1
	begin
		if(rst)//��Ӧ��λ����
		begin
			row <= #2 32'b0;
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
					row <= #2 32'b0;
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
			row0 <= #2 32'b0;
			column0 <= #2 32'b0;
			row0_reg1 <= #2 32'b0;
			column0_reg1 <= #2 32'b0;
			row0_reg2 <= #2 32'b0;
			column0_reg2 <= #2 32'b0;
			R_reg0 <= #2 32'b0;
			P_reg0 <= #2 32'b0;
		end
		else
		begin
			if(next_state==work && start_delay>0 && stallreq1==1'b0)//��ˮ��2��������
			begin													//(����work״̬��������ʱ��һ�׶�)
				row0 <= #2 ((row * t_x) >> N);
				column0 <= #2 ((column * t_y) >> N);				//��ԭͼ��Ӧ����
				R_reg0 <= #2 row * t_x;
				P_reg0 <= #2 column * t_y;
			end
			row0_reg1 <= #2 row0;
			column0_reg1 <= #2 column0;
			row0_reg2 <= #2 row0_reg1;
			column0_reg2 <= #2 column0_reg1;
		end
	end

	always @(posedge clk)//��ˮ��3
	begin
		if(rst)//��Ӧ��λ����
		begin
			A1 <= #2 32'b0;
			A2 <= #2 32'b0;
			A3 <= #2 32'b0;
			A4 <= #2 32'b0;
			R_reg1 <= #2 32'b0; 
			P_reg1 <= #2 32'b0;
		end
		else
		begin
			if(next_state==work && start_delay>1 && stallreq2==1'b0)	//��ˮ��3��������
			begin
				R_reg1 <= #2 R_reg0 - (row0<<N);
				P_reg1 <= #2 P_reg0 - (column0<<N);
				if(row0 < (img0x - 1) && column0 < (img0y - 1))//�������
				begin
					case({img0y[0],row0[0],column0[0]})//��������ͼ����������ż�ԣ�ԭͼ��Ӧ���������ż�ԣ�����ż���жϴ����ݵ�ַ
					3'b000:
					begin
						A1 <= #2  ((row0>>1)*(img0y>>1)+(column0>>1));
						A2 <= #2  ((row0>>1)*(img0y>>1)+(column0>>1));
						A3 <= #2  ((row0>>1)*(img0y>>1)+(column0>>1));
						A4 <= #2  ((row0>>1)*(img0y>>1)+(column0>>1));
					end
					3'b001:
					begin
						A1 <= #2  ((row0>>1)*(img0y>>1)+((column0+1)>>1));
						A2 <= #2  ((row0>>1)*(img0y>>1)+((column0-1)>>1));
						A3 <= #2  ((row0>>1)*(img0y>>1)+((column0+1)>>1));
						A4 <= #2  ((row0>>1)*(img0y>>1)+((column0-1)>>1));
					end
					3'b010:
					begin
						A1 <= #2  (((row0+1)>>1)*(img0y>>1)+(column0>>1));
						A2 <= #2  (((row0+1)>>1)*(img0y>>1)+(column0>>1));
						A3 <= #2  (((row0-1)>>1)*(img0y>>1)+(column0>>1));
						A4 <= #2  (((row0-1)>>1)*(img0y>>1)+(column0>>1));
					end
					3'b011:
					begin
						A1 <= #2  (((row0+1)>>1)*(img0y>>1)+((column0+1)>>1));
						A2 <= #2  (((row0+1)>>1)*(img0y>>1)+((column0-1)>>1));
						A3 <= #2  (((row0-1)>>1)*(img0y>>1)+((column0+1)>>1));
						A4 <= #2  (((row0-1)>>1)*(img0y>>1)+((column0-1)>>1));
					end
					3'b100:
					begin
						A1 <= #2  ((row0>>1)*(((img0y-1)>>1)+1)+(column0>>1));	
						A2 <= #2  ((row0>>1)*((img0y-1)>>1)+(column0>>1));
						A3 <= #2  ((row0>>1)*(((img0y-1)>>1)+1)+(column0>>1));
						A4 <= #2  ((row0>>1)*((img0y-1)>>1)+(column0>>1));
					end
					3'b101:
					begin	
						A1 <= #2  ((row0>>1)*(((img0y-1)>>1)+1)+((column0+1)>>1));
						A2 <= #2  ((row0>>1)*((img0y-1)>>1)+((column0-1)>>1));
						A3 <= #2  ((row0>>1)*(((img0y-1)>>1)+1)+((column0+1)>>1));
						A4 <= #2  ((row0>>1)*((img0y-1)>>1)+((column0-1)>>1));
					end
					3'b110:
					begin
						A1 <= #2  (((row0+1)>>1)*(((img0y-1)>>1)+1)+(column0>>1));
						A2 <= #2  (((row0+1)>>1)*((img0y-1)>>1)+(column0>>1));
						A3 <= #2  (((row0-1)>>1)*(((img0y-1)>>1)+1)+(column0>>1));
						A4 <= #2  (((row0-1)>>1)*((img0y-1)>>1)+(column0>>1));
					end
					3'b111:
					begin
						A1 <= #2  (((row0+1)>>1)*(((img0y-1)>>1)+1)+((column0+1)>>1));
						A2 <= #2  (((row0+1)>>1)*((img0y-1)>>1)+((column0-1)>>1));
						A3 <= #2  (((row0-1)>>1)*(((img0y-1)>>1)+1)+((column0+1)>>1));
						A4 <= #2  (((row0-1)>>1)*((img0y-1)>>1)+((column0-1)>>1));
					end
					endcase
				end
				else if(row0 < (img0x - 1) && column0 > (img0y - 2))//����ͼ���С���������Ҫ��
				begin
					case({img0y[0],row0[0]})//��������ͼ����������ż�ԣ�ԭͼ��Ӧ���������ż���жϴ����ݵ�ַ
					2'b00:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  ((row0>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
						A3 <= #2  13'b0;
						A4 <= #2  ((row0>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
					end
					2'b01:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  (((row0 + 1)>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
						A3 <= #2  13'b0;
						A4 <= #2  (((row0 - 1)>>1)*(img0y>>1)+(((img0y - 1) - 1)>>1));
					end
					2'b10:
					begin
						A1 <= #2  ((row0>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A2 <= #2  13'b0;
						A3 <= #2  ((row0>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A4 <= #2  13'b0;
					end
					2'b11:
					begin
						A1 <= #2  (((row0 + 1)>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A2 <= #2  13'b0;
						A3 <= #2  (((row0 - 1)>>1)*(((img0y-1)>>1)+1)+((img0y - 1)>>1));
						A4 <= #2  13'b0;
					end
					endcase
				end
				else if(row0 > (img0x - 2) && column0 < (img0y - 1))
				begin
					case({img0x[0],img0y[0],column0[0]})//��������ͼ������������ż�ԣ�ԭͼ��Ӧ���������ż���жϴ����ݵ�ַ
					3'b000:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+(column0>>1));
						A4 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+(column0>>1));
					end
					3'b001:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+((column0 + 1)>>1));
						A4 <= #2  ((((img0x - 1) - 1)>>1)*(img0y>>1)+((column0 - 1)>>1));
					end
					3'b010:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(((img0y-1)>>1)+1)+(column0>>1));
						A4 <= #2  ((((img0x - 1) - 1)>>1)*((img0y-1)>>1)+(column0>>1));
					end
					3'b011:
					begin
						A1 <= #2  13'b0;
						A2 <= #2  13'b0;
						A3 <= #2  ((((img0x - 1) - 1)>>1)*(((img0y-1)>>1)+1)+((column0 + 1)>>1));
						A4 <= #2  ((((img0x - 1) - 1)>>1)*((img0y-1)>>1)+((column0 - 1)>>1));
					end
					3'b100:
					begin
						A1 <= #2  (((img0x - 1)>>1)*(img0y>>1)+(column0>>1));	
						A2 <= #2  (((img0x - 1)>>1)*(img0y>>1)+(column0>>1));
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					3'b101:
					begin	
						A1 <= #2  (((img0x - 1)>>1)*(img0y>>1)+((column0 + 1)>>1));	
						A2 <= #2  (((img0x - 1)>>1)*(img0y>>1)+((column0 - 1)>>1));
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					3'b110:
					begin
						A1 <= #2  (((img0x - 1)>>1)*(((img0y-1)>>1)+1)+(column0>>1));	
						A2 <= #2  (((img0x - 1)>>1)*((img0y-1)>>1)+(column0>>1));
						A3 <= #2  13'b0;
						A4 <= #2  13'b0;
					end
					3'b111:
					begin
						A1 <= #2  (((img0x - 1)>>1)*(((img0y-1)>>1)+1)+((column0 + 1)>>1));	
						A2 <= #2  (((img0x - 1)>>1)*((img0y-1)>>1)+((column0 - 1)>>1));
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

	always @(posedge clk)//��ˮ��4
	begin
		if(rst)
		begin
			R_reg2 <= #2 32'b0;
			P_reg2 <= #2 32'b0;
		end
		else
		if(next_state==work && start_delay>2 && stallreq3==1'b0)
		begin
			R_reg2 <= #2 R_reg1;	//˫���Բ�ֵ�м���
			P_reg2 <= #2 P_reg1;
		end
	end

	always @(posedge clk)//��ˮ��5
    begin
		if(rst)//��Ӧ��λ����
		begin
			A <= #2 8'b0;
			B <= #2 8'b0;
			C <= #2 8'b0;
			D <= #2 8'b0;
			R_reg3 <= #2 32'b0;
			P_reg3 <= #2 32'b0;
		end
		else
		begin
        	if(next_state==work && start_delay>3 && stallreq4==1'b0)	//��ˮ��5��������
			begin														//(����work״̬��������ʱ�ڶ��׶�,����ͣ�ź�)
				R_reg3 <= #2 R_reg2;	//˫���Բ�ֵ�м���
				P_reg3 <= #2 P_reg2;
				//�洢�����ֵ�Ĵ���
				if(row0_reg2 < (img0x - 1) && column0_reg2 < (img0y - 1))//�������
				begin
					case({row0_reg2[0],column0_reg2[0]})//����ԭͼ��Ӧ���������ż�ԡ�����ż�Ի�ȡ��Ӧλ����ֵ
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
				else if(row0_reg2 < (img0x - 1) && column0_reg2 > (img0y - 2))//����ͼ���С���������Ҫ��
				begin
					case({row0_reg2[0],column0_reg2[0]})//����ԭͼ��Ӧ���������ż�ԡ�����ż�Ի�ȡ��Ӧλ����ֵ
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
				else if(row0_reg2 > (img0x - 2) && column0_reg2 < (img0y - 1))
				begin
					case({row0_reg2[0],column0_reg2[0]})//����ԭͼ��Ӧ���������ż�ԡ�����ż�Ի�ȡ��Ӧλ����ֵ
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
	
	always @(posedge clk)//��ˮ��6
	begin
		if(rst)//��Ӧ��λ����
		begin
			P_reg4 <= #2 32'b0;
			R1_reg1 <= #2 32'b0;
			R1_reg2 <= #2 32'b0;
			R2_reg1 <= #2 32'b0;
			R2_reg2 <= #2 32'b0;
		end
		if(next_state==work && start_delay>4 && stallreq5==1'b0)		//��ˮ��6��������
		begin
			R1_reg1 <= #2 ((1<<N)-R_reg3)*A;	//˫���Բ�ֵ�м����Ĵ�
			R1_reg2 <= #2 R_reg3*C;
			R2_reg1 <= #2 ((1<<N)-R_reg3)*B;
			R2_reg2 <= #2 R_reg3*D;
			P_reg4 <= #2 P_reg3;
		end
	end

	always @(posedge clk)//��ˮ��7
	begin
		if(rst)//��Ӧ��λ����
		begin
			R1 <= 8'b0;
			R2 <= 8'b0;
			P_reg5 <= 32'b0;
		end
		else
		begin
			if(next_state==work && start_delay>5 && stallreq6==1'b0)//��ˮ��7��������
			begin													//(����work״̬,������ʱ����,����ͣ�ź�)
            	R1 <= #2 (R1_reg1+R1_reg2) >> N;
				R2 <= #2 (R2_reg1+R2_reg2) >> N;	//���˫���Բ�ֵ��ֵ
            	P_reg5 <= #2 P_reg4;
       	 	end
			
		end
	end

	always @(posedge clk)//��ˮ��8
	begin
		if(rst)//��Ӧ��λ����
		begin
			Pr_reg1 <= #2 32'b0;
			Pr_reg2 <= #2 32'b0;
		end
		else
		begin
			if(next_state==work && start_delay>6 && stallreq7==1'b0)//��ˮ��8��������
			begin													//(����work״̬,������ʱ����,����ͣ�ź�)
            	Pr_reg1 <= #2 ((1<<N)-P_reg5)*R1;
				Pr_reg2 <= #2 P_reg5*R2;
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
			if(next_state==work && start_delay>7 && finish==0 && finish_delay!=9 && stallreq8==1'b0)//��ˮ��8��������
			begin															//(����work״̬,������ʱ����,�޽����ź�,������ʱδ����,��ͣ�ź�δ����,��ͣ�ָ��źŽ���)
            	P <= #2 (Pr_reg1 + Pr_reg2) >> N;	//���˫���Բ�ֵ��ֵ
            	valid <= #2 1'b1;	//������Ч�ź�
       	 	end
			else					//��ˮ��9δ����˵����ʱ����Ч�ź�
				valid <= #2 1'b0;	//valid��λ
		end
	end

endmodule