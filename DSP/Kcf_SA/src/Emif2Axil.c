/**
 * @file Emif2Axil.c
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-02-27
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include <csl_emif.h>
#include <csl_psc.h>
#include <csl_pllc.h>

#include "Emif2Axil.h"

void gpioConfig()
{
	CSL_GpioPinConfig config;

	config.trigger = CSL_GPIO_TRIG_RISING_EDGE;
	config.direction = CSL_GPIO_DIR_OUTPUT;

	//enable UART Receive
	config.pinNum = CSL_GPIO_PIN0;
	CSL_gpioConfigBit(&config);
	CSL_gpioClearBit(config.pinNum);

	//enable UART Transmit
	config.pinNum = CSL_GPIO_PIN1;
	CSL_gpioConfigBit(&config);
	CSL_gpioSetBit(config.pinNum);

	//disable NAND Flash Write Protect
	config.pinNum = CSL_GPIO_PIN2;
	CSL_gpioConfigBit(&config);
	CSL_gpioSetBit(config.pinNum);

	//diable NOR Flash Write Protect
	config.pinNum = CSL_GPIO_PIN3;
	CSL_gpioConfigBit(&config);
	CSL_gpioSetBit(config.pinNum);

	//LED
	config.pinNum = CSL_GPIO_PIN14;
	CSL_gpioConfigBit(&config);
	CSL_gpioSetBit(config.pinNum);

	//connect with FPGA2
	config.direction = CSL_GPIO_DIR_INPUT;
	// RD fifo empty
	config.pinNum = CSL_GPIO_PIN4;
	CSL_gpioConfigBit(&config);
	// addr fifo full
	config.pinNum = CSL_GPIO_PIN5;
	CSL_gpioConfigBit(&config);
	// busy
	config.pinNum = CSL_GPIO_PIN6;
	CSL_gpioConfigBit(&config);
	
	config.pinNum = CSL_GPIO_PIN7;
	CSL_gpioConfigBit(&config);

	// result done
	config.pinNum = CSL_GPIO_PIN8;
	CSL_gpioConfigBit(&config);
	// HwFhog data read done
	config.pinNum = CSL_GPIO_PIN9;
	CSL_gpioConfigBit(&config);

	config.pinNum = CSL_GPIO_PIN10;
	CSL_gpioConfigBit(&config);
	config.pinNum = CSL_GPIO_PIN11;
	CSL_gpioConfigBit(&config);
	config.pinNum = CSL_GPIO_PIN12;
	CSL_gpioConfigBit(&config);
	config.pinNum = CSL_GPIO_PIN13;
	CSL_gpioConfigBit(&config);
	//key
	config.pinNum = CSL_GPIO_PIN15;
	CSL_gpioConfigBit(&config);

	// enable interrupt
	CSL_gpioBankIntEnable();
}

void emifConfig(int nEclkRatio)
{
    CSL_EmifHandle hEmif;
	CSL_EmifObj emifObj;
    CSL_Status status;
    CSL_EmifHwSetup hwSetup;

	// CSL_EmifMemType asyncVal;
    CSL_EmifAsyncWait asyncWait = CSL_EMIF_ASYNCWAIT_DEFAULTS;
    // CSL_EmifAsync asyncMem = CSL_EMIF_ASYNCCFG_DEFAULTS;
    CSL_EmifMemType syncVal;
    CSL_EmifSync syncMem = CSL_EMIF_SYNCCFG_DEFAULTS;

    CSL_pscModuleEnable(PSC_MD_EMIF, PSC_PWR_PERI);
    CSL_pllcEclkOutConfig(nEclkRatio);

    syncVal.async = NULL;
    syncVal.sync = &syncMem;

    asyncWait.ce_type[3] = CSL_EMIF_MEMTYPE_SYNC;

    syncMem.readEn = 0;
    syncMem.chipEnExt = 0;
    syncMem.r_ltncy = 0;
    syncMem.w_ltncy = 0;
    syncMem.sbsize = 2; // 32 bit data

    hwSetup.asyncWait = &asyncWait;
    hwSetup.ceCfg[0] = NULL;	//CE0
    hwSetup.ceCfg[1] = NULL; 		//CE1
    hwSetup.ceCfg[2] = NULL;
    hwSetup.ceCfg[3] = &syncVal;

	CSL_emifInit(NULL);
	hEmif = CSL_emifOpen(&emifObj, CSL_EMIF_32, NULL, &status);
	CSL_emifHwSetup(hEmif, &hwSetup);
}
