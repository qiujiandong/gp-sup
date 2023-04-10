/**
 *   @file  csl_timerGetBaseAddress.c
 *
 *   @brief   
 *      The file contains routines which are TIMER Device specific
 *      and need to be modified for each new device which has the 
 *      TIMER IP module. 
 *  ============================================================================*/

#include <soc.h>
#include <csl_tmr.h>
#include <csl_utils.h>

//#pragma CODE_SECTION (CSL_tmrGetBaseAddress, ".text:csl_section:tmr")
CSL_SET_CSECT(CSL_tmrGetBaseAddress, ".text:csl_section:tmr")
CSL_Status CSL_tmrGetBaseAddress 
(
    CSL_InstNum            tmrNum,
    CSL_TmrParam*          pTmrParam,
    CSL_TmrBaseAddress*    pBaseAddress
)
{
    CSL_Status st = CSL_SOK;

    pTmrParam = pTmrParam;

    if (pBaseAddress == NULL)
    {
        st = (CSL_Status)CSL_ESYS_INVPARAMS;
    }
    else
    {
        switch (tmrNum) {
            case CSL_TMR_0:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_0_REGS;
                break;
            case CSL_TMR_1:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_1_REGS;
                break;
            case CSL_TMR_2:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_2_REGS;
                break;
            case CSL_TMR_3:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_3_REGS;
                break;
            case CSL_TMR_4:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_4_REGS;
                break;
            case CSL_TMR_5:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_5_REGS;
                break;
            case CSL_TMR_6:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_6_REGS;
                break;
            case CSL_TMR_7:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_7_REGS;
                break;
            case CSL_TMR_8:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_8_REGS;
                break;
            case CSL_TMR_9:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_9_REGS;
                break;
            case CSL_TMR_10:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_10_REGS;
                break;
            case CSL_TMR_11:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_11_REGS;
                break;
            case CSL_TMR_12:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_12_REGS;
                break;
            case CSL_TMR_13:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_13_REGS;
                break;
            case CSL_TMR_14:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_14_REGS;
                break;
            case CSL_TMR_15:
                pBaseAddress->regs = (CSL_TmrRegsOvly)CSL_TIMER_15_REGS;
                break;
            default:
                pBaseAddress->regs = (CSL_TmrRegsOvly)NULL;
                st = (CSL_Status)CSL_ESYS_FAIL;
                break;
        }
    }
    return st;
}

