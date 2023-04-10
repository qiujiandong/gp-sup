/**
 *   @file  csl_pllcAux.h
 *
 *   @brief API Auxilary header file for PLLC CSL
 *
 *  \par
 *  ============================================================================
 *  @n   (C) Copyright 2010 Texas Instruments, Inc.
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
#ifndef _CSL_PLLCAUX_H_
#define _CSL_PLLCAUX_H_

#include <csl_pllc.h>

#ifdef __cplusplus
extern "C" {
#endif

/** @addtogroup CSL_PLLC_FUNCTION
 @{ */

/** ============================================================================
 *   @n@b CSL_PLLC_getResetStatus
 *
 *   @b Description
 *   @n Gets the Reset Type Status of the PLLC.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  Uint32
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Reads
 *   @n RSTYPE
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;
        Uint32          response;
        ...

        response = CSL_pllcGetResetStatus (hPllc);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE Uint32 CSL_PLLC_getResetStatus()
{
   	return hPllc->RSTYPE;
}

/** ============================================================================
 *   @n@b CSL_PLLC_setResetCtrlReg
 *
 *   @b Description
 *   @n Sets up the Key and Software Reset bit in Reset control register contents.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
            key             Key value to setup
            swRstEnable     Enable/disable software reset
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  void
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Writes
 *   @n PLLC_RSTCTRL_KEY,
 *      PLLC_RSTCTRL_SWRST
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;

        ...

        CSL_PLLC_setResetCtrlReg (hPllc, CSL_PLLC_RSTCTRL_VALID_KEY, 1);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE void CSL_PLLC_setResetCtrlReg 
(
    Uint16              key,
    Uint8               swRstEnable
)
{
   	hPllc->RSTCTRL  =   CSL_FMK (PLLC_RSTCTRL_KEY, key) |
                        CSL_FMK (PLLC_RSTCTRL_SWRST, swRstEnable);

    return;
}

/** ============================================================================
 *   @n@b CSL_PLLC_getResetCtrlReg
 *
 *   @b Description
 *   @n Retrieves the contents of the Reset control register
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
            pKey            Key value read
            pSwRstEnable    Software reset enable bit read
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  void
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Reads
 *   @n PLLC_RSTCTRL_KEY,
 *      PLLC_RSTCTRL_SWRST
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;
        Uint16          key;
        Uint8           swRstEnable
        ...

        CSL_PLLC_getResetCtrlReg (hPllc, &key, &swRstEnable);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE void CSL_PLLC_getResetCtrlReg 
(
    Uint16*             pKey,
    Uint8*              pSwRstEnable
)
{
    Uint32              regVal;        

    regVal  =   hPllc->RSTCTRL;

    *pKey           =   CSL_FEXT(regVal, PLLC_RSTCTRL_KEY);
    *pSwRstEnable   =   CSL_FEXT(regVal, PLLC_RSTCTRL_SWRST);

   	return;
}

/** ============================================================================
 *   @n@b CSL_PLLC_setResetCfgReg
 *
 *   @b Description
 *   @n Sets up the contents of Reset configuration register.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
            wdType          Reset type initiated by Watchdog timers. Set 0 for hard
                            reset and 1 for soft reset
            resetType       Reset type initiated by RESET. Set 0 for hard
                            reset and 1 for soft reset
            pllCtrlRstType  Reset type initiated by PLL controller. Set 0 for hard
                            reset and 1 for soft reset
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  void
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API. Setup a 
 *       valid key using @a CSL_PLLC_setResetCtrlReg () API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Writes
 *   @n PLLC_RSTCFG_WDTYPEN,
 *      PLLC_RSTCFG_RESETTYPE,
 *      PLLC_RSTCFG_PLLCTLRSTTYPE
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;

        ...

        CSL_PLLC_setResetCfgReg (hPllc, 0, 0, 0);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE void CSL_PLLC_setResetCfgReg 
(
    Uint8               wdType,
    Uint8               resetType,
    Uint8               pllCtrlRstType
)
{
   	hPllc->RSTCFG   =   CSL_FMK (PLLC_RSTCFG_WDTYPEN, wdType) |
                        CSL_FMK (PLLC_RSTCFG_RESETTYPE, resetType) |
                        CSL_FMK (PLLC_RSTCFG_PLLCTLRSTTYPE, pllCtrlRstType);

    return;
}

/** ============================================================================
 *   @n@b CSL_PLLC_getResetCfgReg
 *
 *   @b Description
 *   @n Retrieves the contents of Reset configuration register.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
            pWdType         Reset type initiated by Watchdog timers. Returns 0 for hard
                            reset and 1 for soft reset
            pResetType      Reset type initiated by RESET. Returns 0 for hard
                            reset and 1 for soft reset
            pPllCtrlRstType Reset type initiated by PLL controller. Returns 0 for hard
                            reset and 1 for soft reset
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  void
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Reads
 *   @n PLLC_RSTCFG_WDTYPEN,
 *      PLLC_RSTCFG_RESETTYPE,
 *      PLLC_RSTCFG_PLLCTLRSTTYPE
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;
        Uint8           wdType, resetType, pllCtrlRstType;

        ...

        CSL_PLLC_getResetCfgReg (hPllc, &wdType, &resetType, &pllCtrlRstType);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE void CSL_PLLC_getResetCfgReg 
(
    Uint8*              pWdType,
    Uint8*              pResetType,
    Uint8*              pPllCtrlRstType
)
{
    Uint32              regVal;

    regVal  =   hPllc->RSTCFG;
    
    *pWdType            =   CSL_FEXT (regVal, PLLC_RSTCFG_WDTYPEN);
    *pResetType         =   CSL_FEXT (regVal, PLLC_RSTCFG_RESETTYPE);
    *pPllCtrlRstType    =   CSL_FEXT (regVal, PLLC_RSTCFG_PLLCTLRSTTYPE);

    return;
}

/* MainPll */

CSL_IDEF_INLINE Bool CSL_PLLC_getMainPllLockStat
(
)
{
	return (Bool) CSL_FEXT(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_LOCK);
}

/** ============================================================================
 *   @n@b CSL_PLLC_setPllCtrlPllEnSrc
 *
 *   @b Description
 *   @n Sets up the PLLENSRC bit of PLL Control Register. Can be used to enable/disable
 *      configuration of PLLEN bit of PLLCTL register. Writes to PLLEN bit take 
 *      effect on PLLC only when PLLENSRC bit is set to 0.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
            value           0/1 value to configure in PLLENSRC bit
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  void
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Writes
 *   @n PLLC_PLLCTL_PLLENSRC
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;

        ...

        // Enable PLLEN bit configuration
        CSL_PLLC_setPllCtrlPllEnSrc (hPllc, 0);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE void CSL_PLLC_assertMainPllEnSrc
(
)
{
    CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PLLENSRC, ENABLE);

    return;
}

CSL_IDEF_INLINE void CSL_PLLC_deassertMainPllEnSrc
(
)
{
    CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PLLENSRC, DISABLE);

    return;
}

/** ============================================================================
 *   @n@b CSL_PLLC_setPllCtrlPllEn
 *
 *   @b Description
 *   @n Sets the PLLEN bit of PLL Control Register. This bit must be set to 0
 *      to put PLLC in Bypass mode and to 1 to put it in PLL operational mode.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
            value           0/1 value to configure in PLL Enable bit. Set to 0 
                            to put PLLC in Bypass mode and to 1 to put in PLL mode.
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  void
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *       Enable configuration of PLLEN bit first using @a CSL_PLLC_setPllCtrlPllEnSrc () API
 *       by passing it a value 0.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Writes
 *   @n PLLC_PLLCTL_PLLEN
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;

        ...

        // Enable PLLEN bit configuration
        CSL_PLLC_setPllCtrlPllEnSrc (hPllc, 0);

        // Put PLLC in Bypass mode 
        CSL_PLLC_setPllCtrlPllEn (hPllc, 0);

        // Configure PLLM/Pre-Divider
        ...

        // Put PLLC back in PLL mode
        CSL_PLLC_setPllCtrlPllEn (hPllc, 1);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE void CSL_PLLC_assertMainPllCtrlPllEn
(
)
{
    CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PLLEN, ENABLE);

    return;
}

CSL_IDEF_INLINE void CSL_PLLC_deassertMainPllCtrlPllEn
(
)
{
    CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PLLEN, DISABLE);

    return;
}


/** ============================================================================
 *   @n@b CSL_PLLC_setPllCtrlPllPowerDown
 *
 *   @b Description
 *   @n Sets up the PLLPWRDWN bit of PLL Control Register. Must be set to 1 to
 *      power down PLL and to 0 to wake up the PLL.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
            value           Value to configure in PLL Power-down mode select bit. 
                            Set to 1 to place PLLC in power-down mode and to 0 to
                            wake it up.
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  void
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *       PLLC must be put in Bypass mode by passing a value 0 to @a CSL_PLLC_setPllCtrlPllEn () 
 *       API before powering up/down using this API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Writes
 *   @n PLLC_PLLCTL_PLLPWRDN
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;

        ...

        // Enable PLLEN bit configuration
        CSL_PLLC_setPllCtrlPllEnSrc (hPllc, 0);

        // Put PLLC in Bypass mode 
        CSL_PLLC_setPllCtrlPllEn (hPllc, 0);

        // Power down PLL
        CSL_PLLC_setPllCtrlPllPowerDown (hPllc, 1);

        ...

        // Wake up PLL
        CSL_PLLC_setPllCtrlPllPowerDown (hPllc, 0);

        // Put PLLC back in PLL mode
        CSL_PLLC_setPllCtrlPllEn (hPllc, 1);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE void CSL_PLLC_assertMainPllCtrlPowerDown
(
)
{
    CSL_FINST (hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PD, ENABLE);
    return;
}

CSL_IDEF_INLINE void CSL_PLLC_deassertMainPllCtrlPowerDown
(
)
{
    CSL_FINST (hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PD, DISABLE);

    return;
}

/* PLLDIV_V */
CSL_IDEF_INLINE void CSL_PLLC_assertPllDivEn
(
)
{
    CSL_FINST(hPllc->PLLDIV_V, PLLC_PLLDIV_V_DEN, ENABLE);

    return;
}

CSL_IDEF_INLINE void CSL_PLLC_deassertPllDivEn
(
)
{
    CSL_FINST(hPllc->PLLDIV_V, PLLC_PLLDIV_V_DEN, DISABLE);

    return;
}

CSL_IDEF_INLINE Uint32 CSL_PLLC_getPllDivRatio
(
)
{
    return CSL_FEXT(hPllc->PLLDIV_V, PLLC_PLLDIV_V_RATIO);
}

CSL_IDEF_INLINE void CSL_PLLC_setPllDivRatio(Uint8 value)
{
	CSL_FINS(hPllc->PLLDIV_V, PLLC_PLLDIV_V_RATIO, value);
    return ;
}

/* PLLCTLCMD */

CSL_IDEF_INLINE void CSL_PLLC_assertPllCtlCmdGo()
{
	CSL_FINST(hPllc->PLLCTLCMD, PLLC_PLLCTLCMD_GOSET, ASSERT);
    return ;
}

/* PLLSTAT */

CSL_IDEF_INLINE Bool CSL_PLLC_getPllGoStat()
{
    return (Bool)CSL_FEXT(hPllc->PLLSTAT, PLLC_PLLSTAT_GOSTAT);
}


/** ============================================================================
 *   @n@b CSL_PLLC_getPllDChangeReg
 *
 *   @b Description
 *   @n Retrieves the contents of PLL Divider Ratio Change Status register.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  Uint32
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Reads
 *   @n PLLC_DCHANGE_SYS1_16
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;
        Uint32          dChangeVal;
        ...

        dChangeVal   =   CSL_PLLC_getPllDChangeReg (hPllc);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE Uint32 CSL_PLLC_getPllDChangeStat
(
)
{
    return CSL_FEXT (hPllc->DCHANGE, PLLC_DCHANGE_CLK_V);
}

/** ============================================================================
 *   @n@b CSL_PLLC_setPllDChangeReg
 *
 *   @b Description
 *   @n Sets up the contents of PLL Divider Ratio Change Status register.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
            dChangeVal      Value to write to register.
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  void
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Writes
 *   @n PLLC_DCHANGE_SYS1_16
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;

        ...

        CSL_PLLC_setPllDChangeReg (hPllc, 0);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE void CSL_PLLC_ClearPllDChangeStat
(
)
{
    CSL_FINST(hPllc->DCHANGE, PLLC_DCHANGE_CLK_V, CLEAR);

    return;
}

/** ============================================================================
 *   @n@b CSL_PLLC_getPllSysClkStatusReg
 *
 *   @b Description
 *   @n Retrieves the contents of PLL SYSCLK Status register.
 *
 *   @b Arguments
 *   @verbatim
            hPllc           Handle to the PLLC instance
     @endverbatim
 *
 *   <b> Return Value </b>
 *   @n  Uint32
 *
 *   <b> Pre Condition </b>
 *   @n  Must call @a CSL_PLLC_open () before calling any PLLC CSL API.
 *
 *   <b> Post Condition </b>
 *   @n  None
 *
 *   @b Reads
 *   @n PLLC_SYSTAT_SYS1_16ON
 *
 *   @b Example
 *   @verbatim
        CSL_PllcHandle  hPllc;
        Uint32          sysClkStatus;
        ...

        sysClkStatus    =   CSL_PLLC_getPllSysClkStatusReg (hPllc);
     @endverbatim
 *  ============================================================================
 */
CSL_IDEF_INLINE Uint32 CSL_PLLC_getPllSysVClkStatusReg
(
)
{
    return CSL_FEXT (hPllc->SYSTAT, PLLC_SYSTAT_SYS_VON);
}

CSL_IDEF_INLINE Uint32 CSL_PLLC_getPllSys8ClkStatusReg
(
)
{
    return CSL_FEXT (hPllc->SYSTAT, PLLC_SYSTAT_SYS8ON);
}

CSL_IDEF_INLINE Uint32 CSL_PLLC_getPllSys4ClkStatusReg
(
)
{
    return CSL_FEXT (hPllc->SYSTAT, PLLC_SYSTAT_SYS4ON);
}

CSL_IDEF_INLINE Uint32 CSL_PLLC_getPllSys2ClkStatusReg
(
)
{
    return CSL_FEXT (hPllc->SYSTAT, PLLC_SYSTAT_SYS2ON);
}

CSL_IDEF_INLINE Uint32 CSL_PLLC_getPllSys1ClkStatusReg
(
)
{
    return CSL_FEXT (hPllc->SYSTAT, PLLC_SYSTAT_SYS1ON);
}



/* DDRPLLCMD */

CSL_IDEF_INLINE Bool CSL_PLLC_getDDRPllLockStat
(
)
{
	return (Bool) CSL_FEXT(hPllc->DDRPLLCMD, PLLC_DDRPLLCMD_LOCK);
}

CSL_IDEF_INLINE void CSL_PLLC_assertDDRPllPowerDown
(
)
{
	CSL_FINST (hPllc->DDRPLLCMD, PLLC_DDRPLLCMD_PD, ENABLE);
	return;
}

CSL_IDEF_INLINE void CSL_PLLC_deassertDDRPllPowerDown
(
)
{
	CSL_FINST (hPllc->DDRPLLCMD, PLLC_DDRPLLCMD_PD, DISABLE);
	return;
}

/* DDRPLLC_EN */

CSL_IDEF_INLINE void CSL_PLLC_assertDDRPllRefClkBypass
(
)
{
	CSL_FINST (hPllc->DDRPLLC_EN, PLLC_DDRPLLC_EN_BYPASS, ENABLE);
	return;
}

CSL_IDEF_INLINE void CSL_PLLC_deassertDDRPllRefClkBypass
(
)
{
	CSL_FINST (hPllc->DDRPLLC_EN, PLLC_DDRPLLC_EN_BYPASS, DISABLE);
	return;
}

/* DDRPLLC_SAT */

CSL_IDEF_INLINE Bool CSL_PLLC_getDDRPllRefClkStat
(
)
{
	return (Bool) CSL_FEXT(hPllc->DDRPLLC_SAT, PLLC_DDRPLLC_SAT_DDR_REFCLK_ON);
}

/* PASSPLLCMD */

CSL_IDEF_INLINE Bool CSL_PLLC_getPASSPllLockStat
(
)
{
	return (Bool) CSL_FEXT(hPllc->PASSPLLCMD, PLLC_PASSPLLCMD_LOCK);
}

CSL_IDEF_INLINE void CSL_PLLC_assertPASSPllPowerDown
(
)
{
	CSL_FINST (hPllc->PASSPLLCMD, PLLC_PASSPLLCMD_PD, ENABLE);
	return;
}

CSL_IDEF_INLINE void CSL_PLLC_deassertPASSPllPowerDown
(
)
{
	CSL_FINST (hPllc->PASSPLLCMD, PLLC_PASSPLLCMD_PD, DISABLE);
	return;
}

/* PASSPLLC_En */

CSL_IDEF_INLINE void CSL_PLLC_assertPASSPllClkBypass
(
)
{
	CSL_FINST (hPllc->PASSPLLC_En, PLLC_PASSPLLC_EN_BYPASS, ENABLE);
	return;
}

CSL_IDEF_INLINE void CSL_PLLC_deassertPASSPllClkBypass
(
)
{
	CSL_FINST (hPllc->PASSPLLC_En, PLLC_PASSPLLC_EN_BYPASS, DISABLE);
	return;
}
/* PASSPLLC_SAT */

CSL_IDEF_INLINE Bool CSL_PLLC_getPASSPllGMACClkStat
(
)
{
	return (Bool) CSL_FEXT(hPllc->PASSPLLC_SAT, PLLC_PASSPLLC_SAT_GMAC_ON);
}

CSL_IDEF_INLINE Bool CSL_PLLC_getPASSPllPCIEClkStat
(
)
{
	return (Bool) CSL_FEXT(hPllc->PASSPLLC_SAT, PLLC_PASSPLLC_SAT_PCIE_ON);
}

CSL_IDEF_INLINE Bool CSL_PLLC_getPASSPllSRIO1ClkStat
(
)
{
	return (Bool) CSL_FEXT(hPllc->PASSPLLC_SAT, PLLC_PASSPLLC_SAT_SRIO1_ON);
}

CSL_IDEF_INLINE Bool CSL_PLLC_getPASSPllSRIO0ClkStat
(
)
{
	return (Bool) CSL_FEXT(hPllc->PASSPLLC_SAT, PLLC_PASSPLLC_SAT_SRIO0_ON);
}

/**
@}
*/

#ifdef __cplusplus
}
#endif

#endif /* CSL_PLLCAUX_H_ */

