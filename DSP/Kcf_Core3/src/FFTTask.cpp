/**
 * @file FFTTask.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-01-06
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "main.h"
#include "CFftManager.h"

extern "C" {
    Void FFTTskFxn(UArg a0, UArg a1);
}

Void FFTDoneHandler(UArg a0);

Void FFTTskFxn(UArg a0, UArg a1)
{
    Int status;
    MessageQ_Handle hFftCmdQueue;
    FftMsgHandle hFftMsg;
    CFftManager FftMgr;
    int nWidth, nHeight;

    Hwi_Params hwiParams;
	Hwi_Handle hSimRxDataHwi;
	Error_Block eb;

    Error_init(&eb);
	Hwi_Params_init(&hwiParams);

    hwiParams.arg = (UArg)(&FftMgr);
	hwiParams.eventId = CORE3_INTC_FFTDONE_INTCEVT;
	hSimRxDataHwi = Hwi_create(CORE3_INTC_FFTDONE_INT, FFTDoneHandler, &hwiParams, &eb);
	if(hSimRxDataHwi == NULL){
		System_abort("Hwi create failed\n");
	}

    // using default synchronizer SyncSem
	hFftCmdQueue = MessageQ_create(MSGQ_FFTCMD_NAME, NULL);
	if(hFftCmdQueue == NULL){
		System_abort("MessageQ create failed\n");
	}

    FftMgr.init(32, 32);
    FftMgr.HwInit();

    for (;;){
        MessageQ_get(hFftCmdQueue, (MessageQ_Msg *)&hFftMsg, MessageQ_FOREVER);

        nWidth = hFftMsg->nWidth;
        nHeight = hFftMsg->nHeight;

        switch (hFftMsg->eType)
        {
        case FFT2d_R2R:
            FftMgr.ClearTempR(sizeof(float) * nWidth * nHeight);
            FftMgr.FFT_R2R_T(hFftMsg->pSrc, hFftMsg->pDst, nWidth, nHeight);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            FftMgr.FFT_R2R_T(hFftMsg->pDst, hFftMsg->pDst, nHeight, nWidth);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            // TODO check result
            // caller should make cache coherence
            // Cache_inv(hFftMsg->pDst, sizeof(float) * nWidth * nHeight, Cache_Type_ALLD, 1);
            break;
        case FFT2d_R2C:
            FftMgr.FFT_R2C_T(hFftMsg->pSrc, hFftMsg->pDst, nWidth, nHeight);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            FftMgr.FFT_C2C_T(hFftMsg->pDst, hFftMsg->pDst, nHeight, nWidth);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);

            // caller should make cache coherence
            // Cache_inv(hFftMsg->pDst, sizeof(float) * nWidth * nHeight * 2, Cache_Type_ALLD, 1);
            break;
        case FFT2d_R2C_N:
            FftMgr.FFT_R2C_T(hFftMsg->pSrc, hFftMsg->pDst, nWidth, nHeight);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            FftMgr.FFT_C2C_TN(hFftMsg->pDst, hFftMsg->pDst, nHeight, nWidth);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);

            // caller should make cache coherence
            // Cache_inv(hFftMsg->pDst, sizeof(float) * nWidth * nHeight * 2, Cache_Type_ALLD, 1);
            break;
        case IFFT2d_C2R:
            FftMgr.IFFT_C2C_T(hFftMsg->pSrc, hFftMsg->pSrc, nWidth, nHeight);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);
            FftMgr.IFFT_C2R_T(hFftMsg->pSrc, hFftMsg->pDst, nHeight, nWidth);
            Semaphore_pend(hFFTHwiSem, BIOS_WAIT_FOREVER);

            // caller should make cache coherence
            // Cache_inv(hFftMsg->pDst, sizeof(float) * nWidth * nHeight, Cache_Type_ALLD, 1);
            break;
        default:
            assert(0); // FFT type error
            break;
        }

        // free message
        MessageQ_free((MessageQ_Msg)hFftMsg);

        // Send Notify
        do{
            status = Notify_sendEvent(hFftMsg->nReplyCoreId, NOTIFY_LINEID, FFT_DONE_EVTID, 0, TRUE);
        } while (status < 0);
    }
}

Void FFTDoneHandler(UArg a0)
{
    Semaphore_post(hFFTHwiSem);
	((CFftManager *)a0)->ClearInterruptFlag();
}
