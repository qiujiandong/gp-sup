/********************************************************************
 * Copyright (C) 2013-2014 Texas Instruments Incorporated.
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
#ifndef CSLR_TMR_H
#define CSLR_TMR_H

#ifdef __cplusplus
extern "C"
{
#endif
#include <cslr.h>
#include <tistdtypes.h>


/**************************************************************************
* Register Overlay Structure for registers
**************************************************************************/
typedef struct {
    volatile Uint8 RSVD0[4];
    volatile Uint32 EMUMGT_CLKSPD;
    volatile Uint8 RSVD1[8];
    //0x010
    volatile Uint32 CNTLO;
    volatile Uint32 CNTHI;
    volatile Uint32 PRDLO;
    volatile Uint32 PRDHI;
    //0x020
    volatile Uint32 TCR;
    volatile Uint32 TGCR;
    volatile Uint32 WDTCR;
    volatile Uint32 TLGC;
    volatile Uint32 TLMR;
    //0x034
    volatile Uint32 RELLO;
    volatile Uint32 RELHI;
    volatile Uint32 CAPLO;
    volatile Uint32 CAPHI;
    volatile Uint32 INTCTL_STAT;
} CSL_TmrRegs;

#ifndef CSL_MODIFICATION   

/**************************************************************************\
* Overlay structure typedef definition
\**************************************************************************/
typedef volatile CSL_TmrRegs *CSL_TmrRegsOvly;
#endif


/**************************************************************************
* Register Macros
**************************************************************************/

/* Emulation Management/Clock Speed Register */
#define CSL_TMR_EMUMGT_CLKSPD                                   (0x4U)

/* Timer Counter Register 12 */
#define CSL_TMR_CNTLO                                           (0x10U)

/* Timer Counter Register 34 */
#define CSL_TMR_CNTHI                                           (0x14U)

/* Timer Period Register 12 */
#define CSL_TMR_PRDLO                                           (0x18U)

/* Timer Period Register 34 */
#define CSL_TMR_PRDHI                                           (0x1CU)

/* Timer Control Register */
#define CSL_TMR_TCR                                             (0x20U)

/* Timer Global Control Register */
#define CSL_TMR_TGCR                                            (0x24U)

/* Watchdog Timer Control Register */
#define CSL_TMR_WDTCR                                           (0x28U)

/* Timer Reload Register 12 */
#define CSL_TMR_RELLO                                           (0x34U)

/* Timer Reload Register 34 */
#define CSL_TMR_RELHI                                           (0x38U)

/* Timer capture (shadow) register 12 */
#define CSL_TMR_CAPLO                                           (0x3CU)

/* Timer capture (shadow) register 34 */
#define CSL_TMR_CAPHI                                           (0x40U)
#define CSL_TMR_INTCTL_STAT                                     (0x44U)

/**************************************************************************
* Field Definition Macros
**************************************************************************/

/* EMUMGT_CLKSPD */

#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_MASK                       (0x000F0000U)
#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_SHIFT                      (16U)
#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_RESETVAL                   (0x00000006U)
#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_DIV1                       (0x00000001U)
#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_DIV2                       (0x00000002U)
#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_DIV4                       (0x00000004U)
#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_DIV6                       (0x00000006U)
#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_DIV8                       (0x00000008U)
#define CSL_TMR_EMUMGT_CLKSPD_CLKDIV_MAX                        (0x0000000fU)

#define CSL_TMR_EMUMGT_CLKSPD_FREE_MASK                         (0x00000001U)
#define CSL_TMR_EMUMGT_CLKSPD_FREE_SHIFT                        (0U)
#define CSL_TMR_EMUMGT_CLKSPD_FREE_RESETVAL                     (0x00000000U)
#define CSL_TMR_EMUMGT_CLKSPD_FREE_MAX                          (0x00000001U)

#define CSL_TMR_EMUMGT_CLKSPD_SOFT_MASK                         (0x00000002U)
#define CSL_TMR_EMUMGT_CLKSPD_SOFT_SHIFT                        (1U)
#define CSL_TMR_EMUMGT_CLKSPD_SOFT_RESETVAL                     (0x00000000U)
#define CSL_TMR_EMUMGT_CLKSPD_SOFT_MAX                          (0x00000001U)

#define CSL_TMR_EMUMGT_CLKSPD_RESETVAL                          (0x00060000U)

/* CNTLO */

#define CSL_TMR_CNTLO_CNT_MASK                                  (0xFFFFFFFFU)
#define CSL_TMR_CNTLO_CNT_SHIFT                                 (0U)
#define CSL_TMR_CNTLO_CNT_RESETVAL                              (0x00000000U)
#define CSL_TMR_CNTLO_CNT_MAX                                   (0xffffffffU)

#define CSL_TMR_CNTLO_RESETVAL                                  (0x00000000U)

/* CNTHI */

#define CSL_TMR_CNTHI_CNT_MASK                                  (0xFFFFFFFFU)
#define CSL_TMR_CNTHI_CNT_SHIFT                                 (0U)
#define CSL_TMR_CNTHI_CNT_RESETVAL                              (0x00000000U)
#define CSL_TMR_CNTHI_CNT_MAX                                   (0xffffffffU)

#define CSL_TMR_CNTHI_RESETVAL                                  (0x00000000U)

/* PRDLO */

#define CSL_TMR_PRDLO_PRDLO_MASK                                (0xFFFFFFFFU)
#define CSL_TMR_PRDLO_PRDLO_SHIFT                               (0U)
#define CSL_TMR_PRDLO_PRDLO_RESETVAL                            (0x00000000U)
#define CSL_TMR_PRDLO_PRDLO_MAX                                 (0xffffffffU)

#define CSL_TMR_PRDLO_RESETVAL                                  (0x00000000U)

/* PRDHI */

#define CSL_TMR_PRDHI_PRDHI_MASK                                (0xFFFFFFFFU)
#define CSL_TMR_PRDHI_PRDHI_SHIFT                               (0U)
#define CSL_TMR_PRDHI_PRDHI_RESETVAL                            (0x00000000U)
#define CSL_TMR_PRDHI_PRDHI_MAX                                 (0xffffffffU)

#define CSL_TMR_PRDHI_RESETVAL                                  (0x00000000U)

/* TCR */

#define CSL_TMR_TCR_TSTAT_LO_MASK                               (0x00000001U)
#define CSL_TMR_TCR_TSTAT_LO_SHIFT                              (0U)
#define CSL_TMR_TCR_TSTAT_LO_RESETVAL                           (0x00000000U)
#define CSL_TMR_TCR_TSTAT_LO_MAX                                (0x00000001U)

#define CSL_TMR_TCR_INVOUTP_LO_MASK                             (0x00000002U)
#define CSL_TMR_TCR_INVOUTP_LO_SHIFT                            (1U)
#define CSL_TMR_TCR_INVOUTP_LO_RESETVAL                         (0x00000000U)
#define CSL_TMR_TCR_INVOUTP_LO_MAX                              (0x00000001U)

//#define CSL_TMR_TCR_INVINP_LO_MASK                              (0x00000004U)
//#define CSL_TMR_TCR_INVINP_LO_SHIFT                             (2U)
//#define CSL_TMR_TCR_INVINP_LO_RESETVAL                          (0x00000000U)
//#define CSL_TMR_TCR_INVINP_LO_MAX                               (0x00000001U)

#define CSL_TMR_TCR_CP_LO_MASK                                  (0x00000008U)
#define CSL_TMR_TCR_CP_LO_SHIFT                                 (3U)
#define CSL_TMR_TCR_CP_LO_RESETVAL                              (0x00000000U)
#define CSL_TMR_TCR_CP_LO_MAX                                   (0x00000001U)

#define CSL_TMR_TCR_PWID_LO_MASK                                (0x00000030U)
#define CSL_TMR_TCR_PWID_LO_SHIFT                               (4U)
#define CSL_TMR_TCR_PWID_LO_RESETVAL                            (0x00000000U)
#define CSL_TMR_TCR_PWID_LO_MAX                                 (0x00000003U)

#define CSL_TMR_TCR_ENAMODE_LO_MASK                             (0x000000C0U)
#define CSL_TMR_TCR_ENAMODE_LO_SHIFT                            (6U)
#define CSL_TMR_TCR_ENAMODE_LO_RESETVAL                         (0x00000000U)
#define CSL_TMR_TCR_ENAMODE_LO_DISABLE                          (0x00000000U)

#define CSL_TMR_TCR_CLKSRC_LO_MASK                              (0x00000100U)
#define CSL_TMR_TCR_CLKSRC_LO_SHIFT                             (8U)
#define CSL_TMR_TCR_CLKSRC_LO_RESETVAL                          (0x00000000U)
#define CSL_TMR_TCR_CLKSRC_LO_MAX                               (0x00000001U)

#define CSL_TMR_TCR_TIEN_LO_MASK                                (0x00000200U)
#define CSL_TMR_TCR_TIEN_LO_SHIFT                               (9U)
#define CSL_TMR_TCR_TIEN_LO_RESETVAL                            (0x00000000U)
#define CSL_TMR_TCR_TIEN_LO_MAX                                 (0x00000001U)

#define CSL_TMR_TCR_READRSTMODE_LO_MASK                         (0x00000400U)
#define CSL_TMR_TCR_READRSTMODE_LO_SHIFT                        (10U)
#define CSL_TMR_TCR_READRSTMODE_LO_RESETVAL                     (0x00000000U)
#define CSL_TMR_TCR_READRSTMODE_LO_MAX                          (0x00000001U)

#define CSL_TMR_TCR_CAPMODE_LO_MASK                         	(0x00000800U)
#define CSL_TMR_TCR_CAPMODE_LO_SHIFT                        	(11U)
#define CSL_TMR_TCR_CAPMODE_LO_RESETVAL                     	(0x00000000U)
#define CSL_TMR_TCR_CAPMODE_LO_MAX                          	(0x00000001U)

#define CSL_TMR_TCR_CAPEVTMODE_LO_MASK                         	(0x00003000U)
#define CSL_TMR_TCR_CAPEVTMODE_LO_SHIFT                        	(12U)
#define CSL_TMR_TCR_CAPEVTMODE_LO_RESETVAL                     	(0x00000000U)
#define CSL_TMR_TCR_CAPEVTMODE_LO_MAX                          	(0x00000003U)

#define CSL_TMR_TCR_TSTAT_HI_MASK                               (0x00010000U)
#define CSL_TMR_TCR_TSTAT_HI_SHIFT                              (16U)
#define CSL_TMR_TCR_TSTAT_HI_RESETVAL                           (0x00000000U)
#define CSL_TMR_TCR_TSTAT_HI_MAX                                (0x00000001U)

#define CSL_TMR_TCR_INVOUTP_HI_MASK                             (0x00020000U)
#define CSL_TMR_TCR_INVOUTP_HI_SHIFT                            (17U)
#define CSL_TMR_TCR_INVOUTP_HI_RESETVAL                         (0x00000000U)
#define CSL_TMR_TCR_INVOUTP_HI_MAX                              (0x00000001U)

//#define CSL_TMR_TCR_INVINP_HI_MASK                              (0x00040000U)
//#define CSL_TMR_TCR_INVINP_HI_SHIFT                             (18U)
//#define CSL_TMR_TCR_INVINP_HI_RESETVAL                          (0x00000000U)
//#define CSL_TMR_TCR_INVINP_HI_MAX                               (0x00000001U)

#define CSL_TMR_TCR_CP_HI_MASK                                  (0x00080000U)
#define CSL_TMR_TCR_CP_HI_SHIFT                                 (19U)
#define CSL_TMR_TCR_CP_HI_RESETVAL                              (0x00000000U)
#define CSL_TMR_TCR_CP_HI_MAX                                   (0x00000001U)

#define CSL_TMR_TCR_PWID_HI_MASK                                (0x00300000U)
#define CSL_TMR_TCR_PWID_HI_SHIFT                               (20U)
#define CSL_TMR_TCR_PWID_HI_RESETVAL                            (0x00000000U)
#define CSL_TMR_TCR_PWID_HI_MAX                                 (0x00000003U)

#define CSL_TMR_TCR_ENAMODE_HI_MASK                             (0x00C00000U)
#define CSL_TMR_TCR_ENAMODE_HI_SHIFT                            (22U)
#define CSL_TMR_TCR_ENAMODE_HI_RESETVAL                         (0x00000000U)
#define CSL_TMR_TCR_ENAMODE_HI_DISABLE                          (0x00000000U)

//#define CSL_TMR_TCR_CLKSRC_HI_MASK                              (0x01000000U)
//#define CSL_TMR_TCR_CLKSRC_HI_SHIFT                             (24U)
//#define CSL_TMR_TCR_CLKSRC_HI_RESETVAL                          (0x00000000U)
//#define CSL_TMR_TCR_CLKSRC_HI_MAX                               (0x00000001U)

//#define CSL_TMR_TCR_TIEN_HI_MASK                                (0x02000000U)
//#define CSL_TMR_TCR_TIEN_HI_SHIFT                               (25U)
//#define CSL_TMR_TCR_TIEN_HI_RESETVAL                            (0x00000000U)
//#define CSL_TMR_TCR_TIEN_HI_MAX                                 (0x00000001U)

#define CSL_TMR_TCR_READRSTMODE_HI_MASK                         (0x04000000U)
#define CSL_TMR_TCR_READRSTMODE_HI_SHIFT                        (26U)
#define CSL_TMR_TCR_READRSTMODE_HI_RESETVAL                     (0x00000000U)
#define CSL_TMR_TCR_READRSTMODE_HI_MAX                          (0x00000001U)

#define CSL_TMR_TCR_RESETVAL                                    (0x00000000U)

/* TGCR */

#define CSL_TMR_TGCR_TIMLORS_MASK                               (0x00000001U)
#define CSL_TMR_TGCR_TIMLORS_SHIFT                              (0U)
#define CSL_TMR_TGCR_TIMLORS_RESETVAL                           (0x00000000U)
#define CSL_TMR_TGCR_TIMLORS_RESET_ON                           (0x00000000U)
#define CSL_TMR_TGCR_TIMLORS_RESET_OFF                          (0x00000001U)

#define CSL_TMR_TGCR_TIMHIRS_MASK                               (0x00000002U)
#define CSL_TMR_TGCR_TIMHIRS_SHIFT                              (1U)
#define CSL_TMR_TGCR_TIMHIRS_RESETVAL                           (0x00000000U)
#define CSL_TMR_TGCR_TIMHIRS_RESET_ON                           (0x00000000U)
#define CSL_TMR_TGCR_TIMHIRS_RESET_OFF                          (0x00000001U)

#define CSL_TMR_TGCR_TIMMODE_MASK                               (0x0000000CU)
#define CSL_TMR_TGCR_TIMMODE_SHIFT                              (2U)
#define CSL_TMR_TGCR_TIMMODE_RESETVAL                           (0x00000000U)
#define CSL_TMR_TGCR_TIMMODE_MAX                                (0x00000003U)

#define CSL_TMR_TGCR_PLUSEN_MASK                               (0x00000010U)
#define CSL_TMR_TGCR_PLUSEN_SHIFT                              (4U)
#define CSL_TMR_TGCR_PLUSEN_RESETVAL                           (0x00000000U)
#define CSL_TMR_TGCR_PLUSENE_MAX                                (0x00000001U)

#define CSL_TMR_TGCR_PSCHI_MASK                                 (0x00000F00U)
#define CSL_TMR_TGCR_PSCHI_SHIFT                                (8U)
#define CSL_TMR_TGCR_PSCHI_RESETVAL                             (0x00000000U)
#define CSL_TMR_TGCR_PSCHI_MAX                                  (0x0000000fU)

#define CSL_TMR_TGCR_TDDRHI_MASK                                (0x0000F000U)
#define CSL_TMR_TGCR_TDDRHI_SHIFT                               (12U)
#define CSL_TMR_TGCR_TDDRHI_RESETVAL                            (0x00000000U)
#define CSL_TMR_TGCR_TDDRHI_MAX                                 (0x0000000fU)

#define CSL_TMR_TGCR_BW_COMPATIBLE_MASK                         (0x00000010U)
#define CSL_TMR_TGCR_BW_COMPATIBLE_SHIFT                        (4U)
#define CSL_TMR_TGCR_BW_COMPATIBLE_RESETVAL                     (0x00000000U)
#define CSL_TMR_TGCR_BW_COMPATIBLE_MAX                          (0x00000001U)

#define CSL_TMR_TGCR_RESETVAL                                   (0x00000000U)

/* WDTCR */

#define CSL_TMR_WDTCR_WDEN_MASK                                 (0x00004000U)
#define CSL_TMR_WDTCR_WDEN_SHIFT                                (14U)
#define CSL_TMR_WDTCR_WDEN_RESETVAL                             (0x00000000U)
#define CSL_TMR_WDTCR_WDEN_DISABLE                              (0x00000000U)
#define CSL_TMR_WDTCR_WDEN_ENABLE                               (0x00000001U)

#define CSL_TMR_WDTCR_WDFLAG_MASK                               (0x00008000U)
#define CSL_TMR_WDTCR_WDFLAG_SHIFT                              (15U)
#define CSL_TMR_WDTCR_WDFLAG_RESETVAL                           (0x00000000U)
#define CSL_TMR_WDTCR_WDFLAG_MAX                                (0x00000001U)

#define CSL_TMR_WDTCR_WDKEY_MASK                                (0xFFFF0000U)
#define CSL_TMR_WDTCR_WDKEY_SHIFT                               (16U)
#define CSL_TMR_WDTCR_WDKEY_RESETVAL                          	(0x00000000U)
#define CSL_TMR_WDTCR_WDKEY_CMD1                          		(0x0000a5c6U)
#define CSL_TMR_WDTCR_WDKEY_CMD2                            	(0x0000da7eU)
#define CSL_TMR_WDTCR_WDKEY_MAX                              	(0x0000ffffU)

#define CSL_TMR_WDTCR_RESETVAL                                  (0x00000000U)

/* RELLO */

#define CSL_TMR_RELLO_RELLO_MASK                                (0xFFFFFFFFU)
#define CSL_TMR_RELLO_RELLO_SHIFT                               (0U)
#define CSL_TMR_RELLO_RELLO_RESETVAL                            (0x00000000U)
#define CSL_TMR_RELLO_RELLO_MAX                                 (0xffffffffU)

#define CSL_TMR_RELLO_RESETVAL                                  (0x00000000U)

/* RELHI */

#define CSL_TMR_RELHI_RELHI_MASK                                (0xFFFFFFFFU)
#define CSL_TMR_RELHI_RELHI_SHIFT                               (0U)
#define CSL_TMR_RELHI_RELHI_RESETVAL                            (0x00000000U)
#define CSL_TMR_RELHI_RELHI_MAX                                 (0xffffffffU)

#define CSL_TMR_RELHI_RESETVAL                                  (0x00000000U)

/* CAPLO */

#define CSL_TMR_CAPLO_RESETVAL                                  (0x00000000U)

/* CAPHI */

#define CSL_TMR_CAPHI_RESETVAL                                  (0x00000000U)

/* INTCTL_STAT */

#define CSL_TMR_INTCTL_STAT_CMP_INT_STAT_LO_MASK                (0x00000002U)
#define CSL_TMR_INTCTL_STAT_CMP_INT_STAT_LO_SHIFT               (1U)
#define CSL_TMR_INTCTL_STAT_CMP_INT_STAT_LO_RESETVAL            (0x00000000U)
#define CSL_TMR_INTCTL_STAT_CMP_INT_STAT_LO_MAX                 (0x00000001U)

#define CSL_TMR_INTCTL_STAT_EVT_INT_EN_LO_MASK                  (0x00000004U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_EN_LO_SHIFT                 (2U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_EN_LO_RESETVAL              (0x00000000U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_EN_LO_MAX                   (0x00000001U)

#define CSL_TMR_INTCTL_STAT_EVT_INT_STAT_LO_MASK                (0x00000008U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_STAT_LO_SHIFT               (3U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_STAT_LO_RESETVAL            (0x00000000U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_STAT_LO_MAX                 (0x00000001U)

#define CSL_TMR_INTCTL_STAT_CMP_INT_STAT_HI_MASK                (0x00020000U)
#define CSL_TMR_INTCTL_STAT_CMP_INT_STAT_HI_SHIFT               (17U)
#define CSL_TMR_INTCTL_STAT_CMP_INT_STAT_HI_RESETVAL            (0x00000000U)
#define CSL_TMR_INTCTL_STAT_CMP_INT_STAT_HI_MAX                 (0x00000001U)

#define CSL_TMR_INTCTL_STAT_EVT_INT_EN_HI_MASK                  (0x00040000U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_EN_HI_SHIFT                 (18U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_EN_HI_RESETVAL              (0x00000000U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_EN_HI_MAX                   (0x00000001U)

#define CSL_TMR_INTCTL_STAT_EVT_INT_STAT_HI_MASK                (0x00080000U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_STAT_HI_SHIFT               (19U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_STAT_HI_RESETVAL            (0x00000000U)
#define CSL_TMR_INTCTL_STAT_EVT_INT_STAT_HI_MAX                 (0x00000001U)

#define CSL_TMR_INTCTL_STAT_RESETVAL                            (0x00000000U)

#ifdef __cplusplus
}
#endif
#endif
