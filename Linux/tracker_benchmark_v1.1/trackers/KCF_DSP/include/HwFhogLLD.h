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

#include <stdint.h>

typedef struct
{
    volatile uint32_t MB_CTRL; // 0x00
    volatile uint32_t RD_WR_IRQ; // 0x04
    volatile uint32_t RSVD0; // 0x08
    volatile uint32_t SOFT_TRIG; // 0x0C

    volatile uint32_t RSVD1; // 0x10
    volatile uint32_t RD_CFG1; // 0x14
    volatile uint32_t RD_CFG2; // 0x18
    volatile uint32_t RD_CFG3; // 0x1C

    volatile uint32_t RD_CFG4; // 0x20
    volatile uint32_t RD_CFG5; // 0x24
    volatile uint32_t WR_CFG1; // 0x28
    volatile uint32_t WR_CFG2; // 0x2C

    volatile uint32_t RESULT_ADDR; // 0x30 align to 4096
    volatile uint32_t RESULT_SIZE; // 0x34
    volatile uint32_t WR_CFG5; // 0x38
    volatile uint32_t FHOG_START; // 0x3C

    volatile uint32_t FHOG_SIZE;  // 0x40
    volatile uint32_t ABS_ADDR; // 0x44 source address in DDR
    volatile uint32_t STRIDE; // 0x48
    volatile uint32_t SCALEH; //0x4C

    volatile uint32_t SCALEW; //0x50
    volatile uint32_t SCALEN; //0x54
} HwFhogRegs;

typedef HwFhogRegs *HwFhogHandle;

#endif
