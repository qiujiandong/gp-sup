/**
 * @file kcf_dsp.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-03
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include <unistd.h>
#include <iostream>
#include <string>
#include <semaphore.h>
#include <opencv2/opencv.hpp>

#include "CXdmaManager.h"
#include "Srio2PcieLLD.h"
#include "kcf_dsp.h"

using namespace std;
using namespace cv;

CXdmaManager *pXdmaMgr;

sem_t hTxSeqInfoReqSem;
sem_t hTxFrameReqSem;
sem_t hRxResultReqSem;
sem_t hDspReadySem;

int main(int argc, char *argv[])
{    
    void *pSrcData;
    void *pResults;

    int frameNum;
    int transSize;

    SeqInfo *pSeqInfo;
    void *importData;
    SeqResult *pRects;

    string fileName;
    Mat srcMat;
    Mat grayMat;

    FILE *fResults;

    double dTotalTime;
    int rv;

    pXdmaMgr = CXdmaManager::getInstance();

// init
    sem_init(&hTxSeqInfoReqSem, 0, 0);
    sem_init(&hTxFrameReqSem, 0, 0);
    sem_init(&hRxResultReqSem, 0, 0);
    sem_init(&hDspReadySem, 0, 0);

    rv = pXdmaMgr->init();
    if(rv != 0){
        cout << "xdma init failed" << endl;
        return -1;
    }
// end of init

// allocate data
    rv = posix_memalign(&pSrcData, 4096, sizeof(uint8_t) * MAX_FRAME_WIDTH * MAX_FRAME_HEIGHT);
    if(rv != 0){
        cout << "source data allocate failed" << endl;
        return -1;
    }
    rv = posix_memalign(&pResults, 4096, sizeof(SeqResult) * MAX_FRAME_NUM);
    if(rv != 0){
        cout << "result data allocate failed" << endl;
        return -1;
    }
    memset(pResults, 0, sizeof(SeqResult) * MAX_FRAME_NUM);
// end of allocate data

// get input, prepare sequence information
    pSeqInfo = (SeqInfo *)pSrcData;

    cin >> pSeqInfo->roiX;
    cin >> pSeqInfo->roiY;
    cin >> pSeqInfo->roiW;
    cin >> pSeqInfo->roiH;
    cin >> frameNum;
    cin >> ws;

    // get image full name
    getline(cin, fileName);
    // read image and convert to gray
    srcMat = imread(fileName);

    pSeqInfo->width = srcMat.cols;
    pSeqInfo->height = srcMat.rows;

    transSize = upToBoundary(pSeqInfo->width * pSeqInfo->height, 256);
    pSeqInfo->frameNum = frameNum;
    pSeqInfo->frameTransSize = transSize;

    printf("frame num: %d, frame width: %d, frame height: %d\n", pSeqInfo->frameNum, pSeqInfo->width, pSeqInfo->height);

    // request for start
    pXdmaMgr->sendDB(SRIO_DBTX_STARTREQ);

    sem_wait(&hTxSeqInfoReqSem);
    printf("DSP request for sequence info\n");
    pXdmaMgr->startH2C(pSeqInfo, sizeof(SeqInfo));
    printf("Sequnce info tx done\n");
// end of tx sequence information

// tx first frame
    if(srcMat.channels() == 3){
        cvtColor(srcMat, grayMat, COLOR_BGR2GRAY);
        importData = grayMat.ptr(0);
    }
    else{
        importData = srcMat.ptr(0);
    }
    memcpy(pSrcData, importData, transSize);

    sem_wait(&hTxFrameReqSem);
    printf("Frame 0\n");
    pXdmaMgr->startH2C(pSrcData, transSize);
// end of tx first frame

// tx frames
    for (int i = 1; i < frameNum; ++i){
        // get image full name
        getline(cin, fileName);
        // read image and convert to gray
        srcMat = imread(fileName);
        if(srcMat.channels() == 3){
            cvtColor(srcMat, grayMat, COLOR_BGR2GRAY);
            importData = grayMat.ptr(0);
        }
        else{
            importData = srcMat.ptr(0);
        }

        memcpy(pSrcData, importData, transSize);

        sem_wait(&hTxFrameReqSem);
        printf("Frame %d\n", i);
        pXdmaMgr->startH2C(pSrcData, transSize);
    }
// end of tx frames

// rx results
    sem_wait(&hRxResultReqSem);
    printf("DSP request for sending results\n");
    rv = pXdmaMgr->startC2H(pResults, upToBoundary(sizeof(SeqResult) * (frameNum + 1), 256));
    if(rv == -1){
        printf("read error\n");
    }
    else{
        printf("Get results\n");
    }

    dTotalTime = *((double *)pResults);
    pRects = (SeqResult *)(pResults) + 1;

    fResults = fopen("results.txt", "w");
    fprintf(fResults, "%lf\n", dTotalTime);

    for (int i = 0; i < frameNum; ++i){
        fprintf(fResults, "%d,%d,%d,%d\n", pRects[i].x, pRects[i].y, pRects[i].width, pRects[i].height);
    }
    fclose(fResults);
    fResults = NULL;
// end of rx results

    free(pResults);
    pResults = NULL;
    free(pSrcData);
    pSrcData = NULL;

    printf("Waiting for DSP ready\n");
    sem_wait(&hDspReadySem);
    printf("DSP ready for next test\n");

    rv = pXdmaMgr->deInit();
    if(rv != 0){
        return -1;
    }

    return 0;
}

void *waitingInterrupt(void *)
{
    uint32_t irqNum;
    uint16_t nInfo;

    for (;;){
        read(pXdmaMgr->m_nEvt0, &irqNum, 4);
        if(irqNum == 1){
            nInfo = pXdmaMgr->m_pSrio2Pcie->MSI_INFO[0] & 0xFFFF;
            switch (nInfo)
            {
            case SRIO_DBRX_STARTREQ:
                sem_post(&hTxSeqInfoReqSem);
                break;
            case SRIO_DBRX_STARTH2C:
                sem_post(&hTxFrameReqSem);
                break;
            case SRIO_DBRX_STARTC2H:
                sem_post(&hRxResultReqSem);
                break;
            case SRIO_DBRX_PROCDONE:
                sem_post(&hDspReadySem);
                break;
            default:
                break;
            }
        }
    }
    return NULL;
}
