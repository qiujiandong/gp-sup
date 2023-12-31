/*  ============================================================================
 *   Copyright (c) Texas Instruments Incorporated 2002, 2003, 2004, 2005, 2008                 
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

/*
 *  @file  _csl_intcResourceAlloc.c
 *
 *  @brief   File for functional layer of CSL API for intc resource allocation
 *
 *  PATH  $(CSLPATH)\src\intc
 */
 
/* =============================================================================
 *  Revision History
 *  ===============
 *  12-Jun-2004 Ruchika Kharwar File Created
 *
 * =============================================================================
 */

#include <csl_intc.h>
#include <_csl_intc.h>

CSL_SET_DSECT(CSL_intcAllocMask, ".bss:csl_section:intc")
CSL_BitMask32* CSL_intcAllocMask = NULL;

CSL_SET_DSECT(_CSL_intcCpuIntrTable, ".bss:csl_section:intc")
CSL_IntcVect _CSL_intcCpuIntrTable;

CSL_SET_DSECT(CSL_intcEventOffsetMap, ".bss:csl_section:intc")
Int8 *CSL_intcEventOffsetMap = NULL;

CSL_SET_DSECT(CSL_intcNumEvents, ".bss:csl_section:intc")
Uint16 CSL_intcNumEvents;

CSL_SET_DSECT(CSL_intcEventHandlerRecord_p, ".bss:csl_section:intc")
CSL_IntcEventHandlerRecord* CSL_intcEventHandlerRecord_p;

