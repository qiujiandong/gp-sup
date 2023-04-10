/*
 * csl_pllcMainPLLConfig.c
 *
 *  Created on: 2021Äê8ÔÂ26ÈÕ
 *      Author: jayden
 */
#include <csl_pllc.h>
#include <csl_pllcAux.h>
#include <csl_utils.h>

//#pragma CODE_SECTION (pllcWait, ".text:csl_section:pllc");
CSL_SET_CSECT(pllcWait, ".text:csl_section:pllc")
inline void pllcWait(unsigned int i)
{
	volatile unsigned int c=0;
	for(c=0;c<i;c++)
	{
		asm("	nop 5");
	}
}

//#pragma CODE_SECTION (CSL_pllcMainPLLPre, ".text:csl_section:pllc");
CSL_SET_CSECT(CSL_pllcMainPLLPre, ".text:csl_section:pllc")
CSL_Status CSL_pllcMainPLLPre (
){
	// pll source select disable
//	CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PLLENSRC, DISABLE);
	CSL_PLLC_deassertMainPllEnSrc();
	pllcWait(20);
	// pll power down
//	CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PD, ENABLE);
	CSL_PLLC_assertMainPllCtrlPowerDown();
	return CSL_SOK;
}


//#pragma CODE_SECTION (CSL_pllcMainPLLPost, ".text:csl_section:pllc");
CSL_SET_CSECT(CSL_pllcMainPLLPost, ".text:csl_section:pllc")
CSL_Status CSL_pllcMainPLLPost(
){
	// deassert pll power down
//	CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PD, DISABLE);
	CSL_PLLC_deassertMainPllCtrlPowerDown();
	// wait until lock
//	while(!CSL_FEXT(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_LOCK));
	while(!CSL_PLLC_getMainPllLockStat());
	// pll source select enable
//	CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PLLENSRC, ENABLE);
	CSL_PLLC_assertMainPllEnSrc();
	// pll enable
//	CSL_FINST(hPllc->MAINPLLCMD, PLLC_MAINPLLCMD_PLLEN, ENABLE);
	CSL_PLLC_assertMainPllCtrlPllEn();
	pllcWait(200);

	return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_pllcDDRPLLPre, ".text:csl_section:pllc");
CSL_SET_CSECT(CSL_pllcDDRPLLPre, ".text:csl_section:pllc")
CSL_Status CSL_pllcDDRPLLPre (
){
	CSL_PLLC_assertDDRPllRefClkBypass();
	pllcWait(20);
	CSL_PLLC_assertDDRPllPowerDown();
	return CSL_SOK;
}


//#pragma CODE_SECTION (CSL_pllcDDRPLLPost, ".text:csl_section:pllc");
CSL_SET_CSECT(CSL_pllcDDRPLLPost, ".text:csl_section:pllc")
CSL_Status CSL_pllcDDRPLLPost(
){
	CSL_PLLC_deassertDDRPllPowerDown();
	while(!CSL_PLLC_getDDRPllLockStat());
	CSL_PLLC_deassertDDRPllRefClkBypass();

	return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_pllcPASSPLLPre, ".text:csl_section:pllc");
CSL_SET_CSECT(CSL_pllcPASSPLLPre, ".text:csl_section:pllc")
CSL_Status CSL_pllcPASSPLLPre (
){
	CSL_PLLC_assertPASSPllClkBypass();
	pllcWait(20);
	CSL_PLLC_assertPASSPllPowerDown();
	return CSL_SOK;
}


//#pragma CODE_SECTION (CSL_pllcPASSPLLPost, ".text:csl_section:pllc");
CSL_SET_CSECT(CSL_pllcPASSPLLPost, ".text:csl_section:pllc")
CSL_Status CSL_pllcPASSPLLPost(
){
	CSL_PLLC_deassertPASSPllPowerDown();
	while(!CSL_PLLC_getPASSPllLockStat());
	CSL_PLLC_deassertPASSPllClkBypass();

	return CSL_SOK;
}
