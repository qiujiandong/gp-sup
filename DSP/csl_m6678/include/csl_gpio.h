/* ============================================================================
 * Copyright (c) Texas Instruments Inc 2002, 2003, 2004, 2005
 *
 * Use of this software is controlled by the terms and conditions found
 * in the license agreement under which this software has been supplied
 * provided
 * ============================================================================
*/

/** ===========================================================================
 *  @file csl_gpio.h
 *
 *  @path $(CSLPATH)\inc
 *
 *  @desc GPIO functional layer APIs header file. The different enumerations,
 *        structure definitions and function declarations
 * ============================================================================
 * @mainpage GPIO CSL 3.x
 *
 * @section Introduction
 *
 * @subsection xxx Purpose and Scope
 * The purpose of this document is to identify a set of common CSL APIs for
 * the GPIO module across various devices. The CSL developer is expected to
 * refer to this document while designing APIs for these modules. Some of the
 * listed APIs may not be applicable to a given GPIO module. While other cases
 * this list of APIs may not be sufficient to cover all the features of a
 * particular GPIO Module.The CSL developer should use his discretion designing
 * new APIs or extending the existing ones to cover these.
 *
 * @subsection aaa Terms and Abbreviations
 *   -# CSL:  Chip Support Library
 *   -# API:  Application Programmer Interface
 *
 * @subsection References
 *    -# CSL-001-DES, CSL 3.x Design Specification DocumentVersion 1.02
 *=============================================================================
 */

/* ============================================================================
 * Revision History
 * ===============
 *  11-Jun-2004 PGR file created
 *  04-sep-2004 Nsr - Updated CSL_GpioObj and added CSL_GpioBaseAddress,
 *                    CSL_GpioParam, SL_GpioContext,  CSL_GpioConfig structures.
 *                  - Updated comments for H/W control cmd and status query
 *                    enums.
 *                  - Added prototypes for CSL_gpioGetBaseAdddress and
 *                    CSL_gpioHwSetupRaw.
 *                  - Changed prototypes of CSL_gpioInit, CSL_gpioOpen.
 *                  - Updated respective comments along with that of
 *                    CSL_gpioClose.
 *  11-Oct-2004 Nsr - Removed the extern keyword before function declaration and
 *                  - Changed this file according to review.
 *  22-Feb-2005 Nsr - Added control command CSL_GPIO_CMD_GET_BIT according to
 *                     TI issue PSG00000310.
 *  28-Jul-2005 PSK - Updated the CSL source to support only one BANK
 *
 *  11-Jan-2006 NG  - Added CSL_GPIO_CMD_SET_OUT_BIT Control Command
 *  06-Mar-2006 ds  - Rename CSL_GPIO_CMD_SET_OUT_BIT to
 *                    CSL_GPIO_CMD_ENABLE_DISABLE_OUTBIT
 *                  - Moved CSL_GpioPinNum Enumeration from the cslr_gpio.h
 * ============================================================================
 */

#ifndef _CSL_GPIO_H_
#define _CSL_GPIO_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <soc.h>
#include <csl.h>
#include <cslr_gpio.h>

/**< Invalid argument */
#define CSL_EGPIO_INVPARAM CSL_EGPIO_FIRST

/*****************************************************************************\
          GPIO global typedef declarations
\*****************************************************************************/

#define hGpio ((CSL_GpioRegsOvly)CSL_GPIO_REGS)

/**
 * @brief Config structure of GPIO. This is used to configure GPIO
 * using CSL_HwSetupRaw function
 */
typedef struct  {
    /** GPIO Interrupt Per-Bank Enable Register */
    Uint32 BINTEN;

    /** GPIO Direction Register */
    Uint32 DIR;

    /** GPIO Output Data Register */
    Uint32 OUT_DATA;

    /** GPIO Set Data Register */
    Uint32 SET_DATA;

    /** GPIO Clear Data Register */
    Uint32 CLR_DATA;

    /** GPIO Set Rising Edge Interrupt Register */
    Uint32 SET_RIS_TRIG;

    /** GPIO Clear Rising Edge Interrupt Register */
    Uint32 CLR_RIS_TRIG;

    /** GPIO Set Falling Edge Interrupt Register */
    Uint32 SET_FAL_TRIG;

    /** GPIO Clear Falling Edge Interrupt Register */
    Uint32 CLR_FAL_TRIG;
} CSL_GpioConfig;


/** @brief Default Values for GPIO Config structure */
#define CSL_GPIO_CONFIG_DEFAULTS {      \
    CSL_GPIO_BINTEN_RESETVAL ,          \
    CSL_GPIO_DIR_RESETVAL,              \
    CSL_GPIO_OUT_DATA_RESETVAL,         \
    CSL_GPIO_SET_DATA_RESETVAL,         \
    CSL_GPIO_CLR_DATA_RESETVAL,         \
    CSL_GPIO_SET_RIS_TRIG_RESETVAL,     \
    CSL_GPIO_CLR_RIS_TRIG_RESETVAL,     \
    CSL_GPIO_SET_FAL_TRIG_RESETVAL,     \
    CSL_GPIO_CLR_FAL_TRIG_RESETVAL,     \
}

/** Enumeration used for specifying the GPIO pin numbers */
typedef enum {
    /** Gpio pin 0 */
    CSL_GPIO_PIN0,
    /** Gpio pin 1 */
    CSL_GPIO_PIN1,
    /** Gpio pin 2 */
    CSL_GPIO_PIN2,
    /** Gpio pin 3 */
    CSL_GPIO_PIN3,
    /** Gpio pin 4 */
    CSL_GPIO_PIN4,
    /** Gpio pin 5 */
    CSL_GPIO_PIN5,
    /** Gpio pin 6 */
    CSL_GPIO_PIN6,
    /** Gpio pin 7 */
    CSL_GPIO_PIN7,
    /** Gpio pin 8 */
    CSL_GPIO_PIN8,
    /** Gpio pin 0 */
    CSL_GPIO_PIN9,
    /** Gpio pin 10 */
    CSL_GPIO_PIN10,
    /** Gpio pin 11 */
    CSL_GPIO_PIN11,
    /** Gpio pin 12 */
    CSL_GPIO_PIN12,
    /** Gpio pin 13 */
    CSL_GPIO_PIN13,
    /** Gpio pin 14 */
    CSL_GPIO_PIN14,
    /** Gpio pin 15 */
    CSL_GPIO_PIN15
} CSL_GpioPinNum;

/**\brief  Enums for configuring GPIO pin direction
 *
 */
typedef enum {
    CSL_GPIO_DIR_OUTPUT,/**<<b>: Output pin</b>*/
    CSL_GPIO_DIR_INPUT  /**<<b>: Input pin</b>*/
} CSL_GpioDirection;


/** \brief  Enums for configuring GPIO pin edge detection
 *
 */
typedef enum {
    /**<<b>: No edge detection </b>*/
    CSL_GPIO_TRIG_CLEAR_EDGE,

    /**<<b>: Rising edge detection </b>*/
    CSL_GPIO_TRIG_RISING_EDGE,

    /**<<b>: Falling edge detection </b>*/
    CSL_GPIO_TRIG_FALLING_EDGE,

    /**<<b>: Dual edge detection </b>*/
    CSL_GPIO_TRIG_DUAL_EDGE
} CSL_GpioTriggerType;

typedef struct {
    /**< Pin number for GPIO bank */
    CSL_GpioPinNum pinNum;

    /**< Direction for GPIO Pin */
    CSL_GpioDirection direction;

    /**< GPIO pin edge detection */
    CSL_GpioTriggerType trigger;
} CSL_GpioPinConfig;

static inline
void CSL_gpioBankIntEnable (
)
{
    CSL_FINSR(hGpio->BINTEN, 0, 0, TRUE);
    return;
}

static inline
void CSL_gpioBankIntDisable (
)
{
    CSL_FINSR(hGpio->BINTEN, 0, 0, FALSE);
    return;
}

static inline
void CSL_gpioSetDir (
    CSL_GpioPinNum pinNum,
    CSL_GpioDirection dir
)
{
    CSL_FINSR(hGpio->DIR, pinNum, pinNum, dir);
    return;
}

static inline
void CSL_gpioSetTriggerType (
    CSL_GpioPinNum pinNum,
    CSL_GpioTriggerType trigger
)
{
    if (trigger & CSL_GPIO_TRIG_RISING_EDGE) {
        CSL_FINSR(hGpio->SET_RIS_TRIG, pinNum, pinNum, TRUE);
    }
    else {
        CSL_FINSR(hGpio->CLR_RIS_TRIG, pinNum, pinNum, TRUE);
    }

    if (trigger & CSL_GPIO_TRIG_FALLING_EDGE) {
        CSL_FINSR(hGpio->SET_FAL_TRIG, pinNum, pinNum, TRUE);
    }
    else {
        CSL_FINSR (hGpio->CLR_FAL_TRIG, pinNum, pinNum, TRUE);
    }
    return;
}

static inline
void CSL_gpioConfigBit (
    CSL_GpioPinConfig *config
)
{
    CSL_GpioPinNum pinNum;
    CSL_GpioTriggerType trigger;

    pinNum = config->pinNum;
    trigger = config->trigger;

    CSL_FINSR(hGpio->DIR, pinNum, pinNum, config->direction);

    if (trigger & CSL_GPIO_TRIG_RISING_EDGE) {
        CSL_FINSR(hGpio->SET_RIS_TRIG, pinNum, pinNum, TRUE);
    }
    else {
        CSL_FINSR(hGpio->CLR_RIS_TRIG, pinNum, pinNum, TRUE);
    }

    if (trigger & CSL_GPIO_TRIG_FALLING_EDGE) {
        CSL_FINSR(hGpio->SET_FAL_TRIG, pinNum, pinNum, TRUE);
    }
    else {
        CSL_FINSR (hGpio->CLR_FAL_TRIG, pinNum, pinNum, TRUE);
    }
    return;
}

static inline
void CSL_gpioSetBit (
    CSL_GpioPinNum pinNum
)
{
    CSL_FINSR(hGpio->SET_DATA, pinNum, pinNum, TRUE);
    return;
}

static inline
void CSL_gpioClearBit (
    CSL_GpioPinNum pinNum
)
{
    CSL_FINSR(hGpio->CLR_DATA, pinNum, pinNum, TRUE);
    return;
}

static inline
Bool CSL_gpioGetInputBit (
    CSL_GpioPinNum  pinNum
)
{
    return (Bool)CSL_FEXTR(hGpio->IN_DATA, pinNum, pinNum);
}

static inline
Bool CSL_gpioGetOutDrvState (
    CSL_GpioPinNum  pinNum
)
{
    return (Bool) CSL_FEXTR(hGpio->OUT_DATA, pinNum, pinNum);
}

static inline
Bool CSL_gpioGetBintenStat (
)
{
    return (Bool) CSL_FEXTR(hGpio->BINTEN, 0, 0);
}

#ifdef __cplusplus
}
#endif

#endif /*_CSL_GPIO_H_*/
