/**
 * @file FFTTask.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-08
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "CFftManager.h"
#include "main.h"

extern "C" {
    Void FFTTskFxn(UArg a0, UArg a1);
}

extern CFftManager *pFftMgr;

Void FFTTskFxn(UArg a0, UArg a1)
{
    FFTCmd *pCmd = NULL;
    int nWidth, nHeight;

    for (;;){
        Semaphore_pend(hFFTStartSem, BIOS_WAIT_FOREVER);

        pCmd = (FFTCmd *)Queue_dequeue(hFFTQue);
        nWidth = pCmd->nWidth;
        nHeight = pCmd->nHeight;

        switch (pCmd->eType)
        {
        case FFT2d_R2R:
            pFftMgr->ClearTempR(sizeof(float) * pCmd->nWidth * pCmd->nHeight);
            pFftMgr->FFT_R2R_T(pCmd->pSrc, pCmd->pDst, nWidth, nHeight);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            pFftMgr->FFT_R2R_T(pCmd->pDst, pCmd->pDst, nHeight, nWidth);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            // TODO check result
            Cache_inv(pCmd->pDst, sizeof(float) * nWidth * nHeight, Cache_Type_ALLD, 1);
            break;
        case FFT2d_R2C:
            pFftMgr->FFT_R2C_T(pCmd->pSrc, pCmd->pDst, nWidth, nHeight);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            pFftMgr->FFT_C2C_T(pCmd->pDst, pCmd->pDst, nHeight, nWidth);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);

            Cache_inv(pCmd->pDst, sizeof(float) * nWidth * nHeight * 2, Cache_Type_ALLD, 1);
            break;
        case FFT2d_R2C_N:
            pFftMgr->FFT_R2C_T(pCmd->pSrc, pCmd->pDst, nWidth, nHeight);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            pFftMgr->FFT_C2C_TN(pCmd->pDst, pCmd->pDst, nHeight, nWidth);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);

            Cache_inv(pCmd->pDst, sizeof(float) * nWidth * nHeight * 2, Cache_Type_ALLD, 1);
            break;
        case IFFT2d_C2R:
            pFftMgr->IFFT_C2C_T(pCmd->pSrc, pCmd->pSrc, nWidth, nHeight);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            pFftMgr->IFFT_C2R_T(pCmd->pSrc, pCmd->pDst, nHeight, nWidth);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);

            Cache_inv(pCmd->pDst, sizeof(float) * nWidth * nHeight, Cache_Type_ALLD, 1);
            break;
        default:
            System_abort("FFT Type error\n");
            break;
        }
        Semaphore_post(hFFTDoneSem);
    }
}
