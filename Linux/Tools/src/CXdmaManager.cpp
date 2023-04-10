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
    m_nUser(-1),
    m_nH2C(-1),
    m_nC2H(-1),
    m_pSrio2Pcie(NULL)
{
}

CXdmaManager::~CXdmaManager()
{
}

int CXdmaManager::init()
{
    m_nUser = open(USER_DEV_NAME, O_RDWR | O_SYNC);
    if(m_nUser < 0){
        printf("open user error\n");
        return -1;
    }
    m_pSrio2Pcie = (Srio2PcieHandle)mmap(NULL, USER_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, m_nUser, 0x10000);
    m_pHwFhog = (HwFhogHandle)mmap(NULL, USER_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, m_nUser, 0x30000);
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

    return 0;
}

int CXdmaManager::deInit()
{
    if(m_pSrio2Pcie){
        munmap(m_pSrio2Pcie, USER_MAP_SIZE);
        munmap(m_pHwFhog, USER_MAP_SIZE);
        m_pSrio2Pcie = NULL;
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
    write(m_nH2C, pBuf, nLen);
    return 0;
}

int CXdmaManager::startC2H(void *pBuf, uint32_t nLen)
{
    if(pBuf == NULL){
        return -1;
    }
    lseek(m_nC2H, 0, SEEK_SET);
    return read(m_nC2H, pBuf, nLen);
}

void CXdmaManager::getRegValues()
{
    printf("Itendify: \t%08x\n", m_pSrio2Pcie->IDENTIFY);
    printf("SRIO CSR: \t%08x\n", m_pSrio2Pcie->SRIO_CSR);
    printf("SRIO Mode:\t%08x\n", m_pSrio2Pcie->SRIO_MODE);
    printf("SW Size:  \t%08x\n", m_pSrio2Pcie->SW_SIZE);
    printf("SW Dst:   \t%08x\n", m_pSrio2Pcie->SW_DST);
    printf("SW Src:   \t%08x\n", m_pSrio2Pcie->SW_SRC);
    printf("DB TX info:\t%08x\n", m_pSrio2Pcie->DB_TXINFO);
    printf("MSI CSR:  \t%08x\n", m_pSrio2Pcie->MSI_CSR);
    for(int i = 0; i<16; ++i){
        printf("MSI INFO %d:\t%08x\n", i, m_pSrio2Pcie->MSI_INFO[i]);
    }   
}

void CXdmaManager::getHwFhogRegs()
{
    printf("MB_CTRL:  \t%08x\n", m_pHwFhog->MB_CTRL);
    printf("RD_WR_IRQ:\t%08x\n", m_pHwFhog->RD_WR_IRQ);
    printf("RSVD0:    \t%08x\n", m_pHwFhog->RSVD0);
    printf("SOFT_TRIG \t%08x\n", m_pHwFhog->SOFT_TRIG);
    printf("RSVD1:    \t%08x\n", m_pHwFhog->RSVD1);
    printf("RD_CFG1:  \t%08x\n", m_pHwFhog->RD_CFG1);
    printf("RD_CFG2:  \t%08x\n", m_pHwFhog->RD_CFG2);
    printf("RD_CFG3:  \t%08x\n", m_pHwFhog->RD_CFG3);
    printf("RD_CFG4:  \t%08x\n", m_pHwFhog->RD_CFG4);
    printf("RD_CFG5:  \t%08x\n", m_pHwFhog->RD_CFG5);
    printf("WR_CFG1:  \t%08x\n", m_pHwFhog->WR_CFG1);
    printf("WR_CFG2:  \t%08x\n", m_pHwFhog->WR_CFG2);
    printf("RESULT_ADDR:\t%08x\n", m_pHwFhog->RESULT_ADDR);
    printf("RESULT_SIZE:\t%08x\n", m_pHwFhog->RESULT_SIZE);
    printf("WR_CFG5:  \t%08x\n", m_pHwFhog->WR_CFG5);
    printf("FHOG_START:\t%08x\n", m_pHwFhog->FHOG_START);
    printf("FHOG_SIZE:\t%08x\n", m_pHwFhog->FHOG_SIZE);
    printf("ABS_ADDR: \t%08x\n", m_pHwFhog->ABS_ADDR);
    printf("STRIDE:   \t%08x\n", m_pHwFhog->STRIDE);
    printf("SCALEH:   \t%08x\n", m_pHwFhog->SCALEH);
    printf("SCALEW:   \t%08x\n", m_pHwFhog->SCALEW);
    printf("SCALEN:   \t%08x\n", m_pHwFhog->SCALEN);
}
