/*  ============================================================================
 *   Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 *   Use of this software is controlled by the terms and conditions found
 *   in the license agreement under which this software has been supplied.
 *  ============================================================================
 */
/** ============================================================================
 *  @file    csl_emifaGetHwStatus.c
 *
 *  @path    $(CSLPATH)\src\emifa
 *
 *  $desc    File for functional layer of CSL API @a CSL_emifaGetHwStatus()
 *           - The @a CSL_emifaGetHwStatus() function definition & it's 
 *             associated functions
 *
 */
/* =============================================================================
 *  Revision History
 *  ===============
 *  12-May-2005 RM  File Created.
 *  
 *  09-Sep-2005 NG  Updation according to coding guidelines
 *  
 * =============================================================================
 */
#include <csl_emif.h>
#include <csl_emifAux.h>
#include <csl_utils.h>

/** ============================================================================
 * @n@b   CSL_emifaGetHwStatus
 *
 * @b Description
 * @n This function is used to read the current device configuration, status 
 *    flags and the value present associated registers.  User should allocate 
 *    memory for the said data type and pass its pointer as an unadorned void* 
 *    argument to the status query call.  For details about the various status 
 *    queries supported & the associated data structure to record the response, 
 *    refer to @a CSL_EmifaHwStatusQuery.
 *
 * @b Arguments
 * @verbatim      
            hEmif          Pointer to the object that holds reference to the
                            instance of EMIFA requested after the call
 
            query           The query to this API which indicates the status 
                            to be returned
			response        Placeholder to return the status. @a void* casted
   @endverbatim
 *
 * <b> Return Value </b>  CSL_Status
 * @li                    CSL_SOK            - successful on getting hardware 
 *                                             status
 * @li                    CSL_ESYS_INVQUERY  - Query is not valid    
 * @li                    CSL_ESYS_BADHANDLE - Handle is not valid    
 *
 * <b> Pre Condition </b>
 * @n  Both @a CSL_emifaInit() and @a CSL_emifaOpen() must be called 
 *     successfully in order before calling @a CSL_emifaGetHwStatus(). 
 *     For the argument type that can be @a void* casted & passed with a
 *     particular command refer to @a CSL_EmifaHwStatusQuery
 *
 * <b> Post Condition </b>
 * @n  None
 *
 * @b Modifies
 * @n Third parameter response vlaue 
 *
 * @b Example:
 * @verbatim
      CSL_EmifaHandle hEmif;
      CSL_Status status;
      Uint8  *response;
       ...
      status = CSL_emifaGetHwStatus(hEmif,
                                    CSL_EMIFA_QUERY_ENDIAN,
                                    &response);
   @endverbatim
 *
 * ============================================================================
 */

//#pragma CODE_SECTION (CSL_emifGetHwStatus,".text:csl_section:emif");
CSL_SET_CSECT(CSL_emifGetHwStatus,".text:csl_section:emif")
CSL_Status  CSL_emifGetHwStatus (
    CSL_EmifHandle           hEmif,
    CSL_EmifHwStatusQuery    query,
    void                      *response
)
{
    CSL_Status status = CSL_SOK;
     
    if(hEmif == NULL) {
        status = CSL_ESYS_BADHANDLE;
    }
    else if (response == NULL) {
        status = CSL_ESYS_INVPARAMS;
    }
    else {
        switch (query) {
            case CSL_EMIF_QUERY_REV_ID:
                CSL_emifGetRevId (hEmif,(CSL_EmifModIdRev *)response);
                break; 
            case CSL_EMIF_QUERY_ASYNC_TIMEOUT_EN:
                *(Uint8 *)response = CSL_emifGetAsyncTimeoutMaskStatus(hEmif);
                break;  
            case CSL_EMIF_QUERY_ASYNC_TIMEOUT_STATUS:
                *(Uint8 *)response = CSL_emifGetAsyncTimeoutStatus(hEmif);
                break;                
//            case CSL_EMIFA_QUERY_ENDIAN:
//                CSL_emifGetEndian (hEmif,(Uint8*)response);
//                break;
            default:
                status = CSL_ESYS_INVQUERY ;
                break;
        }
    }
    
    return (status);
}

