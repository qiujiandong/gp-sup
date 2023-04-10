/**
 * @file CRxBufManager.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-01-04
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _CRXBUFMANAGER_H_
#define _CRXBUFMANAGER_H_

#include <stdint.h>
#include <csl_edma3.h>

class CRxBufManager
{
private:
    uint8_t *m_pBuf[2];
    int m_nRxInd;

    size_t m_nSize;
    void *m_pHeapHandle;

    CSL_Edma3ChannelHandle m_hCha;
	CSL_Edma3ChannelObj m_ChaObj;
    Bool m_bInitDone;

public:
    CRxBufManager();
    CRxBufManager(size_t bufSz, void *pHeapHandle);
    ~CRxBufManager();

    /**
     * @brief Hardware initialization
     * 
     * @return int 
     */
    int HwInit();

    /**
     * @brief start fill data into buffer(only for simulation)
     * 
     * @param pSrcAddr 
     * @return int 
     */
    int SimStartRxData(uint8_t *pSrcAddr);

    /**
     * @brief clear interrupt flag
     * 
     */
    void ClearInterruptFlag();

    uint8_t *getRxBuf(){
        return m_pBuf[m_nRxInd];
    }
    uint8_t *getOpBuf(){
        return m_pBuf[!m_nRxInd];
    }
    void flipIndex(){
        m_nRxInd = !m_nRxInd;
    }
};

#endif
