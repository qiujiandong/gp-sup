/*
 * csl_bootcfgMainPLL.c
 *
 *  Created on: 2021.8.26
 *      Author: jayden
 */

#include <csl_bootcfg.h>
#include <csl_utils.h>

CSL_IDEF_INLINE void CSL_BootCfgUnlockKicker (void)
{
    hBootCfg->KICK_REG0 = 0x83e70b13;
    hBootCfg->KICK_REG1 = 0x95a4f1e0;

    return;
}

CSL_IDEF_INLINE void CSL_BootCfgSetMainPLLConfiguration (Uint32 MainPLLCTL0, Uint32 MainPLLCTL1)
{
    hBootCfg->MAINPLLCTL0 = MainPLLCTL0;
    hBootCfg->MAINPLLCTL1 = MainPLLCTL1;
}

CSL_IDEF_INLINE void CSL_BootCfgSetDDR3PLLConfiguration (Uint32 ddr3PLLConfig0, Uint32 ddr3PLLConfig1)
{
    hBootCfg->DDR3PLLCTL0 = ddr3PLLConfig0;
    hBootCfg->DDR3PLLCTL1 = ddr3PLLConfig1;
}

CSL_IDEF_INLINE void CSL_BootCfgSetPAPLLConfiguration (Uint32 paPLLConfig0, Uint32 paPLLConfig1)
{
    hBootCfg->PASSPLLCTL0 = paPLLConfig0;
    hBootCfg->PASSPLLCTL1 = paPLLConfig1;
}

CSL_SET_CSECT(bootcfgWait, ".text:csl_section:bootcfg")
static void bootcfgWait(unsigned int i)
{
	volatile unsigned int c=0;
	for(c=0;c<i;c++)
	{
		asm("	nop 5");
	}
}

//#pragma CODE_SECTION (CSL_bootcfgMainPLLCTLConfig, ".text:csl_section:bootcfg");
CSL_SET_CSECT(CSL_bootcfgMainPLLCTLConfig, ".text:csl_section:bootcfg")
CSL_Status CSL_bootcfgMainPLLCTLConfig (
	Uint8 pllm,
	Uint8 plld,
	Uint8 postdiv1,
	Uint8 postdiv2
){
	Uint32 mainpllctl0;
	Uint32 mainpllctl1;

	if(pllm == 0) pllm = 1;
	if(plld == 0) plld = 1;
	if(postdiv1 == 0) postdiv1 = 1;
	if(postdiv2 == 0) postdiv2 = 1;

	mainpllctl0 = 	CSL_FMK(BOOTCFG_MAINPLLCTL0_PLLM, pllm) |
					CSL_FMK(BOOTCFG_MAINPLLCTL0_PLLD, plld);
	mainpllctl1 = 	CSL_FMK(BOOTCFG_MAINPLLCTL1_POSTDIV1, postdiv1) |
					CSL_FMK(BOOTCFG_MAINPLLCTL1_POSTDIV2, postdiv2);

	CSL_BootCfgUnlockKicker();
	CSL_BootCfgSetMainPLLConfiguration(mainpllctl0, mainpllctl1);
	bootcfgWait(100);
//	CSL_BootCfgLockKicker();
	return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_bootcfgDDRPLLCTLConfig, ".text:csl_section:bootcfg");
CSL_SET_CSECT(CSL_bootcfgDDRPLLCTLConfig, ".text:csl_section:bootcfg")
CSL_Status CSL_bootcfgDDRPLLCTLConfig (
	Uint8 pllm,
	Uint8 plld,
	Uint8 postdiv1,
	Uint8 postdiv2
){
	Uint32 ddrpllctl0;
	Uint32 ddrpllctl1;

	if(pllm == 0) pllm = 1;
	if(plld == 0) plld = 1;
	if(postdiv1 == 0) postdiv1 = 1;
	if(postdiv2 == 0) postdiv2 = 1;

	ddrpllctl0 = 	CSL_FMK(BOOTCFG_DDRPLLCTL0_PLLM, pllm) |
					CSL_FMK(BOOTCFG_DDRPLLCTL0_PLLD, plld);
	ddrpllctl1 = 	CSL_FMK(BOOTCFG_DDRPLLCTL1_POSTDIV1, postdiv1) |
					CSL_FMK(BOOTCFG_DDRPLLCTL1_POSTDIV2, postdiv2);

	CSL_BootCfgUnlockKicker();
	CSL_BootCfgSetDDR3PLLConfiguration(ddrpllctl0, ddrpllctl1);
	bootcfgWait(100);
//	CSL_BootCfgLockKicker();
	return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_bootcfgPASSPLLCTLConfig, ".text:csl_section:bootcfg");
CSL_SET_CSECT(CSL_bootcfgPASSPLLCTLConfig, ".text:csl_section:bootcfg")
CSL_Status CSL_bootcfgPASSPLLCTLConfig (
	Uint8 pllm,
	Uint8 plld,
	Uint8 postdiv1,
	Uint8 postdiv2
){
	Uint32 passpllctl0;
	Uint32 passpllctl1;

	if(pllm == 0) pllm = 1;
	if(plld == 0) plld = 1;
	if(postdiv1 == 0) postdiv1 = 1;
	if(postdiv2 == 0) postdiv2 = 1;

	passpllctl0 = 	CSL_FMK(BOOTCFG_DDRPLLCTL0_PLLM, pllm) |
					CSL_FMK(BOOTCFG_DDRPLLCTL0_PLLD, plld);
	passpllctl1 = 	CSL_FMK(BOOTCFG_DDRPLLCTL1_POSTDIV1, postdiv1) |
					CSL_FMK(BOOTCFG_DDRPLLCTL1_POSTDIV2, postdiv2);

	CSL_BootCfgUnlockKicker();
	CSL_BootCfgSetPAPLLConfiguration(passpllctl0, passpllctl1);
	bootcfgWait(100);
//	CSL_BootCfgLockKicker();
	return CSL_SOK;
}
