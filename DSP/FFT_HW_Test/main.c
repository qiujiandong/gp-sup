#include <assert.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <xdc/runtime/Error.h>
#include <ti/sysbios/family/c66/tci66xx/CpIntc.h>
#include <ti/sysbios/family/c66/Cache.h>
#include <ti/sysbios/family/c64p/Hwi.h>
#include <xdc/cfg/global.h>
#include <c6x.h>

#include <csl_edma3.h>
#include "csl_fft.h"
#include "csl_psc.h"

#define LOOP_TIMES (10) //loop times
#define FFT_GROUPS (100) // fft groups in every time
#define FFT_POW (8) // 4, 5, 6, 7, 8
#define FFT_LEN  (1<<FFT_POW)

typedef float Cplx[2];

volatile int nFlag = 0;

Void FFTDoneHandler(UArg a0);

/**
 * @brief generate source data and reference data
 * 
 * @param pfX source data pointer
 * @param pfYRef reference data pointer
 * @param nLen FFT length
 * @param nGroups FFT groups in one loop
 * @return int 
 */
int genData(float *pfX, float *pfYRef, int nLen, int nGroups)
{
    int i, j;
    Cplx *pX = (Cplx *)pfX;
    Cplx *pYRef = (Cplx *)pfYRef;

    if(!pfX || !pfYRef)
        return -1;

    for (i = 0; i<nGroups; ++i){
        for (j = 0; j < nLen; ++j){
            pX[j][0] = 1.0;
            pX[j][1] = 0.0;
        }
        memset(pYRef, 0, nLen * sizeof(Cplx));
        pYRef[0][0] = nLen;
        pX += nLen;
        pYRef += nLen;
    }

    Cache_wbInv(pfX, sizeof(float) * 2 * nLen * nGroups, Cache_Type_ALLD, TRUE);
    Cache_wbInv(pfYRef, sizeof(float) * 2 * nLen * nGroups, Cache_Type_ALLD, TRUE);

    return 0;
}

int main()
{
	int i, j;
	Hwi_Params params;
	Uint8 exCode;

	uint64_t tStart;
	uint64_t tStop;
	size_t sz;

	// allocate data in heap memory
	if(sizeof(float) * 2 * FFT_GROUPS * FFT_LEN < 8192){
		sz = 8192;
	}
	else{
		sz = sizeof(float) * 2 * FFT_GROUPS * FFT_LEN;
		sz = (sz / 8192 + ((sz % 8192 > 0)?1:0)) * 8192;
	}
    float *pfX = memalign(4096, sz);
    assert(pfX);
    memset(pfX, 0, sz);
    Cache_wb(pfX, sz, Cache_Type_ALLD, TRUE);

	float *pfY = memalign(4096, sz);
    assert(pfY);
    memset(pfY, 0, sz);
    Cache_wb(pfY, sz, Cache_Type_ALLD, TRUE);

    float *pfYRef = memalign(4096, sizeof(float) * 2 * FFT_GROUPS * FFT_LEN);
    assert(pfYRef);
    
    // put mid1 and mid2 in MSMC is better
	float *pMid1 = memalign(4096, sizeof(float) * 2 * FFT_LEN);
	assert(pMid1);
	float *pMid2 = memalign(4096, sizeof(float) * 2 * FFT_LEN);
	assert(pMid2);

	// setup interrupt
	Error_Block eb;
	Error_init(&eb);

	CpIntc_clearSysInt(0, 7);
	CpIntc_enableSysInt(0, 7);
	CpIntc_mapSysIntToHostInt(0, 7, 32);
	CpIntc_enableHostInt(0, 32);
	CpIntc_enableAllHostInts(0);

	Hwi_Params_init(&params);
	params.eventId = CpIntc_getEventId(32);
	params.arg = 32;
	params.enableInt = TRUE;
	Hwi_create(4, FFTDoneHandler, &params, &eb);
	Hwi_enable();

	TSCL = 0;

	for (i = 0; i < LOOP_TIMES; ++i){

		CSL_pscModuleDisable(PSC_MD_FFT, PSC_PWR_PERI);
		CSL_pscModuleEnable(PSC_MD_FFT, PSC_PWR_PERI);

		// data init and clear result
        genData(pfX, pfYRef, FFT_LEN, FFT_GROUPS);
        memset(pfY, 0, sizeof(float) * 2 * FFT_GROUPS * FFT_LEN);
		Cache_wbInv(pfY, 2*FFT_LEN*FFT_GROUPS*sizeof(float), Cache_Type_ALLD, TRUE);

        tStart = _itoll(TSCH, TSCL);

		CSL_fftStartMultiRowFFT(
			(Uint32)pfX,
			0,
			(Uint32)pfY,
			0,
			(Uint32)pMid1,
			(Uint32)pMid2,
			FFT_POW,
			FFT_GROUPS,
			0);

		while(!nFlag);
		Cache_inv(pfY, sizeof(Cplx) * FFT_LEN * FFT_GROUPS, Cache_Type_ALLD, TRUE);
		tStop = _itoll(TSCH, TSCL);
		nFlag = 0;

		// check data
		exCode = CSL_fftResultException();
		assert(exCode == 0);

		for (j = 0; j < 2 * FFT_LEN * FFT_GROUPS; ++j){
            if(fabsf(pfY[j] - pfYRef[j]) > 1e-6)
                break;
        }
        assert(j == 2 * FFT_LEN * FFT_GROUPS);

		printf("%d: %d point FFT for %d times, average time: %.2f ns\n", i, FFT_LEN, FFT_GROUPS, (tStop - tStart)*1.0 / FFT_GROUPS);
	}

	free(pfX);
    pfX = NULL;
    free(pfY);
    pfY = NULL;
    free(pfYRef);
    pfYRef = NULL;
    free(pMid1);
    pMid1 = NULL;
	free(pMid2);
	pMid2 = NULL;

	return 0;
}

Void FFTDoneHandler(UArg a0)
{
	nFlag = 1;
	CpIntc_clearSysInt(0, 7);
}
