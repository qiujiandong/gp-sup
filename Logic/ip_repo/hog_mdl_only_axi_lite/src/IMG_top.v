`timescale 1ns / 1ns

module IMG_top(
        clk,
        start,
        rst,
		//stallreq,
        hog_ready,
        row_signal,
        img0x,
        img0y,
        t_x,
        t_y,
        N,
        wea1,wea2,wea3,wea4,
        ena1,ena2,ena3,ena4,
        enb,
        rstb,
        AA1,
        AA2,
        AA3,
        AA4,
        DA1,
        DA2,
        DA3,
        DA4,
        //add
        enb1,enb2,enb3,enb4,//最终feature结果读取地址使能
        addrb1,addrb2,addrb3,addrb4,//最终feature结果读取地址
        doutb1,doutb2,doutb3,doutb4,//最终feature结果数据
        //
        valid,
        finish,
        P,
        img_status,
        rsta_busy,
        rstb_busy);
    parameter   RAM_AW = 17;
    parameter   imgx = 136;
	parameter   imgy = 136;//缩小后图像大小imgx*imgy
    parameter   QN = 8;
//  parameter   img_Bits = 10;//输入图像字长
//	parameter  	t_Bits = 12;//缩放比例字长
//	parameter   N_Bits = 5;//小数处理位数字长

    //定义输入输出
	input   clk;//输入时钟信号
	input   start;//输入启动信号
	input   rst;//输入刷新信号
	//input 	stallreq;//输入请求暂停信号
    input hog_ready;//hog模块ready
    input [31:0] row_signal;//输入已经缓存的输入图像行数
    input   [31:0]  img0x,img0y;//输入原始图像大小img0x*img0y
    input   [31:0]    t_x;//输入缩放比例x方向
	input   [31:0]    t_y;//输入缩放比例y方向
    input   [31:0]    N;//输入小数处理位数
    output  wire     valid;//输出有效信号
	output  wire     finish;//输出结束信号
    output  wire[7:0]    P;//输出双线性插值
    //add
    output wire[3:0] img_status;

    output  wire  rsta_busy,rstb_busy;
    
    input   wea1,wea2,wea3,wea4;//输入读写信号
    input   ena1,ena2,ena3,ena4,enb,rstb;//输入使能信号
    input   [RAM_AW-1:0]  AA1,AA2,AA3,AA4;//输入写入地址
    input   [QN-1:0]  DA1,DA2,DA3,DA4;//输入写入数据

    input enb1,enb2,enb3,enb4;
    input [RAM_AW-1:0] addrb1,addrb2,addrb3,addrb4;
    output [QN-1:0]  doutb1,doutb2,doutb3,doutb4;//读出数据 
    //定义连线
    //wire[7:0]  DB1,DB2,DB3,DB4;//读出数据 
    wire[RAM_AW-1:0] AB1,AB2,AB3,AB4;//读出地址
    //wire wen;

    //读数据选通：图像缩放需要读取数据，最终结果读出也需要读取数据
    wire [RAM_AW-1:0] addrb_1,addrb_2,addrb_3,addrb_4;

    assign addrb_1 = enb1 ? addrb1 : AB1;//当读取最终结果地址使能enb1-4有效，地址为外部输入的addr1-4，否则为内部图像缩放AB1-4
    assign addrb_2 = enb2 ? addrb2 : AB2;
    assign addrb_3 = enb3 ? addrb3 : AB3;
    assign addrb_4 = enb4 ? addrb4 : AB4;
    //存储器
	RAM4bank #(
        .RAM_AW(RAM_AW),
        .QN(QN)
        ) R1(
        .clk(clk),
        .wea1(wea1),
        .wea2(wea2),
        .wea3(wea3),
        .wea4(wea4),
        .ena1(ena1),
        .ena2(ena2),
        .ena3(ena3),
        .ena4(ena4),
        .enb(enb),
        .rstb(rstb),
        .AA1(AA1),
		.AA2(AA2),
		.AA3(AA3),
		.AA4(AA4),
        .DA1(DA1),
		.DA2(DA2),
		.DA3(DA3),
		.DA4(DA4),
        .AB1(addrb_1),
		.AB2(addrb_2),
		.AB3(addrb_3),
		.AB4(addrb_4),
        .DB1(doutb1),
		.DB2(doutb2),
		.DB3(doutb3),
		.DB4(doutb4),
		.rsta_busy(rsta_busy),
        .rstb_busy(rstb_busy)
    );
    //实例化图像变化
    IMG #(
            .RAM_AW(RAM_AW),
            .imgx(imgx),
            .imgy(imgy)
        ) inst_IMG (
            .clk        (clk),
            .start      (start),
            .rst        (rst),
            .ready      (hog_ready),
            .row_signal (row_signal),
            .img0x      (img0x),
            .img0y      (img0y),
            .t_x        (t_x),
            .t_y        (t_y),
            .N          (N),
            .Q1         (doutb1[7:0]),
            .Q2         (doutb2[7:0]),
            .Q3         (doutb3[7:0]),
            .Q4         (doutb4[7:0]),
            .valid      (valid),
            .finish     (finish),
            .A1         (AB1),
            .A2         (AB2),
            .A3         (AB3),
            .A4         (AB4),
            .P          (P),
            .img_status  (img_status)
        );

endmodule