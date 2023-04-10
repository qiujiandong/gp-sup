/**
 * @file utils.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "utils.h"

#define KCF_DFT_SIZE (32)
#define KCF_REGION_NUM (9)
#define KCF_CELL_SIZE (4)

typedef uint8_t OriData[2];
typedef float DxDyData[2];
typedef float NormData[4];

/* ti_math_kTable */
const double ti_math_kTable[4] = {
	1.000000000,              /* 2^(0/4) */
	1.189207115,              /* 2^(1/4) */
	1.414213562,              /* 2^(2/4) */
	1.681792831               /* 2^(3/4) */
};

/* ti_math_jTable */
const double ti_math_jTable[4] = {
	1.000000000,              /* 2^(0/16) */
	1.044273782,              /* 2^(1/16) */
	1.090507733,              /* 2^(2/16) */
	1.138788635               /* 2^(3/16) */
};

const float boundary_x[9] = {
    1.000000E00,
    9.396926E-01,
    7.660444E-01,
    5.000000E-01,
    1.736482E-01,
    -1.736482E-01,
    -5.000000E-01,
    -7.660444E-01,
    -9.396926E-01};

const float boundary_y[9] = {
    0.000000E00,
    3.420201E-01,
    6.427876E-01,
    8.660254E-01,
    9.848078E-01,
    9.848078E-01,
    8.660254E-01,
    6.427876E-01,
    3.420201E-01};

const float factors[64] = {
    1.56250e-02, 4.68750e-02, 7.81250e-02, 1.09375e-01, 1.09375e-01, 7.81250e-02, 4.68750e-02, 1.56250e-02,
    4.68750e-02, 1.40625e-01, 2.34375e-01, 3.28125e-01, 3.28125e-01, 2.34375e-01, 1.40625e-01, 4.68750e-02,
    7.81250e-02, 2.34375e-01, 3.90625e-01, 5.46875e-01, 5.46875e-01, 3.90625e-01, 2.34375e-01, 7.81250e-02,
    1.09375e-01, 3.28125e-01, 5.46875e-01, 7.65625e-01, 7.65625e-01, 5.46875e-01, 3.28125e-01, 1.09375e-01,
    1.09375e-01, 3.28125e-01, 5.46875e-01, 7.65625e-01, 7.65625e-01, 5.46875e-01, 3.28125e-01, 1.09375e-01,
    7.81250e-02, 2.34375e-01, 3.90625e-01, 5.46875e-01, 5.46875e-01, 3.90625e-01, 2.34375e-01, 7.81250e-02,
    4.68750e-02, 1.40625e-01, 2.34375e-01, 3.28125e-01, 3.28125e-01, 2.34375e-01, 1.40625e-01, 4.68750e-02,
    1.56250e-02, 4.68750e-02, 7.81250e-02, 1.09375e-01, 1.09375e-01, 7.81250e-02, 4.68750e-02, 1.56250e-02};

/**
 * @brief calculate dx, dy and x*x
 * 
 * @param pSrc 
 * @param pDxDy 
 * @param pSqr 
 * @return int 
 */
int calcDiff(const CvMat *pSrc, CvMat *pDxDy, CvMat *pSqr)
{
    uint8_t *restrict pSrcData;
    uint8_t *restrict pSrcPreData;
    uint8_t *restrict pSrcPostData;
    DxDyData * pDxDyData;
    float * pSqrData;
    float fDx, fDy;

    if(!pSrc || !pDxDy || !pSqr){
        return -1;
    }

    pSrcData = (uint8_t *)cvPtr2D(pSrc, 1, 0);
    _nassert((int)pSrcData & 0x7 == 0);
    pSrcPreData = pSrcData - pSrc->width;
    _nassert((int)pSrcPreData & 0x7 == 0);
    pSrcPostData = pSrcData + pSrc->width;
    _nassert((int)pSrcPostData & 0x7 == 0);
    pDxDyData = (DxDyData *)cvPtr1D(pDxDy, 0);
    _nassert((int)pDxDyData & 0x7 == 0);
    pSqrData = (float *)cvPtr1D(pSqr, 0);
    _nassert((int)pSqrData & 0x7 == 0);

    memset(pDxDyData, 0, sizeof(DxDyData) * pDxDy->width * pDxDy->height);
    memset(pSqrData, 0, sizeof(float) * pSqr->width * pSqr->height);

    for (int i = 1; i < pSrc->height - 1; ++i){
    	pDxDyData += pDxDy->width;
		pSqrData += pSqr->width;
        for (int j = 1; j < pSrc->width - 1; ++j){
            fDx = pSrcData[j + 1] - pSrcData[j - 1];
            fDy = pSrcPostData[j] - pSrcPreData[j];
            pDxDyData[j][0] = fDx;
            pDxDyData[j][1] = fDy;
            pSqrData[j] = fDx * fDx + fDy * fDy;
        }
        pSrcData += pSrc->step;
        pSrcPreData += pSrc->step;
        pSrcPostData += pSrc->step;
    }

    return 0;
}

/**
 * @brief Get the Feature Maps object
 * 
 * @param pSubw have not resized image CV_32FC1
 * @param pMap 1024x27 CV_32C1
 * @return int 0 for OK
 */
int getFeatureMaps(const CvMat *pSubw, CvMat *pMap)
{
    if(!pSubw || !pMap){
        return -1;
    }

    // resize
    CvMat* pResized = cvCreateMat((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, CV_8UC1);
    cvResize(pSubw, pResized); 

    // diff
    CvMat * pDxDy = cvCreateMat((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, CV_32FC2);
    CvMat * pSqr = cvCreateMat((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, CV_32FC1);
    calcDiff(pResized, pDxDy, pSqr);

    cvReleaseMat(&pResized);

    // amp and ori
	float fDx, fDy;
	OriData ori;
    CvMat *pAmp = cvCreateMat((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, CV_32FC1);
    CvMat *pOri = cvCreateMat((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, (KCF_DFT_SIZE + 2) * KCF_CELL_SIZE, CV_8UC2);
    float *pAmpData = (float *)cvPtr1D(pAmp, 0);
    float *pSqrData = (float *)cvPtr1D(pSqr, 0);

    OriData* pOriData = (OriData*)cvPtr1D(pOri, 0);
    DxDyData* pDxDyData = (DxDyData*)cvPtr1D(pDxDy, 0);
    float fDotProduct, fTemp;

    sqrtsp_v(pSqrData, pAmpData, pSqr->width * pSqr->height);

    for (int i = 0; i < ((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE) * ((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE); ++i) {
        fDx = pDxDyData[i][0];
        fDy = pDxDyData[i][1];

        ori[0] = 0;
        if(fDx > 0.0){
            ori[1] = 0;
            fDotProduct = fDx;
        }
        else{
            ori[1] = 9;
            fDotProduct = -fDx;
        }

        for (int j = 1; j < KCF_REGION_NUM; ++j) {
            fTemp = boundary_x[j] * fDx + boundary_y[j] * fDy;
            if (fTemp > fDotProduct) {
                fDotProduct = fTemp;
                ori[0] = j;
                ori[1] = j;
            }

            if (fDotProduct + fTemp < 0) {
                fDotProduct = -fTemp;
                ori[0] = j;
                ori[1] = j + KCF_REGION_NUM;
            }
        }
        pOriData[i][0] = ori[0];
        pOriData[i][1] = ori[1];
    }

    cvReleaseMat(&pDxDy);
    cvReleaseMat(&pSqr);

    // hist
    float *pDataA, *restrict pInnerA;
    OriData *pDataO, *restrict pInnerO;
    float fAmp;
    float *restrict pFMDataOri0, *restrict pFMDataOri1;
    
    pFMDataOri0 = (float *)cvPtr1D(pMap, 0);
    pFMDataOri1 = pFMDataOri0 + KCF_REGION_NUM;
    memset(pFMDataOri0, 0, sizeof(float) * pMap->width * pMap->height);

    pDataA = pAmpData + 2 * pAmp->width + 2;
    pDataO = pOriData + 2 * pOri->width + 2;
    // loop for each cell
    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        pInnerA = pDataA;
        pInnerO = pDataO;
        // loop in each cell
        for (int j = 0; j < (KCF_CELL_SIZE * 2) * (KCF_CELL_SIZE * 2); ++j){
            ori[0] = (*pInnerO)[0];
            ori[1] = (*pInnerO)[1];
            fAmp = *pInnerA * factors[j];
            pFMDataOri0[ori[0]] += fAmp;
            pFMDataOri1[ori[1]] += fAmp;

            if((j + 1) % (KCF_CELL_SIZE * 2) != 0){
                ++pInnerA;
                ++pInnerO;
            }
            else {
                pInnerA += ((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE) + 1 - (KCF_CELL_SIZE * 2);
                pInnerO += ((KCF_DFT_SIZE + 2) * KCF_CELL_SIZE) + 1 - (KCF_CELL_SIZE * 2);
            }
        }
        // search mat start addr
        if ((i + 1) % KCF_DFT_SIZE != 0){
            pDataA += 4;
            pDataO += 4;
        } 
        else{
            pDataA += 12 + 3 * pAmp->width;
            pDataO += 12 + 3 * pOri->width;
        }
            
        // dst
        pFMDataOri0 += pMap->width;
        pFMDataOri1 += pMap->width;
    }

    cvReleaseMat(&pAmp);
    cvReleaseMat(&pOri);

    return 0;
}

/**
 * @brief normalize feature map and truncate
 * 
 * @param pFM 1024x27 CV_32FC1
 * @param pNorm 1024x108 CV_32FC1
 * @return int 0 for OK
 */
int normalizeAndTruncate(const CvMat *pFM, CvMat *pNorm)
{
    if(!pFM || !pNorm){
        return -1;
    }

    float *pFMData = (float *)cvPtr1D(pFM, 0);
    float *pPartOfNorm = NULL;
    pPartOfNorm = (float *)memalign(8, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE);
    _nassert((int)pPartOfNorm & 0x7 == 0);
    assert(pPartOfNorm);
    float fTemp;

    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        fTemp = 0.0;
        for (int j = 0; j < KCF_REGION_NUM; ++j){
            fTemp += pFMData[j] * pFMData[j];
        }
        pPartOfNorm[i] = fTemp;
        pFMData += pFM->width;
    }

    float *restrict pSrcData;
    float bin0, bin1, bin2, bin3;
    NormData *pSqr = (NormData *)memalign(16, sizeof(NormData) * (KCF_DFT_SIZE-2) * (KCF_DFT_SIZE-2));
    NormData *pDstData;
    _nassert((int)pPartOfNorm & 0xF == 0);
    assert(pSqr);
    memset(pSqr, 0, sizeof(NormData) * (KCF_DFT_SIZE-2) * (KCF_DFT_SIZE-2));

    pSrcData = pPartOfNorm + KCF_DFT_SIZE + 1;
    pDstData = pSqr;
    for (int i = 1; i < KCF_DFT_SIZE - 1; ++i)
    {
        for (int j = 1; j < KCF_DFT_SIZE - 1; ++j){
            bin0 = 0;
            bin1 = 0;
            bin2 = 0;
            bin3 = 0;

            bin0 += *(pSrcData - KCF_DFT_SIZE - 1);
            bin1 += *(pSrcData - KCF_DFT_SIZE + 1);
            bin2 += *(pSrcData + KCF_DFT_SIZE - 1);
            bin3 += *(pSrcData + KCF_DFT_SIZE + 1);

            fTemp = *(pSrcData - KCF_DFT_SIZE);
            bin0 += fTemp;
            bin1 += fTemp;

            fTemp = *(pSrcData + KCF_DFT_SIZE);
            bin2 += fTemp;
            bin3 += fTemp;

            fTemp = *(pSrcData - 1);
            bin0 += fTemp;
            bin2 += fTemp;

            fTemp = *(pSrcData + 1);
            bin1 += fTemp;
            bin3 += fTemp;

            fTemp = *pSrcData;

            (*pDstData)[0] = bin0 + fTemp;
            (*pDstData)[1] = bin1 + fTemp;
            (*pDstData)[2] = bin2 + fTemp;
            (*pDstData)[3] = bin3 + fTemp;
            ++pSrcData;
            ++pDstData;
        }
        pSrcData += 2;
    }

    NormData *pSqrt = (NormData *)memalign(16, sizeof(NormData) * (KCF_DFT_SIZE-2) * (KCF_DFT_SIZE-2));
    _nassert((int)pSqrt & 0xF == 0);
    assert(pSqrt);
    sqrtsp_v((float *)pSqr, (float *)pSqrt, (KCF_DFT_SIZE-2) * (KCF_DFT_SIZE-2) * 4);
    free(pPartOfNorm);
    pPartOfNorm = NULL;
    free(pSqr);
    pSqr = NULL;

    float *restrict pDen = (float *)pSqrt;
    float fDen;
    float *restrict pNum = (float *)cvPtr1D(pFM, 0);
    float *pResult = (float *)cvPtr1D(pNorm, 0);
    memset(pResult, 0, sizeof(float) * KCF_DFT_SIZE * KCF_DFT_SIZE * KCF_REGION_NUM * 12);
    float fResult;

    // truncate and norm
    pNum += (KCF_DFT_SIZE + 1) * (KCF_REGION_NUM * 3);
    pResult += (KCF_DFT_SIZE + 1) * (KCF_REGION_NUM * 12);
    for (int i = 0; i < (KCF_DFT_SIZE-2) * (KCF_DFT_SIZE-2) * 4; ++i){
        fDen = *pDen + FLT_EPSILON;
        for (int j = 0; j < 3 * KCF_REGION_NUM; ++j){
            fResult = divsp_i(pNum[j], fDen);
            *pResult++ = (fResult > 0.2) ? 0.2 : fResult;
        }
        if ((i + 1) % 4 == 0){
            pNum += 3 * KCF_REGION_NUM;
            if(((i + 1) >> 2)%(KCF_DFT_SIZE - 2) == 0){
                pNum += 2 * 3 * KCF_REGION_NUM;
                pResult += 2 * 12 * KCF_REGION_NUM;
            }
        }
        ++pDen;
    }

    free(pSqrt);
    pSqrt = NULL;

    return 0;
}

/**
 * @brief PCA feature maps and transpose
 * 
 * @param pNorm 1024x108 CV_32FC1
 * @param pPca 1024x31 CV_32FC1
 * @return int 0 for OK
 */
int PCAFeatureMaps(const CvMat *pNorm, CvMat *pPca)
{
    if(!pNorm || !pPca){
        return -1;
    }

    float *restrict pData0;
    float *restrict pData1;
    float *restrict pData2;
    float *restrict pData3;
    float fData0;
    float fData1;
    float fData2;
    float fData3;
    float sum0;
    float sum1;
    float sum2;
    float sum3;
    float *pResult;

    pData0 = (float *)cvPtr1D(pNorm, 0);
    pData1 = pData0 + 3 * KCF_REGION_NUM;
    pData2 = pData0 + 6 * KCF_REGION_NUM;
    pData3 = pData0 + 9 * KCF_REGION_NUM;
    pResult = (float *)cvPtr1D(pPca, 0);

    for (int i = 0; i < KCF_DFT_SIZE * KCF_DFT_SIZE; ++i){
        sum0 = 0.0;
        sum1 = 0.0;
        sum2 = 0.0;
        sum3 = 0.0;
        for (int j = 0; j < 3 * KCF_REGION_NUM; ++j){
            fData0 = *(pData0++);
            fData1 = *(pData1++);
            fData2 = *(pData2++);
            fData3 = *(pData3++);
            *(pResult++) = (fData0 + fData1 + fData2 + fData3) * 0.5;
            if(j < KCF_REGION_NUM){
                sum0 += fData0;
                sum1 += fData1;
                sum2 += fData2;
                sum3 += fData3;
            }
        }

        *(pResult++) = sum0 * 0.2357; // sum / sqrt(18)
        *(pResult++) = sum1 * 0.2357;
        *(pResult++) = sum2 * 0.2357;
        *(pResult++) = sum3 * 0.2357;
        pData0 += 9 * KCF_REGION_NUM;
        pData1 += 9 * KCF_REGION_NUM;
        pData2 += 9 * KCF_REGION_NUM;
        pData3 += 9 * KCF_REGION_NUM;
    }

    return 0;
}
