/*  ============================================================================
 *   Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 *   Use of this software is controlled by the terms and conditions found
 *   in the license agreement under which this software has been supplied.
 *  ============================================================================
 */
/** ============================================================================
 *  @file    csl_emifaAux.h
 *
 *  @path    $(CSLPATH)\inc
 *
 *  @desc    Header file for functional layer of CSL
 *           - The defines inline function definitions 
 *
 */
/* =============================================================================
 *  Revision History
 *  ===============
 *  12-May-2005 RM  File Created.
 *  
 *  08-Jul-2005 RM  Changes made in accordance to the change in cslr_emifa.h            
 *                               
 *  09-Sep-2005 NG  Updation according to coding guidelines
 *  
 * =============================================================================
 */
#ifndef _CSL_EMIFAAUX_H_
#define _CSL_EMIFAAUX_H_

#include "csl_emif.h"

#ifdef __cplusplus
extern "C" {
#endif

CSL_IDEF_INLINE
void CSL_emifGetRevId (
    CSL_EmifHandle      hEmif,
    CSL_EmifModIdRev    *status
)
{
    status->modId = (Uint16)CSL_FEXT(hEmif->regs->RCSR, EMIF_RCSR_MODID);
    status->majRev = (Uint8)CSL_FEXT(hEmif->regs->RCSR, EMIF_RCSR_MJREV);
    status->minRev = (Uint8)CSL_FEXT(hEmif->regs->RCSR, EMIF_RCSR_MINREV);
}

CSL_IDEF_INLINE
void CSL_emifSetExt(
    CSL_EmifHandle hEmif
)
{
    CSL_FINS(hEmif->regs->RCSR, EMIF_RCSR_EXT, 1);
}

CSL_IDEF_INLINE
void CSL_emifClearExt(
    CSL_EmifHandle hEmif
)
{
    CSL_FINS(hEmif->regs->RCSR, EMIF_RCSR_EXT, 0);
}

/*-----------------------------------*/

CSL_IDEF_INLINE
Uint8 CSL_emifGetAsyncTimeoutMaskStatus (
    CSL_EmifHandle hEmif
)
{
    Uint8    status;
    status = ((Uint8) CSL_FEXT(hEmif->regs->IMCR, EMIF_IMCR_AT_MASK_CLR)) &
             ((Uint8) CSL_FEXT(hEmif->regs->IMSR, EMIF_IMSR_AT_MASK_SET)) ;
    return status;
}

CSL_IDEF_INLINE
Uint8 CSL_emifGetAsyncTimeoutStatus (
    CSL_EmifHandle hEmif
)
{
    Uint8    status;
    status = (Uint8) CSL_FEXT(hEmif->regs->IRR, EMIF_IRR_AT) ||
             (Uint8) CSL_FEXT(hEmif->regs->IMR, EMIF_IMR_AT);
     
    return status;
}

CSL_IDEF_INLINE
Uint8 CSL_emifGetWaitRiseStatus(
    CSL_EmifHandle hEmif
)
{
	Uint8 status;
	status = (Uint8) CSL_FEXT(hEmif->regs->IRR, EMIF_IRR_WR) ||
            (Uint8) CSL_FEXT(hEmif->regs->IMR, EMIF_IMR_WR);
	return status;
}

CSL_IDEF_INLINE
void CSL_emifAsyncClear (
    CSL_EmifHandle    hEmifa
)
{
    CSL_FINST(hEmifa->regs->IRR, EMIF_IRR_AT, SET);
}

CSL_IDEF_INLINE
void CSL_emifAsyncDisable (
    CSL_EmifHandle    hEmifa
)
{
    CSL_FINST(hEmifa->regs->IMCR, EMIF_IMCR_AT_MASK_CLR, SET);
}

CSL_IDEF_INLINE
void CSL_emifAsyncEnable (
    CSL_EmifHandle    hEmifa
)
{
    CSL_FINST(hEmifa->regs->IMSR, EMIF_IMSR_AT_MASK_SET, SET);
}



#ifdef __cplusplus
}
#endif

#endif /* _CSL_EMIFAAUX_H_ */

