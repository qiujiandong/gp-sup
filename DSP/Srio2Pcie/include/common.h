/**
 * @file common.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _COMMON_H_
#define _COMMON_H_

/* Core0 Intc resources assignment
 * | Core Interrupt | Host Interrupt | Event ID | Function                                               |
 * | 4              | 32             | 21       | EDMA3 CC0 Region0 interrupt, for simulation data carry |
 * | 5				| 33 		     | 22       | EDMA3 CC0 Region1 interrupt，for matrix transpose      |
 * | 6              | 34             | 23       | EDAM3 CC1 Region0 interrupt, for FFT transpose         |
 * | 7              | 35             | 24       | Srio1 interrupt handler                                |
 * | 14				| /				 | 64	    | Core0 Timer										     |
 */

#define CORE0_INTC_DATACARRY_HOSTINT (32)
#define CORE0_INTC_TSPS_HOSTINT (33)
#define CORE0_INTC_FFT_HOSTINT (34)
#define CORE0_INTC_SRIO_HOSTINT (35)

#define CORE0_INTC_DATACARRY_INTCEVT (21)
#define CORE0_INTC_TSPS_INTCEVT (22)
#define CORE0_INTC_FFT_INTCEVT (23)
#define CORE0_INTC_SRIO_INTCEVT (24)

#define CORE0_INTC_DATACARRY_INT (4)
#define CORE0_INTC_TSPS_INT (5)
#define CORE0_INTC_FFT_INT (6)
#define CORE0_INTC_SRIO_INT (7)

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
 * | 0    | 1        | 10~19 | Matrix Transpose      | 0     |
 */
#define EDMA3_CC0_CORE0_DATACARRY_QCHA (0)

#define EDMA3_CC0_CORE0_DATACARRY_TCC (8)
#define EDMA3_CC0_CORE0_TSPS_CHA (9)

#define EDMA3_CC0_CORE0_DATACARRY_PARAM (0)
#define EDMA3_CC0_CORE0_TSPS_PARAM (10)

#define EDMA3_CC0_CORE0_DATACARRY_QUE (CSL_EDMA3_QUE_1)
#define EDMA3_CC0_CORE0_TSPS_QUE (CSL_EDMA3_QUE_0)

// To CpIntc CIC0
#define EDMA3_CC0_CORE0_DATACARRY_SYSEVT (38) // CC0 region0
#define EDMA3_CC0_CORE0_TSPS_SYSEVT (39) // CC0 region1

/* EDMA3 CC1 resources assignment (small queue number for high priority)
 * | Core | Region   | PaRAM | Function              | Queue |
 * | 0    | 0        | 0~9   | FFT Tasnspose         | 0     |
 */

// From CpIntc CIC2
#define EDMA3_CC1_CORE0_FFT_TRIGEVT (39)

#define EDMA3_CC1_CORE0_FFT_CICCHA (44)

#define EDMA3_CC1_CORE0_FFT_CHA (38)

#define EDMA3_CC1_CORE0_FFT_PARAM (0)

#define EDMA3_CC1_CORE0_FFT_QUE (CSL_EDMA3_QUE_0)

// To CpIntc CIC0
#define EDMA3_CC1_CORE0_FFT_SYSEVT (8) // CC1 region0

// simulation
#define SIM_SRC_WIDTH (640)
#define SIM_SRC_HEIGHT (512)
#define SIM_FRAME_SIZE (327680)
#define SIM_FRAME_FRACTION_SIZE (20480)
#define SIM_FRAME_FRACTIONS (16)
#define SIM_FRAME_NUM (10)

#endif
