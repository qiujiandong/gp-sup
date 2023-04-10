/**
 * @file CTspsManager.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
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
    CTspsManager();

public:
    /**
     * @brief Construct a new CTspsManager object
     */
    ~CTspsManager();

    /**
     * @brief Get the Instance object
     * 
     * @return CTspsManager* 
     */
    static CTspsManager *getInstance(){
        static CTspsManager tspsMgr;
        return &tspsMgr;
    }

    /**
     * @brief Hardware initialization
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

    /**
     * @brief 
     * 
     * @param pSrc 
     * @param pDst 
     * @param nSrcStride 
     * @param nDstStride 
     * @param nBlockWidth 
     * @param nBlockHeight 
     * @param nUnit 
     * @return int 
     */
    int startSubWindowExtract(
        void *restrict pSrc,
        void *restrict pDst,
        int nSrcStride,
        int nDstStride,
        int nBlockWidth,
        int nBlockHeight,
        size_t nUnit
    );
    void ClearInterruptFlag();
};

#endif
