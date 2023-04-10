/**
 * @file CXdmaManager.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-01
 * 
 * @copyright Copyright (c) 2023
 * 
 */


#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <sys/mman.h>

#include "CXdmaManager.h"

CXdmaManager::CXdmaManager():
    m_nCtrl(-1),
    m_nUser(-1),
    m_nH2C(-1),
    m_nC2H(-1),
    m_nEvt0(-1),
    m_pCtrlBase(NULL),
    m_pSrio2Pcie(NULL),
    m_hWaitInt(0)
{
}

CXdmaManager::~CXdmaManager()
{
}

int CXdmaManager::init()
{
    m_nCtrl = open(CTRL_DEV_NAME, O_RDWR | O_SYNC);
    if(m_nCtrl < 0){
        printf("open ctrl error\n");
        return -1;
    }
    m_pCtrlBase = mmap(NULL, CTRL_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, m_nCtrl, 0);
    
    m_nUser = open(USER_DEV_NAME, O_RDWR | O_SYNC);
    if(m_nUser < 0){
        printf("open user error\n");
        return -1;
    }
    m_pSrio2Pcie = (Srio2PcieHandle)mmap(NULL, USER_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, m_nUser, 0x10000);

    m_nH2C = open(H2C_DEV_NAME, O_RDWR);
    if(m_nH2C < 0){
        printf("open h2c error\n");
        return -1;
    }
    m_nC2H = open(C2H_DEV_NAME, O_RDWR | O_NONBLOCK);
    if(m_nC2H < 0){
        printf("open c2h error\n");
        return -1;
    }
    m_nEvt0 = open(EVENT_DEV_NAME, O_RDONLY);
    if(m_nEvt0 < 0){
        printf("open event0 error\n");
        return -1;
    }
    pthread_create(&m_hWaitInt, NULL, waitingInterrupt, NULL);

    return 0;
}

int CXdmaManager::deInit()
{
    if(m_pCtrlBase){
        munmap(m_pCtrlBase, CTRL_MAP_SIZE);
        m_pCtrlBase = NULL;
    }
    if(m_pSrio2Pcie){
        munmap(m_pSrio2Pcie, USER_MAP_SIZE);
        m_pSrio2Pcie = NULL;
    }
    if(m_nCtrl > 2){
        close(m_nCtrl);
        m_nCtrl = -1;
    }
    if(m_nUser > 2){
        close(m_nUser);
        m_nUser = -1;
    }
    if(m_nH2C > 2){
        close(m_nH2C);
        m_nH2C = -1;
    }
    if(m_nC2H > 2){
        close(m_nC2H);
        m_nC2H = -1;
    }
    if(m_nEvt0 > 2){
        pthread_cancel(m_hWaitInt);
        pthread_join(m_hWaitInt, NULL);
        close(m_nEvt0);
        m_nEvt0 = -1;
    }
    return 0;
}

int CXdmaManager::sendDB(uint16_t nInfo)
{
    uint32_t nTemp;
    nTemp = m_pSrio2Pcie->DB_TXINFO;
    m_pSrio2Pcie->DB_TXINFO = (nTemp & 0xFFFF0000u) | nInfo;

    nTemp = m_pSrio2Pcie->SRIO_CSR;
    if (nTemp & 0x1){
        return -1;
    }
    m_pSrio2Pcie->SRIO_CSR = (nTemp & 0xFFFFFFFE) | 0x1;
    return 0;
}

int CXdmaManager::startH2C(void *pBuf, uint32_t nLen)
{
    if(pBuf == NULL){
        return -1;
    }
    lseek(m_nH2C, 0, SEEK_SET);
    return write(m_nH2C, pBuf, nLen);
}

int CXdmaManager::startC2H(void *pBuf, uint32_t nLen)
{
    if(pBuf == NULL){
        return -1;
    }
    lseek(m_nC2H, 0, SEEK_SET);
    return read(m_nC2H, pBuf, nLen);
}
