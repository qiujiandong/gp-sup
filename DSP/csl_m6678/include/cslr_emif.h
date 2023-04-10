/*  ============================================================================
 *   Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 *   Use of this software is controlled by the terms and conditions found in the
 *   license agreement under which this software has been supplied.
 *   ===========================================================================
 */
/** ============================================================================
 *   @file  cslr_emif.h
 *
 *   @path  $(CSLPATH)\inc
 *
 *   @desc  This file contains the Register Descriptions for EMIF
 */
#ifndef _CSLR_EMIF_H_
#define _CSLR_EMIF_H_

#include <cslr.h>
#include <tistdtypes.h>

/**************************************************************************\
* Register Overlay Structure
\**************************************************************************/
typedef struct  {
    volatile Uint32 RCSR;
    volatile Uint32 AWCCR;
    volatile Uint8 RSVD0[8];
    //0x10
    volatile Uint32 A1CR;
	volatile Uint32 A2CR;
	volatile Uint32 A3CR;
	volatile Uint32 A4CR;
	volatile Uint8 RSVD1[32];
	//0x40
	volatile Uint32 IRR;
	volatile Uint32 IMR;
	volatile Uint32 IMSR;
	volatile Uint32 IMCR;
	volatile Uint8 RSVD2[16];
	//0x60
	volatile Uint32 NANDFCR;
	volatile Uint32 NANDFSR;
	volatile Uint32 PMCR;
	volatile Uint8 RSVD3[4];
	//0x70
	volatile Uint32 NFECCCS2;
	volatile Uint32 NFECCCS3;
	volatile Uint32 NFECCCS4;
	volatile Uint32 NFECCCS5;
	//0x80
	volatile Uint8 RSVD[60];
	volatile Uint32 NANDF4BECCLR;
	//0xC0
	volatile Uint32 NANDF4BECC1R;
	volatile Uint32 NANDF4BECC2R;
	volatile Uint32 NANDF4BECC3R;
	volatile Uint32 NANDF4BECC4R;
	//0xD0
	volatile Uint32 NANDFEA1R;
	volatile Uint32 NANDFEA2R;
	volatile Uint32 NANDFEV1R;
	volatile Uint32 NANDFEV2R;
} CSL_EmifRegs;

/**************************************************************************\
* Overlay structure typedef definition
\**************************************************************************/
typedef volatile CSL_EmifRegs             *CSL_EmifRegsOvly;

/**************************************************************************\
* Field Definition Macros
\**************************************************************************/

/* RCSR */

#define CSL_EMIF_RCSR_EXT_MASK       (0x40000000u)
#define CSL_EMIF_RCSR_EXT_SHIFT      (30)
#define CSL_EMIF_RCSR_EXT_RESETVAL   (0x00000000u)

#define CSL_EMIF_RCSR_MODID_MASK       (0x3FFF0000u)
#define CSL_EMIF_RCSR_MODID_SHIFT      (16)
#define CSL_EMIF_RCSR_MODID_RESETVAL   (0x00000046u)

#define CSL_EMIF_RCSR_MJREV_MASK       (0x0000FF00u)
#define CSL_EMIF_RCSR_MJREV_SHIFT      (8)
#define CSL_EMIF_RCSR_MJREV_RESETVAL   (0x00000004u)

#define CSL_EMIF_RCSR_MINREV_MASK       (0x000000FFu)
#define CSL_EMIF_RCSR_MINREV_SHIFT      (0)
#define CSL_EMIF_RCSR_MINREV_RESETVAL   (0x00000000u)

#define CSL_EMIF_RCSR_RESETVAL			(0x00460400)

/* AWCCR */

#define CSL_EMIF_AWCCR_WP1_MASK           	(0x20000000u)
#define CSL_EMIF_AWCCR_WP1_SHIFT          	(29)
#define CSL_EMIF_AWCCR_WP1_RESETVAL       	(0x00000001u)

#define CSL_EMIF_AWCCR_WP0_MASK           	(0x10000000u)
#define CSL_EMIF_AWCCR_WP0_SHIFT          	(28)
#define CSL_EMIF_AWCCR_WP0_RESETVAL       	(0x00000001u)

#define CSL_EMIF_AWCCR_CE3_WAIT_MASK           	(0x00C00000u)
#define CSL_EMIF_AWCCR_CE3_WAIT_SHIFT          	(22)
#define CSL_EMIF_AWCCR_CE3_WAIT_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AWCCR_CE2_WAIT_MASK           	(0x00300000u)
#define CSL_EMIF_AWCCR_CE2_WAIT_SHIFT          	(20)
#define CSL_EMIF_AWCCR_CE2_WAIT_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AWCCR_CE1_WAIT_MASK           	(0x000C0000u)
#define CSL_EMIF_AWCCR_CE1_WAIT_SHIFT          	(18)
#define CSL_EMIF_AWCCR_CE1_WAIT_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AWCCR_CE0_WAIT_MASK           	(0x00030000u)
#define CSL_EMIF_AWCCR_CE0_WAIT_SHIFT          	(16)
#define CSL_EMIF_AWCCR_CE0_WAIT_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AWCCR_CE3_TYPE_MASK           	(0x0000C000u)
#define CSL_EMIF_AWCCR_CE3_TYPE_SHIFT          	(14)
#define CSL_EMIF_AWCCR_CE3_TYPE_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AWCCR_CE2_TYPE_MASK           	(0x00003000u)
#define CSL_EMIF_AWCCR_CE2_TYPE_SHIFT          	(12)
#define CSL_EMIF_AWCCR_CE2_TYPE_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AWCCR_CE1_TYPE_MASK           	(0x00000C00u)
#define CSL_EMIF_AWCCR_CE1_TYPE_SHIFT          	(10)
#define CSL_EMIF_AWCCR_CE1_TYPE_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AWCCR_CE0_TYPE_MASK           	(0x00000300u)
#define CSL_EMIF_AWCCR_CE0_TYPE_SHIFT          	(8)
#define CSL_EMIF_AWCCR_CE0_TYPE_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AWCCR_MAX_EXT_WAIT_MASK        (0x000000FFu)
#define CSL_EMIF_AWCCR_MAX_EXT_WAIT_SHIFT       (0)
#define CSL_EMIF_AWCCR_MAX_EXT_WAIT_RESETVAL    (0x00000080u)

#define CSL_EMIF_AWCCR_RESETVAL					(0xF0000080u)

/* AxCR */
#define CSL_EMIF_AxCR_SS_MASK           		(0x80000000u)
#define CSL_EMIF_AxCR_SS_SHIFT          		(31)
#define CSL_EMIF_AxCR_SS_RESETVAL       		(0x00000000u)

#define CSL_EMIF_AxCR_EW_MASK           		(0x40000000u)
#define CSL_EMIF_AxCR_EW_SHIFT          		(30)
#define CSL_EMIF_AxCR_EW_RESETVAL       		(0x00000000u)

#define CSL_EMIF_AxCR_W_SETUP_MASK          	(0x3C000000u)
#define CSL_EMIF_AxCR_W_SETUP_SHIFT         	(26)
#define CSL_EMIF_AxCR_W_SETUP_RESETVAL      	(0x0000000Fu)

#define CSL_EMIF_AxCR_W_STROBE_MASK           	(0x03F00000u)
#define CSL_EMIF_AxCR_W_STROBE_SHIFT          	(20)
#define CSL_EMIF_AxCR_W_STROBE_RESETVAL       	(0x0000003Fu)

#define CSL_EMIF_AxCR_W_HOLD_MASK           	(0x000E0000u)
#define CSL_EMIF_AxCR_W_HOLD_SHIFT          	(17)
#define CSL_EMIF_AxCR_W_HOLD_RESETVAL       	(0x00000007u)

#define CSL_EMIF_AxCR_R_SETUP_MASK           	(0x0001E000u)
#define CSL_EMIF_AxCR_R_SETUP_SHIFT          	(13)
#define CSL_EMIF_AxCR_R_SETUP_RESETVAL       	(0x0000000Fu)

#define CSL_EMIF_AxCR_R_STROBE_MASK           	(0x00001F80u)
#define CSL_EMIF_AxCR_R_STROBE_SHIFT          	(7)
#define CSL_EMIF_AxCR_R_STROBE_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AxCR_R_HOLD_MASK           	(0x00000070u)
#define CSL_EMIF_AxCR_R_HOLD_SHIFT          	(4)
#define CSL_EMIF_AxCR_R_HOLD_RESETVAL       	(0x00000007u)

#define CSL_EMIF_AxCR_TA_MASK           		(0x0000000Cu)
#define CSL_EMIF_AxCR_TA_SHIFT          		(2)
#define CSL_EMIF_AxCR_TA_RESETVAL       		(0x00000003u)

#define CSL_EMIF_AxCR_ASIZE_MASK           		(0x00000003u)
#define CSL_EMIF_AxCR_ASIZE_SHIFT          		(0)
#define CSL_EMIF_AxCR_ASIZE_RESETVAL       		(0x00000000u)

// SYNC MODE
#define CSL_EMIF_AxCR_RENEN_MASK           		(0x00000080u)
#define CSL_EMIF_AxCR_RENEN_SHIFT          		(7)
#define CSL_EMIF_AxCR_RENEN_RESETVAL       		(0x00000000u)

#define CSL_EMIF_AxCR_CEEXT_MASK           		(0x00000040u)
#define CSL_EMIF_AxCR_CEEXT_SHIFT          		(6)
#define CSL_EMIF_AxCR_CEEXT_RESETVAL       		(0x00000000u)

#define CSL_EMIF_AxCR_SYNCWL_MASK           	(0x00000030u)
#define CSL_EMIF_AxCR_SYNCWL_SHIFT          	(4)
#define CSL_EMIF_AxCR_SYNCWL_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AxCR_SYNRWL_MASK           	(0x0000000Cu)
#define CSL_EMIF_AxCR_SYNRWL_SHIFT          	(2)
#define CSL_EMIF_AxCR_SYNRWL_RESETVAL       	(0x00000000u)

#define CSL_EMIF_AxCR_SIZE_MASK           		(0x00000003u)
#define CSL_EMIF_AxCR_SIZE_SHIFT          		(0)
#define CSL_EMIF_AxCR_SIZE_RESETVAL       		(0x00000000u)
// END OF SYNC MODE

#define CSL_EMIF_AxCR_ASYNC_RESETVAL  			(0x3FFFFFFCu)


/* IRR */
#define CSL_EMIF_IRR_WR_MASK           			(0x0000003Cu)
#define CSL_EMIF_IRR_WR_SHIFT          			(2)
#define CSL_EMIF_IRR_WR_RESETVAL       			(0x00000000u)

#define CSL_EMIF_IRR_AT_MASK           			(0x00000001u)
#define CSL_EMIF_IRR_AT_SET           			(0x00000001u)
#define CSL_EMIF_IRR_AT_SHIFT          			(0)
#define CSL_EMIF_IRR_AT_RESETVAL       			(0x00000000u)

#define CSL_EMIF_IRR_RESETVAL  					(0x00000000u)

/* IMR */

#define CSL_EMIF_IMR_WR_MASK         	(0x0000003Cu)
#define CSL_EMIF_IMR_WR_SHIFT         	(2)
#define CSL_EMIF_IMR_WR_RESETVAL       	(0x00000000u)

#define CSL_EMIF_IMR_AT_MASK           			(0x00000001u)
#define CSL_EMIF_IMR_AT_SHIFT          			(0)
#define CSL_EMIF_IMR_AT_RESETVAL       			(0x00000000u)

#define CSL_EMIF_IMR_RESETVAL  					(0x00000000u)

/* IMSR */

#define CSL_EMIF_IMSR_WR_MASK_SET_MASK        (0x0000003Cu)
#define CSL_EMIF_IMSR_WR_MASK_SET_SHIFT      	(2)
#define CSL_EMIF_IMSR_WR_MASK_SET_RESETVAL  	(0x00000000u)

#define CSL_EMIF_IMSR_AT_MASK_SET_MASK       	(0x00000001u)
#define CSL_EMIF_IMSR_AT_MASK_SET_SET       	(0x00000001u)
#define CSL_EMIF_IMSR_AT_MASK_SET_SHIFT       	(0)
#define CSL_EMIF_IMSR_AT_MASK_SET_RESETVAL   	(0x00000000u)

#define CSL_EMIF_IMSR_RESETVAL  				(0x00000000u)


/* IMCR */

#define CSL_EMIF_IMCR_WR_MASK_CLR_MASK        (0x0000003Cu)
#define CSL_EMIF_IMCR_WR_MASK_CLR_SHIFT      	(2)
#define CSL_EMIF_IMCR_WR_MASK_CLR_RESETVAL  	(0x00000000u)

#define CSL_EMIF_IMCR_AT_MASK_CLR_MASK       	(0x00000001u)
#define CSL_EMIF_IMCR_AT_MASK_CLR_SET       	(0x00000001u)
#define CSL_EMIF_IMCR_AT_MASK_CLR_SHIFT       	(0)
#define CSL_EMIF_IMCR_AT_MASK_CLR_RESETVAL   	(0x00000000u)

#define CSL_EMIF_IMCR_RESETVAL  				(0x00000000u)

/* NANDFCR */
#define CSL_EMIF_NANDFCR_ADDR_CALC_START_MASK       (0x00002000u)
#define CSL_EMIF_NANDFCR_ADDR_CALC_START_SHIFT      (13)
#define CSL_EMIF_NANDFCR_ADDR_CALC_START_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_4ECC_START_MASK       		(0x00001000u)
#define CSL_EMIF_NANDFCR_4ECC_START_SHIFT      		(12)
#define CSL_EMIF_NANDFCR_4ECC_START_RESETVAL  		(0x00000000u)

#define CSL_EMIF_NANDFCR_CE3_ECC_START_MASK       	(0x00000800u)
#define CSL_EMIF_NANDFCR_CE3_ECC_START_SHIFT      	(11)
#define CSL_EMIF_NANDFCR_CE3_ECC_START_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_CE2_ECC_START_MASK       	(0x00000400u)
#define CSL_EMIF_NANDFCR_CE2_ECC_START_SHIFT      	(10)
#define CSL_EMIF_NANDFCR_CE2_ECC_START_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_CE1_ECC_START_MASK       	(0x00000200u)
#define CSL_EMIF_NANDFCR_CE1_ECC_START_SHIFT      	(9)
#define CSL_EMIF_NANDFCR_CE1_ECC_START_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_CE0_ECC_START_MASK       	(0x00000100u)
#define CSL_EMIF_NANDFCR_CE0_ECC_START_SHIFT      	(8)
#define CSL_EMIF_NANDFCR_CE0_ECC_START_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_4BIT_ECC_SEL_MASK       	(0x00000030u)
#define CSL_EMIF_NANDFCR_4BIT_ECC_SEL_SHIFT      	(4)
#define CSL_EMIF_NANDFCR_4BIT_ECC_SEL_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_CE3_USE_NAND_MASK       	(0x00000008u)
#define CSL_EMIF_NANDFCR_CE3_USE_NAND_SHIFT      	(3)
#define CSL_EMIF_NANDFCR_CE3_USE_NAND_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_CE2_USE_NAND_MASK       	(0x00000004u)
#define CSL_EMIF_NANDFCR_CE2_USE_NAND_SHIFT      	(2)
#define CSL_EMIF_NANDFCR_CE2_USE_NAND_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_CE1_USE_NAND_MASK       	(0x00000002u)
#define CSL_EMIF_NANDFCR_CE1_USE_NAND_SHIFT      	(1)
#define CSL_EMIF_NANDFCR_CE1_USE_NAND_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_CE0_USE_NAND_MASK       	(0x00000001u)
#define CSL_EMIF_NANDFCR_CE0_USE_NAND_SHIFT      	(0)
#define CSL_EMIF_NANDFCR_CE0_USE_NAND_RESETVAL  	(0x00000000u)

#define CSL_EMIF_NANDFCR_RESETVAL					(0X00000000)

/* NANDFSR */
#define CSL_EMIF_NANDFSR_ERR_NUM_MASK       		(0x00030000u)
#define CSL_EMIF_NANDFSR_ERR_NUM_SHIFT      		(16)
#define CSL_EMIF_NANDFSR_ERR_NUM_RESETVAL  			(0x00000000u)

#define CSL_EMIF_NANDFSR_CORE_STATE_MASK       		(0x00000F00u)
#define CSL_EMIF_NANDFSR_CORE_STATE_SHIFT      		(8)
#define CSL_EMIF_NANDFSR_CORE_STATE_RESETVAL  		(0x00000000u)

#define CSL_EMIF_NANDFSR_WAIT_STATE_MASK       		(0x0000000Fu)
#define CSL_EMIF_NANDFSR_WAIT_STATE_SHIFT      		(0)
#define CSL_EMIF_NANDFSR_WAIT_STATE_RESETVAL  		(0x00000000u)

#define CSL_EMIF_NANDFSR_RESETVAL					(0X00000000)

/* PMCR */
#define CSL_EMIF_PMCR_CE3_PG_DEL_MASK       		(0xFC000000u)
#define CSL_EMIF_PMCR_CE3_PG_DEL_SHIFT      		(26)
#define CSL_EMIF_PMCR_CE3_PG_DEL_RESETVAL  			(0x0000003Fu)

#define CSL_EMIF_PMCR_CE3_PG_SIZE_MASK       		(0x02000000u)
#define CSL_EMIF_PMCR_CE3_PG_SIZE_SHIFT      		(25)
#define CSL_EMIF_PMCR_CE3_PG_SIZE_RESETVAL  		(0x00000000u)

#define CSL_EMIF_PMCR_CE3_PG_MID_EN_MASK       		(0x01000000u)
#define CSL_EMIF_PMCR_CE3_PG_MID_EN_SHIFT      		(24)
#define CSL_EMIF_PMCR_CE3_PG_MID_EN_RESETVAL  		(0x00000000u)

#define CSL_EMIF_PMCR_CE2_PG_DEL_MASK       		(0x00FC0000u)
#define CSL_EMIF_PMCR_CE2_PG_DEL_SHIFT      		(18)
#define CSL_EMIF_PMCR_CE2_PG_DEL_RESETVAL  			(0x0000003Fu)

#define CSL_EMIF_PMCR_CE2_PG_SIZE_MASK       		(0x00020000u)
#define CSL_EMIF_PMCR_CE2_PG_SIZE_SHIFT      		(17)
#define CSL_EMIF_PMCR_CE2_PG_SIZE_RESETVAL  		(0x00000000u)

#define CSL_EMIF_PMCR_CE2_PG_MID_EN_MASK       		(0x00010000u)
#define CSL_EMIF_PMCR_CE2_PG_MID_EN_SHIFT      		(16)
#define CSL_EMIF_PMCR_CE2_PG_MID_EN_RESETVAL  		(0x00000000u)

#define CSL_EMIF_PMCR_CE1_PG_DEL_MASK       		(0x0000FC00u)
#define CSL_EMIF_PMCR_CE1_PG_DEL_SHIFT      		(10)
#define CSL_EMIF_PMCR_CE1_PG_DEL_RESETVAL  			(0x0000003Fu)

#define CSL_EMIF_PMCR_CE1_PG_SIZE_MASK       		(0x00000200u)
#define CSL_EMIF_PMCR_CE1_PG_SIZE_SHIFT      		(9)
#define CSL_EMIF_PMCR_CE1_PG_SIZE_RESETVAL  		(0x00000000u)

#define CSL_EMIF_PMCR_CE1_PG_MID_EN_MASK       		(0x00000100u)
#define CSL_EMIF_PMCR_CE1_PG_MID_EN_SHIFT      		(8)
#define CSL_EMIF_PMCR_CE1_PG_MID_EN_RESETVAL  		(0x00000000u)

#define CSL_EMIF_PMCR_CE0_PG_DEL_MASK       		(0x000000FCu)
#define CSL_EMIF_PMCR_CE0_PG_DEL_SHIFT      		(2)
#define CSL_EMIF_PMCR_CE0_PG_DEL_RESETVAL  			(0x0000003Fu)

#define CSL_EMIF_PMCR_CE0_PG_SIZE_MASK       		(0x00000002u)
#define CSL_EMIF_PMCR_CE0_PG_SIZE_SHIFT      		(1)
#define CSL_EMIF_PMCR_CE0_PG_SIZE_RESETVAL  		(0x00000000u)

#define CSL_EMIF_PMCR_CE0_PG_MID_EN_MASK       		(0x00000001u)
#define CSL_EMIF_PMCR_CE0_PG_MID_EN_SHIFT      		(0)
#define CSL_EMIF_PMCR_CE0_PG_MID_EN_RESETVAL  		(0x00000000u)

#define CSL_EMIF_PMCR_RESETVAL						(0XFCFCFCFC)

/* NFECCCS2R */
#define CSL_EMIF_NFECCCS2R_RESETVAL					(0X00000000)

/* NFECCCS3R */
#define CSL_EMIF_NFECCCS3R_RESETVAL					(0X00000000)

/* NFECCCS4R */
#define CSL_EMIF_NFECCCS4R_RESETVAL					(0X00000000)

/* NFECCCS5R */
#define CSL_EMIF_NFECCCS5R_RESETVAL					(0X00000000)

/* NANDF4BECCLR */
#define CSL_EMIF_NANDF4BECCLR_RESETVAL				(0X00000000)

/* NANDF4BECC1R */
#define CSL_EMIF_NANDF4BECC1R_RESETVAL				(0X00000000)

/* NANDF4BECC2R */
#define CSL_EMIF_NANDF4BECC2R_RESETVAL				(0X00000000)

/* NANDF4BECC3R */
#define CSL_EMIF_NANDF4BECC3R_RESETVAL				(0X00000000)

/* NANDF4BECC4R */
#define CSL_EMIF_NANDF4BECC4R_RESETVAL				(0X00000000)

/* NANDFEA1R */
#define CSL_EMIF_NANDFEA1R_RESETVAL					(0X00000000)

/* NANDFEA2R */
#define CSL_EMIF_NANDFEA2R_RESETVAL					(0X00000000)

/* NANDFEV1R */
#define CSL_EMIF_NANDFEV1R_RESETVAL					(0X00000000)

/* NANDFEV2R */
#define CSL_EMIF_NANDFEV2R_RESETVAL					(0X00000000)
#endif
