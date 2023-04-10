/*  ============================================================================
 *   Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 *   Use of this software is controlled by the terms and conditions found
 *   in the license agreement under which this software has been supplied.
 *  ============================================================================
 */
/** ============================================================================
 *  @file    csl_emifaGetHwSetup.c
 *
 *  @path    $(CSLPATH)\src\emifa
 *
 *  $desc    File for functional layer of CSL API @a CSL_emifaGetHwSetup()
 *           - The @a CSL_emifaGetHwSetup() function definition & it's 
 *             associated functions
 *
 */
/* =============================================================================
 *  Revision History
 *  ===============
 *  12-May-2005 RM  File Created.
 *  
 *  09-Sep-2005 NG  Updation according to coding guidelines
 *  
 * =============================================================================
 */
#include <csl_emif.h>
#include <csl_utils.h>

/** ============================================================================
 * @n@b   CSL_emifaGetHwSetup
 *
 * @b Description
 * @n This function gets the current setup of the EMIFA. The status is
 *    returned through @a CSL_EmifaHwSetup. The obtaining of status
 *    is the reverse operation of @a CSL_emifaHwSetup() function.
 *
 * @b Arguments
 * @verbatim      
            hEmif          Pointer to the object that holds reference to the
                            instance of EMIFA requested after the call
 
            setup           Pointer to setup structure which contains the
                            information to program EMIFA to a useful state 
   @endverbatim
 *
 * <b> Return Value </b>  CSL_Status
 * @li                    CSL_SOK             - Hardware status call is 
 *                                               successful
 * @li                    CSL_ESYS_FAIL      - The external memory interface 
 *                                              instance is not available.
 * @li                    CSL_ESYS_INVPARAMS - Parameters are not valid    
 * @li                    CSL_ESYS_BADHANDLE - Handle is not valid    
 *
 * <b> Pre Condition </b>
 * @n  Both @a CSL_emifaInit() and @a CSL_emifaOpen() must be called 
 *     successfully in order before calling @a CSL_emifaGetHwSetup().
 *
 * <b> Post Condition </b>
 * @n  None
 *
 * @b Modifies
 * @n Second parameter setup
 *
 * @b Example:
 * @verbatim
      CSL_EmifaHandle hEmif;
      CSL_Status status;
      CSL_EmifaHwSetup hwSetup;      
      CSL_EmifaAsync asyncMem;
      CSL_EmifaMemType value;
      CSL_EmifaAsyncWait asyncWait;

      value.ssel = 0;
      value.async = &asyncMem;
      value.sync = NULL;      
      hwSetup.asyncWait = &asyncWait;
      hwSetup.ceCfg [0] = &value;
      hwSetup.ceCfg [1] = NULL;
      hwSetup.ceCfg [2] = NULL;
      hwSetup.ceCfg [3] = NULL;   
      
      //Initialize the Emifa CSL 
     
      //Open Emifa Module

      status = CSL_emifaGetHwSetup(hEmif, &hwSetup);

   @endverbatim
 *
 * =============================================================================
 */

//#pragma CODE_SECTION (CSL_emifGetHwSetup, ".text:csl_section:emif")
CSL_SET_CSECT(CSL_emifGetHwSetup, ".text:csl_section:emif")
CSL_Status  CSL_emifGetHwSetup (
    CSL_EmifHandle     hEmif,
    CSL_EmifHwSetup    *setup
)
{
    Uint8 loop;
    volatile Uint32* ceCfgBaseAddr=0;
    CSL_Status status = CSL_SOK;
    
    /* invalid parameter checking */
    if (setup == NULL) {
        status = CSL_ESYS_INVPARAMS;
    }
    else if (hEmif == NULL) {
        /* bad handle checking */
        status = CSL_ESYS_BADHANDLE;
    }    
    else {
        /* Get Async config */
        if (setup->asyncWait != NULL) {
            setup->asyncWait->wp0 = (CSL_EmifArdyPol)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_WP0);
            setup->asyncWait->wp1 = (CSL_EmifArdyPol)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_WP1);
            setup->asyncWait->ce_type[0] = (CSL_EmifMemoryType)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_CE0_TYPE);
            setup->asyncWait->ce_type[1] = (CSL_EmifMemoryType)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_CE1_TYPE);
            setup->asyncWait->ce_type[2] = (CSL_EmifMemoryType)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_CE2_TYPE);
            setup->asyncWait->ce_type[3] = (CSL_EmifMemoryType)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_CE3_TYPE);
            setup->asyncWait->ce_wait[0] = (CSL_EmifWaitSel)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_CE0_WAIT);
            setup->asyncWait->ce_wait[1] = (CSL_EmifWaitSel)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_CE1_WAIT);
            setup->asyncWait->ce_wait[2] = (CSL_EmifWaitSel)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_CE2_WAIT);
            setup->asyncWait->ce_wait[3] = (CSL_EmifWaitSel)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_CE3_WAIT);
            setup->asyncWait->maxExtWait = (Uint8)CSL_FEXT(hEmif->regs->AWCCR, EMIF_AWCCR_MAX_EXT_WAIT);
        }

        ceCfgBaseAddr = &(hEmif->regs->A1CR);

        for (loop=0; loop < NUMCHIPENABLE; loop++) {
            if (setup->ceCfg[loop] != NULL)
            {
                if ((setup->asyncWait->ce_type[loop] == CSL_EMIF_MEMTYPE_ASYNC ) && (setup->ceCfg[loop]->async != NULL))
                {      
                    setup->ceCfg[loop]->async->selectStrobe = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_SS);
                    setup->ceCfg[loop]->async->ewMode = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_EW);
                    setup->ceCfg[loop]->async->wSetup = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_W_SETUP);
                    setup->ceCfg[loop]->async->wStrobe = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_W_STROBE);
                    setup->ceCfg[loop]->async->wHold = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_W_HOLD);
                    setup->ceCfg[loop]->async->rSetup = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_R_SETUP);
                    setup->ceCfg[loop]->async->rStrobe = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_R_STROBE);
                    setup->ceCfg[loop]->async->rHold = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_R_HOLD);
                    setup->ceCfg[loop]->async->TA = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_TA);
                    setup->ceCfg[loop]->async->asize = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_ASIZE);
                }

                if ((setup->asyncWait->ce_type[loop] == CSL_EMIF_MEMTYPE_SYNC ) && (setup->ceCfg[loop]->sync != NULL))
                {
                    setup->ceCfg[loop]->sync->chipEnExt = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_CEEXT);
                    setup->ceCfg[loop]->sync->readEn = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_RENEN);
                    setup->ceCfg[loop]->sync->w_ltncy = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_SYNCWL);
                    setup->ceCfg[loop]->sync->r_ltncy = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_SYNRWL);
                    setup->ceCfg[loop]->sync->sbsize = (Uint8)CSL_FEXT(*(ceCfgBaseAddr + loop), EMIF_AxCR_SIZE);
                }      
                else {
                    status = CSL_ESYS_FAIL;
                }  
            }
        }
    }
    
    return (status);
}

