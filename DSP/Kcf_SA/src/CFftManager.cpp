/**
 * @file CFftManager.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "common.h"
#include "CFftManager.h"
#include <csl_fft.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <xdc/runtime/Memory.h>
#include <xdc/runtime/Error.h> 
#include <ti/sysbios/family/c66/tci66xx/CpIntc.h>
#include <ti/sysbios/family/c66/Cache.h>


CFftManager::CFftManager():
    m_hCha(0),
    m_pTempR(NULL),
    m_pTempI(NULL),
    m_pMid1(NULL),
    m_pMid2(NULL),
    m_bInitDone(false)
{
}

CFftManager::~CFftManager()
{
    if(m_pTempR){
        free(m_pTempR);
        m_pTempR = NULL;
        m_pTempI = NULL;
    }

    if(m_pMid1){
        free(m_pMid1);
        m_pMid1 = NULL;
    }
    if(m_pMid2){
        free(m_pMid2);
        m_pMid2 = NULL;
    }
}

int CFftManager::init(int maxWidth, int maxHeight)
{
    // allocate real and image together
	// NOTE: when data is in DDR, the m_pTempR and m_pTempI should allocate in DDR, too.
	m_pTempR = (float *)memalign(4096, sizeof(float) * maxWidth * maxHeight * 2);
	// m_pTempR = (float *)Memory_calloc((xdc_runtime_IHeap_Handle)SharedRegion_getHeap(1), sizeof(float) * maxWidth * maxHeight * 2, 4096, &eb);
	if(!m_pTempR)
		return -1;
	m_pTempI = m_pTempR + maxWidth * maxHeight;
    
	m_pMid1 = (float *)memalign(4096, sizeof(float) * maxWidth * 2);
	if(!m_pMid1)
		return -1;
	m_pMid2 = (float *)memalign(4096, sizeof(float) * maxWidth * 2);
	if(!m_pMid2)
		return -1;

	return 0;
}

int CFftManager::HwInit()
{
    CSL_Status status;
	CSL_Edma3ChannelAttr chaAttr;

	if(m_bInitDone)
		return 0;

	// CIC2 is used to connect FFT interrupt to EDMA3
	CpIntc_clearSysInt(2, EDMA3_CC1_CORE0_FFT_TRIGEVT);
	CpIntc_enableSysInt(2, EDMA3_CC1_CORE0_FFT_TRIGEVT);
	CpIntc_mapSysIntToHostInt(2, EDMA3_CC1_CORE0_FFT_TRIGEVT, EDMA3_CC1_CORE0_FFT_CICCHA);
	CpIntc_enableHostInt(2, EDMA3_CC1_CORE0_FFT_CICCHA);
	CpIntc_enableAllHostInts(2);

	// CIC0 is used to connect EMDA finish interrupt to CPU
    CpIntc_clearSysInt(0, EDMA3_CC1_CORE0_FFT_SYSEVT);
	CpIntc_enableSysInt(0, EDMA3_CC1_CORE0_FFT_SYSEVT);
	CpIntc_mapSysIntToHostInt(0, EDMA3_CC1_CORE0_FFT_SYSEVT, CORE0_INTC_FFT_HOSTINT);
	CpIntc_enableHostInt(0, CORE0_INTC_FFT_HOSTINT);
	CpIntc_enableAllHostInts(0);

    chaAttr.chaNum = EDMA3_CC1_CORE0_FFT_CHA;
    chaAttr.regionNum = CSL_EDMA3_REGION_0;

    m_hCha = CSL_edma3ChannelOpen(&m_ChaObj, CSL_TPCC_1, &chaAttr, &status);

    CSL_edma3HwChannelSetupParam(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM);
    CSL_edma3HwChannelSetupQue(m_hCha, EDMA3_CC1_CORE0_FFT_QUE);

    CSL_edma3ChaClearDMAChannelEvent(m_hCha);
	CSL_edma3ChaDMAChannelEnable(m_hCha);
	CSL_edma3ChaInterruptEnable(m_hCha);

    m_bInitDone = true;
	return 0;
}

int CFftManager::FFT_R2R_T(float *pSrc, float *pDst, int nLen, int nRows)
{
    if(!pSrc || !pDst){
        return -1;
    }

    CSL_Status status;
	CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;
    CSL_fftConfig fftConfig;

    // only real part
    Cache_wb(pSrc, nLen * nRows * sizeof(float), Cache_Type_ALLD, TRUE);
    
    hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_EN, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_DIS, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)m_pTempR;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(4, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)pDst;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(4, nRows*4); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE((EDMA3_CC1_CORE0_FFT_PARAM + 1) << 5, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*4, 4); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM + 1, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)m_pTempI;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(4, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)m_pTempR;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(4, nRows*4); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*4, 4); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	fftConfig.srcRAddr = (uint32_t)pSrc;
	fftConfig.srcIAddr = (uint32_t)m_pTempR;
	fftConfig.dstRAddr = (uint32_t)m_pTempR;
	fftConfig.dstIAddr = (uint32_t)m_pTempI;
	fftConfig.mode = CSL_FFT_MODE_FFT;
	fftConfig.midAddr1 = (uint32_t)m_pMid1;
	fftConfig.midAddr2 = (uint32_t)m_pMid2;
	fftConfig.fftNum = nRows;
	fftConfig.dataFormatIn = CSL_FFT_FMT_FLOAT;
	fftConfig.dataFormatOut = CSL_FFT_FMT_FLOAT;
	fftConfig.complexReal = CSL_FFT_COMPLEX;
	fftConfig.dataOrgnize = CSL_FFT_SPLIT;
    fftConfig.fftIfft = CSL_FFT_TYPE_FFT;

	fftConfig.fftSize = getPowOfLen(nLen);
	// not used now
	fftConfig.pointPosIn = 0;
	fftConfig.pointPosOut = 0;
	fftConfig.mtMode = CSL_FFT_MT_C2C;
	fftConfig.mtSize = 0;
	fftConfig.mtRow = 0;
	fftConfig.mtCol = 0;

    CSL_fftSetup(&fftConfig);
	CSL_fftStart();

    return 0;
}

int CFftManager::FFT_R2C_T(float *pSrc, float *pDst, int nLen, int nRows)
{
	if(!pSrc || !pDst){
        return -1;
    }

    CSL_Status status;
	CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;
    CSL_fftConfig fftConfig;

    Cache_wb(pSrc, nLen * nRows * sizeof(float), Cache_Type_ALLD, TRUE);

	memset(pDst, 0, sizeof(float) * nLen * nRows * 2);
	hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_EN, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_DIS, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)m_pTempR;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(4, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)pDst;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(4, nRows*8); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE((EDMA3_CC1_CORE0_FFT_PARAM + 1) << 5, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*4, 8); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM + 1, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)m_pTempI;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(4, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)(pDst + 1);
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(4, nRows*8); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*4, 8); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	fftConfig.srcRAddr = (uint32_t)pSrc;
	fftConfig.srcIAddr = 0;
	fftConfig.dstRAddr = (uint32_t)m_pTempR;
	fftConfig.dstIAddr = (uint32_t)m_pTempI;
	fftConfig.mode = CSL_FFT_MODE_FFT;
	fftConfig.midAddr1 = (uint32_t)m_pMid1;
	fftConfig.midAddr2 = (uint32_t)m_pMid2;
	fftConfig.fftNum = nRows;
	fftConfig.dataFormatIn = CSL_FFT_FMT_FLOAT;
	fftConfig.dataFormatOut = CSL_FFT_FMT_FLOAT;
	fftConfig.complexReal = CSL_FFT_REAL;
	fftConfig.dataOrgnize = CSL_FFT_SPLIT;
    fftConfig.fftIfft = CSL_FFT_TYPE_FFT;

	fftConfig.fftSize = getPowOfLen(nLen);
	// not used now
	fftConfig.pointPosIn = 0;
	fftConfig.pointPosOut = 0;
	fftConfig.mtMode = CSL_FFT_MT_C2C;
	fftConfig.mtSize = 0;
	fftConfig.mtRow = 0;
	fftConfig.mtCol = 0;

    CSL_fftSetup(&fftConfig);
	CSL_fftStart();
	return 0;
}

int CFftManager::FFT_C2C_T(float *pSrc, float *pDst, int nLen, int nRows)
{
	if(!pSrc || !pDst){
        return -1;
    }

    CSL_Status status;
	CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;
    CSL_fftConfig fftConfig;

    Cache_wb(pSrc, nLen * nRows * sizeof(float) * 2, Cache_Type_ALLD, TRUE);

	// NOTE real is in high address, imag is in low address [imag, real, imag, real , ...]
	hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_EN, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_DIS, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)m_pTempR;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(4, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)(pDst + 1);
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(8, nRows*8); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE((EDMA3_CC1_CORE0_FFT_PARAM + 1) << 5, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*8, 8); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM + 1, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)(m_pTempR + 1);
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(4, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)pDst;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(8, nRows*8); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*8, 8); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	fftConfig.srcRAddr = (uint32_t)pSrc;
	fftConfig.srcIAddr = 0;
	fftConfig.dstRAddr = (uint32_t)m_pTempR;
	fftConfig.dstIAddr = 0;
	fftConfig.mode = CSL_FFT_MODE_FFT;
	fftConfig.midAddr1 = (uint32_t)m_pMid1;
	fftConfig.midAddr2 = (uint32_t)m_pMid2;
	fftConfig.fftNum = nRows;
	fftConfig.dataFormatIn = CSL_FFT_FMT_FLOAT;
	fftConfig.dataFormatOut = CSL_FFT_FMT_FLOAT;
	fftConfig.complexReal = CSL_FFT_COMPLEX;
	fftConfig.dataOrgnize = CSL_FFT_CROSS;
    fftConfig.fftIfft = CSL_FFT_TYPE_FFT;

	fftConfig.fftSize = getPowOfLen(nLen);
	// not used now
	fftConfig.pointPosIn = 0;
	fftConfig.pointPosOut = 0;
	fftConfig.mtMode = CSL_FFT_MT_C2C;
	fftConfig.mtSize = 0;
	fftConfig.mtRow = 0;
	fftConfig.mtCol = 0;

    CSL_fftSetup(&fftConfig);
	CSL_fftStart();
	return 0;
}

int CFftManager::FFT_C2C_TN(float *pSrc, float *pDst, int nLen, int nRows)
{
	if(!pSrc || !pDst){
        return -1;
    }

    CSL_Status status;
	CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;
    CSL_fftConfig fftConfig;

    Cache_wb(pSrc, nLen * nRows * sizeof(float) * 2, Cache_Type_ALLD, TRUE);

	// NOTE real is in low address, imag is in high address [real, imag, real, imag, ...]
	hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)m_pTempR;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(8, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)pDst;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(8, nRows*8); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*8, 8); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	fftConfig.srcRAddr = (uint32_t)pSrc;
	fftConfig.srcIAddr = 0;
	fftConfig.dstRAddr = (uint32_t)m_pTempR;
	fftConfig.dstIAddr = 0;
	fftConfig.mode = CSL_FFT_MODE_FFT;
	fftConfig.midAddr1 = (uint32_t)m_pMid1;
	fftConfig.midAddr2 = (uint32_t)m_pMid2;
	fftConfig.fftNum = nRows;
	fftConfig.dataFormatIn = CSL_FFT_FMT_FLOAT;
	fftConfig.dataFormatOut = CSL_FFT_FMT_FLOAT;
	fftConfig.complexReal = CSL_FFT_COMPLEX;
	fftConfig.dataOrgnize = CSL_FFT_CROSS;
    fftConfig.fftIfft = CSL_FFT_TYPE_FFT;

	fftConfig.fftSize = getPowOfLen(nLen);
	// not used now
	fftConfig.pointPosIn = 0;
	fftConfig.pointPosOut = 0;
	fftConfig.mtMode = CSL_FFT_MT_C2C;
	fftConfig.mtSize = 0;
	fftConfig.mtRow = 0;
	fftConfig.mtCol = 0;

    CSL_fftSetup(&fftConfig);
	CSL_fftStart();
	return 0;
}

int CFftManager::IFFT_C2C_T(float *pSrc, float *pDst, int nLen, int nRows)
{
	if(!pSrc || !pDst){
        return -1;
    }

    CSL_Status status;
	CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;
    CSL_fftConfig fftConfig;

    Cache_wb(pSrc, nLen * nRows * sizeof(float) * 2, Cache_Type_ALLD, TRUE);

	hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)m_pTempR;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(8, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)pDst;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(8, nRows*8); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*8, 8); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	fftConfig.srcRAddr = (uint32_t)pSrc;
	fftConfig.srcIAddr = 0;
	fftConfig.dstRAddr = (uint32_t)m_pTempR;
	fftConfig.dstIAddr = 0;
	fftConfig.mode = CSL_FFT_MODE_FFT;
	fftConfig.midAddr1 = (uint32_t)m_pMid1;
	fftConfig.midAddr2 = (uint32_t)m_pMid2;
	fftConfig.fftNum = nRows;
	fftConfig.dataFormatIn = CSL_FFT_FMT_FLOAT;
	fftConfig.dataFormatOut = CSL_FFT_FMT_FLOAT;
	fftConfig.complexReal = CSL_FFT_COMPLEX;
	fftConfig.dataOrgnize = CSL_FFT_CROSS;
    fftConfig.fftIfft = CSL_FFT_TYPE_IFFT;

	fftConfig.fftSize = getPowOfLen(nLen);
	// not used now
	fftConfig.pointPosIn = 0;
	fftConfig.pointPosOut = 0;
	fftConfig.mtMode = CSL_FFT_MT_C2C;
	fftConfig.mtSize = 0;
	fftConfig.mtRow = 0;
	fftConfig.mtCol = 0;

    CSL_fftSetup(&fftConfig);
	CSL_fftStart();
	return 0;
}

int CFftManager::IFFT_C2R_T(float *pSrc, float *pDst, int nLen, int nRows)
{
	if(!pSrc || !pDst){
        return -1;
    }

    CSL_Status status;
	CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;
    CSL_fftConfig fftConfig;

    Cache_wb(pSrc, nLen * nRows * sizeof(float) * 2, Cache_Type_ALLD, TRUE);

	hParam = CSL_edma3GetChaParamHandle(m_hCha, EDMA3_CC1_CORE0_FFT_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC1_CORE0_FFT_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)m_pTempR;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(4, nLen); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)pDst;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(8, nRows*4); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nLen*8, 4); // (src, dst)
	paramSetup.cCnt = nRows;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	fftConfig.srcRAddr = (uint32_t)pSrc;
	fftConfig.srcIAddr = 0;
	fftConfig.dstRAddr = (uint32_t)m_pTempR;
	fftConfig.dstIAddr = 0;
	fftConfig.mode = CSL_FFT_MODE_FFT;
	fftConfig.midAddr1 = (uint32_t)m_pMid1;
	fftConfig.midAddr2 = (uint32_t)m_pMid2;
	fftConfig.fftNum = nRows;
	fftConfig.dataFormatIn = CSL_FFT_FMT_FLOAT;
	fftConfig.dataFormatOut = CSL_FFT_FMT_FLOAT;
	fftConfig.complexReal = CSL_FFT_COMPLEX;
	fftConfig.dataOrgnize = CSL_FFT_CROSS;
    fftConfig.fftIfft = CSL_FFT_TYPE_IFFT;

	fftConfig.fftSize = getPowOfLen(nLen);
	// not used now
	fftConfig.pointPosIn = 0;
	fftConfig.pointPosOut = 0;
	fftConfig.mtMode = CSL_FFT_MT_C2C;
	fftConfig.mtSize = 0;
	fftConfig.mtRow = 0;
	fftConfig.mtCol = 0;

    CSL_fftSetup(&fftConfig);
	CSL_fftStart();
	return 0;
}

uint8_t CFftManager::getPowOfLen(uint16_t nLength)
{
    uint8_t pow = 0;
    uint16_t tmp;
    assert((nLength & (nLength - 1)) == 0);
    for(tmp = nLength-1; (tmp&1)==1; tmp = tmp >> 1) pow++;
    return pow;
}

void CFftManager::ClearInterruptFlag()
{
	CpIntc_clearSysInt(2, EDMA3_CC1_CORE0_FFT_TRIGEVT);
	CSL_edma3ChaClearPendingInterrupts(m_hCha);
    CpIntc_clearSysInt(0, EDMA3_CC1_CORE0_FFT_SYSEVT);
}

void CFftManager::ClearTempR(size_t nSize)
{
	memset(m_pTempR, 0, nSize);
	Cache_wb(m_pTempR, nSize, Cache_Type_ALLD, 1);
}
