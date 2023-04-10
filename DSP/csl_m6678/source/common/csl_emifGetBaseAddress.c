/*  ============================================================================
 *  Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 *  Use of this software is controlled by the terms and conditions found in the
 *  license agreement under which this software has been supplied.
 *  ===========================================================================
 */
/** ============================================================================
 *   @file  csl_emifaGetBaseAddress.c
 *
 *   @path  $(CSLPATH)\src\common
 *
 *   @desc  CSL Implementation of CSL_emifaGetBaseAddress
 *
 */
/*  ============================================================================
 *  Revision History
 *  ===============
 *  13-May-2005 Ramitha Mathew File Created.
 *  25-Jan-2006 SD             Modified the code section start address 
 *  09-Aug-2006 NG             Added condition to check the invalid parameter
 *
 *  ============================================================================
 */
#include <soc.h>
#include <csl_emif.h>
#include <csl_utils.h>

/** ============================================================================
 *   @n@b CSL_emifaGetBaseAddress
 *
 * @b Description
 * @n The get base address call will give the External memory interface current 
 *    current instance base address
 *
 *   @b Arguments
 *   @verbatim      
            emifaNum         Specifies the instance of the EMIFA external memory
                            interface for which the base address is requested
 
            pEmifaParam      Module specific parameters.
 
            pBaseAddress    Pointer to the base address structure to return the
                            base address details.
     @endverbatim
 *
 *   <b> Return Value </b>  CSL_Status
 *   @li                    CSL_OK              Successful on getting the base 
 *                                              address of emifa
 *   @li                    CSL_ESYS_FAIL       The external memory interface 
 *                                              instance is not available.
 *   @li                    CSL_ESYS_INVPARAMS  Invalid parameter 
 *
 *   <b> Pre Condition </b>
 *   @n  @a CSL_emifaInit() and CSL_emifaOpen () must be called successfully.
 *
 *   <b> Post Condition </b>
 *   @n  Base address structure is populated
 *
 *   @b Modifies
 *   @n    1. The status variable
 *
 *         2. Base address structure.
 *
 *   @b Example
 *   @verbatim
        CSL_Status          status;
        CSL_EmifaBaseAddress  baseAddress;

       ...
       status = CSL_emifaGetBaseAddress(CSL_EMIFA, NULL, &baseAddress);

    @endverbatim
 *  @return Returns the status of the get base address operation
 *
 * ============================================================================
 */
//#pragma CODE_SECTION (CSL_emifGetBaseAddress, ".text:csl_section:emif");
CSL_SET_CSECT(CSL_emifGetBaseAddress, ".text:csl_section:emif")
CSL_Status CSL_emifGetBaseAddress(
    CSL_InstNum             emifNum,
    CSL_EmifParam          *pEmifParam,
    CSL_EmifBaseAddress    *pBaseAddress
)
{
    CSL_Status status = CSL_SOK;

    if (pBaseAddress == NULL) {
        status = CSL_ESYS_INVPARAMS;
	}
    else {
        switch (emifNum) {
            case CSL_EMIF_32:
                pBaseAddress->regs = (CSL_EmifRegsOvly)CSL_EMIF32_REGS;
                break;

            default:
                pBaseAddress->regs = (CSL_EmifRegsOvly)NULL;
                status = CSL_ESYS_FAIL;
                break;
        }
    }
    return (status);
}

