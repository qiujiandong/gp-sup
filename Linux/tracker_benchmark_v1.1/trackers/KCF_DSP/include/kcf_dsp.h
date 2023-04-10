/**
 * @file kcf_dsp.h
 * @author your name (you@domain.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-03
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _KCF_DSP_H_
#define _KCF_DSP_H_

#include <cstdint>

#define FILE_NAME_MAX_LEN (100)
#define MAX_FRAME_NUM (4096) // actural is max(OTB100): 3872, max(UAV123): 3085
#define MAX_FRAME_WIDTH (1280)
#define MAX_FRAME_HEIGHT (720) // max size is 900kB

#define SRIO_DBTX_STARTREQ (0x0000)

#define SRIO_DBRX_STARTREQ (0x0000)
#define SRIO_DBRX_STARTH2C (0x1111)
#define SRIO_DBRX_STARTC2H (0x2222)
#define SRIO_DBRX_PROCDONE (0x3333)

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
    int16_t x;
    int16_t y;
    int16_t width;
    int16_t height;
} SeqResult;

static inline uint32_t upToBoundary(uint32_t size, uint32_t boundary)
{
    return ((size + boundary - 1) / boundary) * boundary;
}

#endif
