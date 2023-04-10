/*  ============================================================================
 *   Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 *   Use of this software is controlled by the terms and conditions found
 *   in the license agreement under which this software has been supplied.
 *  ============================================================================
 */
/** ============================================================================
 *  @file    csl_emifaInit.c
 *  
 *  @path    $(CSLPATH)\src\emifa
 *
 *  @desc    File for functional layer of CSL API @a CSL_emifaInit()
 *           - The @a CSL_emifaInit() function definition & it's associated 
 *             functions
 *
 */
/* =============================================================================
 *  Revision History
 *  ===============
 *  10-May-2005 RM  File Created.
 *  
 *  09-Sep-2005 NG  Updation according to coding guidelines
 *  
 * =============================================================================
 */
#include <csl_emif.h>
#include <csl_utils.h>

/** ===========================================================================
 *  @n@b   CSL_emifaInit
 *
 *  @b Description
 *  @n This function is idempotent i.e. calling it many times is same as calling
 *     it once.  This function presently does nothing.
 *
 *  @b Arguments
    @verbatim
            pContext   Context information for the instance.  Should be NULL
    @endverbatim
 *
 *  <b> Return Value </b>  CSL_Status
 *  @li                    CSL_SOK - Always returns
 *
 *  <b> Pre Condition </b>
 *  @n  This function should be called before using any of the CSL APIs
 *
 *  <b> Post Condition </b>
 *  @n  None
 *
 *  @b Modifies
 *  @n  None
 *
 *  @b Example
 * @verbatim
   ...
   CSL_emifaInit( NULL );
   ...
   }
   @endverbatim
 *
 * ============================================================================
 */

//#pragma CODE_SECTION (CSL_emifInit, ".text:csl_section:emif");
CSL_SET_CSECT(CSL_emifInit, ".text:csl_section:emif")
CSL_Status  CSL_emifInit(
    CSL_EmifContext    *pContext
)
{
    return CSL_SOK;
}

