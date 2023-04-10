/*
 * csl_pllcEclkOutConfig.c
 *
 *  Created on: 2021��8��27��
 *      Author: jayden
 */

#include <csl_pllc.h>
#include <csl_pllcAux.h>
#include <csl_utils.h>

//#pragma CODE_SECTION (CSL_pllcEclkOutConfig, ".text:csl_section:pllc");
CSL_SET_CSECT(CSL_pllcEclkOutConfig, ".text:csl_section:pllc")
CSL_Status CSL_pllcEclkOutConfig (
	Uint8 ratio
){
	int goStatus;

	if(ratio == 0) ratio = 0;
	//check no change is processing
	do{
		goStatus = CSL_PLLC_getPllGoStat();
	}while(goStatus);

	// enable divider
	CSL_PLLC_assertPllDivEn();

	// the real clock divide factor is ratio*2
	CSL_PLLC_setPllDivRatio(ratio);

	// start change divide factor
	CSL_PLLC_assertPllCtlCmdGo();

	// wait for finish
	do{
		goStatus = CSL_PLLC_getPllGoStat();
	}while(goStatus);

	// Clear divide factor change status
	CSL_PLLC_ClearPllDChangeStat();

	return CSL_SOK;
}
