/**
 * @file CKcfTracker.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-01-06
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "main.h"

#include "CKcfTracker.h"
#include "utils.h"

CKcfTracker::CKcfTracker(
    CTspsManager * hTspsMgr,
    UInt16 nHeapId,
    UInt16 nCoreId,
    MessageQ_QueueId fftQueueId):
    m_fLearningRate(0.012),
    m_fProbSigmaFactor(0.125),
    m_fKernelSigma(0.6),
    m_fLambda(0.001),
    m_fPadding(2.5),
    m_fBaseScale(1.0),
    m_fScaleStep(1.05),
    m_fScaleW(1.0),
    m_fScaleH(1.0),
    m_fPeakWeight(0.95),
    m_pTmpl(NULL),
    m_pAlphaHat(NULL),
    m_pHann(NULL),
    m_pProb(NULL),
    m_pTmplDft(NULL),
    m_fTmplQsum(0.0),
    m_hTspsMgr(hTspsMgr),
    m_nHeapId(nHeapId),
    m_nCoreId(nCoreId),
    m_fftQueueId(fftQueueId)
{
    float *pTmplData, *pProbData, *pTmplDftData;
   
    m_iRoi = cvRect(0, 0, 0, 0);

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
    // FFTCmd cmd;
    // uint16_t nHeight = m_pProb->height;
    // uint16_t nWidth = m_pProb->width;
    float* pLine;

    Int16 status;
    FftMsgHandle hFftCmd;

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

    Cache_wbInv(pData, KCF_DFT_SIZE * KCF_DFT_SIZE * sizeof(float), Cache_Type_ALLD, TRUE);
    // FFT
    hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
    hFftCmd->eType = FFT2d_R2R;
    hFftCmd->nWidth = m_pProb->width;
    hFftCmd->nHeight = m_pProb->height;
    hFftCmd->pSrc = pData;
    hFftCmd->pDst = pData;
    hFftCmd->nReplyCoreId = m_nCoreId;
    // MessageQ_setMsgId(hFftCmd, MSG_C1FFT_ID);
    if(m_nCoreId == 1){
        MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
    }

    status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
    if(status < 0){
        System_abort("MessageQ put failed\n");
    }

    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);
}

/**
 * @brief Get the Features object
 * 
 * @param src 512x640 CV_8UC1 IR image
 * @param x 31x1024 CV_32FC1 feature map(31 channel 32x32 image)
 * @param fScaleAdj scale adjust based on ROI
 */
void CKcfTracker::getFeatures(const CvMat &src, CvMat *pX, float fScaleAdj)
{

#if PARTIAL_TIME
    UInt64 tStart;
    UInt64 tStop;

    tStart = _itoll(TSCH, TSCL);
#endif

    float fCx = m_iRoi.x + (m_iRoi.width - 1) / 2;
    float fCy = m_iRoi.y + (m_iRoi.height - 1) / 2;
    uint16_t nWidth = m_iRoi.width * m_fPadding * fScaleAdj;
    uint16_t nHeight = m_iRoi.height * m_fPadding * fScaleAdj;
    // TODO check rect to prevent it exceed border
    CvRect rect = cvRect(fCx - (nWidth - 1) / 2, fCy - (nHeight - 1) / 2, nWidth, nHeight);
    m_fScaleW = divsp_i(nWidth, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE);
    m_fScaleH = divsp_i(nHeight, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE);

    // get subrect
    CvMat subw;
    cvGetSubRect(&src, &subw, rect);
    
    // 1024x27
    CvMat *pFM = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3, CV_32FC1);
    getFeatureMaps(&subw, pFM);

    // 1024x108
    CvMat *pNorm = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 12, CV_32FC1);
    normalizeAndTruncate(pFM, pNorm);
    cvReleaseMat(&pFM);

    // 1024x31
    CvMat *pPca = cvCreateMat(KCF_DFT_SIZE * KCF_DFT_SIZE, KCF_REGION_NUM * 3 + 4, CV_32FC1);
    PCAFeatureMaps(pNorm, pPca);
    cvReleaseMat(&pNorm);

    // add window and transpose
    float *restrict pHann = (float *)cvPtr1D(m_pHann, 0);
    float *restrict pSrc = (float *)cvPtr1D(pPca, 0);
    float *restrict pDst = (float *)cvPtr1D(pX, 0);

    m_hTspsMgr->startTranspose(pSrc, pDst, pPca->width, pPca->height, sizeof(float));
    Cache_inv(pDst, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    Semaphore_pend(hTspsDoneSem, BIOS_WAIT_FOREVER);
    
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        // add window after transpose
        for (int j = 0; j < KCF_DFT_SIZE * KCF_DFT_SIZE; ++j){
            *pDst = pHann[j] * *pDst;
            ++pDst;
        }
    }
    cvReleaseMat(&pPca);

#if PARTIAL_TIME
    tStop = _itoll(TSCH, TSCL);
	System_printf("Get features Time: %f ns\n", (tStop - tStart)*1.0/1000);
#endif
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
    // FFTCmd cmd[KCF_REGION_NUM * 3 + 4];
    FftMsgHandle hFftCmd;
    Int status;

#if PARTIAL_TIME
    UInt64 tStart;
    UInt64 tStop;

    tStart = _itoll(TSCH, TSCL);
#endif

    Cache_inv((float *)cvPtr1D(&kxx, 0), sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, FALSE);

    float *pXHat = (float *)cvPtr1D(m_pTmplDft, 0);
    Cache_inv(pXHat, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, FALSE);

    float *restrict pXData = (float *)cvPtr1D(&x, 0);
    
    float *pSrcData = pXData;
    float *pDstData = pXHat;

    float * pSum = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);
    assert(pSum);
    memset(pSum, 0, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);

    Cplx *restrict pSumSrc = (Cplx *)pSum;
    Cplx * pSumDst = (Cplx *)pSum;

    // Cache_wb(pXData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    // FFT
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        Cache_wb(pSrcData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

        hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
        hFftCmd->eType = FFT2d_R2C;
        hFftCmd->nWidth = KCF_DFT_SIZE;
        hFftCmd->nHeight = KCF_DFT_SIZE;
        hFftCmd->pSrc = pSrcData;
        hFftCmd->pDst = pDstData;
        hFftCmd->nReplyCoreId = m_nCoreId;
        if(m_nCoreId == 1){
            MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
        }

        status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
        if(status < 0){
            System_abort("MessageQ put failed\n");
        }

        pSrcData += KCF_DFT_SIZE * KCF_DFT_SIZE;
        pDstData += KCF_DFT_SIZE * KCF_DFT_SIZE * 2;
    }

    // calc qsum
	m_fTmplQsum = 0.0;
	for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4); ++i){
		fTemp = *pXData++;
		m_fTmplQsum += fTemp * fTemp;
	}

    // Cache_inv(pXHat, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    // conjugate mult and sum

    double dMultSrc, dMultAns, dSumSrc;
    double *restrict pMultSrc = (double *)pXHat;

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

    // ifft
    Cache_wb(pSum, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, TRUE);

    hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
    hFftCmd->eType = IFFT2d_C2R;
    hFftCmd->nWidth = KCF_DFT_SIZE;
    hFftCmd->nHeight = KCF_DFT_SIZE;
    hFftCmd->pSrc = pSum;
    hFftCmd->pDst = (float *)cvPtr1D(&kxx, 0);
    hFftCmd->nReplyCoreId = m_nCoreId;
    if(m_nCoreId == 1){
        MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
    }

    status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
    if(status < 0){
        System_abort("MessageQ put failed\n");
    }

    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);
    // Cache_inv((float *)cvPtr1D(&kxx, 0), sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

    free(pSum);
    pSum = NULL;

    // exp
    float fFactor = _rcpsp(KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4) * m_fKernelSigma * m_fKernelSigma) * 2.0;
    float *restrict pExpSrc = (float *)cvPtr1D(&kxx, 0);

    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        *pExpSrc++ = expsp_i((*(pExpSrc) - m_fTmplQsum) * fFactor);
    }

#if PARTIAL_TIME
    tStop = _itoll(TSCH, TSCL);
	System_printf("Gauss auto-correlation Time: %f ns\n", (tStop - tStart)*1.0/1000);
#endif

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
    // FFTCmd cmd[KCF_REGION_NUM * 3 + 4];
    FftMsgHandle hFftCmd;
    Int status;

#if PARTIAL_TIME
    UInt64 tStart;
    UInt64 tStop;

    tStart = _itoll(TSCH, TSCL);
#endif

    Cache_inv((float *)cvPtr1D(&kzx, 0), sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, FALSE);

    float *pZHat = (float *)memalign(4096, sizeof(float) * 2 * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4));
    assert(pZHat);
    Cache_inv(pZHat, sizeof(float) * 2 * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, FALSE);

    float *restrict pTmplData = (float *)cvPtr1D(m_pTmpl, 0);
    float *restrict pZData = (float *)cvPtr1D(&z, 0);
    
    float *pSrcData = pZData;
    float *pDstData = pZHat;

    float * pSum = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);
    assert(pSum);
    memset(pSum, 0, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);

    double dMultAns, dSumSrc;
    double *restrict pMultZ = (double *)pZHat;
    double *restrict pMultX = (double *)cvPtr1D(m_pTmplDft, 0);
    Cplx *restrict pSumSrc = (Cplx *)pSum;
    Cplx * pSumDst = (Cplx *)pSum;

    // Cache_wb(pZData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
    // FFT
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){
        Cache_wb(pSrcData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

        hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
        hFftCmd->eType = FFT2d_R2C;
        hFftCmd->nWidth = KCF_DFT_SIZE;
        hFftCmd->nHeight = KCF_DFT_SIZE;
        hFftCmd->pSrc = pSrcData;
        hFftCmd->pDst = pDstData;
        hFftCmd->nReplyCoreId = m_nCoreId;
        // MessageQ_setMsgId(hFftCmd, MSG_C1FFT_ID);
        if(m_nCoreId == 1){
            MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
        }

        status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
        if(status < 0){
            System_abort("MessageQ put failed\n");
        }

        pSrcData += KCF_DFT_SIZE * KCF_DFT_SIZE;
        pDstData += KCF_DFT_SIZE * KCF_DFT_SIZE * 2;
    }

    // calc qsum
    m_fTmplQsum = 0.0;
    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4); ++i){
        fTemp = *pTmplData++;
        m_fTmplQsum += fTemp * fTemp;
    }

    // calc qsum
	float fTmplQSum = 0.0;
	for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4); ++i){
		fTemp = *pZData++;
		fTmplQSum += fTemp * fTemp;
	}

    // wait for template fft done
    for (int i = 0; i < (KCF_REGION_NUM * 3 + 4); ++i){
        Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);
    }

    // Cache_inv(pZHat, sizeof(float) * 2 * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4), Cache_Type_ALLD, TRUE);
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

    // ifft
    Cache_wb(pSum, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, TRUE);

    hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
    hFftCmd->eType = IFFT2d_C2R;
    hFftCmd->nWidth = KCF_DFT_SIZE;
    hFftCmd->nHeight = KCF_DFT_SIZE;
    hFftCmd->pSrc = pSum;
    hFftCmd->pDst = (float *)cvPtr1D(&kzx, 0);
    hFftCmd->nReplyCoreId = m_nCoreId;
    // MessageQ_setMsgId(hFftCmd, MSG_C1FFT_ID);
    if(m_nCoreId == 1){
        MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
    }

    status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
    if(status < 0){
        System_abort("MessageQ put failed\n");
    }

    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);
    Cache_inv((float *)cvPtr1D(&kzx, 0), sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

    free(pSum);
    pSum = NULL;

    // exp
    float fFactor = _rcpsp(KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4) * m_fKernelSigma * m_fKernelSigma);
    float *restrict pExpSrc = (float *)cvPtr1D(&kzx, 0);
    float fSub = m_fTmplQsum + fTmplQSum;

    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        *pExpSrc++ = expsp_i((*(pExpSrc) * 2.0 - fSub) * fFactor);
    }

#if PARTIAL_TIME
    tStop = _itoll(TSCH, TSCL);
	System_printf("Gauss cross-correlation Time: %f ns\n", (tStop - tStart)*1.0/1000);
#endif

    return;
}

/**
 * @brief update alpha and m_pTmpl
 * 
 * @param x 31x1024 CV_32FC1_DFT
 * @param fLearningRate learning rate 0 - 1
 */
void CKcfTracker::train(CvMat &x, float fLearningRate)
{
    // FFTCmd cmd[KCF_REGION_NUM * 3 + 4];
    FftMsgHandle hFftCmd;
    Int status;

    float *pKxxData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    assert(pKxxData);
    CvMat *pKxx = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(pKxx, KCF_DFT_SIZE, KCF_DFT_SIZE, CV_32FC1, pKxxData);

    gaussAutoCorrelation(x, *pKxx);

    Cache_wbInv(pKxxData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

    hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
    hFftCmd->eType = FFT2d_R2R;
    hFftCmd->nWidth = KCF_DFT_SIZE;
    hFftCmd->nHeight = KCF_DFT_SIZE;
    hFftCmd->pSrc = pKxxData;
    hFftCmd->pDst = pKxxData;
    hFftCmd->nReplyCoreId = m_nCoreId;
    // MessageQ_setMsgId(hFftCmd, MSG_C1FFT_ID);
    if(m_nCoreId == 1){
        MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
    }

    status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
    if(status < 0){
        System_abort("MessageQ put failed\n");
    }

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
}

/**
 * @brief calculate new pos
 * 
 * @param z f(z) = F^(-1)(kxz_hat \cdot alpha_hat)
 * @param fPeakValue return value
 * @return CvPoint2D32f 
 */
CvPoint2D32f CKcfTracker::detect(CvMat &z, float &fPeakValue)
{
    // FFTCmd cmd;
    FftMsgHandle hFftCmd;
    Int status;

    // pKzxData also used for f(z)
    float *pKzxData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    assert(pKzxData);
    CvMat *pKzx = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(pKzx, KCF_DFT_SIZE, KCF_DFT_SIZE, CV_32FC1, pKzxData);

    gaussCrossCorrelation(z, *pKzx);

    // FFT R2C normal
    float *pKzxHat = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2);
    assert(pKzxHat);
    Cache_inv(pKzxHat, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, FALSE);

    Cache_wbInv(pKzxData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

    hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
    hFftCmd->eType = FFT2d_R2C_N;
    hFftCmd->nWidth = KCF_DFT_SIZE;
    hFftCmd->nHeight = KCF_DFT_SIZE;
    hFftCmd->pSrc = pKzxData;
    hFftCmd->pDst = pKzxHat;
    hFftCmd->nReplyCoreId = m_nCoreId;
    if(m_nCoreId == 1){
        MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
    }

    // MessageQ_setMsgId(hFftCmd, MSG_C1FFT_ID);
    status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
    if(status < 0){
        System_abort("MessageQ put failed\n");
    }
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

    hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
    hFftCmd->eType = IFFT2d_C2R;
    hFftCmd->nWidth = KCF_DFT_SIZE;
    hFftCmd->nHeight = KCF_DFT_SIZE;
    hFftCmd->pSrc = pKzxHat;
    hFftCmd->pDst = pKzxData;
    hFftCmd->nReplyCoreId = m_nCoreId;
    if(m_nCoreId == 1){
        MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
    }

    // MessageQ_setMsgId(hFftCmd, MSG_C1FFT_ID);
    status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
    if(status < 0){
        System_abort("MessageQ put failed\n");
    }
    Semaphore_pend(hFFTDoneSem, BIOS_WAIT_FOREVER);

    free(pKzxHat);
    pKzxHat = NULL;

    // find max
    fPeakValue = 0.0;
    CvPoint nPt = cvPoint(0, 0);
    CvPoint2D32f ans = cvPoint2D32f(0.0, 0.0);
    float *restrict pFz = pKzxData;
    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        fTemp = *pFz++;
        if(fTemp > fPeakValue){
            fPeakValue = fTemp;
            nPt.x = i % KCF_DFT_SIZE;
            nPt.y = i / KCF_DFT_SIZE;
        }
    }

    ans.x = subPixelPeak(pKzxData[nPt.y * KCF_DFT_SIZE + (nPt.x + KCF_DFT_SIZE - 1) % KCF_DFT_SIZE],
                                 fPeakValue,
                                 pKzxData[nPt.y * KCF_DFT_SIZE + (nPt.x + KCF_DFT_SIZE + 1) % KCF_DFT_SIZE]);
    ans.y = subPixelPeak(pKzxData[((nPt.y + KCF_DFT_SIZE - 1) % KCF_DFT_SIZE) * KCF_DFT_SIZE + nPt.x],
                                 fPeakValue,
                                 pKzxData[((nPt.y + KCF_DFT_SIZE + 1) % KCF_DFT_SIZE) * KCF_DFT_SIZE + nPt.x]);
    ans.x += (nPt.x + (KCF_DFT_SIZE >> 1)) % KCF_DFT_SIZE - (KCF_DFT_SIZE >> 1);
    ans.y += (nPt.y + (KCF_DFT_SIZE >> 1)) % KCF_DFT_SIZE - (KCF_DFT_SIZE >> 1);

    free(pKzxData);
    pKzxData = NULL;
    cvFree(&pKzx);
    pKzx = NULL;

    return ans;
}

void CKcfTracker::init(const CvRect &roi, const CvMat &src)
{
#if TOTAL_TIME
    UInt64 tStart;
    UInt64 tStop;
#endif
    m_iRoi = roi;

    float *pTmplData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4));
    assert(pTmplData);
    CvMat *pTmpl = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(pTmpl, KCF_REGION_NUM * 3 + 4, KCF_DFT_SIZE * KCF_DFT_SIZE, CV_32FC1, pTmplData);

#if TOTAL_TIME
    tStart = _itoll(TSCH, TSCL);
#endif

    getFeatures(src, pTmpl, 1.0);
    train(*pTmpl, 1.0);

#if TOTAL_TIME
    tStop = _itoll(TSCH, TSCL);
	System_printf("Training Time: %f ns\n", (tStop - tStart)*1.0/1000);
#endif

    free(pTmplData);
    pTmplData = NULL;
    cvFree(&pTmpl);
    pTmpl = NULL;
}

CvRect CKcfTracker::update(const CvMat &src)
{
    float fPeak;
    CvPoint2D32f iLoc;
    FftMsgHandle hFftCmd;
    Int status;

#if TOTAL_TIME
    UInt64 tStart;
    UInt64 tStop;
#endif

    float *pTmplData = (float *)memalign(4096, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * (KCF_REGION_NUM * 3 + 4));
    assert(pTmplData);
    CvMat *pTmpl = (CvMat *)cvAlloc(sizeof(CvMat));
    cvInitMatHeader(pTmpl, KCF_REGION_NUM * 3 + 4, KCF_DFT_SIZE * KCF_DFT_SIZE, CV_32FC1, pTmplData);

#if TOTAL_TIME
    tStart = _itoll(TSCH, TSCL);
#endif

    // do template FFT when get features in new frame
    float *pSrcData = (float *)cvPtr1D(m_pTmpl, 0);
    float *pDstData = (float *)cvPtr1D(m_pTmplDft, 0);

    Cache_inv(pDstData, sizeof(float) * (KCF_REGION_NUM * 3 + 4) * KCF_DFT_SIZE * KCF_DFT_SIZE * 2, Cache_Type_ALLD, FALSE);

    // Cache_wb(pTmplData, sizeof(float) * (KCF_REGION_NUM * 3 + 4) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);
    for (int i = 0; i < KCF_REGION_NUM * 3 + 4; ++i){

        Cache_wb(pSrcData, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE, Cache_Type_ALLD, TRUE);

        hFftCmd = (FftMsgHandle)MessageQ_alloc(m_nHeapId, sizeof(FftMsg));
        hFftCmd->eType = FFT2d_R2C;
        hFftCmd->nWidth = KCF_DFT_SIZE;
        hFftCmd->nHeight = KCF_DFT_SIZE;
        hFftCmd->pSrc = pSrcData;
        hFftCmd->pDst = pDstData;
        hFftCmd->nReplyCoreId = m_nCoreId;
        // MessageQ_setMsgId(hFftCmd, MSG_C1FFT_ID);
        if(m_nCoreId == 1){
            MessageQ_setMsgPri(hFftCmd, MessageQ_HIGHPRI);
        }

        status = MessageQ_put(m_fftQueueId, (MessageQ_Msg)hFftCmd);
        if(status < 0){
            System_abort("MessageQ put failed\n");
        }

        pSrcData += KCF_DFT_SIZE * KCF_DFT_SIZE;
        pDstData += KCF_DFT_SIZE * KCF_DFT_SIZE * 2;
    }

    // detect
    getFeatures(src, pTmpl, 1.0);
    iLoc = detect(*pTmpl, fPeak);

    m_iRoi.x += (int)(iLoc.x * m_fScaleW * KCF_CELL_SIZE + 0.5);
    m_iRoi.y += (int)(iLoc.y * m_fScaleH * KCF_CELL_SIZE + 0.5);

#if TOTAL_TIME
    tStop = _itoll(TSCH, TSCL);
	System_printf("Detection Time: %f ns\n", (tStop - tStart)*1.0/1000);
#endif

#if TOTAL_TIME
    tStart = _itoll(TSCH, TSCL);
#endif
    // train
    getFeatures(src, pTmpl, 1.0);
    train(*pTmpl, m_fLearningRate);

#if TOTAL_TIME
    tStop = _itoll(TSCH, TSCL);
	System_printf("Training Time: %f ns\n", (tStop - tStart)*1.0/1000);
#endif

    free(pTmplData);
    pTmplData = NULL;
    cvFree(&pTmpl);
    pTmpl = NULL;

    return m_iRoi;
}
