/*
 * csl_fft.c
 *
 *  Created on: 2022.1.14
 *      Author: jayden
 */

#include "csl_fft.h"

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
){
	CSL_fftConfig config;
	config.srcRAddr = srcRAddr;
	config.srcIAddr = srcIAddr;
	config.dstRAddr = dstRAddr;
	config.dstIAddr = dstIAddr;
	config.mode = CSL_FFT_MODE_FFT;
	config.midAddr1 = midAddr1;
	config.midAddr2 = midAddr2;
	config.fftNum = num;
	config.dataFormatIn = CSL_FFT_FMT_FLOAT;
	config.dataFormatOut = CSL_FFT_FMT_FLOAT;
	config.complexReal = CSL_FFT_COMPLEX;
	config.dataOrgnize = CSL_FFT_CROSS;
	if(ifft == TRUE){
		config.fftIfft = CSL_FFT_TYPE_IFFT;
	}
	else{
		config.fftIfft = CSL_FFT_TYPE_FFT;
	}
	config.fftSize = powOfLen;
	// not used now
	config.pointPosIn = 0;
	config.pointPosOut = 0;
	config.mtMode = CSL_FFT_MT_C2C;
	config.mtSize = 0;
	config.mtRow = 0;
	config.mtCol = 0;
	// end of not used now

	CSL_fftSetup(&config);
	CSL_fftStart();
}

void CSL_fftStartMultiRowRealFFT(
	Uint32 srcRAddr,
	Uint32 dstRAddr,
	Uint32 dstIAddr,
	Uint32 midAddr1,
	Uint32 midAddr2,
	Uint8 powOfLen,
	Uint16 num,
	Bool ifft
){
	CSL_fftConfig config;
	config.srcRAddr = srcRAddr;
	config.srcIAddr = NULL;
	config.dstRAddr = dstRAddr;
	config.dstIAddr = dstIAddr;
	config.mode = CSL_FFT_MODE_FFT;
	config.midAddr1 = midAddr1;
	config.midAddr2 = midAddr2;
	config.fftNum = num;
	config.dataFormatIn = CSL_FFT_FMT_FLOAT;
	config.dataFormatOut = CSL_FFT_FMT_FLOAT;
	config.complexReal = CSL_FFT_REAL;
	config.dataOrgnize = CSL_FFT_SPLIT;
	if(ifft == TRUE){
		config.fftIfft = CSL_FFT_TYPE_IFFT;
	}
	else{
		config.fftIfft = CSL_FFT_TYPE_FFT;
	}
	config.fftSize = powOfLen;
	// not used now
	config.pointPosIn = 0;
	config.pointPosOut = 0;
	config.mtMode = CSL_FFT_MT_C2C;
	config.mtSize = 0;
	config.mtRow = 0;
	config.mtCol = 0;
	// end of not used now

	CSL_fftSetup(&config);
	CSL_fftStart();
}

CSL_Status CSL_fftFFT2D(
    float *srcRAddr,
	float *srcIAddr,
	float *dstRAddr,
	float *dstIAddr,
    Uint32 width,
    Uint32 hight
)
{
	Uint8 wPow = 0;
    Uint8 hPow = 0;
    Uint32 varw = width;
    Uint32 varh = hight;
    Uint32 dstR = (Uint32)dstRAddr;
    Uint32 dstI = (Uint32)dstIAddr;
    while(!(varw&1)){
		varw = varw >> 1;
		wPow += 1;
	}
    while(!(varh&1)){
		varh = varh >> 1;
		hPow += 1;
	}

    CSL_fftConfig config;
    config.srcRAddr = (Uint32)srcRAddr;
    config.srcIAddr = (Uint32)srcIAddr;
    config.dstRAddr = dstR;
    config.dstIAddr = dstI;
    config.mode = CSL_FFT_MODE_FFT;
    config.midAddr1 = 0;
    config.midAddr2 = 0;
    config.fftNum = hight;
    config.dataFormatIn = CSL_FFT_FMT_FLOAT;
    config.dataFormatOut = CSL_FFT_FMT_FLOAT;
    config.complexReal = CSL_FFT_REAL;
    config.dataOrgnize = CSL_FFT_SPLIT;
    config.fftIfft = CSL_FFT_TYPE_FFT;
    config.fftSize = wPow;
    // not used now
    config.pointPosIn = 0;
    config.pointPosOut = 0;
    config.mtMode = CSL_FFT_MT_C2C;
    config.mtSize = 0;
    config.mtRow = 0;
    config.mtCol = 0;
    // end of not used now

    CSL_fftSetup(&config);
    CSL_fftStart();
    while(!CSL_fftIsFinished())
        ;

    config.mode = CSL_FFT_MODE_MT;
    config.srcRAddr = dstR;
    config.dstRAddr = dstR;
    config.mtMode = CSL_FFT_MT_S2S;
    config.mtSize = width * hight;
    config.mtRow = width;
    config.mtCol = hight;

    CSL_fftSetup(&config);
    CSL_fftStart();
    while(!CSL_fftIsFinished())
        ;

    config.mode = CSL_FFT_MODE_MT;
    config.srcRAddr = dstI;
    config.dstRAddr = dstI;
    config.mtMode = CSL_FFT_MT_S2S;
    config.mtSize = width * hight;
    config.mtRow = width;
    config.mtCol = hight;

    CSL_fftSetup(&config);
    CSL_fftStart();
    while(!CSL_fftIsFinished())
        ;

    config.srcRAddr = dstR;
    config.srcIAddr = dstI;
    config.dstRAddr = dstR;
    config.dstIAddr = dstI;
    config.mode = CSL_FFT_MODE_FFT;
    config.fftSize = hPow;
    config.fftNum = width;
    config.dataFormatIn = CSL_FFT_FMT_FLOAT;
    config.dataFormatOut = CSL_FFT_FMT_FLOAT;
    config.complexReal = CSL_FFT_COMPLEX;
    config.dataOrgnize = CSL_FFT_SPLIT;
    config.fftIfft = CSL_FFT_TYPE_FFT;
    CSL_fftSetup(&config);
    CSL_fftStart();
    while(!CSL_fftIsFinished())
        ;

    config.mode = CSL_FFT_MODE_MT;
    config.srcRAddr = dstR;
    config.dstRAddr = dstR;
    config.mtMode = CSL_FFT_MT_S2S;
    config.mtSize = width * hight;
    config.mtRow = hight;
    config.mtCol = width;

    CSL_fftSetup(&config);
    CSL_fftStart();
    while(!CSL_fftIsFinished())
        ;

    config.mode = CSL_FFT_MODE_MT;
    config.srcRAddr = dstI;
    config.dstRAddr = dstI;
    config.mtMode = CSL_FFT_MT_S2S;
    config.mtSize = width * hight;
    config.mtRow = hight;
    config.mtCol = width;

    CSL_fftSetup(&config);
    CSL_fftStart();
    while(!CSL_fftIsFinished())
        ;

    return CSL_SOK;
}

CSL_Status CSL_fftIFFT2D(
    float *srcRAddr,
	float *srcIAddr,
	float *dstRAddr,
	float *dstIAddr,
    Uint32 width,
    Uint32 hight
){
	Uint8 wPow = 0;
	Uint8 hPow = 0;
	Uint32 varw = width;
	Uint32 varh = hight;
	Uint32 dstR = (Uint32)dstRAddr;
	Uint32 dstI = (Uint32)dstIAddr;
	while(!(varw&1)){
		varw = varw >> 1;
		wPow += 1;
	}
	while(!(varh&1)){
		varh = varh >> 1;
		hPow += 1;
	}

	CSL_fftConfig config;
	config.srcRAddr = (Uint32)srcRAddr;
	config.srcIAddr = (Uint32)srcIAddr;
	config.dstRAddr = (Uint32)dstRAddr;
	config.dstIAddr = (Uint32)dstIAddr;
	config.mode = CSL_FFT_MODE_FFT;
	config.midAddr1 = 0;
	config.midAddr2 = 0;
	config.fftNum = hight;
	config.dataFormatIn = CSL_FFT_FMT_FLOAT;
	config.dataFormatOut = CSL_FFT_FMT_FLOAT;
	config.complexReal = CSL_FFT_COMPLEX;
	config.dataOrgnize = CSL_FFT_SPLIT;
	config.fftIfft = CSL_FFT_TYPE_IFFT;
	config.fftSize = wPow;
	config.pointPosIn = 0;
	config.pointPosOut = 0;
	config.mtMode = CSL_FFT_MT_C2C;
	config.mtSize = 0;
	config.mtRow = 0;
	config.mtCol = 0;

	CSL_fftSetup(&config);
	CSL_fftStart();
	while(!CSL_fftIsFinished())
		;

	config.mode = CSL_FFT_MODE_MT;
	config.srcRAddr = dstR;
	config.dstRAddr = dstR;
	config.mtMode = CSL_FFT_MT_S2S;
	config.mtSize = width * hight;
	config.mtRow = width;
	config.mtCol = hight;

	CSL_fftSetup(&config);
	CSL_fftStart();
	while(!CSL_fftIsFinished())
		;

	config.mode = CSL_FFT_MODE_MT;
	config.srcRAddr = dstI;
	config.dstRAddr = dstI;
	config.mtMode = CSL_FFT_MT_S2S;
	config.mtSize = width * hight;
	config.mtRow = width;
	config.mtCol = hight;

	CSL_fftSetup(&config);
	CSL_fftStart();
	while(!CSL_fftIsFinished())
		;

	config.srcRAddr = dstR;
	config.srcIAddr = dstI;
	config.dstRAddr = dstR;
	config.dstIAddr = dstI;
	config.mode = CSL_FFT_MODE_FFT;
	config.fftSize = hPow;
	config.fftNum = width;
	config.dataFormatIn = CSL_FFT_FMT_FLOAT;
	config.dataFormatOut = CSL_FFT_FMT_FLOAT;
	config.complexReal = CSL_FFT_COMPLEX;
	config.dataOrgnize = CSL_FFT_SPLIT;
	config.fftIfft = CSL_FFT_TYPE_IFFT;
	CSL_fftSetup(&config);
	CSL_fftStart();
	while(!CSL_fftIsFinished())
		;
	// config.midAddr1 = 0;
	// config.midAddr2 = 0;
	// config.pointPosIn = 0;
	// config.pointPosOut = 0;
	// config.mtMode = CSL_FFT_MT_C2C;
	// config.mtSize = 0;
	// config.mtRow = 0;
	// config.mtCol = 0;

	config.mode = CSL_FFT_MODE_MT;
	config.srcRAddr = dstR;
	config.dstRAddr = dstR;
	config.mtMode = CSL_FFT_MT_S2S;
	config.mtSize = width * hight;
	config.mtRow = hight;
	config.mtCol = width;

	CSL_fftSetup(&config);
	CSL_fftStart();
	while(!CSL_fftIsFinished())
		;

	config.mode = CSL_FFT_MODE_MT;
	config.srcRAddr = dstI;
	config.dstRAddr = dstI;
	config.mtMode = CSL_FFT_MT_S2S;
	config.mtSize = width * hight;
	config.mtRow = hight;
	config.mtCol = width;

	CSL_fftSetup(&config);
	CSL_fftStart();
	while(!CSL_fftIsFinished())
		;

	return CSL_SOK;
}
