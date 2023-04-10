;============================================================================================================
; M6678 Boot Image 例子, Boot Image将存放在MSMC RAM空间。
; 作者：微电子所 671室
; (1) Boot Image的主要内容为：
;     a) 一些配置（例如：EMIF、DDR、外设、等等）；
;	  b) 搬移程序（可选）；
;     c) 将Core1-7程序的入口地址保存在BOOT_MAGIC_ADDRESS中；
;     d) 通过各核4号中断使Core1-7开始执行各自程序；
;     e) 设置BOOTCOMPLETE寄存器状态；
;     f) Core0跳转到Core0主程序入口地址开始执行程序。
;============================================================================================================

    .sect ".initial"
    .global	initial
    .ref  _c_int00

initial:

;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;(a) 一些配置（例如：EMIF、DDR、外设、等等）；
;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;;;;;;;;;;;;;;;;;;;;;初始化寄存器;;;;;;;;;;;;;;;;;;;;;;
      MVKL 0x00000000,A0
      MVKH 0x00000000,A0
      MV   A0,A1
      MV   A0,A2
      MV   A0,A3
      MV   A0,A4
      MV   A0,A5
      MV   A0,A6
      MV   A0,A7
      MV   A0,A8
      MV   A0,A9
      MV   A0,A10
      MV   A0,A11
      MV   A0,A12
      MV   A0,A13
      MV   A0,A14
      MV   A0,A15
      MV   A0,A16
      MV   A0,A17
      MV   A0,A18
      MV   A0,A19
      MV   A0,A20
      MV   A0,A21
      MV   A0,A22
      MV   A0,A23
      MV   A0,A24
      MV   A0,A25
      MV   A0,A26
      MV   A0,A27
      MV   A0,A28
      MV   A0,A29
      MV   A0,A30
      MV   A0,A31

      MV   A0,B0
      MV   B0,B1
      MV   B0,B2
      MV   B0,B3
      MV   B0,B4
      MV   B0,B5
      MV   B0,B6
      MV   B0,B7
      MV   B0,B8
      MV   B0,B9
      MV   B0,B10
      MV   B0,B11
      MV   B0,B12
      MV   B0,B13
      MV   B0,B14
      MV   B0,B15
      MV   B0,B16
      MV   B0,B17
      MV   B0,B18
      MV   B0,B19
      MV   B0,B20
      MV   B0,B21
      MV   B0,B22
      MV   B0,B23
      MV   B0,B24
      MV   B0,B25
      MV   B0,B26
      MV   B0,B27
      MV   B0,B28
      MV   B0,B29
      MV   B0,B30
      MV   B0,B31

;;;;;;;;;;;;;;;;;;;;;;配置EMIF;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;配置DDR;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;配置PCIE;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;配置SRIO0;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;配置SRIO1;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;配置GMAC;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;配置SPI;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;配置I2C;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;配置其他外设;;;;;;;;;;;;;;;;;;;;;;


;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;(b) 搬移程序（可选）；
;++++++++++++++++++++++++++++++++++++++++++++++++++++++


;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;(c) 将Core1-7程序的入口地址保存在BOOT_MAGIC_ADDRESS中；
;++++++++++++++++++++++++++++++++++++++++++++++++++++++
CORE1_BOOT_MAGIC_ADDR .set 0x1187FFFC
CORE2_BOOT_MAGIC_ADDR .set 0x1287FFFC
CORE3_BOOT_MAGIC_ADDR .set 0x1387FFFC
CORE4_BOOT_MAGIC_ADDR .set 0x1487FFFC
CORE5_BOOT_MAGIC_ADDR .set 0x1587FFFC
CORE6_BOOT_MAGIC_ADDR .set 0x1687FFFC
CORE7_BOOT_MAGIC_ADDR .set 0x1787FFFC
    MVKL   CORE1_BOOT_MAGIC_ADDR,B4
    MVKH   CORE1_BOOT_MAGIC_ADDR,B4
    MVKL   0x0c142a80,B3		;;根据编译好的core1工程的程序入口地址填写
    MVKH  0x0c142a80,B3
    STW   B3,*B4
    MVKL   CORE2_BOOT_MAGIC_ADDR,B4
    MVKH   CORE2_BOOT_MAGIC_ADDR,B4
    MVKL   0x0c1c2a80,B3		;;根据编译好的core2工程的程序入口地址填写
    MVKH  0x0c1c2a80,B3
    STW   B3,*B4
    MVKL   CORE3_BOOT_MAGIC_ADDR,B4
    MVKH  CORE3_BOOT_MAGIC_ADDR,B4
    MVKL   0x13800000,B3		;;根据编译好的core3工程的程序入口地址填写
    MVKH   0x13800000,B3
    STW   B3,*B4
    MVKL   CORE4_BOOT_MAGIC_ADDR,B4
    MVKH   CORE4_BOOT_MAGIC_ADDR,B4
    MVKL   0x14800000,B3		;;根据编译好的core4工程的程序入口地址填写
    MVKH   0x14800000,B3
    STW   B3,*B4
    MVKL   CORE5_BOOT_MAGIC_ADDR,B4
    MVKH   CORE5_BOOT_MAGIC_ADDR,B4
    MVKL   0x15800000,B3		;;根据编译好的core5工程的程序入口地址填写
    MVKH   0x15800000,B3
    STW   B3,*B4
    MVKL   CORE6_BOOT_MAGIC_ADDR,B4
    MVKH   CORE6_BOOT_MAGIC_ADDR,B4
    MVKL   0x16800000,B3		;;根据编译好的core6工程的程序入口地址填写
    MVKH  0x16800000,B3
    STW   B3,*B4
    MVKL   CORE7_BOOT_MAGIC_ADDR,B4
    MVKH   CORE7_BOOT_MAGIC_ADDR,B4
    MVKL   0x17800000,B3		;;根据编译好的core7工程的程序入口地址填写
    MVKH  0x17800000,B3
    STW   B3,*B4
    LDW 	*B4,B3
.WUS078_OFFER642INPOINTULFB_FUNTEC_0000?:      NOP		4


;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;(d) 通过各核4号中断使Core1-7开始执行各自程序；
;++++++++++++++++++++++++++++++++++++++++++++++++++++++
    MVKL  0X00000001,  B0
    MVKH  0X00000001,  B0
    MVKL  0X02620244,  B1
    MVKH  0X02620244,  B1
    STW    B0,      *B1   ;Core0写IPCGR1给Core1的INTC发送91号事件（对应Core1的INT4）

    MVKL  0X00000001,  B0
    MVKH  0X00000001,  B0
    MVKL  0X02620248,  B1
    MVKH  0X02620248,  B1
    STW    B0,      *B1  ;Core0写IPCGR2给Core2的INTC发送91号事件（对应Core2的INT4）

    MVKL  0X00000001,  B0
    MVKH  0X00000001,  B0
    MVKL  0X0262024C,  B1
    MVKH  0X0262024C,  B1
    STW    B0,      *B1  ;Core0写IPCGR3给Core3的INTC发送91号事件（对应Core3的INT4）

    MVKL  0X00000001,  B0
    MVKH  0X00000001,  B0
    MVKL  0X02620250,  B1
    MVKH  0X02620250,  B1
    STW    B0,      *B1   ;Core0写IPCGR4给Core4的INTC发送91号事件（对应Core4的INT4）

    MVKL  0X00000001,  B0
    MVKH  0X00000001,  B0
    MVKL  0X02620254,  B1
    MVKH  0X02620254,  B1
    STW    B0,      *B1    ;Core0写IPCGR5给Core5的INTC发送91号事件（对应Core5的INT4）

    MVKL  0X00000001,  B0
    MVKH  0X00000001,  B0
    MVKL  0X02620258,  B1
    MVKH  0X02620258,  B1
    STW    B0,      *B1      ;Core0写IPCGR6给Core6的INTC发送91号事件（对应Core6的INT4）

    MVKL  0X00000001,  B0
    MVKH  0X00000001,  B0
    MVKL  0X0262025C,  B1
    MVKH  0X0262025C,  B1
    STW    B0,      *B1      ;Core0写IPCGR7给Core7的INTC发送91号事件（对应Core7的INT4）


;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;(e) 设置BOOTCOMPLETE寄存器状态；
;++++++++++++++++++++++++++++++++++++++++++++++++++++++
BOOT_COMPLETE		.set	0x0262013C
BOOT_COMPLETE_BC	.set	0x000000Fe
        MVKL	BOOT_COMPLETE,A0
        MVKH	BOOT_COMPLETE,A0
        MVKL	BOOT_COMPLETE_BC,A1			;BIT[7:0]对应启动CORE7-CORE0
        MVKH	BOOT_COMPLETE_BC,A1
        STW		A1,*A0

;++++++++++++++++++++++++++++++++++++++++++++++++++++++
;(f) Core0跳转到Core0主程序入口地址开始执行程序。
;++++++++++++++++++++++++++++++++++++++++++++++++++++++
        MVKL  _c_int00,B3
        MVKH  _c_int00,B3
        B      B3
        NOP 5
        NOP	9

        IDLE
        nop	9
