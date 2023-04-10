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
#define SRIO_DBTX_NWRXDONE (0x2222)

#define SRIO_DBRX_STARTREQ (0x0000)
#define SRIO_DBRX_STARTH2C (0x1111)
#define SRIO_DBRX_STARTC2H (0x2222)
#define SRIO_DBRX_PROCDONE (0x3333)

#define BASE_SIZE (256)
#define U32_DATA_CNT (1<<21)
#define TEST_TIMES (16)
#define RESULT_SIZE (256)

static inline uint32_t upToBoundary(uint32_t size, uint32_t boundary)
{
    return ((size + boundary - 1) / boundary) * boundary;
}

#endif
