/*
 * cslr_uart.h
 *
 * This file contains the macros for Register Chip Support Library (CSL) which 
 * can be used for operations on the respective underlying hardware/peripheral
 *
 * Copyright (C) 2009 Texas Instruments Incorporated - http://www.ti.com/
 * 
 *  Redistribution and use in source and binary forms, with or without 
 *  modification, are permitted provided that the following conditions 
 *  are met:
 *
 *    Redistributions of source code must retain the above copyright 
 *    notice, this list of conditions and the following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the 
 *    documentation and/or other materials provided with the   
 *    distribution.
 *
 *    Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 *  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
*/

/** ============================================================================
 *   @file  cslr_uart.h
 *
 *   @path  $(CSLPATH)
 *
 *   @desc  This file contains the Register Descriptions for UART
 *
 *  ============================================================================
 */
#ifndef _CSLR_UART_H_
#define _CSLR_UART_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <cslr.h>
#include <tistdtypes.h>




/* Minimum unit = 4 bytes */

/**************************************************************************\
* Register Overlay Structure
\**************************************************************************/
typedef struct  {
    volatile Uint32 DATA;
	volatile Uint32 STAT;
	volatile Uint32 CTRL;
	volatile Uint32 SCALE;
} CSL_UartRegs;

/**************************************************************************\
* Overlay structure typedef definition
\**************************************************************************/
typedef volatile CSL_UartRegs             *CSL_UartRegsOvly;

/**************************************************************************\
* Field Definition Macros
\**************************************************************************/

/* DATA */

#define CSL_UART_DATA_BYTE_MASK           	(0x000000FFu)
#define CSL_UART_DATA_HALFWORD_MASK         (0x0000FFFFu)
#define CSL_UART_DATA_WORD_MASK         	(0xFFFFFFFFu)

#define CSL_UART_DATA_BYTE_SHIFT           	(0x00000000u)
#define CSL_UART_DATA_HALFWORD_SHIFT        (0x00000000u)
#define CSL_UART_DATA_WORD_SHIFT         	(0x00000000u)

/* STAT */

#define CSL_UART_STAT_RCNT_MASK           	(0xFC000000u)
#define CSL_UART_STAT_RCNT_SHIFT           	(0x0000001Au)

#define CSL_UART_STAT_TCNT_MASK           	(0x03F00000u)
#define CSL_UART_STAT_TCNT_SHIFT           	(0x00000014u)

#define CSL_UART_STAT_RF_MASK           	(0x00000400u)
#define CSL_UART_STAT_RF_SHIFT           	(0x0000000Au)

#define CSL_UART_STAT_TF_MASK           	(0x00000200u)
#define CSL_UART_STAT_TF_SHIFT           	(0x00000009u)

#define CSL_UART_STAT_RH_MASK           	(0x00000100u)
#define CSL_UART_STAT_RH_SHIFT           	(0x00000008u)

#define CSL_UART_STAT_TH_MASK           	(0x00000080u)
#define CSL_UART_STAT_TH_SHIFT           	(0x00000007u)

#define CSL_UART_STAT_TE_MASK           	(0x00000004u)
#define CSL_UART_STAT_TE_SHIFT           	(0x00000002u)

#define CSL_UART_STAT_TS_MASK           	(0x00000002u)
#define CSL_UART_STAT_TS_SHIFT           	(0x00000001u)

#define CSL_UART_STAT_DR_MASK           	(0x00000001u)
#define CSL_UART_STAT_DR_SHIFT           	(0x00000000u)

/* CTRL */

#define CSL_UART_CTRL_DI_MASK           	(0x00002000u)
#define CSL_UART_CTRL_DI_SHIFT           	(0x0000000Du)
#define CSL_UART_CTRL_DI_RESETVAL           (0x00000000u)

#define CSL_UART_CTRL_RF_MASK           	(0x00000400u)
#define CSL_UART_CTRL_RF_SHIFT           	(0x0000000Au)
#define CSL_UART_CTRL_RF_RESETVAL           (0x00000000u)

#define CSL_UART_CTRL_TF_MASK           	(0x00000200u)
#define CSL_UART_CTRL_TF_SHIFT           	(0x00000009u)
#define CSL_UART_CTRL_TF_RESETVAL           (0x00000000u)

#define CSL_UART_CTRL_LB_MASK           	(0x00000080u)
#define CSL_UART_CTRL_LB_SHIFT           	(0x00000007u)
#define CSL_UART_CTRL_LB_RESETVAL           (0x00000000u)

#define CSL_UART_CTRL_PE_MASK           	(0x00000020u)
#define CSL_UART_CTRL_PE_SHIFT           	(0x00000005u)
#define CSL_UART_CTRL_PE_RESETVAL           (0x00000000u)

#define CSL_UART_CTRL_PS_MASK           	(0x00000010u)
#define CSL_UART_CTRL_PS_SHIFT           	(0x00000004u)
#define CSL_UART_CTRL_PS_RESETVAL           (0x00000000u)

#define CSL_UART_CTRL_TI_MASK           	(0x00000008u)
#define CSL_UART_CTRL_TI_SHIFT           	(0x00000003u)
#define CSL_UART_CTRL_TI_RESETVAL           (0x00000008u)

#define CSL_UART_CTRL_RI_MASK           	(0x00000004u)
#define CSL_UART_CTRL_RI_SHIFT           	(0x00000002u)
#define CSL_UART_CTRL_RI_RESETVAL           (0x00000004u)

#define CSL_UART_CTRL_TE_MASK           	(0x00000002u)
#define CSL_UART_CTRL_TE_SHIFT           	(0x00000001u)
#define CSL_UART_CTRL_TE_RESETVAL           (0x00000002u)

#define CSL_UART_CTRL_RE_MASK           	(0x00000001u)
#define CSL_UART_CTRL_RE_SHIFT           	(0x00000000u)
#define CSL_UART_CTRL_RE_RESETVAL           (0x00000001u)

/* SCALE */

#define CSL_UART_SCALE_VALUE_MASK           (0x00000FFFu)
#define CSL_UART_SCALE_VALUE_SHIFT          (0x00000000u)

#ifdef __cplusplus
}
#endif

#endif

