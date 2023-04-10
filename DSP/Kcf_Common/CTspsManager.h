/**
 * @file CTspsManager.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-01-08
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _CTSPSMANAGER_H_
#define _CTSPSMANAGER_H_

#include <csl_edma3.h>

class CTspsManager
{
private:
    CSL_Edma3ChannelHandle m_hCha;
	CSL_Edma3ChannelObj m_ChaObj;
    Bool m_bInitDone;
    Int16 m_nCoreId;
    // Uint8 m_nQChaNum;
    Uint8 m_nRegion;
    UInt16 m_nParamNum;
    CSL_Edma3Que m_eQueNum;
    // Int m_nTCC;
    Int m_nChaNum;
    UInt m_nSysEvt;
    UInt m_nHostInt;

public:
    /**
     * @brief Construct a new CTspsManager object
     * 
     * @param nCoreId Only support Core1 an Core2
     */
    CTspsManager(Int16 nCoreId);
    ~CTspsManager();

    /**
     * @brief Hardware initialization
     * 
     * @param coreId Only support Core1 an Core2
     * @return int 
     */
    int HwInit();

    /**
     * @brief Start transpose
     * 
     * @param pSrc 
     * @param pDst 
     * @param nSrcWidth 
     * @param nSrcHeight 
     * @param nUnit 
     * @return int 
     */
    int startTranspose(
        void *restrict pSrc, 
        void *restrict pDst, 
        int nSrcWidth, 
        int nSrcHeight, 
        size_t nUnit);
    void ClearInterruptFlag();
};

#endif
