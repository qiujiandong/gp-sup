/********************************************************************
* Copyright (C) 2010 Texas Instruments Incorporated.
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
#ifndef _CSLR_PLLC_H_
#define _CSLR_PLLC_H_

#include <cslr.h>
#include <tistdtypes.h>

/**************************************************************************\
* Register Overlay Structure
\**************************************************************************/
typedef struct  {
    volatile Uint8 RSVD0[228];
    //0x0E4
    volatile Uint32 RSTYPE;
    volatile Uint32 RSTCTRL;
    volatile Uint32 RSTCFG;
    volatile Uint8 RSVD1[16];
    //0x100
    volatile Uint32 MAINPLLCMD;
    volatile Uint8 RSVD2[20];
    //0x118
    volatile Uint32 PLLDIV_V;
    volatile Uint8 RSVD3[28];
    //0x138
    volatile Uint32 PLLCTLCMD;
    volatile Uint32 PLLSTAT;
    //0x140
    volatile Uint8 RSVD4[4];
    volatile Uint32 DCHANGE;
    volatile Uint8 RSVD5[8];
    volatile Uint32 SYSTAT;
    volatile Uint8 RSVD6[12];
    //0x160
    volatile Uint32 DDRPLLCMD;
    volatile Uint32 DDRPLLC_EN;
    volatile Uint32 DDRPLLC_SAT;
    volatile Uint8 RSVD7[4];
    volatile Uint32 PASSPLLCMD;
    volatile Uint32 PASSPLLC_En;
	volatile Uint32 PASSPLLC_SAT;
} CSL_PllcRegs;

/**************************************************************************\
* Overlay structure typedef definition
\**************************************************************************/
typedef volatile CSL_PllcRegs               *CSL_PllcRegsOvly;

/**************************************************************************\
* Field Definition Macros
\**************************************************************************/

/* RSTYPE */

#define CSL_PLLC_RSTYPE_EMUSRST_MASK		(0x10000000u)
#define CSL_PLLC_RSTYPE_EMUSRST_SHIFT		(0x0000001Cu)
#define CSL_PLLC_RSTYPE_EMUSRST_RESETVAL	(0x00000000u)

#define CSL_PLLC_RSTYPE_WDRSTN_MASK		    (0x0000FF00u)
#define CSL_PLLC_RSTYPE_WDRSTN_SHIFT		(0x00000008u)
#define CSL_PLLC_RSTYPE_WDRSTN_RESETVAL	    (0x00000000u)

#define CSL_PLLC_RSTYPE_PLLCTLRST_MASK		(0x00000004u)
#define CSL_PLLC_RSTYPE_PLLCTLRST_SHIFT		(0x00000002u)
#define CSL_PLLC_RSTYPE_PLLCTLRST_RESETVAL	(0x00000000u)

#define CSL_PLLC_RSTYPE_RESET_MASK          (0x00000002u)
#define CSL_PLLC_RSTYPE_RESET_SHIFT         (0x00000001u)
#define CSL_PLLC_RSTYPE_RESET_RESETVAL      (0x00000000u)

#define CSL_PLLC_RSTYPE_POR_MASK            (0x00000001u)
#define CSL_PLLC_RSTYPE_POR_SHIFT           (0x00000000u)
#define CSL_PLLC_RSTYPE_POR_RESETVAL        (0x00000000u)

#define CSL_PLLC_RSTYPE_RESETVAL            (0x00000000u)

/* RSTCTRL */

#define CSL_PLLC_RSTCTRL_SWRST_MASK		    (0x00010000u)
#define CSL_PLLC_RSTCTRL_SWRST_SHIFT	    (0x00000010u)
#define CSL_PLLC_RSTCTRL_SWRST_RESETVAL     (0x00000001u)

/*----SWRST Tokens----*/
#define CSL_PLLC_RSTCTRL_SWRST_NO		    (0x00000001u)
#define CSL_PLLC_RSTCTRL_SWRST_YES		    (0x00000000u)

#define CSL_PLLC_RSTCTRL_KEY_MASK		    (0x0000FFFFu)
#define CSL_PLLC_RSTCTRL_KEY_SHIFT		    (0x00000000u)
#define CSL_PLLC_RSTCTRL_KEY_RESETVAL	    (0x00000003u)

#define CSL_PLLC_RSTCTRL_RESETVAL		    (0x00010003u)

/* RSTCFG */

#define CSL_PLLC_RSTCFG_PLLCTLRSTTYPE_MASK      (0x00002000u)
#define CSL_PLLC_RSTCFG_PLLCTLRSTTYPE_SHIFT		(0x0000000Du)
#define CSL_PLLC_RSTCFG_PLLCTLRSTTYPE_RESETVAL	(0x00000000u)

/*----PLLCTLRSTTYPE Tokens----*/
#define CSL_PLLC_RSTCFG_PLLCTLRSTTYPE_HARD	    (0x00000000u)
#define CSL_PLLC_RSTCFG_PLLCTLRSTTYPE_SOFT	    (0x00000001u)

#define CSL_PLLC_RSTCFG_RESETTYPE_MASK	        (0x00001000u)
#define CSL_PLLC_RSTCFG_RESETTYPE_SHIFT	        (0x0000000Cu)
#define CSL_PLLC_RSTCFG_RESETTYPE_RESETVAL      (0x00000000u)

/*----RESETTYPE Tokens----*/
#define CSL_PLLC_RSTCFG_RESETTYPE_HARD	        (0x00000000u)
#define CSL_PLLC_RSTCFG_RESETTYPE_SOFT	        (0x00000001u)

#define CSL_PLLC_RSTCFG_WDTYPEN_MASK	        (0x000000FFu)
#define CSL_PLLC_RSTCFG_WDTYPEN_SHIFT	        (0x00000000u)
#define CSL_PLLC_RSTCFG_WDTYPEN_RESETVAL        (0x00000000u)

/*----WDTYPEN Tokens----*/
#define CSL_PLLC_RSTCFG_WDTYPEN_HARD	        (0x00000000u)
#define CSL_PLLC_RSTCFG_WDTYPEN_SOFT	        (0x00000001u)

#define CSL_PLLC_RSTCFG_RESETVAL		        (0x00000000u)

/* MAINPLLCMD */

#define CSL_PLLC_MAINPLLCMD_LOCK_MASK       			(0x00000040u)
#define CSL_PLLC_MAINPLLCMD_LOCK_SHIFT      			(0x00000006u)
#define CSL_PLLC_MAINPLLCMD_LOCK_RESETVAL   			(0x00000000u)

#define CSL_PLLC_MAINPLLCMD_PLLENSRC_MASK       		(0x00000020u)
#define CSL_PLLC_MAINPLLCMD_PLLENSRC_SHIFT      		(0x00000005u)
#define CSL_PLLC_MAINPLLCMD_PLLENSRC_RESETVAL   		(0x00000000u)

/*----PLLENSRC Tokens----*/
#define CSL_PLLC_MAINPLLCMD_PLLENSRC_ENABLE           	(0x00000000u)
#define CSL_PLLC_MAINPLLCMD_PLLENSRC_DISABLE          	(0x00000001u)

#define CSL_PLLC_MAINPLLCMD_PD_MASK       				(0x00000002u)
#define CSL_PLLC_MAINPLLCMD_PD_SHIFT      				(0x00000001u)
#define CSL_PLLC_MAINPLLCMD_PD_RESETVAL   				(0x00000000u)

/*----PD Tokens----*/
#define CSL_PLLC_MAINPLLCMD_PD_DISABLE           		(0x00000000u)
#define CSL_PLLC_MAINPLLCMD_PD_ENABLE          			(0x00000001u)

#define CSL_PLLC_MAINPLLCMD_PLLEN_MASK       			(0x00000001u)
#define CSL_PLLC_MAINPLLCMD_PLLEN_SHIFT      			(0x00000000u)
#define CSL_PLLC_MAINPLLCMD_PLLEN_RESETVAL   			(0x00000000u)

/*----PD Tokens----*/
#define CSL_PLLC_MAINPLLCMD_PLLEN_DISABLE           		(0x00000000u)
#define CSL_PLLC_MAINPLLCMD_PLLEN_ENABLE          			(0x00000001u)


/* PLLDIV_V */

#define CSL_PLLC_PLLDIV_V_DEN_MASK       				(0x00008000u)
#define CSL_PLLC_PLLDIV_V_DEN_SHIFT      				(0x0000000Fu)
#define CSL_PLLC_PLLDIV_V_DEN_RESETVAL   				(0x00000000u)

/*----DEN Tokens----*/
#define CSL_PLLC_PLLDIV_V_DEN_DISABLE           		(0x00000000u)
#define CSL_PLLC_PLLDIV_V_DEN_ENABLE          			(0x00000001u)

#define CSL_PLLC_PLLDIV_V_RATIO_MASK       				(0x0000000Fu)
#define CSL_PLLC_PLLDIV_V_RATIO_SHIFT      				(0x00000000u)
#define CSL_PLLC_PLLDIV_V_RATIO_RESETVAL   				(0x00000000u)

/* PLLCTLCMD */

#define CSL_PLLC_PLLCTLCMD_GOSET_MASK       			(0x00000001u)
#define CSL_PLLC_PLLCTLCMD_GOSET_SHIFT      			(0x00000000u)
#define CSL_PLLC_PLLCTLCMD_GOSET_RESETVAL   			(0x00000000u)

/*----DEN Tokens----*/
#define CSL_PLLC_PLLCTLCMD_GOSET_ASSERT           		(0x00000001u)

/* PLLSTAT */

#define CSL_PLLC_PLLSTAT_GOSTAT_MASK       				(0x00000001u)
#define CSL_PLLC_PLLSTAT_GOSTAT_SHIFT      				(0x00000000u)
#define CSL_PLLC_PLLSTAT_GOSTAT_RESETVAL   				(0x00000000u)

/* DCHANGE */

#define CSL_PLLC_DCHANGE_CLK_V_MASK       				(0x00000004u)
#define CSL_PLLC_DCHANGE_CLK_V_SHIFT      				(0x00000002u)
#define CSL_PLLC_DCHANGE_CLK_V_RESETVAL   				(0x00000000u)

/*----DEN Tokens----*/
#define CSL_PLLC_DCHANGE_CLK_V_CLEAR           			(0x00000000u)

/* SYSTAT */

#define CSL_PLLC_SYSTAT_SYS_VON_MASK       				(0x00000010u)
#define CSL_PLLC_SYSTAT_SYS_VON_SHIFT      				(0x00000004u)
#define CSL_PLLC_SYSTAT_SYS_VON_RESETVAL   				(0x00000000u)

#define CSL_PLLC_SYSTAT_SYS8ON_MASK       				(0x00000008u)
#define CSL_PLLC_SYSTAT_SYS8ON_SHIFT      				(0x00000003u)
#define CSL_PLLC_SYSTAT_SYS8ON_RESETVAL   				(0x00000000u)

#define CSL_PLLC_SYSTAT_SYS4ON_MASK       				(0x00000004u)
#define CSL_PLLC_SYSTAT_SYS4ON_SHIFT      				(0x00000002u)
#define CSL_PLLC_SYSTAT_SYS4ON_RESETVAL   				(0x00000000u)

#define CSL_PLLC_SYSTAT_SYS2ON_MASK       				(0x00000002u)
#define CSL_PLLC_SYSTAT_SYS2ON_SHIFT      				(0x00000001u)
#define CSL_PLLC_SYSTAT_SYS2ON_RESETVAL   				(0x00000000u)

#define CSL_PLLC_SYSTAT_SYS1ON_MASK       				(0x00000001u)
#define CSL_PLLC_SYSTAT_SYS1ON_SHIFT      				(0x00000000u)
#define CSL_PLLC_SYSTAT_SYS1ON_RESETVAL   				(0x00000000u)

/* DDRPLLCMD */

#define CSL_PLLC_DDRPLLCMD_LOCK_MASK       				(0x00000002u)
#define CSL_PLLC_DDRPLLCMD_LOCK_SHIFT      				(0x00000001u)
#define CSL_PLLC_DDRPLLCMD_LOCK_RESETVAL   				(0x00000000u)

#define CSL_PLLC_DDRPLLCMD_PD_MASK       				(0x00000001u)
#define CSL_PLLC_DDRPLLCMD_PD_SHIFT      				(0x00000000u)
#define CSL_PLLC_DDRPLLCMD_PD_RESETVAL   				(0x00000000u)

/*----PD Tokens----*/
#define CSL_PLLC_DDRPLLCMD_PD_DISABLE           		(0x00000000u)
#define CSL_PLLC_DDRPLLCMD_PD_ENABLE          			(0x00000001u)

/* DDRPLLC_EN */

#define CSL_PLLC_DDRPLLC_EN_BYPASS_MASK       			(0x00000001u)
#define CSL_PLLC_DDRPLLC_EN_BYPASS_SHIFT      			(0x00000000u)
#define CSL_PLLC_DDRPLLC_EN_BYPASS_RESETVAL   			(0x00000000u)

/*----BYPASS Tokens----*/
#define CSL_PLLC_DDRPLLC_EN_BYPASS_DISABLE           		(0x00000000u)
#define CSL_PLLC_DDRPLLC_EN_BYPASS_ENABLE          			(0x00000001u)

/* DDRPLLC_SAT */

#define CSL_PLLC_DDRPLLC_SAT_DDR_REFCLK_ON_MASK       	(0x00000001u)
#define CSL_PLLC_DDRPLLC_SAT_DDR_REFCLK_ON_SHIFT      	(0x00000000u)
#define CSL_PLLC_DDRPLLC_SAT_DDR_REFCLK_ON_RESETVAL   	(0x00000000u)

/* PASSPLLCMD */

#define CSL_PLLC_PASSPLLCMD_LOCK_MASK       			(0x00000002u)
#define CSL_PLLC_PASSPLLCMD_LOCK_SHIFT      			(0x00000001u)
#define CSL_PLLC_PASSPLLCMD_LOCK_RESETVAL   			(0x00000000u)

#define CSL_PLLC_PASSPLLCMD_PD_MASK       				(0x00000001u)
#define CSL_PLLC_PASSPLLCMD_PD_SHIFT      				(0x00000000u)
#define CSL_PLLC_PASSPLLCMD_PD_RESETVAL   				(0x00000000u)

/*----PD Tokens----*/
#define CSL_PLLC_PASSPLLCMD_PD_DISABLE           		(0x00000000u)
#define CSL_PLLC_PASSPLLCMD_PD_ENABLE          			(0x00000001u)

/* PASSPLLC_EN */

#define CSL_PLLC_PASSPLLC_EN_BYPASS_MASK       			(0x00000004u)
#define CSL_PLLC_PASSPLLC_EN_BYPASS_SHIFT      			(0x00000002u)
#define CSL_PLLC_PASSPLLC_EN_BYPASS_RESETVAL   			(0x00000000u)

/*----BYPASS Tokens----*/
#define CSL_PLLC_PASSPLLC_EN_BYPASS_DISABLE           	(0x00000000u)
#define CSL_PLLC_PASSPLLC_EN_BYPASS_ENABLE          	(0x00000001u)

/* PASSPLLC_SAT */

#define CSL_PLLC_PASSPLLC_SAT_GMAC_ON_MASK       		(0x00000008u)
#define CSL_PLLC_PASSPLLC_SAT_GMAC_ON_SHIFT      		(0x00000003u)
#define CSL_PLLC_PASSPLLC_SAT_GMAC_ON_RESETVAL   		(0x00000000u)

#define CSL_PLLC_PASSPLLC_SAT_PCIE_ON_MASK       		(0x00000004u)
#define CSL_PLLC_PASSPLLC_SAT_PCIE_ON_SHIFT      		(0x00000002u)
#define CSL_PLLC_PASSPLLC_SAT_PCIE_ON_RESETVAL   		(0x00000000u)

#define CSL_PLLC_PASSPLLC_SAT_SRIO1_ON_MASK       		(0x00000002u)
#define CSL_PLLC_PASSPLLC_SAT_SRIO1_ON_SHIFT      		(0x00000001u)
#define CSL_PLLC_PASSPLLC_SAT_SRIO1_ON_RESETVAL   		(0x00000000u)

#define CSL_PLLC_PASSPLLC_SAT_SRIO0_ON_MASK       		(0x00000001u)
#define CSL_PLLC_PASSPLLC_SAT_SRIO0_ON_SHIFT      		(0x00000000u)
#define CSL_PLLC_PASSPLLC_SAT_SRIO0_ON_RESETVAL   		(0x00000000u)

#endif
