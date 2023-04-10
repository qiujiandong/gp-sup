/*
 * cslr_fft.h
 *
 *  Created on: 2022.1.14
 *      Author: jayden
 */

#ifndef CSLR_FFT_H_
#define CSLR_FFT_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <cslr.h>
#include <tistdtypes.h>

typedef struct
{
    volatile Uint32 SRC_RADDR;
    volatile Uint32 SRC_IADDR;
    volatile Uint32 DST_RADDR;
    volatile Uint32 DST_IADDR;
    // 0x10
    volatile Uint32 MID_ADDR1;
    volatile Uint32 MID_ADDR2;
    volatile Uint32 PROC_NUM;
    volatile Uint32 CFG;
    // 0x20
    volatile Uint32 CTL;
    volatile Uint32 STATUS;
    volatile Uint32 RESULT;
    volatile Uint32 MT_SIZE;
    // 0x30
    volatile Uint32 MT_ROW_SIZE;
    volatile Uint32 MT_COL_SIZE;
    volatile Uint32 AXI_PRI;
    volatile Uint32 PROC_CYCLE;
}CSL_FftRegs;

typedef volatile CSL_FftRegs *CSL_FftRegsOvly;

#define CSL_FFT_CFG_INPUT_FORMAT_MASK           (0x80000000)
#define CSL_FFT_CFG_INPUT_FORMAT_SHIFT          (0x0000001F)
#define CSL_FFT_CFG_INPUT_FORMAT_FLOAT          (0x00000000u)
#define CSL_FFT_CFG_INPUT_FORMAT_FIXED          (0x00000001u)

#define CSL_FFT_CFG_OUTPUT_FORMAT_MASK           (0x40000000)
#define CSL_FFT_CFG_OUTPUT_FORMAT_SHIFT          (0x0000001E)
#define CSL_FFT_CFG_OUTPUT_FORMAT_FLOAT          (0x00000000u)
#define CSL_FFT_CFG_OUTPUT_FORMAT_FIXED          (0x00000001u)

#define CSL_FFT_CFG_DATA_FORMAT_MASK           (0x20000000)
#define CSL_FFT_CFG_DATA_FORMAT_SHIFT          (0x0000001D)
#define CSL_FFT_CFG_DATA_FORMAT_COMPLEX        (0x00000000u)
#define CSL_FFT_CFG_DATA_FORMAT_REAL           (0x00000001u)

#define CSL_FFT_CFG_DATA_ORGNIZE_MASK           (0x10000000)
#define CSL_FFT_CFG_DATA_ORGNIZE_SHIFT          (0x0000001C)
#define CSL_FFT_CFG_DATA_ORGNIZE_CROSS           (0x00000000u)
#define CSL_FFT_CFG_DATA_ORGNIZE_SPLIT           (0x00000001u)

#define CSL_FFT_CFG_MODE_MASK           (0x08000000)
#define CSL_FFT_CFG_MODE_SHIFT          (0x0000001B)
#define CSL_FFT_CFG_MODE_FFT           (0x00000000u)
#define CSL_FFT_CFG_MODE_IFFT           (0x00000001u)

#define CSL_FFT_CFG_SIZE_MASK           (0x07C00000)
#define CSL_FFT_CFG_SIZE_SHIFT          (0x00000016)

#define CSL_FFT_CFG_INPUT_PP_MASK           (0x003E0000)
#define CSL_FFT_CFG_INPUT_PP_SHIFT          (0x00000011)

#define CSL_FFT_CFG_OUTPUT_PP_MASK           (0x0001F000)
#define CSL_FFT_CFG_OUTPUT_PP_SHIFT          (0x0000000C)

#define CSL_FFT_CFG_MT_MODE_MASK           (0x00000C00)
#define CSL_FFT_CFG_MT_MODE_SHIFT          (0x0000000A)
#define CSL_FFT_CFG_MT_MODE_C2C          (0x00000000u)
#define CSL_FFT_CFG_MT_MODE_S2C          (0x00000001u)
#define CSL_FFT_CFG_MT_MODE_C2S          (0x00000002u)
#define CSL_FFT_CFG_MT_MODE_S2S          (0x00000003u)

#define CSL_FFT_CFG_FFTMT_MASK           (0x00000200)
#define CSL_FFT_CFG_FFTMT_SHIFT          (0x00000009)
#define CSL_FFT_CFG_FFTMT_FFT          (0x00000000u)
#define CSL_FFT_CFG_FFTMT_MT          (0x00000001u)

#define CSL_FFT_CFG_ROWCOL_MASK           (0x00000100)
#define CSL_FFT_CFG_ROWCOL_SHIFT          (0x00000008)
#define CSL_FFT_CFG_ROWCOL_DEFAULT         (0x00000000u)
#define CSL_FFT_CFG_ROWCOL_CUSTOM          (0x00000001u)

#define CSL_FFT_CFG_ROW_MASK           (0x000000F0)
#define CSL_FFT_CFG_ROW_SHIFT          (0x00000004)

#define CSL_FFT_CFG_COL_MASK           (0x0000000F)
#define CSL_FFT_CFG_COL_SHIFT          (0x00000000)

#define CSL_FFT_CTL_RUN_MASK      (0xF0000000)
#define CSL_FFT_CTL_RUN_SHIFT      (0x0000001C)
#define CSL_FFT_CTL_RUN_START     (0x00000008u)
#define CSL_FFT_CTL_RUN_STOP      (0x00000004u)

#define CSL_FFT_STATUS_FINISHED_MASK      (0x00800000)
#define CSL_FFT_STATUS_FINISHED_SHIFT      (0x00000017)

#define CSL_FFT_STATUS_STATE_MASK       (0xF8000000)
#define CSL_FFT_STATUS_STATE_SHIFT      (0x0000001B)

#define CSL_FFT_RESULT_INF_MASK       (0x00000001)
#define CSL_FFT_RESULT_INF_SHIFT      (0x00000000)

#define CSL_FFT_RESULT_NAN_MASK       (0x00000002)
#define CSL_FFT_RESULT_NAN_SHIFT      (0x00000001)

#define CSL_FFT_RESULT_OVERFLOW_MASK       (0x00000004)
#define CSL_FFT_RESULT_OVERFLOW_SHIFT      (0x00000002)

#define CSL_FFT_RESULT_F2FIX_OVERFLOW_MASK       (0x00000008)
#define CSL_FFT_RESULT_F2FIX_OVERFLOW_SHIFT      (0x00000003)

#define CSL_FFT_RESULT_INVALIDSIZE_MASK       (0x00000010)
#define CSL_FFT_RESULT_INVALIDSIZE_SHIFT      (0x00000004)

#ifdef __cplusplus
}
#endif

#endif /* CSLR_FFT_H_ */
