/**
 * @file CKcfTracker.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-09-07
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#ifndef _CKCFTRACKER_H_
#define _CKCFTRACKER_H_

#include <cv.h>

#define KCF_REGION_NUM  (9)
#define KCF_DFT_SIZE    (32)
#define KCF_CELL_SIZE   (4)

#define FIXED_SCALE (136)

typedef union Cplx
{
    double d;
    float f[2];
} Cplx;

class CKcfTracker
{
// NOTE: change protect to public to test time in Update
private:
    float m_fLearningRate;      // Template linear update learning rate
    float m_fProbSigmaFactor;   // y(Prob) is an 2 dimensional gaussian function
    float m_fKernelSigma;       // Gaussian kernel function sigma
    float m_fLambda;            // Regularizaion factor
    float m_fPadding;           // image padding factor
    float m_fBaseScale;
    float m_fScaleStep;         // scale step for multi-scale estimation
    float m_fScaleW;
    float m_fScaleH;
    float m_fAddScaleW;
    float m_fAddScaleH;
    float m_fPeakWeight;        // to downweight detection scores of other scales for added stability

    CvPoint2D32f m_roiPt;
    CvSize2D32f m_roiSz;
    CvMat *m_pTmpl;             // 31x1024 CV_32FC1
    CvMat *m_pAlphaHat;         // 32x32 CV_32FC1
    CvMat *m_pHann;             // 32x32 CV_32FC1
    CvMat *m_pProb;             // 32x32 CV_32FC1

    CvMat *m_pTmplDft;          // 31x1024 CV_32FC2
    float m_fTmplQsum;

    bool m_bUpdatedFlag; // indicating the m_pTempDft and m_fTemplQsum is updated
    void *m_pFFTCmd;// for m_pTmpl do FFT

public:
    CKcfTracker();
    ~CKcfTracker();
    /**
     * @brief Get the Features object
     * 
     * @param src 512x640 CV_8UC1 IR image
     * @param x 31x1024 CV_32FC1 feature map(31 channel 32x32 image)
     * @param fScaleAdj scale adjust based on ROI
     */
    void getFeatures(const CvMat &src, CvMat &x, float fScaleAdj);

    /**
     * @brief prepare blocks to extract feature, assuming the first scale is the max scale
     * if maxSubw == NULL the max Subwindow will tx to FPGA
     * 
     * @param pSrc 
     * @param pBlock block in hw
     * @return int 
     */
    int prepareBlock(
        const CvMat &src,
        CvRect *pBlock,
        CvMat *pSubw = NULL);

    /**
     * @brief Get the Features By Hw Fhog object
     *
     * @param block
     * @param x 31x1024 CV_32FC1 feature map(31 channel 32x32 image)
     */
    void getFeaturesByHwFhog(const CvRect &block, CvMat &x);

    void getFeaturesBySw(const CvMat &subw, CvMat &x);

    /**
     * @brief Gaussian Auto-Correlation
     * 
     * @param x 31x1024 CV_32FC1_DFT feature map(31 channel 32x32 image)
     * @param kxx 32x32 CV_32FC1_DFT hatkxx = exp(Σ_c(||x||^2 + ||x||^2 - 2 * F^(-1)(x\hat\cdot x\hat*)))
     */
    void gaussAutoCorrelation(const CvMat &x, CvMat &kxx);

    /**
     * @brief Gaussian Cross-Correlation
     * 
     * @param z 31x1024 CV_32FC1 feature map(31 channel 32x32 image)
     * @param kzx 32x32 CV_32FC1 hatkxx = exp(Σ_c(||x||^2 + ||z||^2 - 2 * F^(-1)(z\hat\cdot x\hat*)))
     */
    void gaussCrossCorrelation(const CvMat &z, CvMat &kzx);

    /**
     * @brief update alpha and m_pTmpl
     * 
     * @param x 31x1024 CV_32FC1_DFT
     * @param fLearningRate learning rate 0 - 1
     */
    void train(CvMat &x, float fLearningRate);

    /**
     * @brief calculate new pos
     * 
     * @param z f(z) = F^(-1)(kxz_hat \cdot alpha_hat)
     * @param fPeakValue return value
     * @return CvPoint2D32f 
     */
    CvPoint2D32f detect(CvMat &z, float *pfPeakValue);

    void createHanningMats();
	void createGaussianPeak();

    void init(const CvRect &roi, const CvMat &src);
    CvRect update(const CvMat &src);

    void setupROI(const CvRect &roi){
        m_roiPt.x = roi.x;
        m_roiPt.x = roi.y;
        m_roiSz.width = roi.width;
        m_roiSz.height = roi.height;
    }
};

#endif
