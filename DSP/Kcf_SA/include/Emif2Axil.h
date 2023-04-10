/**
 * @file Emif2Axil.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-02-27
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _EMIF2AXIL_H_
#define _EMIF2AXIL_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <csl_gpio.h>

// NOTE: check AXIL_SPACE_SIZE
#define AXIL_SPACE_SIZE (0x40000)

static inline Bool isRdFifoEmpty(){
	return CSL_gpioGetInputBit(CSL_GPIO_PIN4);
}

static inline Bool isAddrFifoFull(){
	return CSL_gpioGetInputBit(CSL_GPIO_PIN5);
}

static inline Bool isBusy(){
	return CSL_gpioGetInputBit(CSL_GPIO_PIN6);
}

static inline void writeReg(volatile Uint32 *addr, Uint32 val){
	while(CSL_gpioGetInputBit(CSL_GPIO_PIN5));
	*(addr) = val;
}

static inline Uint32 readReg(volatile Uint32 *addr){
	while(CSL_gpioGetInputBit(CSL_GPIO_PIN5));
	*((Uint32 *)(((Uint32)addr) + AXIL_SPACE_SIZE)) = 0;
	while(CSL_gpioGetInputBit(CSL_GPIO_PIN4));
	return *(addr);
}

void gpioConfig();
void emifConfig(int nEclkRatio);

#ifdef __cplusplus
}
#endif

#endif
