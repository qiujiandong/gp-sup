/**
 *   @file  csl_cpIntc.h
 *
 *   @brief   
 *      This is the main header file for the CPINTC Module which defines
 *      all the data structures and exported API.
 *
 *  \par
 *  ============================================================================
 *  @n   (C) Copyright 2008, 2009, Texas Instruments, Inc.
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

/** @defgroup CSL_CPINTC_API CPINTC
 *
 * @section Introduction
 *
 * @subsection xxx Overview
 *  The CPINTC is the interrupt controller which handles the system interrupts
 *  for the host, processes & prioritizes them and then is responsible for 
 *  delivering these to the host.
 *
 * @subsection References
 *   -# CPINTC Architecture Specification.
 *
 * @subsection Assumptions
 *    The abbreviations CPINTC, cpintc have been used throughout this
 *    document to refer to Interrupt Controller.
 */
 
#ifndef CSL_CPINTC_H
#define CSL_CPINTC_H

#ifdef __cplusplus
extern "C" {
#endif

#include <soc.h>
#include <csl.h>
#include <cslr_cpintc.h>

/** @brief Register Overlay Memory map for the CPINTC0 Registers. */

#define hCpintc0 ((CSL_CPINTC_RegsOvly)CSL_CP_INTC_0_REGS)

#define hCpintc1 ((CSL_CPINTC_RegsOvly)CSL_CP_INTC_1_REGS)

#define hCpintc2 ((CSL_CPINTC_RegsOvly)CSL_CP_INTC_2_REGS)

#define hCpintc3 ((CSL_CPINTC_RegsOvly)CSL_CP_INTC_3_REGS)

/** @brief This defines the system interrupt */
typedef Uint32   CSL_CPINTCSystemInterrupt;

/** @brief This defines the host interrupt */
typedef Uint32   CSL_CPINTCHostInterrupt;

/** @brief This defines the channels */
typedef Uint32   CSL_CPINTCChannel;

static inline void CSL_cpintcEnableAllHostInterrupt (CSL_CPINTC_RegsOvly hnd)
{
    CSL_FINS(hnd->GLOBAL_ENABLE_HINT_REG, CPINTC_GLOBAL_ENABLE_HINT_REG_ENABLE_HINT_ANY, 1);
}

static inline void CSL_cpintcDisableAllHostInterrupt (CSL_CPINTC_RegsOvly hnd)
{
	CSL_FINS(hnd->GLOBAL_ENABLE_HINT_REG, CPINTC_GLOBAL_ENABLE_HINT_REG_ENABLE_HINT_ANY, 0);
}

static inline void CSL_cpintcSetSysInterrupt
(
	CSL_CPINTC_RegsOvly hnd,
    CSL_CPINTCSystemInterrupt sysIntr
)
{
    CSL_FINS(hnd->STATUS_SET_INDEX_REG, CPINTC_ENABLE_SET_INDEX_REG_ENABLE_SET_INDEX, sysIntr);
}

static inline void CSL_cpintcClearSysInterrupt
(
	CSL_CPINTC_RegsOvly hnd,
    CSL_CPINTCSystemInterrupt sysIntr
)
{
    CSL_FINS(hnd->STATUS_CLR_INDEX_REG, CPINTC_STATUS_CLR_INDEX_REG_STATUS_CLR_INDEX, sysIntr);
}

static inline void CSL_cpintcClearAllSysInterrupt
(
	CSL_CPINTC_RegsOvly hnd
)
{
	hnd->ENA_STATUS_REG[0] = 0xFFFFFFFF;
	hnd->ENA_STATUS_REG[1] = 0xFFFFFFFF;
	hnd->ENA_STATUS_REG[2] = 0xFFFFFFFF;
}

static inline void CSL_cpintcEnableSysInterrupt
(
	CSL_CPINTC_RegsOvly hnd,
    CSL_CPINTCSystemInterrupt sysIntr
)
{
    CSL_FINS(hnd->ENABLE_SET_INDEX_REG, CPINTC_STATUS_SET_INDEX_REG_STATUS_SET_INDEX, sysIntr);
}

static inline void CSL_cpintcDisableSysInterrupt
(
	CSL_CPINTC_RegsOvly hnd,
    CSL_CPINTCSystemInterrupt sysIntr
)
{
    CSL_FINS(hnd->ENABLE_CLR_INDEX_REG, CPINTC_ENABLE_CLR_INDEX_REG_ENABLE_CLR_INDEX, sysIntr);
}

static inline void CSL_cpintcEnableHostInterrupt
(
	CSL_CPINTC_RegsOvly           hnd,
    CSL_CPINTCHostInterrupt     hostIntr
)
{
    CSL_FINS(hnd->HINT_ENABLE_SET_INDEX_REG, CPINTC_HINT_ENABLE_SET_INDEX_REG_HINT_ENABLE_SET_INDEX, hostIntr);
}

static inline void CSL_cpintcDisableHostInterrupt
(
	CSL_CPINTC_RegsOvly hnd,
    CSL_CPINTCHostInterrupt hostIntr
)
{
    CSL_FINS(hnd->HINT_ENABLE_CLR_INDEX_REG, CPINTC_HINT_ENABLE_CLR_INDEX_REG_HINT_ENABLE_CLR_INDEX, hostIntr);
}

static inline Bool CSL_cpintcIsRawSysInterruptPending
(
	CSL_CPINTC_RegsOvly hnd,
	CSL_CPINTCHostInterrupt sysIntr
)
{
	Uint8 regIndex = sysIntr>>5;
	Uint8 bitIndex = sysIntr & 0x1F;
    return (Bool)CSL_FEXTR(hnd->RAW_STATUS_REG[regIndex], bitIndex, bitIndex);
}

static inline Bool CSL_cpintcIsEnabledSysInterruptPending
(
	CSL_CPINTC_RegsOvly hnd,
	CSL_CPINTCHostInterrupt sysIntr
)
{
	Uint8 regIndex = sysIntr>>5;
	Uint8 bitIndex = sysIntr & 0x1F;
    return (Bool)CSL_FEXTR(hnd->ENA_STATUS_REG[regIndex], bitIndex, bitIndex);
}

static inline void CSL_cpintcMapSystemIntrToChannel
(
	CSL_CPINTC_RegsOvly       	hnd,
    CSL_CPINTCSystemInterrupt   sysIntr,
    CSL_CPINTCChannel           channel
)
{
	Uint8 regIndex = sysIntr >> 2;
	Uint8 shiftIndex = (sysIntr & 0x3) << 3;
	CSL_FINSR(hnd->CH_MAP_REG[regIndex], shiftIndex+7, shiftIndex, channel);
}

#ifdef __cplusplus
}
#endif

#endif /* CSL_CPINTC_H */

