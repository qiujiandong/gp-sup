#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <ti/dsplib/dsplib.h>
#include <ti/sysbios/family/c66/Cache.h>
#include <c6x.h>
#include <assert.h>

#include "fft.h"

#define LOOP_TIMES (10)
#define FFT_GROUPS (1)
#define FFT_LEN (256)

typedef float Cplx[2];

extern unsigned char brev[];

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
    uint64_t tStart;
    uint64_t tStop;

    float *pfX = NULL;
    float *pfY = NULL;
    float *pfYRef = NULL;
    float *pfW = NULL;

    // allocate data in heap memory
    pfX = memalign(8, sizeof(float) * 2 * FFT_GROUPS * FFT_LEN);
    assert(pfX);
    pfYRef = memalign(8, sizeof(float) * 2 * FFT_GROUPS * FFT_LEN);
    assert(pfYRef);
    pfY = memalign(8, sizeof(float) * 2 * FFT_GROUPS * FFT_LEN);
    assert(pfY);
    pfW = memalign(8, sizeof(float) * 2 * FFT_LEN);
    memset(pfW, 0, sizeof(float) * 2 * FFT_LEN);

    int i, j;

    gen_twiddle_fft_sp(pfW, FFT_LEN);

    TSCL = 0;

    for (i = 0; i < LOOP_TIMES; ++i){

        // data init and clear result
        genData(pfX, pfYRef, FFT_LEN, FFT_GROUPS);
        memset(pfY, 0, sizeof(float) * 2 * FFT_GROUPS * FFT_LEN);
        Cache_wbInv(pfY, 2*FFT_LEN*FFT_GROUPS*sizeof(float), Cache_Type_ALLD, TRUE);

        tStart = _itoll(TSCH, TSCL);

        for(j = 0; j<FFT_GROUPS; ++j){
            DSPF_sp_fftSPxSP(FFT_LEN, pfX + j*2*FFT_LEN, pfW, pfY + j*2*FFT_LEN, brev, 2, 0, FFT_LEN);
        }

        // data write back to DDR
        Cache_wbInv(pfY, 2*FFT_LEN*FFT_GROUPS*sizeof(float), Cache_Type_ALLD, TRUE);

        tStop = _itoll(TSCH, TSCL);

        // check data
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
    free(pfW);
    pfW = NULL;

    return 0;
}
