#include <csl_emif.h>
#include <csl_utils.h>

CSL_SET_CSECT(CSL_emifHwSetupRaw, ".text:csl_section:emif")
//#pragma CODE_SECTION (CSL_emifHwSetupRaw, ".text:csl_section:emif");
CSL_Status CSL_emifHwSetupRaw(
    CSL_EmifHandle    hEmif,
    CSL_EmifConfig    *config
)
{
    CSL_Status status = CSL_SOK;

    if(hEmif == NULL) {
        status = CSL_ESYS_BADHANDLE;
    }
    else if(config == NULL) {
        status = CSL_ESYS_INVPARAMS;
    }
    else {
        /* setting the Chip Enable2 Configuration register */
        hEmif->regs->A1CR = config->A1CR;

         /* setting the Chip Enable3 Configuration register */
        hEmif->regs->A2CR = config->A2CR;

         /* setting the Chip Enable4 Configuration register */
        hEmif->regs->A3CR = config->A3CR;

         /* setting the Chip Enable5 Configuration register */
        hEmif->regs->A4CR = config->A4CR;

         /* setting the Asynchronous Wait Cycle Configuration register */
        hEmif->regs->AWCCR = config->AWCCR;

        /* setting the Interrupt Raw Register */
        hEmif->regs->IRR = config->IRR;

        /* setting Interrupt Masked Register */
        hEmif->regs->IMR = config->IMR;

        /* setting the Interrupt Mask Set Register */
        hEmif->regs->IMSR = config->IMSR;

        /* setting the Interrupt Mask Clear Register */
        hEmif->regs->IMCR = config->IMCR;

        /* setting the Burst Priority Register */
//        hEmif->regs->BPRIO = config->BPRIO;
    }

    return (status);
}

