/**
 * @file HwFhogLLD.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-08
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _HW_FHOG_LLD_H_
#define _HW_FHOG_LLD_H_

#include "Emif2Axil.h"

typedef struct
{
    Uint32 MB_CTRL; // 0x00
    Uint32 RD_WR_IRQ; // 0x04
    Uint32 RSVD0; // 0x08
    Uint32 SOFT_TRIG; // 0x0C

    Uint32 RSVD1; // 0x10
    Uint32 RD_CFG1; // 0x14
    Uint32 RD_CFG2; // 0x18
    Uint32 RD_CFG3; // 0x1C

    Uint32 RD_CFG4; // 0x20
    Uint32 RD_CFG5; // 0x24
    Uint32 WR_CFG1; // 0x28
    Uint32 WR_CFG2; // 0x2C

    Uint32 RESULT_ADDR; // 0x30 align to 4096
    Uint32 RESULT_SIZE; // 0x34
    Uint32 WR_CFG5; // 0x38
    Uint32 FHOG_START; // 0x3C

    Uint32 FHOG_SIZE;  // 0x40
    Uint32 ABS_ADDR; // 0x44 source address in DDR
    Uint32 STRIDE; // 0x48
    Uint32 SCALEH; //0x4C

    Uint32 SCALEW; //0x50
    Uint32 SCALEN; //0x54
} HwFhogRegs;

typedef HwFhogRegs *HwFhogHandle;

typedef struct
{
	uint32_t nSize;
	uint32_t nAbsAddr;
	uint32_t nStride;
	uint32_t nScaleH;
	uint32_t nScaleW;
	uint32_t nScaleN;
} HwFhogParam;

static inline HwFhogHandle getHwFhogHandle(Uint32 offset){
    return (HwFhogHandle)offset;
}

static inline void hwFhogInit(
    HwFhogHandle hHwFhog,
    Uint32 resultAddr,
    Uint32 resultSize)
{
    writeReg(&(hHwFhog->RESULT_ADDR), resultAddr);
    writeReg(&(hHwFhog->RESULT_SIZE), resultSize);
}

static inline int setupHwFhog(HwFhogHandle hHwFhog, const HwFhogParam *pParam){
    if(hHwFhog == 0 ){
        return -1;
    }
    writeReg(&(hHwFhog->FHOG_SIZE), pParam->nSize);
    writeReg(&(hHwFhog->ABS_ADDR), pParam->nAbsAddr);
    writeReg(&(hHwFhog->STRIDE), pParam->nStride);
    writeReg(&(hHwFhog->SCALEH), pParam->nScaleH);
    writeReg(&(hHwFhog->SCALEW), pParam->nScaleW);
    writeReg(&(hHwFhog->SCALEN), pParam->nScaleN);
    writeReg(&(hHwFhog->FHOG_START), 1);
    return 0;
}

#endif
