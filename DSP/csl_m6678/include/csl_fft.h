/*
 * csl_fft.h
 *
 *  Created on: 2022.1.14
 *      Author: jayden
 */

#ifndef CSL_FFT_H_
#define CSL_FFT_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <soc.h>
#include <csl.h>
#include <cslr_fft.h>

#define hFft ((CSL_FftRegsOvly)CSL_FFT_REGS)

typedef enum
{
    CSL_FFT_MODE_FFT,
    CSL_FFT_MODE_MT
}CSL_fftMode;

typedef enum
{
    CSL_FFT_FMT_FLOAT,
    CSL_FFT_FMT_FIXED
}CSL_fftFmt;

typedef enum
{
    CSL_FFT_COMPLEX,
    CSL_FFT_REAL
}CSL_fftDatFmt;


typedef enum
{
    CSL_FFT_TYPE_FFT,
    CSL_FFT_TYPE_IFFT
}CSL_fftFftType;

typedef enum
{
    CSL_FFT_MT_C2C,
    CSL_FFT_MT_S2C,
    CSL_FFT_MT_C2S,
    CSL_FFT_MT_S2S
}CSL_fftMtType;

typedef enum
{
    CSL_FFT_CROSS,
    CSL_FFT_SPLIT
}CSL_fftDatOrg;

typedef struct 
{
    Uint32 srcRAddr;    // 4k boundary, can be same with dstAddr
    Uint32 srcIAddr;
    Uint32 dstRAddr;
    Uint32 dstIAddr;

    CSL_fftMode mode; // 0: fft, 1: mt

    // fft
    Uint32 midAddr1;    // try to use MSMC
    Uint32 midAddr2;
    Uint32 fftNum;          // fft data group
    CSL_fftFmt dataFormatIn;      // 0: float, 1: fix point
    CSL_fftFmt dataFormatOut;     // same as above
    CSL_fftDatFmt complexReal;       // 0: complex, 1: real
    CSL_fftDatOrg dataOrgnize;       // 0: cross, 1: split(if real then must be split)
    CSL_fftFftType fftIfft;           // 0: fft, 1:ifft
    Uint8 fftSize;          // fft length = 2^fftSize
    Uint8 pointPosIn;
    Uint8 pointPosOut;

    // mt
    CSL_fftMtType mtMode;       // 0: c2c, 1:s2c, 2:c2s, 3:s2s
    Uint32 mtSize;      // mtSize = mtRow*mtCol
    Uint32 mtRow;       // least 5 bits must be zero
    Uint32 mtCol;       // least 5 bits must be zero
}CSL_fftConfig;


static inline
void CSL_fftSetup(CSL_fftConfig *config)
{
    hFft->SRC_RADDR = config->srcRAddr;
    hFft->SRC_IADDR = config->srcIAddr;
    hFft->DST_RADDR = config->dstRAddr;
    hFft->DST_IADDR = config->dstIAddr;
    hFft->MID_ADDR1 = config->midAddr1;
    hFft->MID_ADDR2 = config->midAddr2;
    hFft->PROC_NUM = config->fftNum;
    hFft->CFG = CSL_FMK(FFT_CFG_MODE, config->fftIfft) |
                CSL_FMK(FFT_CFG_FFTMT, config->mode) |
                CSL_FMK(FFT_CFG_OUTPUT_FORMAT, config->dataFormatOut) |
                CSL_FMK(FFT_CFG_DATA_FORMAT, config->complexReal) |
                CSL_FMK(FFT_CFG_DATA_ORGNIZE, config->dataOrgnize) |
                CSL_FMK(FFT_CFG_INPUT_FORMAT, config->dataFormatIn) |
                CSL_FMK(FFT_CFG_SIZE, config->fftSize) |
                CSL_FMK(FFT_CFG_INPUT_PP, config->pointPosIn) |
                CSL_FMK(FFT_CFG_OUTPUT_PP, config->pointPosOut) |
                CSL_FMK(FFT_CFG_MT_MODE, config->mtMode);
    hFft->MT_SIZE = config->mtSize;
    hFft->MT_ROW_SIZE = config->mtRow;
    hFft->MT_COL_SIZE = config->mtCol;
}

static inline 
void CSL_fftStart()
{
    hFft->CTL = CSL_FMKT(FFT_CTL_RUN, START);
}

static inline
void CSL_fftStop()
{
    hFft->CTL = CSL_FMKT(FFT_CTL_RUN, STOP);
}

static inline 
void CSL_fftFftTypeSetup(CSL_fftFftType *fftType)
{
    CSL_FINS(hFft->CFG, FFT_CFG_MODE, *fftType);
}

static inline
void CSL_fftModeSetup(CSL_fftMode *mode)
{
    CSL_FINS(hFft->CFG, FFT_CFG_FFTMT, *mode);
}

static inline
Bool CSL_fftIsFinished()
{
    return CSL_FEXT(hFft->STATUS, FFT_STATUS_FINISHED);
}

static inline
void CSL_fftClearStatus(){
	hFft->STATUS = 0;
}

static inline
Uint32 CSL_fftCycle()
{
    return hFft->PROC_CYCLE;
}

static inline
Uint8 CSL_fftResultException()
{
	return CSL_FEXTR(hFft->RESULT, 4, 0);
}

void CSL_fftStartMultiRowFFT(
	Uint32 srcRAddr,
	Uint32 srcIAddr,
	Uint32 dstRAddr,
	Uint32 dstIAddr,
	Uint32 midAddr1,
	Uint32 midAddr2,
	Uint8 powOfLen,
	Uint16 num,
	Bool ifft
);

void CSL_fftStartMultiRowRealFFT(
	Uint32 srcRAddr,
	Uint32 dstRAddr,
	Uint32 dstIAddr,
	Uint32 midAddr1,
	Uint32 midAddr2,
	Uint8 powOfLen,
	Uint16 num,
	Bool ifft
);

CSL_Status CSL_fftFFT2D(
	float *srcRAddr,
	float *srcIAddr,
	float *dstRAddr,
	float *dstIAddr,
    Uint32 width,
    Uint32 hight
);

CSL_Status CSL_fftIFFT2D(
	float *srcRAddr,
	float *srcIAddr,
	float *dstRAddr,
	float *dstIAddr,
    Uint32 width,
    Uint32 hight);

#ifdef __cplusplus
}
#endif
#endif /* CSL_FFT_H_ */
