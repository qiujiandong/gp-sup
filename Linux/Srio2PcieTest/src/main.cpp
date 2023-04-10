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
#include <string.h>
#include <semaphore.h>

#include "CXdmaManager.h"
#include "Srio2PcieLLD.h"
#include "main.h"

using namespace std;

CXdmaManager *pXdmaMgr;

sem_t hTxDataSem;
sem_t hRxDataSem;

int main(int argc, char *argv[])
{    
    void *pBuffer;
    void *pResult;

    uint64_t *pTxTime;
    uint64_t *pRxTime;

    FILE *fResults;

    uint32_t nSize;
    int factor;
    int rv;

    pXdmaMgr = CXdmaManager::getInstance();

// init
    sem_init(&hRxDataSem, 0, 0);
    sem_init(&hTxDataSem, 0, 0);

    rv = pXdmaMgr->init();
    if(rv != 0){
        cout << "xdma init failed" << endl;
        return -1;
    }
// end of init

// allocate data
    rv = posix_memalign(&pBuffer, 4096, sizeof(uint32_t) * U32_DATA_CNT);
    if(rv != 0){
        cout << "source data allocate failed" << endl;
        return -1;
    }
    rv = posix_memalign(&pResult, 4096, RESULT_SIZE);
    if(rv != 0){
        cout << "result data allocate failed" << endl;
        return -1;
    }
    memset(pResult, 0, RESULT_SIZE);
    pTxTime = (uint64_t *)pResult;
    pRxTime = pTxTime + TEST_TIMES;
// end of allocate data

    // request for start
    pXdmaMgr->sendDB(SRIO_DBTX_STARTREQ);
    cout << "start test" << endl;

    factor = 1;

    for (int i = 0; i<TEST_TIMES; ++i){
        nSize = BASE_SIZE * factor;

        sem_wait(&hRxDataSem);
        if(pXdmaMgr->startC2H(pBuffer, nSize) == -1){
            cout << "Read timeout" << endl;
        };
        pXdmaMgr->sendDB(SRIO_DBTX_NWRXDONE);

        sem_wait(&hTxDataSem);
        if(pXdmaMgr->startH2C(pBuffer, nSize) != nSize){
            cout << "Write Error" << endl;
        }

        factor *= 2;
    }

// rx results
    cout << "waiting for result" << endl;
    sem_wait(&hRxDataSem);
    if(pXdmaMgr->startC2H(pResult, RESULT_SIZE) == -1){
        cout << "result rx timeout" << endl;
    }
    else{
        cout << "result rx done" << endl;
    }

    fResults = fopen("results.txt", "w");
    for (int i = 0; i < TEST_TIMES; ++i){
        fprintf(fResults, "%ld\n", pTxTime[i]);
    }
    for (int i = 0; i < TEST_TIMES; ++i){
        fprintf(fResults, "%ld\n", pRxTime[i]);
    }
    fclose(fResults);
    fResults = NULL;
// end of rx results

    free(pResult);
    pResult = NULL;
    free(pBuffer);
    pBuffer = NULL;

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
            case SRIO_DBRX_STARTH2C:
                sem_post(&hTxDataSem);
                break;
            case SRIO_DBRX_STARTC2H:
                sem_post(&hRxDataSem);
                break;
            default:
                break;
            }
        }
    }
    return NULL;
}
