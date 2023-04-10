/**
 * @file CHwFhogManager.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-08
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include <cv.h>
#include "HwFhogLLD.h"

#define TXBLOCK_DSTADDR (0x00000000)
#define RXRESULT_SRCADDR (0x10000000)
#define FEATUREMAP_SIZE (0x1F000)

typedef struct
{
    int num;
    int logDen;
} ResizeFactors;

typedef struct
{
    float fScaleW;
    float fScaleH;
} RealScale;

class CHwFhogManager
{
private:
    HwFhogHandle m_hHwFhog;
    CvSize m_txBlockSize;
    CHwFhogManager();
    int calcResizeFactors(ResizeFactors *pFactors, int nSrcLen);

public:
    ~CHwFhogManager();
    static CHwFhogManager *getInstance(){
        static CHwFhogManager hwFhogMgr;
        return &hwFhogMgr;
    }

    int HwInit();
    void setTxBlockSize(CvSize sz){
        m_txBlockSize = sz;
    }
    int startHwFhog(const CvRect *pRect, RealScale *pRealScale);
    void ClearInterruptFlag();
};
