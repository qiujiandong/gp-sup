/*  ============================================================================
 *   Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 *   Use of this software is controlled by the terms and conditions found
 *   in the license agreement under which this software has been supplied.
 *  ============================================================================
 */
/** ============================================================================
 *  @file    csl_emifa.h
 *
 *  @path    $(CSLPATH)\inc
 *
 *  @desc    Header file for functional layer of CSL
 *           - The different enumerations, structure definitions
 *             and function declarations
 * 
 */
/** 
 * @mainpage EMIF CSL 3.x
 *
 * @section Introduction
 *
 * @subsection xxx Purpose and Scope
 * The purpose of this document is to identify a set of common CSL APIs for
 * the EMIF module across various devices. The CSL developer is expected to
 * refer to this document while designing APIs for these modules. Some of the
 * cases listed APIs may not be applicable to a given EMIF module. While
 * other in this list of APIs may not be sufficient to cover all the features of 
 * a particular EMIFA Module. The CSL developer should use his discretion 
 * designing new APIs or extending the existing ones to cover these.
 *
 * @subsection aaa Terms and Abbreviations
 *   -# CSL:  Chip Support Library
 *   -# API:  Application Programmer Interface
 *
 * @subsection References
 *    -# EMIF_SPEC, EMIF Module Specifications Document; Version 3.16.1  
 *                  Jan 18,2005
 *
 */
/* =============================================================================
 *  Revision History
 *  ===============
 *  12-May-2005 RM  File Created.
 *  
 *  07-Jul-2005 RM  - Changed the module name from EMIF64 to EMIFA            
 *                  - Changes made in accordance to the change in cslr_emifa.h        
 *
 *  09-Sep-2005 NG  Updation according to coding guidelines
 *  
 * =============================================================================
 */
#ifndef _CSL_EMIF_H_
#define _CSL_EMIF_H_

#ifdef __cplusplus
extern "C" {
#endif

//#include <cslr.h>
#include <soc.h>
#include <csl_error.h>
#include <csl_types.h>
#include <cslr_emif.h>

/*****************************************************************************
  EMIF global typedef declarations
 *****************************************************************************
 */

/** Total number of Chip Enables for Async/Sync memories */
#define NUMCHIPENABLE   0x4

/** The default values of EMIF Async Wait structure */
#define CSL_EMIF_ASYNCWAIT_MAXEXTWAIT_DEFAULT    0x80
#define CSL_EMIF_ASYNCWAIT_TURNARND_DEFAULT      0x03

/** The default values of EMIF CEConfig for Async structure */
#define CSL_EMIF_ASYNCCFG_SELECTSTROBE_DEFAULT    0x00
#define CSL_EMIF_ASYNCCFG_EWMODE_DEFAULT          0x00
#define CSL_EMIF_ASYNCCFG_WSETUP_DEFAULT          0x0F
#define CSL_EMIF_ASYNCCFG_SSTROBE_DEFAULT         0x3F
#define CSL_EMIF_ASYNCCFG_WHOLD_DEFAULT           0x07
#define CSL_EMIF_ASYNCCFG_RSETUP_DEFAULT          0x0F
#define CSL_EMIF_ASYNCCFG_RSTROBE_DEFAULT         0x3F
#define CSL_EMIF_ASYNCCFG_RHOLD_DEFAULT           0x07
#define CSL_EMIF_ASYNCCFG_TA_DEFAULT           	  0x03
#define CSL_EMIF_ASYNCCFG_ASIZE_DEFAULT           0x00

/** The default values of EMIF CEConfig for Sync structure */
#define CSL_EMIF_SYNCCFG_CHIPENEXT_DEFAULT     0x00
#define CSL_EMIF_SYNCCFG_READEN_DEFAULT        0x00
#define CSL_EMIF_SYNCCFG_WLTNCY_DEFAULT        0x00
#define CSL_EMIF_SYNCCFG_RLTNCY_DEFAULT        0x00
#define CSL_EMIF_SYNCCFG_SBSIZE_DEFAULT        0x00


/** @brief Enumeration for bit field AP of Asynchronous Wait Cycle Configuration 
 *         Register 
 */    
typedef enum CSL_EmifArdyPol{
    /** strobe period extended when ARDY is low  */
    CSL_EMIF_ARDYPOL_LOW    = 0,

    /** strobe period extended when ARDY is high  */
    CSL_EMIF_ARDYPOL_HIGH   = 1
} CSL_EmifArdyPol;

typedef enum CSL_EmifWaitSel{
    /** strobe period extended when ARDY is low  */
    CSL_EMIF_USE_WAIT0    = 0,
    
    /** strobe period extended when ARDY is high  */
    CSL_EMIF_USE_WAIT1   = 1
} CSL_EmifWaitSel;

/** @brief Enumeration for bit field for memory type 
 */    
typedef enum CSL_EmifMemoryType{
    /** Asynchronous memory type */
    CSL_EMIF_MEMTYPE_ASYNC    = 0,
    
    /** Synchronous memory type  */
    CSL_EMIF_MEMTYPE_SYNC     = 1
} CSL_EmifMemoryType;

/** @brief Module specific context information. */
typedef struct CSL_EmifContext{
    /** Context information of EMIFA external memory interface CSL passed as an 
     *  argument to CSL_emifaInit().Present implementation of EMIFA CSL doesn't 
     *  have any context information; hence assigned NULL.
     *  The below declaration is just a place-holder for future implementation.
     */
    Uint16    contextInfo;
} CSL_EmifContext;


/** @brief This structure contains the base-address information for the EMIFA
 *         instance
 */
typedef struct CSL_EmifBaseAddress{
    /** Base-address of the configuration registers of the peripheral */
    CSL_EmifRegsOvly    regs;
} CSL_EmifBaseAddress;

/** @brief This Object contains the reference to the instance of EMIFA opened
 *         using the @a CSL_emifOpen().
 *         The pointer to this, is passed to all EMIFA CSL APIs.
 */
typedef struct CSL_EmifObj {
    /** This is a pointer to the registers of the instance of EMIFA
     *  referred to by this object
     */
    CSL_EmifRegsOvly    regs;
    
    /** This is the instance of EMIF being referred to by this object  */
    CSL_InstNum          perNum;    
} CSL_EmifObj;

/** @brief This is a pointer to @a CSL_EmifObj and is passed as the first
 *         parameter to all EMIF CSL APIs
 */
typedef CSL_EmifObj *CSL_EmifHandle;

/** 
 * @brief Module specific parameters. Present implementation of EMIF CSL
 *        doesn't have any module specific parameters.
 */
typedef struct CSL_EmifParam{
    /** Bit mask to be used for module specific parameters. The below
     *  declaration is just a place-holder for future implementation. Passed as 
     *  an argument to CSL_emifOpen().
     */
    CSL_BitMask16    flags;

} CSL_EmifParam;

/** @brief EMIF Async structure.
 *
 * All fields needed for EMIF Async configuration are present in this
 * structure.  The pointer to this structure is a member to the structure 
 * CSL_EmifMemType.  CSL_EmifAsync structure holds the value to be programmed
 * into CE Configuration register when ssel=0 (i.e., asynchronous). 
 */
typedef struct CSL_EmifAsync{
    /** Select Strobe Mode Enable */
    Uint8    selectStrobe;
    /** Select Extended Wait Mode Enable */
    Uint8    ewMode;
    /** Asynchronous Ready Input Enable */
//    Uint8    asyncRdyEn;
    /** Write Setup Width */
    Uint8    wSetup;
    /** Write Strobe Width */
    Uint8    wStrobe;
    /** Write Hold Width */
    Uint8    wHold;
    /** Read Setup Width */
    Uint8    rSetup;    
    /** Read Strobe Width */
    Uint8    rStrobe;  
    /** Read Hold Width */
    Uint8    rHold;
    /** Turn Around*/
    Uint8	 TA;
   /** Asynchronous Memory Size */
    Uint8    asize;   
} CSL_EmifAsync;

/** 
 * @brief EMIF Sync structure.
 *
 * All fields needed for EMIF Sync configuration are present in this structure.
 * The pointer to this structure is a member to the structure CSL_EmifMemType.
 * CSL_EmifSync structure holds the value to be programmed into CE
 * Configuration register when ssel=1 (i.e. synchronous). 
 */
typedef struct CSL_EmifSync{
    /** Read Byte Enable enable */
//    Uint8    readByteEn;
    /** Synchronous Memory Chip Enable Extend */
    Uint8    chipEnExt;       
    /** Synchronous Memory Read Enable Mode */
    Uint8    readEn;
    /** Synchronous Memory Write Latency */
    Uint8    w_ltncy;
    /** Synchronous Memory Read Latency */
    Uint8    r_ltncy;
    /** Synchronous Memory Device Size */
    Uint8    sbsize;  
} CSL_EmifSync;

/** 
 * @brief EMIF MemType structure.
 *
 * This structure defines the memory type of a particular chip enable. 
 * If a particular chip enable e.g., CE2 is to be configured as asynchronous
 * memory, ssel must be 0, sync must be NULL and async must be a pointer to 
 * CSL_EmifAsync structure with the proper values configured.
 */
typedef struct CSL_EmifMemType{
    /** Synchronous/asynchronous memory select. Asynchronous memory mode 
     *  when ssel is set to 0 and synchronous when ssel is 1.
     */
//    Uint8             ssel;
    /** Pointer to structure of asynchronous type. The pointer 
     *  value should be NULL if the chip select value is synchronous.
     */
    CSL_EmifAsync    *async;
    /** Pointer to structure of synchronous type. The pointer value 
     *  should be NULL if the chip select value is asynchronous.
     */
    CSL_EmifSync     *sync;
    /** Turn Around cycles  */
//    Uint8               turnArnd;

} CSL_EmifMemType;

/** 
 * @brief EMIF AsyncWait structure.
 *
 * This structure is a structure member of CSL_EmifHwSetup. It holds
 * the value to be programmed into Asynchronous Wait Cycle Configuration 
 * register. This is valid only for asynchronous (ssel=0) memories.
 */
typedef struct CSL_EmifAsyncWait{
    /** Asynchronous Ready Pin Polarity */
	CSL_EmifArdyPol    wp1;
    CSL_EmifArdyPol    wp0;
    CSL_EmifWaitSel		ce_wait[NUMCHIPENABLE];
    CSL_EmifMemoryType	ce_type[NUMCHIPENABLE];
    /** Maximum Extended Wait cycles */
    Uint8               maxExtWait;       

}CSL_EmifAsyncWait;

/** @brief This has all the fields required to configure EMIF at Power Up
 *  (After a Hardware Reset) or a Soft Reset
 *
 *  This structure is used to setup or obtain existing setup of
 *  EMIF using @a CSL_emifHwSetup() & @a CSL_emifGetHwSetup() functions
 *  respectively.
 */
typedef struct CSL_EmifHwSetup{
    /** Pointer to structure for configuring the Asynchronous Wait Cycle 
     *  Configuration register
     */
    CSL_EmifAsyncWait    *asyncWait;
    /** Array of CSL_EmifMemType* for   configuring the Chip enables
     *  as Async or Sync memory type.
     */
    CSL_EmifMemType      *ceCfg[NUMCHIPENABLE];
} CSL_EmifHwSetup;

/** @brief EMIF Module ID and Revision structure
 *
 *  This structure is used for querying the EMIF module ID and revision
 */
typedef struct CSL_EmifModIdRev{
    /** EMIF Module ID */
    Uint16    modId;
    /** EMIF Major Revision */
    Uint8     majRev;
    /** EMIF Minor Revision */
    Uint8     minRev;
} CSL_EmifModIdRev;

/** 
 * @brief EMIF config structure which is used in CSL_emifHwSetupRaw function.
 *        This is a structure of register values, rather than a structure of
 *        register field values like CSL_EmifHwSetup.
 */
typedef struct CSL_EmifConfig{
    /** Chip Enable2 Configuration register */
    volatile Uint32    A1CR;
    /** Chip Enable3 Configuration  register */
    volatile Uint32    A2CR;
    /** Chip Enable4 Configuration  register */
    volatile Uint32    A3CR;
    /** Chip Enable5 Configuration  register */
    volatile Uint32    A4CR;
    /** Asynchronous Wait Cycle Configuration  register */
    volatile Uint32    AWCCR;
    /** Interrupt Raw Register */
    volatile Uint32    IRR;
    /** Interrupt Masked Register */
    volatile Uint32    IMR;
    /** Interrupt Mask Set Register */
    volatile Uint32    IMSR;
    /** Interrupt Mask Clear Register */
    volatile Uint32    IMCR;
    /** Burst Priority Register */
//    volatile Uint32    BPRIO;
} CSL_EmifConfig;

/** @brief Enumeration for queries passed to @a CSL_emifGetHwStatus()
 *         This is used to get the status of different operations 
 */
typedef enum CSL_EmifHwStatusQuery{
        /**
         * @brief   Get the EMIFA module ID and revision numbers
         *
         * @param   (CSL_EmifaModIdRev *)
         */
    CSL_EMIF_QUERY_REV_ID = 0,
        /**
         * @brief   Get Asynchronous Timeout status ie enabled or not
         *
         * @param   (Uint8 *)
         */
    CSL_EMIF_QUERY_ASYNC_TIMEOUT_EN,
        /**
         * @brief   Get Asynchronous Timeout status in Interrupt Raw register
         *
         * @param   (Uint8 *)
         */   
    CSL_EMIF_QUERY_ASYNC_TIMEOUT_STATUS
        /**
         * @brief   Gets the EMIF EMIF Endianness
         *
         * @param   (Uint8 *)
         */       
//    CSL_EMIF_QUERY_ENDIAN
} CSL_EmifHwStatusQuery;

/** 
 * @brief Enumeration for commands passed to @a CSL_emifHwControl()
 *
 * This is used to select the commands to control the operations
 * existing setup of emif. The arguments to be passed with each
 * enumeration if any are specified next to the enumeration.
 */
typedef enum CSL_EmifHwControlCmd{
        /**
         * @brief   Clears Asyn Timeout interrupt
         *
         * @param   (None)
         */
    CSL_EMIF_CMD_ASYNC_TIMEOUT_CLEAR = 0,
        /**
         * @brief   Disables Asyn Timeout interrupt
         *
         * @param   (None)
         */
    CSL_EMIF_CMD_ASYNC_TIMEOUT_DISABLE,
        /**
         * @brief   Enables Asyn Timeout interrupt
         *
         * @param   (None)
         */
    CSL_EMIF_CMD_ASYNC_TIMEOUT_ENABLE
        /**
         * @brief   Number of memory transfers after which the EMIF
         *          momentarily raises the priority of old commands in the VBUSM 
         *          Command FIFO
         * @param   (Uint8 *)
         */          
//    CSL_EMIF_CMD_PRIO_RAISE
} CSL_EmifHwControlCmd;

/** @brief The defaults of EMIF Async Wait structure */
#define CSL_EMIF_ASYNCWAIT_DEFAULTS {\
    (CSL_EmifArdyPol)CSL_EMIF_ARDYPOL_HIGH, \
	(CSL_EmifArdyPol)CSL_EMIF_ARDYPOL_HIGH, \
	{CSL_EMIF_USE_WAIT0, CSL_EMIF_USE_WAIT0, CSL_EMIF_USE_WAIT0, CSL_EMIF_USE_WAIT0}, \
	{CSL_EMIF_MEMTYPE_ASYNC, CSL_EMIF_MEMTYPE_ASYNC, CSL_EMIF_MEMTYPE_ASYNC, CSL_EMIF_MEMTYPE_ASYNC}, \
    (Uint8)CSL_EMIF_ASYNCWAIT_MAXEXTWAIT_DEFAULT \
}

/** @brief The defaults of EMIFA CEConfig for Async structure */
#define CSL_EMIF_ASYNCCFG_DEFAULTS {\
    (Uint8)CSL_EMIF_ASYNCCFG_SELECTSTROBE_DEFAULT, \
    (Uint8)CSL_EMIF_ASYNCCFG_EWMODE_DEFAULT, \
    (Uint8)CSL_EMIF_ASYNCCFG_WSETUP_DEFAULT, \
    (Uint8)CSL_EMIF_ASYNCCFG_SSTROBE_DEFAULT, \
    (Uint8)CSL_EMIF_ASYNCCFG_WHOLD_DEFAULT,\
    (Uint8)CSL_EMIF_ASYNCCFG_RSETUP_DEFAULT, \
    (Uint8)CSL_EMIF_ASYNCCFG_RSTROBE_DEFAULT, \
    (Uint8)CSL_EMIF_ASYNCCFG_RHOLD_DEFAULT, \
	(Uint8)CSL_EMIF_ASYNCCFG_TA_DEFAULT, \
    (Uint8)CSL_EMIF_ASYNCCFG_ASIZE_DEFAULT \
}
    
/** @brief The defaults of EMIF CEConfig for Sync structure */
#define CSL_EMIF_SYNCCFG_DEFAULTS {\
    (Uint8)CSL_EMIF_SYNCCFG_CHIPENEXT_DEFAULT, \
    (Uint8)CSL_EMIF_SYNCCFG_READEN_DEFAULT, \
    (Uint8)CSL_EMIF_SYNCCFG_WLTNCY_DEFAULT, \
    (Uint8)CSL_EMIF_SYNCCFG_RLTNCY_DEFAULT, \
    (Uint8)CSL_EMIF_SYNCCFG_SBSIZE_DEFAULT \
}

/** @brief The default Config structure */
#define CSL_EMIF_CONFIG_DEFAULTS { \
    (Uint32)CSL_EMIF_AxCR_ASYNC_RESETVAL, \
    (Uint32)CSL_EMIF_AxCR_ASYNC_RESETVAL, \
    (Uint32)CSL_EMIF_AxCR_ASYNC_RESETVAL, \
    (Uint32)CSL_EMIF_AxCR_ASYNC_RESETVAL, \
    (Uint32)CSL_EMIF_AWCCR_RESETVAL, \
    (Uint32)CSL_EMIF_IRR_RESETVAL, \
    (Uint32)CSL_EMIF_IMR_RESETVAL, \
    (Uint32)CSL_EMIF_IMSR_RESETVAL, \
    (Uint32)CSL_EMIF_IMCR_RESETVAL, \
}

/******************************************************************************
  EMIFA global function declarations
 ******************************************************************************
 */

/** ============================================================================
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
 * =============================================================================
 */
CSL_Status  CSL_emifInit (
    CSL_EmifContext    *pContext
);

/** ============================================================================
 *   @n@b   CSL_emifaOpen
 *
 *   @b Description
 *   @n This function populates the peripheral data object for the EMIFA 
 *      instance and returns a handle to the instance.
 *      The open call sets up the data structures for the particular instance
 *      of EMIFA device. The device can be re-opened anytime after it has been
 *      normally closed if so required. The handle returned by this call is
 *      input as an essential argument for rest of the APIs described
 *      for this module.
 *
 *   @b Arguments
 *   @verbatim

            pEmifaObj        Pointer to the EMIFA instance object
 
            emifaNum         Instance of the EMIFA to be opened.
 
            pEmifaParam      Pointer to module specific parameters
 
            pStatus          Pointer for returning status of the function call

     @endverbatim
 *
 *   <b> Return Value </b>  
 *   @li                 CSL_EmifaHandle - Valid EMIFA instance handle will be 
 *                                         returned if status value is equal to 
 *                                         CSL_SOK.
 * 
 *   <b> Pre Condition </b>
 *   @n  @a CSL_emifaInit() must be called successfully.
 *
 *   <b> Post Condition </b>
 *   @n  EMIFA object structure is populated
 *
 *   @b Modifies
 *   @n    1. The status variable
 *   @n    2. EMIFA object structure
  *
 *   @b Example:
 *   @verbatim
         CSL_Status           status;
         CSL_EmifaObj         emifaObj;
         CSL_EmifaHandle      hEmifa;
 
         hI2c = CSL_emifaOpen (&emifaObj,
                               CSL_EMIFA,
                               NULL,
                               &status
                              );
     @endverbatim
 *
 * =============================================================================
 */
CSL_EmifHandle CSL_emifOpen (
    CSL_EmifObj      *hEmifObj,
    CSL_InstNum       emifNum,
    CSL_EmifParam    *pEmifParam,
    CSL_Status        *status
);

/** ============================================================================
 *  @n@b csl_emifaClose.c                                                       
 *                                                                             
 *   @b Description                                                            
 *   @n This function marks that CSL for the external memory interface instance 
 *      needsto be reopened before using any external memory interface CSL APIs.                                        
 *                                                                             
 *   @b Arguments                                                              
 *   @verbatim                                                                 
            hEmifa         Handle to the external memory interface instance         
     @endverbatim                                                              
 *                                                                             
 *   <b> Return Value </b>  CSL_Status                                         
 *   @li                 CSL_SOK            - external memory interface is 
 *                                            closed successfully                  
 *                                                                             
 *   @li                 CSL_ESYS_BADHANDLE - The handle passed is invalid  
 *                                                                             
 *   <b> Pre Condition </b>                                                    
 *   @n  Both @a CSL_emifaInit() and @a CSL_emifaOpen() must be called 
 *       successfully in order before calling @a CSL_emifaClose().
 *                                                                             
 *   <b> Post Condition </b>                                                   
 *   @n  1. The external memory interface CSL APIs cannot be called until the    
 *          external memory interface CSL is reopened again using 
 *          CSL_emifaOpen().
 *                                                                             
 *   @b Modifies                                                               
 *   @n  hEmifa structure                                                                 
 *                                                                             
 *   @b Example                                                                
 *   @verbatim                                                                 
            CSL_EmifaHandle   hEmifa;                                              
                                                                               
            ...                                                                
                                                                               
            CSL_emifaClose(hEmifa);                                               
                                                                               
            ...                                                                
     @endverbatim                                                              
 * ============================================================================= 
 */         
CSL_Status  CSL_emifClose (
    CSL_EmifHandle    hEmif
);

/** ============================================================================
 *  @n@b CSL_emifaGetBaseAddress
 *
 *  @b Description
 *  @n The getbaseaddress call will give the External memory interface current 
 *    instance base address
 *
 *  @b Arguments
 *  @verbatim      
            emifaNum         Specifies the instance of the EMIFA external memory
                             interface for which the base address is requested
 
            pEmifaParam      Module specific parameters.
 
            pBaseAddress     Pointer to the base address structure to return the
                             base address details.
    @endverbatim
 *
 *  <b> Return Value </b>  CSL_Status
 *  @li                    CSL_OK            Open call is successful
 *  @li                    CSL_ESYS_FAIL     The external memory interface 
 *                                           instance is not available.
 *
 *  <b> Pre Condition </b>
 *  @n  @a CSL_emifaInit() and CSL_emifaOpen () must be called successfully.
 *
 *  <b> Post Condition </b>
 *  @n  Base address structure is populated
 *
 *  @b Modifies
 *  @n    1. The status variable
 *
 *         2. Base address structure.
 *
 *  @b Example
 *  @verbatim
        CSL_Status          status;
        CSL_EmifaBaseAddress  baseAddress;

       ...
       status = CSL_emifaGetBaseAddress(CSL_EMIFA, NULL, &baseAddress);

    @endverbatim
 *
 * =============================================================================
 */
CSL_Status CSL_emifGetBaseAddress (
    CSL_InstNum             emifNum,
    CSL_EmifParam          *pEmifParam,
    CSL_EmifBaseAddress    *pBaseAddress
);

/** ============================================================================
 *  @n@b CSL_emifaHwSetupRaw
 *
 *   @b Description
 *   @n This function initializes the device registers with the register-values
 *      provided through the Config data structure.
 *
 *   @b Arguments
 *   @verbatim
            hEmifa        Handle to the EMIFA external memory interface instance
            
            config        Pointer to the config structure containing the
                          device register values
     @endverbatim
 *
 *   <b> Return Value </b>  CSL_Status
 *   @li                    CSL_SOK             - Configuration successful
 *   @li                    CSL_ESYS_BADHANDLE  - Invalid handle
 *   @li                    CSL_ESYS_INVPARAMS  - Configuration structure
 *                                                pointer is not properly
 *                                                initialized
 *
 *   <b> Pre Condition </b>
 *   @n  Both CSL_ emifaInit () and CSL_emifaOpen() must be called successfully 
 *       in order before calling this function
 *
 *   <b> Post Condition </b>
 *   @n  The registers of the specified EMIFA instance will be 
 *       setup according to the values passed through the Config structure
 *
 *   @b Modifies
 *   @n Hardware registers of the EMIFA 
 *    
 *   @b Example
 *   @verbatim
        CSL_EmifaHandle        hEmifa;
        CSL_EmifaConfig        config = CSL_EMIFA_CONFIG_DEFAULTS;
        CSL_Status             status;
        
        ..
        status = CSL_emifaHwSetupRaw(hEmifa, &config);       
        ...
            
     @endverbatim
 * =============================================================================
 */
CSL_Status  CSL_emifHwSetupRaw (
    CSL_EmifHandle    hEmif,
    CSL_EmifConfig    *config
);

/** ============================================================================
 * @n@b   CSL_emifaHwSetup
 *
 * @b Description
 * @n This function initializes the device registers with the appropriate values
 *  provided through the HwSetup data structure. For information passed through 
 *  the HwSetup data structure refer @a CSL_EmifaHwSetup.
 *  
 * @b Arguments
 * @verbatim      
            hEmifa          Pointer to the object that holds reference to the
                            instance of EMIFA requested after the call
 
            setup           Pointer to setup structure which contains the
                            information to program EMIFA to a useful state 
   @endverbatim
 *
 * <b> Return Value </b>  CSL_Status
 * @li                    CSL_OK             - configuration successful
 * @li                    CSL_ESYS_FAIL      - The external memory interface 
 *                                              instance is not available.
 * @li                    CSL_ESYS_INVPARAMS - Parameters are not valid    
 * @li                    CSL_ESYS_BADHANDLE - Handle is not valid    
 *
 * <b> Pre Condition </b>
 * @n  Both @a CSL_emifaInit() and @a CSL_emifaOpen() must be called
 *     successfully in order before calling this function. The user has to 
 *     allocate space for & fill in the main setup structure appropriately
 *     before calling this function. 
 *
 * <b> Post Condition </b>
 * @n  EMIFA registers are configured according to the hardware setup parameters
 *
 *  @b Modifies
 *  @n EMIFA registers  
 *
 * @b Example:
 * @verbatim
     CSL_EmifaHandle hEmifa;          
     CSL_EmifaAsync asyncMem = CSL_EMIFA_ASYNCCFG_DEFAULTS;
     CSL_EmifaAsyncWait asyncWait = CSL_EMIFA_ASYNCWAIT_DEFAULTS; 
     CSL_EmifaMemType value;
     CSL_EmifaHwSetup hwSetup ;

     value.ssel = 0;
     value.async = &asyncMem;
     value.sync = NULL;      
     hwSetup.asyncWait = &asyncMem;
     hwSetup.cefg [0] = &value;
     hwSetup.ceCfg [1] = NULL;
     hwSetup.ceCfg [2] = NULL;
     hwSetup.ceCfg [3] = NULL;
     
     CSL_emifaHwSetup(hEmifa, &hwSetup);  
     
   @endverbatim
 *
 * =============================================================================
 */
CSL_Status  CSL_emifHwSetup (
    CSL_EmifHandle     hEmif,
    CSL_EmifHwSetup    *setup
);

/** ============================================================================
 * @n@b   CSL_emifaGetHwSetup
 *
 * @b Description
 * @n This function gets the current setup of the EMIFA. The status is
 *    returned through @a CSL_EmifaHwSetup. The obtaining of status
 *    is the reverse operation of @a CSL_emifaHwSetup() function.
 *
 * @b Arguments
 * @verbatim      
            hEmifa          Pointer to the object that holds reference to the
                            instance of EMIFA requested after the call
 
            setup           Pointer to setup structure which contains the
                            information to program EMIFA to a useful state 
   @endverbatim
 *
 * <b> Return Value </b>  CSL_Status
 * @li                    CSL_OK             - Hardware status call is 
 *                                               successful
 * @li                    CSL_ESYS_FAIL      - The external memory interface 
 *                                              instance is not available.
 * @li                    CSL_ESYS_INVPARAMS - Parameters are not valid    
 * @li                    CSL_ESYS_BADHANDLE - Handle is not valid    
 *
 * <b> Pre Condition </b>
 * @n  Both @a CSL_emifaInit() and @a CSL_emifaOpen() must be called 
 *     successfully in order before calling @a CSL_emifaGetHwSetup().
 *
 * <b> Post Condition </b>
 * @n  None
 *
 * @b Modifies
 * @n Second parameter setup
 *
 * @b Example:
 * @verbatim
      CSL_EmifaHandle hEmifa;
      CSL_Status status;
      CSL_EmifaHwSetup hwSetup;      
      CSL_EmifaAsync asyncMem;
      CSL_EmifaMemType value;
      CSL_EmifaAsyncWait asyncWait;

      value.ssel = 0;
      value.async = &asyncMem;
      value.sync = NULL;      
      hwSetup.asyncWait = &asyncWait;
      hwSetup.ceCfg [0] = &value;
      hwSetup.ceCfg [1] = NULL;
      hwSetup.ceCfg [2] = NULL;
      hwSetup.ceCfg [3] = NULL;   
      
      status = CSL_emifaGetHwSetup(hEmifa, &hwSetup);

   @endverbatim
 *
 * =============================================================================
 */
CSL_Status  CSL_emifGetHwSetup (
    CSL_EmifHandle     hEmif,
    CSL_EmifHwSetup    *setup
);

/** ============================================================================
 * @n@b   CSL_emifaHwControl
 *
 * @b Description
 * @n Control operations for the EMIFA.  For a particular control operation, the
 *  pointer to the corresponding data type needs to be passed as argument 
 *  HwControl function Call.  All the arguments (structure elements included) 
 *  passed to  the HwControl function are inputs.  For the list of commands 
 *  supported and argument type that can be @a void* casted & passed with a 
 *  particular command refer to @a CSL_EmifaHwControlCmd.
 *
 * @b Arguments
 * @verbatim      
            hEmifa          Pointer to the object that holds reference to the
                            instance of EMIFA requested after the call
 
            cmd             The command to this API indicates the action to be 
                            taken
            arg             An optional argument @a void* casted
   @endverbatim
 *
 * <b> Return Value </b>  CSL_Status
 * @li                    CSL_OK             - Hardware control call is 
 *                                             successful
 * @li                    CSL_ESYS_INVCMD    - command is not valid    
 * @li                    CSL_ESYS_BADHANDLE - Handle is not valid    
 *
 * <b> Pre Condition </b>
 *  @n  Both @a CSL_emifaInit() and @a CSL_emifaOpen() must be called 
 *  successfully in order before calling @a CSL_emifaHwControl(). 
 *  For the argument type that can be @a void* casted & passed with a 
 *  particular command refer to @a CSL_EmifaHwControlCmd
 *
 * <b> Post Condition </b>
 * @n  EMIFA registers are configured according to the command passed
 *
 *  @b Modifies
 *  @n EMIFA registers  
 *
 * @b Example:
 * @verbatim
       CSL_EmifaHandle hEmifa;
       CSL_Status status;
       Uint8 * command;
       ...
       status = CSL_emifaHwControl(hEmifa,
                                   CSL_EMIFA_CMD_PRIO_RAISE,
                                   &command);
   @endverbatim
 *
 * =============================================================================
 */
CSL_Status  CSL_emifHwControl (
    CSL_EmifHandle          hEmif,
    CSL_EmifHwControlCmd    cmd,
    void                     *arg
);

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
            hEmifa          Pointer to the object that holds reference to the
                            instance of EMIFA requested after the call
 
            query           The query to this API which indicates the status 
                            to be returned
            response        Placeholder to return the status. @a void* casted
   @endverbatim
 *
 * <b> Return Value </b>  CSL_Status
 * @li                    CSL_OK             - successful on getting hardware 
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
      CSL_EmifaHandle hEmifa;
      CSL_Status status;
      Uint8  *response;
       ...
      status = CSL_emifaGetHwStatus(hEmifa,
                                    CSL_EMIFA_QUERY_ENDIAN,
                                    &response);
   @endverbatim
 *
 *
 * =============================================================================
 */
CSL_Status  CSL_emifGetHwStatus (
    CSL_EmifHandle           hEmif,
    CSL_EmifHwStatusQuery    query,
    void                      *response
);

#ifdef __cplusplus
}
#endif

#endif

