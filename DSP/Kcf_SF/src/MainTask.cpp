/**
 * @file MainTask.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "CKcfTracker.h"
#include "CSrio2PcieManager.h"
#include "CFftManager.h"
#include "CTspsManager.h"
#include "CRxBufManager.h"
#include "main.h"
#include <cv.h>
#include <c6x.h>

extern CTspsManager *pTspsMgr;
extern CSrio2PcieManager *pSrio2PcieMgr;
extern CRxBufManager *pRxBufMgr;

extern "C" {
    Void MainTskFxn(UArg a0, UArg a1);
}

#if SIMULATION_MODE
#pragma DATA_SECTION(".images")
uint8_t img[SIM_FRAME_NUM * SIM_FRAME_WIDTH * SIM_FRAME_HEIGHT];
#endif

Void MainTskFxn(UArg a0, UArg a1)
{
    CvRect roi;
    int frameNum;
    int frameWidth;
    int frameHeight;
    int frameTransSize;
    CvMat src;

    int resultsSize;
    void *pResults;
    double *pTotalTime;
    SeqResult *pRects;

    uint64_t tStart;
    uint64_t tStop;

    CKcfTracker tracker;

    tracker.createHanningMats();
    tracker.createGaussianPeak();

#if !SIMULATION_MODE
    int status;
	SeqInfo *pSeqInfo;
	int nSeqenctCnt = 0;

    pSeqInfo = (SeqInfo *)memalign(4096, sizeof(SeqInfo));
    if(pSeqInfo == NULL){
        System_abort("Alloc SeqInfo Failed\n");
    }
#endif

    for (;;){

#if !SIMULATION_MODE
        // waiting for start
        System_printf("DSP waiting for sequnce %d to start\n", nSeqenctCnt++);
        Semaphore_pend(hRxDbStartReqSem, BIOS_WAIT_FOREVER);

        // request for sequence information
        status = pSrio2PcieMgr->startTxSeqInfoFromPC(pSeqInfo);
        if(status != 0){
            System_abort("Rx Seq Info Error\n");
        }
        Cache_inv(pSeqInfo, sizeof(SeqInfo), Cache_Type_ALLD, TRUE);
        Semaphore_pend(hRxDbSwFromPCSem, BIOS_WAIT_FOREVER);

        roi = cvRect(pSeqInfo->roiX, pSeqInfo->roiY, pSeqInfo->roiW, pSeqInfo->roiH);
        frameNum = pSeqInfo->frameNum;
        frameWidth = pSeqInfo->width;
        frameHeight = pSeqInfo->height;
        frameTransSize = pSeqInfo->frameTransSize;
        // end of request for sequence information

        resultsSize = (sizeof(SeqResult) * (frameNum + 1) + 255) / 256 * 256;
        pResults = memalign(4096, resultsSize);
        if(pResults == NULL){
            System_abort("Alloc Results Failed\n");
        }
        pTotalTime = (double *)pResults;
        pRects = ((SeqResult *)pResults) + 1;

        System_printf("---------- Start Proc ----------\n");
        System_printf("Frame width: %d, height: %d, count: %d\n", frameWidth, frameHeight, frameNum);
        System_printf("ROI: x: %d, y: %d, width: %d, heigth: %d\n", roi.x, roi.y, roi.width, roi.height);
        System_printf("Frame trans size: %d, result size: %d\n", frameTransSize, resultsSize);

        pRxBufMgr->init(frameTransSize);

#if !HW_FHOG_MODE
        pSrio2PcieMgr->startTxFrameFromPC(pRxBufMgr->getRxBuf(), frameTransSize >> 3);
#endif

#else
        roi = cvRect(13, 500, 40, 40);
        frameNum = SIM_FRAME_NUM;
        frameWidth = SIM_FRAME_WIDTH;
        frameHeight = SIM_FRAME_HEIGHT;
        frameTransSize = SIM_FRAME_WIDTH * SIM_FRAME_HEIGHT;

        resultsSize = sizeof(SeqResult) * (frameNum + 1) + 255;
        pResults = malloc(resultsSize);
        if(pResults == NULL){
            System_abort("Alloc Results Failed\n");
        }
        pTotalTime = (double *)pResults;
        pRects = ((SeqResult *)pResults) + 1;

        pRxBufMgr->init(frameTransSize);
        pRxBufMgr->SimStartRxData(img);
#endif
        TSCL = 0;
        *pTotalTime = 0.0;

        for (int i = 0; i < frameNum; ++i){

#if !SIMULATION_MODE

#if HW_FHOG_MODE
            pSrio2PcieMgr->startTxFrameFromPC(pRxBufMgr->getRxBuf(), frameTransSize >> 3);
#endif
            Cache_inv(pRxBufMgr->getRxBuf(), frameTransSize, Cache_Type_ALLD, TRUE);
            Semaphore_pend(hRxDbSwFromPCSem, BIOS_WAIT_FOREVER);
            pRxBufMgr->flipIndex();

#if !HW_FHOG_MODE
            if(i < frameNum - 1){
                Cache_inv(pRxBufMgr->getRxBuf(), frameTransSize, Cache_Type_ALLD, FALSE);
                pSrio2PcieMgr->startTxFrameFromPC(pRxBufMgr->getRxBuf(), frameTransSize >> 3);
            }
#endif

#else
            Semaphore_pend(hRxSimData, BIOS_WAIT_FOREVER);
            pRxBufMgr->flipIndex();

            if(i < frameNum - 1){
                Cache_inv(pRxBufMgr->getRxBuf(), frameTransSize, Cache_Type_ALLD, FALSE);
                pRxBufMgr->SimStartRxData(img + (i + 1) * SIM_FRAME_WIDTH * SIM_FRAME_HEIGHT);
            }
#endif

            cvInitMatHeader(&src, frameHeight, frameWidth, CV_8UC1, pRxBufMgr->getOpBuf());

            tStart = _itoll(TSCH, TSCL);

            if(i == 0){
                tracker.init(roi, src);
            }
            else{
                roi = tracker.update(src);
            }

            tStop = _itoll(TSCH, TSCL);

            *pTotalTime += (tStop - tStart) * 1.0 / 1000000000;
            pRects[i].x = roi.x;
            pRects[i].y = roi.y;
            pRects[i].width = roi.width;
            pRects[i].height = roi.height;
        }

        System_printf("---------- Proc Done ----------\n");

#if !SIMULATION_MODE
        Cache_wb(pResults, sizeof(SeqResult) * (frameNum + 1), Cache_Type_ALLD, TRUE);

        status = pSrio2PcieMgr->startTxNwToPC(pResults, resultsSize >> 3);
        if(status != 0){
			System_abort("Tx Tracking results by Nw Error\n");
		}

        System_printf("Result tx done\n");
        pRxBufMgr->deinit();

        free(pResults);
        pResults = NULL;

        pSrio2PcieMgr->startTxDbWithMSI(SRIO_DBTX_PC_PROCDONE);
#else
        System_printf("Result tx done\n");
        pRxBufMgr->deinit();

        free(pResults);
        pResults = NULL;
#endif
    }

    // free(pSeqInfo);
    // pSeqInfo = NULL;
}
