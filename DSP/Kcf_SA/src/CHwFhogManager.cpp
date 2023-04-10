/**
 * @file CHwFhogManager.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-08
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "common.h"
#include "utils.h"
#include "CHwFhogManager.h"
#include "main.h"
#include <ti/sysbios/family/c66/tci66xx/CpIntc.h>

#define SRIO2PCIE_BASE_ADDR (0x7C030000)
#define RESIZE_DST_LEN (136)

CHwFhogManager::CHwFhogManager():
    m_hHwFhog(0)
{
    m_txBlockSize.width = 0;
    m_txBlockSize.height = 0;
}

CHwFhogManager::~CHwFhogManager()
{
}

int CHwFhogManager::calcResizeFactors(ResizeFactors *pFactors, int nSrcLen)
{
    if(pFactors == NULL){
        return -1;
    }

    int nBits = 0;
    int den = 1;
    float delta = 1.0;

    float fDstPos;
    float fRealPos;
    float eta;

    if(nSrcLen >= RESIZE_DST_LEN){
        eta = divsp_i(nSrcLen, RESIZE_DST_LEN);
    }
    else{
        eta = divsp_i(nSrcLen - 1, RESIZE_DST_LEN);
    }

    fDstPos = eta * (RESIZE_DST_LEN - 1);
    while(1){
        fRealPos = divsp_i((int)(eta * den) * (RESIZE_DST_LEN - 1), den);
        delta = fabs(fRealPos - fDstPos);
        if(delta < 0.5){
            break;
        }
        nBits += 1;
        den *= 2;
    }

    pFactors->num = (int)(eta * den);
    pFactors->logDen = nBits;
    return 0;
}

int CHwFhogManager::HwInit()
{
    m_hHwFhog = getHwFhogHandle(SRIO2PCIE_BASE_ADDR);
    hwFhogInit(m_hHwFhog, RXRESULT_SRCADDR, FEATUREMAP_SIZE);

    // call gpioConfig() in Srio2PcieManager.cpp HwInit()

    return 0;
}

int CHwFhogManager::startHwFhog(const CvRect *pRect, RealScale *pRealScale)
{
    ResizeFactors fw, fh;
    HwFhogParam param;

    if(m_hHwFhog == 0 || pRect == NULL || pRealScale == NULL){
        return -1;
    }
    // NOTE the image resize IP in FPGA only support 32k Bytes
    if(pRect->width * pRect->height > 32768){
        return -2;
    }

    param.nSize = (pRect->width << 16) + pRect->height;
    param.nStride = m_txBlockSize.width;
    param.nAbsAddr = TXBLOCK_DSTADDR + pRect->y * m_txBlockSize.width + pRect->x;

    calcResizeFactors(&fw, pRect->width);
    calcResizeFactors(&fh, pRect->height);

    if(fw.logDen > fh.logDen){
        fh.num *= 1 << (fw.logDen - fh.logDen);
    }
    else if(fw.logDen < fh.logDen){
        fw.num *= 1 << (fh.logDen - fw.logDen);
    }

    param.nScaleW = fw.num;
    param.nScaleH = fh.num;
    param.nScaleN = fw.logDen;

    setupHwFhog(m_hHwFhog, &param);

    pRealScale->fScaleW = divsp_i(param.nScaleW, 1 << param.nScaleN);
    pRealScale->fScaleH = divsp_i(param.nScaleH, 1 << param.nScaleN);

    return 0;
}

void CHwFhogManager::ClearInterruptFlag()
{
    // nothing todo
}
