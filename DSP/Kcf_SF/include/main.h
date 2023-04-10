/**
 * @file main.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _MAIN_H
#define _MAIN_H

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#include <xdc/runtime/System.h>
#include <xdc/runtime/Memory.h>
#include <xdc/runtime/Error.h>
#include <xdc/cfg/global.h>
#include <ti/sysbios/BIOS.h>
#include <ti/sysbios/family/c64p/Hwi.h>
#include <ti/sysbios/family/c66/Cache.h>

#define CELL_SIZE (4)
#define FFT_POINT (32)

#define SIMULATION_MODE (0)
#define SIM_FRAME_WIDTH (640)
#define SIM_FRAME_HEIGHT (512)
#define SIM_FRAME_NUM (10)

#define __DUBUG (0)

#define HW_FHOG_MODE (1)

typedef struct
{
    uint32_t frameNum;
    uint32_t frameTransSize;
    uint32_t width;
    uint32_t height;
    uint32_t roiX;
    uint32_t roiY;
    uint32_t roiW;
    uint32_t roiH;
} SeqInfo;

typedef struct
{
    uint16_t x;
    uint16_t y;
    uint16_t width;
    uint16_t height;
} SeqResult;

typedef enum FFT2dType
{
	FFT2d_R2R = 0,
	FFT2d_R2C,
	FFT2d_R2C_N,
	IFFT2d_C2R
} FFT2dType;

typedef struct FFTCmd{
	Queue_Elem _elem;
	FFT2dType eType;
	float *pSrc;
	float *pDst;
	int nWidth;
	int nHeight;
} FFTCmd;

#endif
