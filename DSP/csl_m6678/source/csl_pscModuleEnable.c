#include <csl_psc.h>
#include <csl_pscAux.h>
#include <csl_utils.h>

//#pragma CODE_SECTION (CSL_pscModuleEnable, ".text:csl_section:psc");
CSL_SET_CSECT(CSL_pscModuleEnable, ".text:csl_section:psc")
CSL_Status CSL_pscModuleEnable (
    CSL_PSC_MDNUM modulenum,
	CSL_PSC_PWRNUM pwrnum
)
{
	while(!CSL_PSC_isStateTransitionDone(pwrnum));
	CSL_PSC_setModuleNextState(modulenum, PSC_MODSTATE_ENABLE);
	CSL_PSC_startStateTransition(pwrnum);
	while(!CSL_PSC_isStateTransitionDone(pwrnum));

	return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_pscModuleDisable, ".text:csl_section:psc");
CSL_SET_CSECT(CSL_pscModuleDisable, ".text:csl_section:psc")
CSL_Status CSL_pscModuleDisable (
    CSL_PSC_MDNUM modulenum,
	CSL_PSC_PWRNUM pwrnum
)
{
	while(!CSL_PSC_isStateTransitionDone(pwrnum));
	CSL_PSC_setModuleNextState(modulenum, PSC_MODSTATE_SWRSTDISABLE);
	CSL_PSC_startStateTransition(pwrnum);
	while(!CSL_PSC_isStateTransitionDone(pwrnum));

	return CSL_SOK;
}
