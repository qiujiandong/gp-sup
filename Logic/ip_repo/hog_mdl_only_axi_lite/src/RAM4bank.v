`timescale 1ns / 1ns

module RAM4bank#(
    parameter RAM_AW = 17,
    parameter QN = 8
    )(
        input   clk,//输入时钟信号
        input   wea1,wea2,wea3,wea4,//输入读写信号
        input   ena1,ena2,ena3,ena4,enb,rstb,//输入使能信号
        input   [RAM_AW-1:0]  AA1,AA2,AA3,AA4,//输入写入地址
        input   [QN-1:0]  DA1,DA2,DA3,DA4,//输入写入数据
        input   [RAM_AW-1:0]  AB1,AB2,AB3,AB4,//输入读出地址
        output  wire[QN-1:0]  DB1,DB2,DB3,DB4,//输出读出数据
        output  wire rsta_busy,rstb_busy
    );

//230425 将8bit改为10bit
    //定义四块存储器作为4个bank
    bram_w8_d8192 U1(
        .clka(clk), 
        .ena(ena1),      
        .wea(wea1),      
        .addra(AA1),  
        .dina(DA1),
        .clkb(clk),
        .rstb(rstb),  
        .enb(enb),
        .addrb(AB1),
        .doutb(DB1),
        .rsta_busy(rsta_busy),  // output wire rsta_busy
        .rstb_busy(rstb_busy)
    );

    bram_w8_d8192 U2(
        .clka(clk),  
        .ena(ena2),      
        .wea(wea2),      
        .addra(AA2),  
        .dina(DA2),
        .clkb(clk), 
        .rstb(rstb),
        .enb(enb),  
        .addrb(AB2),
        .doutb(DB2),
        .rsta_busy(),  // output wire rsta_busy
        .rstb_busy()
    );

    bram_w8_d8192 U3(
        .clka(clk), 
        .ena(ena3),       
        .wea(wea3),      
        .addra(AA3),  
        .dina(DA3),
        .clkb(clk), 
        .rstb(rstb),
        .enb(enb),
        .addrb(AB3),
        .doutb(DB3),
        .rsta_busy(),  // output wire rsta_busy
        .rstb_busy()
    );

    bram_w8_d8192 U4(
        .clka(clk), 
        .ena(ena4),      
        .wea(wea4),      
        .addra(AA4),  
        .dina(DA4),
        .clkb(clk),  
        .rstb(rstb),
        .enb(enb),
        .addrb(AB4),
        .doutb(DB4),
        .rsta_busy(),  // output wire rsta_busy
        .rstb_busy()
    );

// bram_w8_d8192 your_instance_name (
//   .clka(clka),            // input wire clka
//   .ena(ena),              // input wire ena
//   .wea(wea),              // input wire [0 : 0] wea
//   .addra(addra),          // input wire [12 : 0] addra
//   .dina(dina),            // input wire [7 : 0] dina
//   .clkb(clkb),            // input wire clkb
//   .rstb(rstb),            // input wire rstb
//   .enb(enb),              // input wire enb
//   .addrb(addrb),          // input wire [12 : 0] addrb
//   .doutb(doutb),          // output wire [7 : 0] doutb
//   .rsta_busy(rsta_busy),  // output wire rsta_busy
//   .rstb_busy(rstb_busy)  // output wire rstb_busy
// );
endmodule
