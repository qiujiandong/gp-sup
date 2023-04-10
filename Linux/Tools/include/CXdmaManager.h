/**
 * @file CXdmaManager.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-01
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _C_XDMA_MANAGER_H_
#define _C_XDMA_MANAGER_H_

#include <stdint.h>
#include <pthread.h>

#include "Srio2PcieLLD.h"
#include "HwFhogLLD.h"

#define H2C_DEV_NAME "/dev/xdma0_h2c_0"
#define C2H_DEV_NAME "/dev/xdma0_c2h_0"
#define CTRL_DEV_NAME "/dev/xdma0_control"
#define USER_DEV_NAME "/dev/xdma0_user"
#define EVENT_DEV_NAME "/dev/xdma0_events_0"

#define USER_MAP_SIZE (0x10000u)
#define CTRL_MAP_SIZE (0x10000u)

extern void *waitingInterrupt(void *);

class CXdmaManager
{
private:
    int m_nUser;
    int m_nH2C;
    int m_nC2H;
    Srio2PcieHandle m_pSrio2Pcie;
    HwFhogHandle m_pHwFhog;

    CXdmaManager();

public:
    ~CXdmaManager();
    static CXdmaManager*getInstance(){
        static CXdmaManager xdmaMgr;
        return &xdmaMgr;
    }

    int init();
    int deInit();
    int sendDB(uint16_t nInfo);
    int startH2C(void *pBuf, uint32_t nLen);
    int startC2H(void *pBuf, uint32_t nLen);
    void getRegValues();
    void getHwFhogRegs();
};

#endif
