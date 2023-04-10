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

#include "CXdmaManager.h"
#include "Srio2PcieLLD.h"
#include "main.h"

using namespace std;

CXdmaManager *pXdmaMgr;

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
    rv = pXdmaMgr->init();
    if(rv != 0){
        cout << "xdma init failed" << endl;
        return -1;
    }
// end of init

    pXdmaMgr->getRegValues();

    rv = pXdmaMgr->deInit();
    if(rv != 0){
        return -1;
    }

    return 0;
}
