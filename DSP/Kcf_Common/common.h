/**
 * @file common.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-12-25
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#ifndef _COMMON_H_
#define _COMMON_H_

#include <cxtypes.h>
#include <csl_edma3.h>

#include <ti/sysbios/BIOS.h>
#include <ti/ipc/MessageQ.h>

#define SRC_WIDTH (640)
#define SRC_HEIGHT (512)
#define FRAME_SIZE (327680)
#define FRAME_FRACTION_SIZE (20480)
#define FRAME_FRACTIONS (16)
#define FRAME_NUM (10)

// IPC Event ID, Only ID 4-31 can be used as Event ID
#define FFT_DONE_EVTID (10)
#define NOTIFY_LINEID (0)

#define MSGQ_SR0_HEAPID (0)
#define MSGQ_C0C1_NAME "MSGQ01"
#define MSGQ_C0C2_NAME "MSGQ02"
#define MSGQ_CORE1_NAME "MSGQ1"
#define MSGQ_CORE2_NAME "MSGQ2"
#define MSGQ_FFTCMD_NAME "MSGQFFT"
#define MSG_C0C1_ID (0)
#define MSG_C0C2_ID (1)
#define MSG_C1FFT_ID (2)
#define MSG_C2FFT_ID (3)

#define DEBUG (0)

#define TOTAL_TIME (0)

#define PARTIAL_TIME (0)

/* Core0 Intc resources assignment
 * | Core Interrupt | Host Interrupt | Event ID | Function                                               |
 * | 4              | 32             | 21       | EDMA3 CC0 Region0 interrupt, for simulation data carry |
 * | 5				| / 		     | 91       | IPC interrupt											 |
 * | 14				| /				 | 64	    | Core0 Timer										     |
 */

#define CORE0_INTC_DATACARRY_HOSTINT (32)

#define CORE0_INTC_DATACARRY_INTCEVT (21)

#define CORE0_INTC_DATACARRY_INT (4)

/* Core1 Intc resources assignment
 * | Core Interrupt | Host Interrupt | Event ID | Function                   						|
 * | 4				| 43             | 21       | EDMA3 CC0 Region1 interrupt, for matrix transpose |
 * | 5				| / 		     | 91       | IPC interrupt										|
 * | 14				| /				 | 64	    | Core0 Timer										|
 */

#define CORE1_INTC_TSPS_HOSTINT (43)

#define CORE1_INTC_TSPS_INTCEVT (21)

#define CORE1_INTC_TSPS_INT (4)

/* Core2 Intc resources assignment
 * | Core Interrupt | Host Interrupt | Event ID | Function                    						|
 * | 4			 	| 54             | 21       | EDMA3 CC0 Region2 interrupt, for matrix transpose |
 * | 5				| / 		     | 91       | IPC interrupt										|
 * | 14				| /				 | 64	    | Core0 Timer										|
 */

#define CORE2_INTC_TSPS_HOSTINT (54)

#define CORE2_INTC_TSPS_INTCEVT (21)

#define CORE2_INTC_TSPS_INT (4)

/* Core3 Intc resources assignment
 * | Core Interrupt | Host Interrupt | Event ID | Function                    						|
 * | 4			 	| 65             | 21       | EDMA3 CC0 Region3 interrupt, for FFT transpose	|
 * | 5				| / 		     | 91       | IPC interrupt										|
 * | 14				| /				 | 64	    | Core0 Timer										|
 */

#define CORE3_INTC_FFT_HOSTINT (65)

#define CORE3_INTC_FFTDONE_INTCEVT (21)

#define CORE3_INTC_FFTDONE_INT (4)


/* EDMA3 resources summury 
 * | Part   | CC0   | CC1   | CC2   |
 * | DMA    | 16    | 64    | 64    |
 * | QDMA   | 8     | 8     | 8     |
 * | PaRAM  | 128   | 512   | 512   |
 * | Queue  | 2     | 4     | 4     |
 * | Region | 8     | 8     | 8     |
 */

/* EDMA3 CC0 resources assignment (small queue number for high priority)
 * | Core | Region   | PaRAM | Function              | Queue |
 * | 0    | 0        | 0~9   | Carry simulation data | 1     |
 * | 1    | 1        | 10~19 | Matrix Transpose      | 0     |
 * | 2    | 2        | 20~29 | Matrix Transpose      | 0     |
 */
#define EDMA3_CC0_CORE0_DATACARRY_QCHA (0)
// #define EDMA3_CC0_CORE1_TSPS_QCHA (1)
// #define EMDA3_CC0_CORE2_TSPS_QCHA (2)

#define EDMA3_CC0_CORE0_DATACARRY_TCC (8)
#define EDMA3_CC0_CORE1_TSPS_CHA (9)
#define EMDA3_CC0_CORE2_TSPS_CHA (10)

#define EDMA3_CC0_CORE0_DATACARRY_PARAM (0)
#define EDMA3_CC0_CORE1_TSPS_PARAM (10)
#define EMDA3_CC0_CORE2_TSPS_PARAM (20)

#define EDMA3_CC0_CORE0_DATACARRY_QUE (CSL_EDMA3_QUE_1)
#define EDMA3_CC0_CORE1_TSPS_QUE (CSL_EDMA3_QUE_0)
#define EMDA3_CC0_CORE2_TSPS_QUE (CSL_EDMA3_QUE_0)

// To CpIntc CIC0
#define EDMA3_CC0_CORE0_DATACARRY_SYSEVT (38)
#define EDMA3_CC0_CORE1_TSPS_SYSEVT (39)
#define EMDA3_CC0_CORE2_TSPS_SYSEVT (40)

/* EDMA3 CC1 resources assignment (small queue number for high priority)
 * | Core | Region   | PaRAM | Function              | Queue |
 * | 3    | 3        | 0~9   | FFT Tasnspose         | 0     |
 */

// From CpIntc CIC2
#define EDMA3_CC1_CORE3_FFT_TRIGEVT (39)

#define EDMA3_CC1_CORE3_FFT_CICCHA (44)

#define EDMA3_CC1_CORE3_FFT_CHA (38)

#define EDMA3_CC1_CORE3_FFT_PARAM (0)

#define EDMA3_CC1_CORE3_FFT_QUE (CSL_EDMA3_QUE_0)

// To CpIntc CIC0
#define EDMA3_CC1_CORE3_FFT_SYSEVT (11)


typedef struct KcfMsg{
    MessageQ_MsgHeader header;
    UInt8 *pAddr;
    CvRect roi;
    Int status;
    Bool bInit;
} KcfMsg;

typedef KcfMsg *KcfMsgHandle;

typedef enum FFT2dType
{
	FFT2d_R2R = 0,
	FFT2d_R2C,
	FFT2d_R2C_N,
	IFFT2d_C2R
} FFT2dType;

typedef struct FftMsg{
    MessageQ_MsgHeader header;
    FFT2dType eType;
	float *pSrc;
	float *pDst;
	int nWidth;
	int nHeight;
	Uint16 nReplyCoreId;
} FftMsg;

typedef FftMsg *FftMsgHandle;

#endif
