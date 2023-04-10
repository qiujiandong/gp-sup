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

#include "CSrio2PcieManager.h"
#include "main.h"
#include <c6x.h>

extern CSrio2PcieManager *pSrio2PcieMgr;

extern "C" {
    Void MainTskFxn(UArg a0, UArg a1);
}

Void MainTskFxn(UArg a0, UArg a1)
{
    Error_Block eb;
    uint32_t *pTxBuf;
    uint32_t *pRxBuf;
    void *pResult;
    uint64_t *pTxTime;
    uint64_t *pRxTime;
    uint32_t nSize;
    int factor;

    uint64_t tStart;
    uint64_t tStop;

	int nTestCnt = 0;

    Error_init(&eb);

    pTxBuf = (uint32_t *)Memory_calloc((xdc_runtime_IHeap_Handle)hRxBufHeap, sizeof(uint32_t) * U32_DATA_CNT, 4096, &eb);
    if(pTxBuf == NULL){
        System_abort("Txbuf Memory calloc faild\n");
    }
    for (int i = 0; i < U32_DATA_CNT; ++i){
        pTxBuf[i] = i;
    }
    Cache_wb(pTxBuf, sizeof(uint32_t) * U32_DATA_CNT, Cache_Type_ALLD, TRUE);

    pRxBuf = (uint32_t *)Memory_calloc((xdc_runtime_IHeap_Handle)hRxBufHeap, sizeof(uint32_t) * U32_DATA_CNT, 4096, &eb);
    if(pRxBuf == NULL){
        System_abort("Rxbuf Memory calloc faild\n");
    }
    memset(pRxBuf, 0, sizeof(uint32_t) * U32_DATA_CNT);
    Cache_wb(pRxBuf, sizeof(uint32_t) * U32_DATA_CNT, Cache_Type_ALLD, TRUE);

    pResult = (float *)Memory_calloc((xdc_runtime_IHeap_Handle)hRxBufHeap, 256, 4096, &eb); // 256 / 8 = 32
    if(pResult == NULL){
        System_abort("ResultTime Memory calloc faild\n");
    }
    memset(pResult, 0, 256);
    Cache_wb(pResult, 256, Cache_Type_ALLD, TRUE);
    pTxTime = (uint64_t *)pResult;
    pRxTime = pTxTime + TEST_TIMES;

    TSCL = 0;

    // every cycle test tx and rx from size 256 to size 8388608(2^23)
    for (;;){
        // waiting for start
        System_printf("DSP waiting for test %d to start\n", nTestCnt++);
        Semaphore_pend(hRxDbStartReqSem, BIOS_WAIT_FOREVER);

        // tx data and read back
        factor = 1;
        for (int i = 0; i < TEST_TIMES; ++i){
            // determine size
            nSize = BASE_SIZE * factor;

            tStart = _itoll(TSCH, TSCL);
            pSrio2PcieMgr->startTxNwToPC(pTxBuf, nSize >> 3);
            Semaphore_pend(hTxNwDoneSem, BIOS_WAIT_FOREVER);
            tStop = _itoll(TSCH, TSCL);
            pTxTime[i] = tStop - tStart;

            memset(pRxBuf, 0, nSize);
            Cache_wbInv(pRxBuf, nSize, Cache_Type_ALLD, TRUE);
            tStart = _itoll(TSCH, TSCL);
            pSrio2PcieMgr->startTxFrameFromPC(pRxBuf, nSize >> 3);
            Semaphore_pend(hRxDbSwDoneSem, BIOS_WAIT_FOREVER);
            tStop = _itoll(TSCH, TSCL);
            pRxTime[i] = tStop - tStart;

            for (int j = 0; j < (nSize >> 2); ++j){
                if(pTxBuf[j] != pRxBuf[j]){
                    System_printf("Rx Data %d Error\n", j);
                    break;
                }
            }

            factor *= 2;
        }

        pSrio2PcieMgr->startTxNwToPC(pResult, 256 >> 3);
    }

    // Memory_free((xdc_runtime_IHeap_Handle)hRxBufHeap, pTxBuf, sizeof(uint32_t) * U32_DATA_CNT);
    // pTxBuf = NULL;
    // Memory_free((xdc_runtime_IHeap_Handle)hRxBufHeap, pRxBuf, sizeof(uint32_t) * U32_DATA_CNT);
    // pRxBuf = NULL;
    // Memory_free((xdc_runtime_IHeap_Handle)hRxBufHeap, pResult, 256);
    // pResult = NULL;
}
