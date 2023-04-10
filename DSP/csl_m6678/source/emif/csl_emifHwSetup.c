/*  ============================================================================
 *   Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 *   Use of this software is controlled by the terms and conditions found
 *   in the license agreement under which this software has been supplied.
 *  ============================================================================
 */
/** ============================================================================
 *  @file    csl_emifaHwSetup.c
 *
 *  @path    $(CSLPATH)\src\emifa
 *
 *  @desc    File for functional layer of CSL API @a CSL_emifaHwSetup()
 *           - The @a CSL_emifaHwSetup() function definition & it's associated
 *             functions
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
#include <csl_emif.h>
#include <csl_utils.h>

/** ============================================================================
 * @n@b   CSL_emifaHwSetup
 *
 * @b Description
 * @n This function initializes the device registers with the appropriate values
 *  provided through the HwSetup data structure. For information passed through 
 *  the HwSetup data structure refer @a CSL_EmifaHwSetup.
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
 * @li                    CSL_SOK            - configuration successful
 * @li                    CSL_ESYS_FAIL      - The external memory interface 
 *                                              instance is not available.
 * @li                    CSL_ESYS_INVPARAMS - Parameters are not valid    
 * @li                    CSL_ESYS_BADHANDLE - Handle is not valid    
 *
 * <b> Pre Condition </b>
 * @n  Both @a CSL_emifaInit() and @a CSL_emifaOpen() must be called
 *     successfully in order before calling this function. The user has to 
 *     allocate space for & fill in the main setup structure appropriately
 *     before calling this function. 
 *
 * <b> Post Condition </b>
 * @n  EMIFA registers are configured according to the hardware setup parameters
 *
 *   @b Modifies
 *   @n EMIFA registers  
 *
 * @b Example:
 * @verbatim
     CSL_EmifaHandle hEmif;
     CSL_EmifaAsync asyncMem = CSL_EMIFA_ASYNCCFG_DEFAULTS;
     CSL_EmifaAsyncWait asyncWait = CSL_EMIFA_ASYNCWAIT_DEFAULTS; 
     CSL_EmifaMemType value;
     CSL_EmifaHwSetup hwSetup ;

     value.ssel = 0;
     value.async = &asyncMem;
     value.sync = NULL;      
     hwSetup.asyncWait = &asyncMem;
     hwSetup.cefg [0] = &value;
     hwSetup.ceCfg [1] = NULL;
     hwSetup.ceCfg [2] = NULL;
     hwSetup.ceCfg [3] = NULL;
     
     //Initialize the Emifa CSL 
     
     //Open Emifa Module

     CSL_emifaHwSetup(hEmif, &hwSetup);
     
   @endverbatim
 *
 * ============================================================================
 */

//#pragma CODE_SECTION (CSL_emifHwSetup, ".text:csl_section:emif");
CSL_SET_CSECT(CSL_emifHwSetup, ".text:csl_section:emif")
CSL_Status CSL_emifHwSetup(
    CSL_EmifHandle     hEmif,
    CSL_EmifHwSetup    *setup
)
{
    CSL_Status status = CSL_SOK;
    Uint32 mask, mask1, mask2;
    Uint8 loop;
    volatile Uint32 *ceCfgBaseAddr = 0;
    
    /* invalid parameter checking */
    if (setup == NULL) {
        status = CSL_ESYS_INVPARAMS;
    }
    else if (hEmif == NULL) {
        /* bad handle checking */
        status = CSL_ESYS_BADHANDLE;
    }           
    else {

		CSL_FINS(hEmif->regs->RCSR, EMIF_RCSR_EXT, 1);

        if (setup->asyncWait != NULL) {
            mask = 0xC0F00000;

            hEmif->regs->AWCCR = (hEmif->regs->AWCCR & mask) |
                    (CSL_FMK(EMIF_AWCCR_WP0, setup->asyncWait->wp0)) |
                    (CSL_FMK(EMIF_AWCCR_WP1, setup->asyncWait->wp1)) |
					(CSL_FMK(EMIF_AWCCR_CE3_WAIT, setup->asyncWait->ce_wait[3])) |
					(CSL_FMK(EMIF_AWCCR_CE2_WAIT, setup->asyncWait->ce_wait[2])) |
					(CSL_FMK(EMIF_AWCCR_CE1_WAIT, setup->asyncWait->ce_wait[1])) |
					(CSL_FMK(EMIF_AWCCR_CE0_WAIT, setup->asyncWait->ce_wait[0])) |
					(CSL_FMK(EMIF_AWCCR_CE3_TYPE, setup->asyncWait->ce_type[3])) |
					(CSL_FMK(EMIF_AWCCR_CE2_TYPE, setup->asyncWait->ce_type[2])) |
					(CSL_FMK(EMIF_AWCCR_CE1_TYPE, setup->asyncWait->ce_type[1])) |
					(CSL_FMK(EMIF_AWCCR_CE0_TYPE, setup->asyncWait->ce_type[0])) |
                    (CSL_FMK(EMIF_AWCCR_MAX_EXT_WAIT, setup->asyncWait->maxExtWait));
        }

        /* Configuring chip selects for synchronous or Asynchronous memory */
        ceCfgBaseAddr = &(hEmif->regs->A1CR);

        mask1 = ~((CSL_EMIF_AxCR_SS_MASK) |
                  (CSL_EMIF_AxCR_EW_MASK) |
                  (CSL_EMIF_AxCR_W_SETUP_MASK) |
                  (CSL_EMIF_AxCR_W_STROBE_MASK) |
                  (CSL_EMIF_AxCR_W_HOLD_MASK) |
                  (CSL_EMIF_AxCR_R_SETUP_MASK) |
                  (CSL_EMIF_AxCR_R_STROBE_MASK) |
                  (CSL_EMIF_AxCR_R_HOLD_MASK) |
                  (CSL_EMIF_AxCR_TA_MASK) |
				  (CSL_EMIF_AxCR_ASIZE_MASK));

        mask2 = ~((CSL_EMIF_AxCR_RENEN_MASK) |
                  (CSL_EMIF_AxCR_CEEXT_MASK) |
                  (CSL_EMIF_AxCR_SYNCWL_MASK) |
                  (CSL_EMIF_AxCR_SYNRWL_MASK) |
                  (CSL_EMIF_AxCR_SIZE_MASK));

        for (loop = 0; loop < NUMCHIPENABLE; loop++) {
            if (setup->ceCfg[loop] != NULL) {
                if ((setup->asyncWait->ce_type[loop] == CSL_EMIF_MEMTYPE_ASYNC) && (setup->ceCfg[loop]->async != NULL)) {
                    *(ceCfgBaseAddr + loop) = (*(ceCfgBaseAddr + loop) & mask1) |
                            (CSL_FMK(EMIF_AxCR_SS, setup->ceCfg[loop]->async->selectStrobe)) |
                            (CSL_FMK(EMIF_AxCR_EW, setup->ceCfg[loop]->async->ewMode)) |
                            (CSL_FMK(EMIF_AxCR_W_SETUP, setup->ceCfg[loop]->async->wSetup)) |
                            (CSL_FMK(EMIF_AxCR_W_STROBE, setup->ceCfg[loop]->async->wStrobe)) |
                            (CSL_FMK(EMIF_AxCR_W_HOLD, setup->ceCfg[loop]->async->wHold)) |
                            (CSL_FMK(EMIF_AxCR_R_SETUP, setup->ceCfg[loop]->async->rSetup)) |
                            (CSL_FMK(EMIF_AxCR_R_STROBE, setup->ceCfg[loop]->async->rStrobe)) |
                            (CSL_FMK(EMIF_AxCR_R_HOLD, setup->ceCfg[loop]->async->rHold)) |
							(CSL_FMK(EMIF_AxCR_TA, setup->ceCfg[loop]->async->TA)) |
                            (CSL_FMK(EMIF_AxCR_ASIZE, setup->ceCfg[loop]->async->asize));
                }
                else {
                    if ((setup->asyncWait->ce_type[loop] == CSL_EMIF_MEMTYPE_SYNC) && (setup->ceCfg[loop]->sync != NULL)) {
                        *(ceCfgBaseAddr + loop) = (*(ceCfgBaseAddr + loop) & mask2)|
                            (CSL_FMK(EMIF_AxCR_RENEN, setup->ceCfg[loop]->sync->readEn)) |
                            (CSL_FMK(EMIF_AxCR_CEEXT, setup->ceCfg[loop]->sync->chipEnExt)) |
                            (CSL_FMK(EMIF_AxCR_SYNCWL, setup->ceCfg[loop]->sync->w_ltncy)) |
                            (CSL_FMK(EMIF_AxCR_SYNRWL, setup->ceCfg[loop]->sync->r_ltncy)) |
                            (CSL_FMK(EMIF_AxCR_SIZE, setup->ceCfg[loop]->sync->sbsize));
                    }     
                    else {
                        status = CSL_ESYS_FAIL;
                    }
                }
            }
        }
    }
    
    return (status);
}

