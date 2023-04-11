/**
 * @file CKcfTracker.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "CTspsManager.h"
#include "CSrio2PcieManager.h"
#include "CHwFhogManager.h"
#include "CKcfTracker.h"
#include "utils.h"
#include "main.h"

extern CTspsManager *pTspsMgr;
extern CSrio2PcieManager *pSrio2PcieMgr;
extern CHwFhogManager *pHwFhogMgr;

CKcfTracker::CKcfTracker():
    m_fLearningRate(0.012),
    m_fProbSigmaFactor(0.125),
    m_fKernelSigma(0.6),
    m_fLambda(0.001),
    m_fPadding(2.5),
    m_fBaseScale(1.0),
    m_fScaleStep(1.05),
    m_fScaleW(1.0),
    m_fScaleH(1.0),
    m_fAddScaleW(1.0),
    m_fAddScaleH(1.0),
    m_fPeakWeight(0.95),
    m_pTmpl(NULL),
    m_pAlphaHat(NULL),
    m_pHann(NULL),
    m_pProb(NULL),
    m_pTmplDft(NULL),
    m_fTmplQsum(0.0),
    m_bUpdatedFlag(0),
    m_pFFTCmd(NULL)
{
    float *pTmplData, *pProbData, *pTmplDftData;

    m_roiPt = cvPoint2D32f(0, 0);
    m_roiSz = cvSize2D32f(0, 0);

    m_pAlphaHat = cvCreateMat(KCF_DFT_SIZE, KCF_DFT_SIZE, CV_32FC1);
    assert(m_pAlphaHat);
    float *pAlphaData = (float *)cvPtr1D(m_pAlphaHat, 0);
    memset(pAlphaData, 0, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    m_pHann = cvCreateMat(KCF_DFT_SIZE, KCF_DFT_SIZE, CV_32FC1);
    assert(m_pHann);

    pProbData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    assert(pProbData);
    m_pProb = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(m_pProb, KCF_DFT_SIZE, KCF_DFT_SIZE, CV_32FC1, pProbData);

    pTmplData = (float *)memalign(4096, sizeof(float) * (KCF_REGION_NUM * 3 + 4) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    assert(pTmplData);
    memset(pTmplData, 0, sizeof(float) * (KCF_REGION_NUM * 3 + 4) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    m_pTmpl = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(m_pTmpl, KCF_REGION_NUM * 3 + 4, KCF_DFT_SIZE * KCF_DFT_SIZE, CV_32FC1, pTmplData);

    pTmplDftData = (float *)memalign(4096, sizeof(float) * (KCF_REGION_NUM * 3 + 4) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);
    assert(pTmplDftData);
    m_pTmplDft = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(m_pTmplDft, KCF_REGION_NUM * 3 + 4, KCF_DFT_SIZE * KCF_DFT_SIZE, CV_32FC2, pTmplDftData);

    m_pFFTCmd = malloc(sizeof(FFTCmd) * (KCF_REGION_NUM * 3 + 4));
    assert(m_pFFTCmd);
}

CKcfTracker::~CKcfTracker()
{
    float *pData;

    if (m_pHann) {
        cvReleaseMat(&m_pHann);
    }
    if (m_pAlphaHat) {
        cvReleaseMat(&m_pAlphaHat);
    }

    if (m_pTmplDft) {
        pData = (float *)cvPtr1D(m_pTmplDft, 0);
        free(pData);
        cvFree(&m_pTmplDft);
        m_pTmplDft = NULL;
    }
    if (m_pTmpl) {
        pData = (float *)cvPtr1D(m_pTmpl, 0);
        free(pData);
        cvFree(&m_pTmpl);
        m_pTmpl = NULL;
    }
    if (m_pProb) {
        pData = (float *)cvPtr1D(m_pProb, 0);
        free(pData);
        cvFree(&m_pProb);
        m_pProb = NULL;
    }
    if(m_pFFTCmd){
        free(m_pFFTCmd);
        m_pFFTCmd = NULL;
    }
}

void CKcfTracker::createHanningMats()
{
    float* pData = (float*)cvPtr1D(m_pHann, 0);
    memset(pData, 0, sizeof(float) * m_pHann->width * m_pHann->height);
    float *restrict pRow = new float[KCF_DFT_SIZE];
    assert(pRow);
    // float* pLine;
    int nCol, nRow;

    for (int i = 0; i < KCF_DFT_SIZE; ++i) {
        pRow[i] = 0.5 * (1.0 - cossp_i(2 * CV_PI * i / (KCF_DFT_SIZE - 1)));
    }

    nCol = 0;
    nRow = 0;
#pragma MUST_ITERATE(1024, , 4);
    for(int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        *pData = pRow[nCol] * pRow[nRow];
        ++pData;
        ++nCol;
        nCol %= KCF_DFT_SIZE;
        if(nCol == KCF_DFT_SIZE - 1){
            ++nRow;
        }
    }

    delete[] pRow;
    pRow = NULL;
}

void CKcfTracker::createGaussianPeak()
{
    uint16_t nDeltaX, nDeltaY;
    FFTCmd cmd;
    float* pLine;

    float* pData = (float*)cvPtr1D(m_pProb, 0);
    
    // float fSigma = sqrtsp_i(m_pProb->width * m_pProb->height) / m_fPadding * m_fProbSigmaFactor;
    float fSigma = KCF_DFT_SIZE * 1.0 / m_fPadding * m_fProbSigmaFactor;
    float fMult = -0.5f / (fSigma * fSigma);

    pLine = pData;
    for (int i = 0; i < KCF_DFT_SIZE; i++) {
        for (int j = 0; j < KCF_DFT_SIZE; j++) {
            nDeltaY = (i > KCF_DFT_SIZE / 2) ? KCF_DFT_SIZE - i : i;
            nDeltaX = (j > KCF_DFT_SIZE / 2) ? KCF_DFT_SIZE - j : j;
            *(pLine++)= expsp_i(fMult * (nDeltaX * nDeltaX + nDeltaY * nDeltaY));
        }
    }

    // FFT
    cmd.eType = FFT2d_R2R;
    cmd.nWidth = m_pProb->width;
    cmd.nHeight = m_pProb->height;
    cmd.pSrc = pData;
    cmd.pDst = pData;
    Queue_enqueue(hFFTQue, &cmd._elem);
    Semaphore_post(hFFTStartSem);
    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);
}

/**
 * @brief Get the Features object
 * 
 * @param pSrc 512x640 CV_8UC1 IR image
 * @param pX 31x1024 CV_32FC1 feature map(31 channel 32x32 image)
 * @param fScaleAdj scale adjust based on ROI
 */
void CKcfTracker::getFeatures(const CvMat &src, CvMat &x, float fScaleAdj)
{
    // CvMat *pSubw;
    CvMat subw, matFM, matNorm, matPCA;
    uint8_t *pSubwData;
    float *pFMData, *pNormData, *pPCAData;

    int nWidth;
    int nHeight;
    size_t nSubwSize;
    CvPoint lu, rd;

    uint8_t *pSrcData;
    uint8_t *pDstData;
    int xOffset;
    int yOffset;
    int blockWidth;
    int blockHeight;
    CvRect rect;

    bool bExceedBorder;

    Error_Block eb;
    Error_init(&eb);

    pPCAData = (float *)memalign(64, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4));
    assert(pPCAData);
    pNormData = (float *)memalign(64, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * KCF_REGION_NUM * 12);
    assert(pNormData);
    pFMData = (float *)memalign(64, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * KCF_REGION_NUM * 3);
    assert(pFMData);

    cvInitMatHeader(&matFM, KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3, CV_32FC1, pFMData);
    cvInitMatHeader(&matNorm, KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 12, CV_32FC1, pNormData);
    cvInitMatHeader(&matPCA, KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3 + 4, CV_32FC1, pPCAData);

    // 1024x27
    // CvMat *pFM = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3, CV_32FC1);

    nWidth = round(m_roiSz.width * m_fPadding * fScaleAdj);
    nHeight = round(m_roiSz.height * m_fPadding * fScaleAdj);

    lu.x = round(m_roiPt.x + (m_roiSz.width - nWidth) * 0.5);
    lu.y = round(m_roiPt.y + (m_roiSz.height - nHeight) * 0.5);
    rd.x = lu.x + nWidth - 1;
    rd.y = lu.y + nHeight - 1;

    bExceedBorder = lu.x < 0 || lu.y < 0 || rd.x > src.cols - 1 || rd.y > src.rows - 1;

    if(bExceedBorder){
        // pSubwData = (uint8_t *)malloc(sizeof(uint8_t) * nWidth * nHeight);
        nSubwSize = (sizeof(uint8_t) * nWidth * nHeight + 255) & (size_t)(-256);
        pSubwData = (uint8_t *)Memory_calloc((xdc_runtime_IHeap_Handle)hRxBufHeap, nSubwSize, 4096, &eb);
        assert(pSubwData);
        // pSubw = cvCreateMat(nHeight, nWidth, CV_8UC1);
        cvInitMatHeader(&subw, nHeight, nWidth, CV_8UC1, pSubwData);
        memset(pSubwData, 0, nSubwSize);
        Cache_wb(pSubwData, nSubwSize, Cache_Type_ALLD, TRUE);

        pDstData = pSubwData;
        if(lu.x < 0){
            xOffset = 0;
            pDstData += -lu.x;
        }
        else if(lu.x > src.cols - 1){
            xOffset = src.cols - 1;
        }
        else{
            xOffset = lu.x;
        }
        if(lu.y < 0){
            yOffset = 0;
            pDstData += (-lu.y) * subw.step;
        }
        else if(lu.y > src.rows - 1){
            yOffset = src.rows - 1;
        }
        else{
            yOffset = lu.y;
        }
        if(rd.x > src.cols - 1){
            blockWidth = src.cols - xOffset;
        }
        else{
            blockWidth = rd.x - xOffset + 1;
        }
        if(rd.y > src.rows - 1){
            blockHeight = src.rows - yOffset;
        }
        else{
            blockHeight = rd.y - yOffset + 1;
        }
        pSrcData = cvPtr2D(&src, yOffset, xOffset);
        pTspsMgr->startSubWindowExtract(pSrcData, pDstData, src.step, subw.step, blockWidth, blockHeight, sizeof(uint8_t));
        Cache_inv(cvPtr1D(&subw, 0), sizeof(uint8_t) * subw.step * subw.rows, Cache_Type_ALLD, TRUE);
        Semaphore_pend(hTspsDoneSem, BIOS_WAIT_FOREVER);
    }
    else{
        // pSubw = (CvMat *)cvAlloc(sizeof(CvMat));
        rect = cvRect(lu.x, lu.y, nWidth, nHeight);
        cvGetSubRect(&src, &subw, rect);
    }

    m_fScaleW = divsp_i(nWidth, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE);
    m_fScaleH = divsp_i(nHeight, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE);
    
    getFeatureMaps(&subw, &matFM);

    if(bExceedBorder){

        // free(subw.data.ptr);
        // subw.data.ptr = NULL;
        Memory_free((xdc_runtime_IHeap_Handle)hRxBufHeap, pSubwData, nSubwSize);
        pSubwData = NULL;
    }

    // 1024x108
    // CvMat *pNorm = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 12, CV_32FC1);
    normalizeAndTruncate(&matFM, &matNorm);
    // cvReleaseMat(&pFM);
    free(matFM.data.ptr);
    matFM.data.ptr = NULL;

    // 1024x31
    // CvMat *pPca = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3 + 4, CV_32FC1);
    PCAFeatureMaps(&matNorm, &matPCA);
    // cvReleaseMat(&pNorm);
    free(matNorm.data.ptr);
    matNorm.data.ptr = NULL;

    // add window and transpose
    float *restrict pHann = (float *)cvPtr1D(m_pHann, 0);
    float *restrict pSrcMap = (float *)cvPtr1D(&matPCA, 0);
    float *restrict pDstMap = (float *)cvPtr1D(&x, 0);

    pTspsMgr->startTranspose(pSrcMap, pDstMap, matPCA.width, matPCA.height, sizeof(float));
    Cache_inv(pDstMap, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    Semaphore_pend(hTspsDoneSem, BIOS_WAIT_FOREVER);

    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        // add window after transpose
        for (int j = 0; j < KCF_DFT_SIZE * KCF_DFT_SIZE; ++j){
            *pDstMap = pHann[j] * *pDstMap;
            ++pDstMap;
        }
    }
    // cvReleaseMat(&pPca);
    free(matPCA.data.ptr);
    matPCA.data.ptr = NULL;
}

/**
 * @brief prepare blocks to extract feature, assuming the first scale is the max scale
 * if maxSubw == NULL the max Subwindow will tx to FPGA
 * 
 * @param pSrc 
 * @param nScaleCnt 
 * @param pfScales 
 * @param pTxSize 
 * @param pBlocks 
 * @return int 
 */
int CKcfTracker::prepareBlock(
    const CvMat &src,
    CvRect *pBlock,
    CvMat *pSubw
){
    int nWidth;
    int nHeight;
    CvPoint lu, rd;
    size_t nSubwSize;
    uint8_t *pSrcData;
    uint8_t *pDstData;
    int xOffset;
    int yOffset;
    int blockWidth;
    int blockHeight;
    int status;

    bool bExceedBorder;

    uint8_t *pData;
    uint8_t *pResizedData;

    CvMat blockMat;
    CvMat resizedMat;

    Error_Block eb;

    if(pBlock == NULL){
        return -1;
    }
    Error_init(&eb);

    nWidth = round(m_roiSz.width * m_fPadding);
    nHeight = round(m_roiSz.height * m_fPadding);

    // the left-up and right-down coordinates in source imgae
    lu.x = round(m_roiPt.x + (m_roiSz.width - nWidth) * 0.5);
    lu.y = round(m_roiPt.y + (m_roiSz.height - nHeight) * 0.5);
    rd.x = lu.x + nWidth - 1;
    rd.y = lu.y + nHeight - 1;

    bExceedBorder = lu.x < 0 || lu.y < 0 || rd.x > src.cols - 1 || rd.y > src.rows - 1;

    if(pSubw != NULL && !bExceedBorder){
        cvGetSubRect(&src, pSubw, cvRect(lu.x, lu.y, nWidth, nHeight));
        return 0;
    }

    nSubwSize = (sizeof(uint8_t) * nWidth * nHeight + 255) & (size_t)(-256);

    pData = (uint8_t *)Memory_calloc((xdc_runtime_IHeap_Handle)hRxBufHeap, nSubwSize, 4096, &eb);
    if(pData == NULL){
        System_abort("Memory alloc failed for padding block\n");
    }
    memset(pData, 0, nSubwSize);
    Cache_wb(pData, nSubwSize, Cache_Type_ALLD, TRUE);

    xOffset = lu.x;
    yOffset = lu.y;
    pDstData = pData;

    if(lu.x < 0){
        xOffset = 0;
        pDstData += -lu.x;
    }
    else if(lu.x > src.cols - 1){
        xOffset = src.cols - 1;
    }

    if(lu.y < 0){
        yOffset = 0;
        pDstData += (-lu.y) * nWidth;
    }
    else if(lu.y > src.rows - 1){
        yOffset = src.rows - 1;
    }

    if(rd.x > src.cols - 1){
        blockWidth = src.cols - xOffset;
    }
    else{
        blockWidth = rd.x - xOffset + 1;
    }

    if(rd.y > src.rows - 1){
        blockHeight = src.rows - yOffset;
    }
    else{
        blockHeight = rd.y - yOffset + 1;
    }

    pSrcData = cvPtr2D(&src, yOffset, xOffset);
    pTspsMgr->startSubWindowExtract(pSrcData, pDstData, src.step, nWidth, blockWidth, blockHeight, sizeof(uint8_t));
    Cache_inv(pData, sizeof(uint8_t) * nWidth * nHeight, Cache_Type_ALLD, TRUE);
    Semaphore_pend(hTspsDoneSem, BIOS_WAIT_FOREVER);

    if(pSubw != NULL){
        cvInitMatHeader(pSubw, nHeight, nWidth, CV_8UC1, pData);
        return 1;
    }

    m_fAddScaleW = 1.0;
    m_fAddScaleH = 1.0;
    pBlock->x = 0;
    pBlock->y = 0;
    pBlock->width = nWidth;
    pBlock->height = nHeight;

    // NOTE: the hardware resize module using 128kB block ram for one quard of image
    if(ceil(nWidth * 0.5) * ceil(nHeight * 0.5) > 131072){
        
        System_printf("exceed block size\n");

        m_fAddScaleW = divsp_i(nWidth, FIXED_SCALE);
        m_fAddScaleH = divsp_i(nHeight, FIXED_SCALE);
        pResizedData = (uint8_t *)memalign(4096, sizeof(uint8_t) * FIXED_SCALE * FIXED_SCALE);
        assert(pResizedData);
        cvInitMatHeader(&blockMat, nHeight, nWidth, CV_8UC1, pData);
        cvInitMatHeader(&resizedMat, FIXED_SCALE, FIXED_SCALE, CV_8UC1, pResizedData);

        cvResize(&blockMat, &resizedMat);

        pBlock->width = FIXED_SCALE;
        pBlock->height = FIXED_SCALE;

        // tx block
        Cache_wb(pResizedData, FIXED_SCALE * FIXED_SCALE, Cache_Type_ALLD, TRUE);
        status = pSrio2PcieMgr->startTxNwToFPGA(pResizedData, (FIXED_SCALE * FIXED_SCALE) >> 3, TXBLOCK_DSTADDR);
        if(status != 0){
            System_abort("Nw tx HwFhog Block error!\n");
        }
        pHwFhogMgr->setTxBlockSize(cvSize(FIXED_SCALE, FIXED_SCALE));

        free(resizedMat.data.ptr);
        resizedMat.data.ptr = NULL;
    }
    else{
        // tx block
        Cache_wb(pData, nSubwSize, Cache_Type_ALLD, TRUE);
        status = pSrio2PcieMgr->startTxNwToFPGA(pData, nSubwSize >> 3, TXBLOCK_DSTADDR);
        if(status != 0){
            System_abort("Nw tx HwFhog Block error!\n");
        }
        pHwFhogMgr->setTxBlockSize(cvSize(nWidth, nHeight));
    }

    Memory_free((xdc_runtime_IHeap_Handle)hRxBufHeap, pData, nSubwSize);
    pData = NULL;

    return 0;
}

/**
 * @brief Get the Features By Hw Fhog object
 * 
 * @param pBlock 
 * @param pX 31x1024 CV_32FC1 feature map(31 channel 32x32 image)
 */
void CKcfTracker::getFeaturesByHwFhog(const CvRect &block, CvMat &x)
{
    int status;
    RealScale realScale;

    // start Hw FHOG
    status = pHwFhogMgr->startHwFhog(&block, &realScale);
    if(status != 0){
        System_abort("start HwFhog param error\n");
    }
    m_fScaleW = realScale.fScaleW * m_fAddScaleW;
    m_fScaleH = realScale.fScaleH * m_fAddScaleH;
    status = Semaphore_pend(hHwFhogDoneSem, 1000); // 1s
    if(status == 0){
        System_abort("HwFhog Timeout\n");
    }

    // start read data from DDR in FPGA
    pSrio2PcieMgr->startTxSwFromFPGA(cvPtr1D(&x, 0), FEATUREMAP_SIZE >> 3, RXRESULT_SRCADDR);
    Cache_inv(cvPtr1D(&x, 0), FEATUREMAP_SIZE, Cache_Type_ALLD, TRUE);
    status = Semaphore_pend(hRxDbSwFromFPGASem, BIOS_WAIT_FOREVER);
    if(status == 0){
        System_abort("HwFhog data readback Timeout\n");
    }
}

void CKcfTracker::getFeaturesBySw(const CvMat &subw, CvMat &x)
{
    CvMat matFM, matNorm, matPCA;
    float *pFMData, *pNormData, *pPCAData;

    pPCAData = (float *)memalign(64, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4));
    assert(pPCAData);
    pNormData = (float *)memalign(64, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * KCF_REGION_NUM * 12);
    assert(pNormData);
    pFMData = (float *)memalign(64, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * KCF_REGION_NUM * 3);
    assert(pFMData);

    cvInitMatHeader(&matFM, KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3, CV_32FC1, pFMData);
    cvInitMatHeader(&matNorm, KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 12, CV_32FC1, pNormData);
    cvInitMatHeader(&matPCA, KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3 + 4, CV_32FC1, pPCAData);

    // 1024x27
    // CvMat *pFM = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3, CV_32FC1);

    m_fScaleW = divsp_i(subw.cols, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE);
    m_fScaleH = divsp_i(subw.rows, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE);

    getFeatureMaps(&subw, &matFM);

    // 1024x108
    // CvMat *pNorm = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 12, CV_32FC1);
    normalizeAndTruncate(&matFM, &matNorm);
    // cvReleaseMat(&pFM);
    free(matFM.data.ptr);
    matFM.data.ptr = NULL;

    // 1024x31
    // CvMat *pPca = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3 + 4, CV_32FC1);
    PCAFeatureMaps(&matNorm, &matPCA);
    // cvReleaseMat(&pNorm);
    free(matNorm.data.ptr);
    matNorm.data.ptr = NULL;

    // add window and transpose
    float *restrict pHann = (float *)cvPtr1D(m_pHann, 0);
    float *restrict pSrcMap = (float *)cvPtr1D(&matPCA, 0);
    float *restrict pDstMap = (float *)cvPtr1D(&x, 0);

    pTspsMgr->startTranspose(pSrcMap, pDstMap, matPCA.width, matPCA.height, sizeof(float));
    Cache_inv(pDstMap, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    Semaphore_pend(hTspsDoneSem, BIOS_WAIT_FOREVER);

    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        // add window after transpose
        for (int j = 0; j < KCF_DFT_SIZE * KCF_DFT_SIZE; ++j){
            *pDstMap = pHann[j] * *pDstMap;
            ++pDstMap;
        }
    }
    // cvReleaseMat(&pPca);
    free(matPCA.data.ptr);
    matPCA.data.ptr = NULL;
}

/**
 * @brief Gaussian Auto-Correlation
 * 
 * @param x 31x1024 CV_32FC1_DFT feature map(31 channel 32x32 image)
 * @param kxx 32x32 CV_32FC1_DFT hatkxx = exp(Σ_c(||x||^2 + ||x||^2 - 2 * F^(-1)(x\hat\cdot x\hat*)))
 */
void CKcfTracker::gaussAutoCorrelation(const CvMat &x, CvMat &kxx)
{
    float fTemp;
    FFTCmd cmd[KCF_REGION_NUM * 3 + 4];

    Cache_inv((float *)cvPtr1D(&kxx, 0), sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, FALSE);

    float *pXHat = (float *)cvPtr1D(m_pTmplDft, 0);
    Cache_inv(pXHat, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, FALSE);

    float *pSrcData = (float *)cvPtr1D(&x, 0);
    float *pDstData = pXHat;

    Cache_wb(pSrcData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    // FFT
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        cmd[i].eType = FFT2d_R2C;
        cmd[i].nWidth = KCF_DFT_SIZE;
        cmd[i].nHeight = KCF_DFT_SIZE;
        cmd[i].pSrc = pSrcData;
        cmd[i].pDst = pDstData;
        Queue_enqueue(hFFTQue, &cmd[i]._elem);
        Semaphore_post(hFFTStartSem);
        pSrcData += KCF_DFT_SIZE * KCF_DFT_SIZE;
        pDstData += KCF_DFT_SIZE * KCF_DFT_SIZE * 2;
    }

    // calc qsum
    float *restrict pXData = (float *)cvPtr1D(&x, 0);
    float *restrict pfTmplQSum = &m_fTmplQsum;
	*pfTmplQSum = 0.0;
	for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4); ++i){
		fTemp = *pXData++;
		*pfTmplQSum += fTemp * fTemp;
	}

    double dMultSrc, dMultAns, dSumSrc;
    double *restrict pMultSrc = (double *)pXHat;
    float * pSum = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);
    assert(pSum);
    memset(pSum, 0, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);
    Cplx *restrict pSumSrc = (Cplx *)pSum;
    Cplx * pSumDst = (Cplx *)pSum;

    // conjugate mult and sum
    Cache_inv(pXHat, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);

        pSumSrc = (Cplx *)pSum;
        pSumDst = (Cplx *)pSum;
        for (int j = 0; j < KCF_DFT_SIZE * KCF_DFT_SIZE; ++j){
            dSumSrc = pSumSrc->d;
            pSumSrc++;
            dMultSrc = *(pMultSrc++);
            dMultAns = _complex_conjugate_mpysp(dMultSrc, dMultSrc);

            pSumDst->f[0] = _lof2(dSumSrc) + _hif2(dMultAns);
            pSumDst->f[1] = _hif2(dSumSrc) + _lof2(dMultAns);
            pSumDst++;
        }
    }

    Cache_wb(pSum, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, TRUE);

    // ifft
    cmd[0].eType = IFFT2d_C2R;
    cmd[0].nWidth = KCF_DFT_SIZE;
    cmd[0].nHeight = KCF_DFT_SIZE;
    cmd[0].pSrc = pSum;
    cmd[0].pDst = (float *)cvPtr1D(&kxx, 0);
    Queue_enqueue(hFFTQue, &cmd[0]._elem);
    Semaphore_post(hFFTStartSem);
    Cache_inv((float *)cvPtr1D(&kxx, 0), sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);
    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);
    
    free(pSum);
    pSum = NULL;

    // exp
    float fFactor = _rcpsp(KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4) * m_fKernelSigma * m_fKernelSigma) * 2.0;
    float *restrict pExpSrc = (float *)cvPtr1D(&kxx, 0);
    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        *pExpSrc++ = expsp_i((*(pExpSrc) - m_fTmplQsum) * fFactor);
    }

    return;
}

/**
 * @brief Gaussian Cross-Correlation
 * 
 * @param z 31x1024 CV_32FC1 feature map(31 channel 32x32 image)
 * @param kzx 32x32 CV_32FC1 hatkxx = exp(Σ_c(||x||^2 + ||z||^2 - 2 * F^(-1)(z\hat\cdot x\hat*)))
 */
void CKcfTracker::gaussCrossCorrelation(const CvMat &z, CvMat &kzx)
{
    float fTemp;
    FFTCmd cmd[KCF_REGION_NUM * 3 + 4];
    
    float *pZHat = (float *)memalign(4096, sizeof(float) * 2 * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4));
    assert(pZHat);

    float *pSrcData = (float *)cvPtr1D(&z, 0);
    float *pDstData = pZHat;

    Cache_wb(cvPtr1D(&z, 0), sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    // FFT
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        cmd[i].eType = FFT2d_R2C;
        cmd[i].nWidth = KCF_DFT_SIZE;
        cmd[i].nHeight = KCF_DFT_SIZE;
        cmd[i].pSrc = pSrcData;
        cmd[i].pDst = pDstData;
        Queue_enqueue(hFFTQue, &cmd[i]._elem);
        Semaphore_post(hFFTStartSem);
        pSrcData += KCF_DFT_SIZE * KCF_DFT_SIZE;
        pDstData += KCF_DFT_SIZE * KCF_DFT_SIZE * 2;
    }

    // calc qsum
	float fTmplQSum = 0.0;
    float *restrict pZData = (float *)cvPtr1D(&z, 0);
	for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4); ++i){
		fTemp = *pZData++;
		fTmplQSum += fTemp * fTemp;
	}

    float *restrict pTmplData = (float *)cvPtr1D(m_pTmpl, 0);
    float *restrict pfTmplQSum = &m_fTmplQsum;
    if(!m_bUpdatedFlag){
        // calc qsum
        *pfTmplQSum = 0.0;

        for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4); ++i){
            fTemp = *pTmplData++;
            *pfTmplQSum += fTemp * fTemp;
        }

        // wait for template fft done
        for (int i = 0; i < (KCF_REGION_NUM * 3 + 4); ++i){
            Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);
        }
        m_bUpdatedFlag = TRUE;
    }

    float * pSum = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);
    assert(pSum);
    memset(pSum, 0, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);

    double dMultAns, dSumSrc;
    double *restrict pMultZ = (double *)pZHat;
    double *restrict pMultX = (double *)cvPtr1D(m_pTmplDft, 0);
    Cplx *restrict pSumSrc = (Cplx *)pSum;
    Cplx * pSumDst = (Cplx *)pSum;

    Cache_inv(pZHat, sizeof(float) * 2 * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    // conjugate mult and sum
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);

        pSumSrc = (Cplx *)pSum;
        pSumDst = (Cplx *)pSum;
        for (int j = 0; j < KCF_DFT_SIZE * KCF_DFT_SIZE; ++j){
            dSumSrc = pSumSrc->d;
            pSumSrc++;
            dMultAns = _complex_conjugate_mpysp(*pMultX++, *pMultZ++);

            pSumDst->f[0] = _lof2(dSumSrc) + _hif2(dMultAns);
            pSumDst->f[1] = _hif2(dSumSrc) + _lof2(dMultAns);
            pSumDst++;
        }
    }

	free(pZHat);
	pZHat = NULL;

    Cache_wb(pSum, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, TRUE);
    // ifft
    cmd[0].eType = IFFT2d_C2R;
    cmd[0].nWidth = KCF_DFT_SIZE;
    cmd[0].nHeight = KCF_DFT_SIZE;
    cmd[0].pSrc = pSum;
    cmd[0].pDst = (float *)cvPtr1D(&kzx, 0);
    Queue_enqueue(hFFTQue, &cmd[0]._elem);
    Semaphore_post(hFFTStartSem);

    Cache_inv(cvPtr1D(&kzx, 0), sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);
    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);

    free(pSum);
    pSum = NULL;

    // exp
    float fFactor = _rcpsp(KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4) * m_fKernelSigma * m_fKernelSigma);
    float *restrict pExpSrc = (float *)cvPtr1D(&kzx, 0);
    float fSub = m_fTmplQsum + fTmplQSum;

    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        *pExpSrc++ = expsp_i((*(pExpSrc) * 2.0 - fSub) * fFactor);
    }

    return;
}

/**
 * @brief update alpha and m_pTmpl
 * 
 * @param x 31x1024 CV_32FC1_DFT
 * @param fLearningRate learning rate 0 - 1
 */
void CKcfTracker::train(CvMat& x, float fLearningRate)
{
    FFTCmd cmd;

    float *pKxxData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    assert(pKxxData);
    CvMat *pKxx = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(pKxx, KCF_DFT_SIZE, KCF_DFT_SIZE, CV_32FC1, pKxxData);

    gaussAutoCorrelation(x, *pKxx);

    Cache_wbInv(pKxxData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

    // FFT2d_R2R
    cmd.eType = FFT2d_R2R;
    cmd.nWidth = m_pProb->width;
    cmd.nHeight = m_pProb->height;
    cmd.pSrc = pKxxData;
    cmd.pDst = pKxxData;
    Queue_enqueue(hFFTQue, &cmd._elem);
    Semaphore_post(hFFTStartSem);
    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);

    // pAlpha = prob ./ (kxxhat + lambda)
    CvMat *pAlpha = cvCreateMat(KCF_DFT_SIZE, KCF_DFT_SIZE, CV_32FC1);
    assert(pAlpha);
    float *restrict pProbData = (float *)cvPtr1D(m_pProb, 0);
    float *restrict pKxxHat = pKxxData;
    float *restrict pAlphaData = (float *)cvPtr1D(pAlpha, 0);

    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        *pAlphaData++ = divsp_i(*pProbData++, (*pKxxHat++ + m_fLambda));
    }

    free(pKxxData);
    pKxxData = NULL;
    cvFree(&pKxx);
    pKxx = NULL;

    // update alpha and tmpl
    float fAntiLearningRate = 1- fLearningRate;
    
    // m_pAlphaHat 32x32
    float *restrict pAlphaDst = (float *)cvPtr1D(m_pAlphaHat, 0);
    pAlphaData = (float *)cvPtr1D(pAlpha, 0);
    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i) {
        *pAlphaDst++ = *pAlphaDst * fAntiLearningRate + *pAlphaData++ * fLearningRate;
    }
    cvReleaseMat(&pAlpha);

    // m_pTmpl 31x1024
    float *restrict pTmplData = (float *)cvPtr1D(m_pTmpl, 0);
    float *restrict pXData = (float *)cvPtr1D(&x, 0);
    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4); ++i) {
        *pTmplData++ = *pTmplData * fAntiLearningRate + *pXData++ * fLearningRate;
    }

    // do template FFT when get features in new frame
    float *pSrcData = (float *)cvPtr1D(m_pTmpl, 0);
    float *pDstData = (float *)cvPtr1D(m_pTmplDft, 0);

    Cache_inv(pDstData, sizeof(float) * (KCF_REGION_NUM * 3 + 4) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, TRUE);

    // Cache_wb(pTmplData, sizeof(float) * (KCF_REGION_NUM * 3 + 4) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){

        Cache_wb(pSrcData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

        ((FFTCmd*)m_pFFTCmd)[i].eType = FFT2d_R2C;
        ((FFTCmd*)m_pFFTCmd)[i].nWidth = KCF_DFT_SIZE;
        ((FFTCmd*)m_pFFTCmd)[i].nHeight = KCF_DFT_SIZE;
        ((FFTCmd*)m_pFFTCmd)[i].pSrc = pSrcData;
        ((FFTCmd*)m_pFFTCmd)[i].pDst = pDstData;
        Queue_enqueue(hFFTQue, &((FFTCmd*)m_pFFTCmd)[i]._elem);
        Semaphore_post(hFFTStartSem);
        pSrcData += KCF_DFT_SIZE * KCF_DFT_SIZE;
        pDstData += KCF_DFT_SIZE * KCF_DFT_SIZE * 2;
    }

    m_bUpdatedFlag = FALSE;
}

/**
 * @brief calculate new pos
 * 
 * @param z f(z) = F^(-1)(kxz_hat \cdot alpha_hat)
 * @param fPeakValue return value
 * @return CvPoint2D32f 
 */
CvPoint2D32f CKcfTracker::detect(CvMat &z, float *pfPeakValue)
{
    FFTCmd cmd;
    CvMat kzx;

    assert(pfPeakValue);

    // pKzxData also used for f(z)
    float *pKzxData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    assert(pKzxData);
    // CvMat *pKzx = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(&kzx, KCF_DFT_SIZE, KCF_DFT_SIZE, CV_32FC1, pKzxData);

    gaussCrossCorrelation(z, kzx);

    Cache_wbInv(pKzxData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

    // FFT R2C normal
    float *pKzxHat = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);
    assert(pKzxHat);

    cmd.eType = FFT2d_R2C_N;
    cmd.nWidth = m_pProb->width;
    cmd.nHeight = m_pProb->height;
    cmd.pSrc = pKzxData;
    cmd.pDst = pKzxHat;
    Queue_enqueue(hFFTQue, &cmd._elem);
    Semaphore_post(hFFTStartSem);
    Cache_inv(pKzxHat, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, TRUE);
    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);

    // calc f(z)*\hat = kzxHat \cdot alphaHat
    float fTemp;
    
    float *restrict pKzxHatData = pKzxHat;
    float *restrict pAlphaData = (float *)cvPtr1D(m_pAlphaHat, 0);
    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        fTemp = *pAlphaData++;
        *pKzxHatData++ = *pKzxHatData * fTemp;
        *pKzxHatData++ = *pKzxHatData * fTemp;
    }

    // IFFT
    Cache_wb(pKzxHat, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, TRUE);

    cmd.eType = IFFT2d_C2R;
    cmd.nWidth = m_pProb->width;
    cmd.nHeight = m_pProb->height;
    cmd.pSrc = pKzxHat;
    cmd.pDst = pKzxData;
    Queue_enqueue(hFFTQue, &cmd._elem);
    Semaphore_post(hFFTStartSem);
    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);

    free(pKzxHat);
    pKzxHat = NULL;

    // find max
    *pfPeakValue = 0.0;
    CvPoint nPt = cvPoint(0, 0);
    CvPoint2D32f ans = cvPoint2D32f(0.0, 0.0);
    float *restrict pFz = pKzxData;
    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        fTemp = *pFz++;
        if(fTemp > *pfPeakValue){
            *pfPeakValue = fTemp;
            nPt.x = i % KCF_DFT_SIZE;
            nPt.y = i / KCF_DFT_SIZE;
        }
    }

    ans.x = subPixelPeak(pKzxData[nPt.y * KCF_DFT_SIZE + (nPt.x + KCF_DFT_SIZE - 1) % KCF_DFT_SIZE],
                                 *pfPeakValue,
                                 pKzxData[nPt.y * KCF_DFT_SIZE + (nPt.x + KCF_DFT_SIZE + 1) % KCF_DFT_SIZE]);
    ans.y = subPixelPeak(pKzxData[((nPt.y + KCF_DFT_SIZE - 1) % KCF_DFT_SIZE) * KCF_DFT_SIZE + nPt.x],
                                 *pfPeakValue,
                                 pKzxData[((nPt.y + KCF_DFT_SIZE + 1) % KCF_DFT_SIZE) * KCF_DFT_SIZE + nPt.x]);
    ans.x += (nPt.x + (KCF_DFT_SIZE >> 1)) % KCF_DFT_SIZE - (KCF_DFT_SIZE >> 1);
    ans.y += (nPt.y + (KCF_DFT_SIZE >> 1)) % KCF_DFT_SIZE - (KCF_DFT_SIZE >> 1);

    free(pKzxData);
    pKzxData = NULL;

    return ans;
}

void CKcfTracker::init(const CvRect &roi, const CvMat &src)
{
    m_roiPt = cvPoint2D32f(roi.x, roi.y);
    m_roiSz = cvSize2D32f(roi.width, roi.height);

    CvMat tmpl;
    float *pTmplData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4));
    assert(pTmplData);
    cvInitMatHeader(&tmpl, KCF_REGION_NUM * 3 + 4, KCF_DFT_SIZE * KCF_DFT_SIZE, CV_32FC1, pTmplData);

#if HW_FHOG_MODE
    CvRect block;

    // txBlockToFPGA(&src, 1, &fScale, &block);
    prepareBlock(src, &block);
    getFeaturesByHwFhog(block, tmpl);
#else
    getFeatures(src, tmpl, (float)1.0);
#endif

    while(Semaphore_pend(hFFTDoneSem, BIOS_NO_WAIT));
    train(tmpl, (float)1.0);

    free(pTmplData);
    pTmplData = NULL;
}

CvRect CKcfTracker::update(const CvMat &src)
{
    CvMat tmpl;
    CvPoint2D32f iLoc;
    float fPeak;

    float *pTmplData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4));
    assert(pTmplData);
    cvInitMatHeader(&tmpl, KCF_REGION_NUM * 3 + 4, KCF_DFT_SIZE * KCF_DFT_SIZE, CV_32FC1, pTmplData);

    // detect
#if HW_FHOG_MODE

    CvRect block;

    // txBlockToFPGA(&src, 3, fScales, blocks);
    prepareBlock(src, &block);

    // the normal scale
    getFeaturesByHwFhog(block, tmpl);
    iLoc = detect(tmpl, &fPeak);

#else

    // detect
    getFeatures(src, tmpl, (float)1.0);
    iLoc = detect(tmpl, &fPeak);

#endif

    m_roiPt.x += iLoc.x * m_fScaleW * KCF_CELL_SIZE;
    m_roiPt.y += iLoc.y * m_fScaleH * KCF_CELL_SIZE;

    if(m_roiPt.x < 0){
        m_roiPt.x = 0;
    }
    else if(m_roiPt.x > src.cols - 1){
        m_roiPt.x = src.cols - 1;
    }

    if(m_roiPt.y < 0){
        m_roiPt.y = 0;
    }
    else if(m_roiPt.y > src.rows - 1){
        m_roiPt.y = src.rows - 1;
    }

    if(m_roiPt.x + m_roiSz.width - 1 > src.cols - 1){
        m_roiSz.width = src.cols - 1 - m_roiPt.x + 1;
    }

    if(m_roiPt.y + m_roiSz.height - 1 > src.rows - 1){
        m_roiSz.height = src.rows - 1 - m_roiPt.y + 1;
    }

#if HW_FHOG_MODE

    prepareBlock(src, &block);
    getFeaturesByHwFhog(block, tmpl);

#else

    getFeatures(src, tmpl, (float)1.0);

#endif

    train(tmpl, m_fLearningRate);

    free(pTmplData);
    pTmplData = NULL;

#if __DUBUG
    System_printf("ROI: x: %f, y: %f, width: %f, height: %f\n", m_roiPt.x, m_roiPt.y, m_roiSz.width, m_roiSz.height);
#endif

    return cvRect(m_roiPt.x, m_roiPt.y, m_roiSz.width, m_roiSz.height);
}
