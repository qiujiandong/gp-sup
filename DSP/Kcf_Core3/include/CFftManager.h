/**
 * @file CFftManager.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-01-06
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _CFFTMANAGER_H_
#define _CFFTMANAGER_H_

#include <csl_edma3.h>

/**
 * @brief Hardware FFT caculation manager
 * 
 */
class CFftManager{
private:
    CSL_Edma3ChannelHandle m_hCha;
	CSL_Edma3ChannelObj m_ChaObj;
    float *m_pTempR;
    float *m_pTempI;
    float *m_pMid1;
    float *m_pMid2;
    Bool m_bInitDone;
    int m_nCicId;

    uint8_t getPowOfLen(uint16_t nLength);

public:
    CFftManager();
    ~CFftManager();

    /**
     * @brief init middle space.
     *
     * @param maxWidth max FFT length
     * @param maxHeight max FFT lines
     * @return int
     */
    int init(int maxWidth, int maxHeight);

    /**
     * @brief attach FFT finish interrupt to EDMA channel and enable EDMA interrupt
     * using PaRAM 0, PaRAM 1-9 is reserved,
     * using Queue 0,
     * using region 0,
     * Attach to host interrupt ID 21
     * user should setup a Hwi for the event
     * 
     * @return int
     */
    int HwInit();

    /**
     * @brief do FFT and transpose. 
     * source data is central symmetry real data
     * pSrc and pDst can point to the same space
     * using m_pTempR as input imag data and output imag data
     * 
     * @param pSrc input only real part data
     * @param pDst output only real part data
     * @param nLen FFT points
     * @param nRows number of rows
     * @return int 
     */
    int FFT_R2R_T(float *pSrc, float *pDst, int nLen, int nRows);

    /**
     * @brief do FFT and transpose
     * source data is half size of dst data(dst data is complex)
     * when pSrc and pDst is same, carefully check if source data space is large enough
     * 
     * @param pSrc input only real part data
     * @param pDst output real part and imaginary part data, cross storeage stratagy
     * @param nLen FFT points
     * @param nRows number of rows
     * @return int 
     */
    int FFT_R2C_T(float *pSrc, float *pDst, int nLen, int nRows);

    /**
     * @brief do FFT and transpose
     *  real is in high address, imag is in low address
     * [imag, real, imag, real , ...]
     * 
     * @param pSrc 
     * @param pDst 
     * @param nLen FFT points
     * @param nRows number of rows
     * @return int 
     */
    int FFT_C2C_T(float *pSrc, float *pDst, int nLen, int nRows);

    /**
     * @brief do FFT and transpose normal mode
     * real is in low address, imag is in high address
     * [real, imag, real, imag , ...]
     * 
     * @param pSrc 
     * @param pDst 
     * @param nLen FFT points
     * @param nRows number of rows
     * @return int 
     */
    int FFT_C2C_TN(float *pSrc, float *pDst, int nLen, int nRows);

    int IFFT_C2C_T(float *pSrc, float *pDst, int nLen, int nRows);
    int IFFT_C2R_T(float *pSrc, float *pDst, int nLen, int nRows);

    void ClearInterruptFlag();
    void ClearTempR(size_t nSize);
};

#endif
