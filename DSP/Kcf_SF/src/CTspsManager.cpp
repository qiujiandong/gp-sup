/**
 * @file CTspsManager.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-03-05
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "common.h"
#include "CTspsManager.h"

#include <ti/sysbios/family/c66/tci66xx/CpIntc.h>
#include <ti/sysbios/family/c66/Cache.h>

CTspsManager::CTspsManager():
    m_hCha(0),
    m_bInitDone(false)
{
}

CTspsManager::~CTspsManager()
{
}

int CTspsManager::HwInit()
{
    CSL_Status status;
	CSL_Edma3ChannelAttr chaAttr;

    if(m_bInitDone)
		return 0;

    chaAttr.chaNum = EDMA3_CC0_CORE0_TSPS_CHA;
    chaAttr.regionNum = CSL_EDMA3_REGION_1;
    m_hCha = CSL_edma3ChannelOpen(&m_ChaObj, CSL_TPCC_0, &chaAttr, &status);

    CSL_edma3HwChannelSetupParam(m_hCha, EDMA3_CC0_CORE0_TSPS_PARAM);
    CSL_edma3HwChannelSetupQue(m_hCha, EDMA3_CC0_CORE0_TSPS_QUE);

    CSL_edma3ClearDMAChannelEvent((CSL_Edma3Handle)m_hCha, CSL_EDMA3_REGION_1, EDMA3_CC0_CORE0_TSPS_CHA);
	CSL_edma3DMAChannelEnable((CSL_Edma3Handle)m_hCha, CSL_EDMA3_REGION_1, EDMA3_CC0_CORE0_TSPS_CHA);
    CSL_edma3InterruptLoEnable((CSL_Edma3Handle)m_hCha, CSL_EDMA3_REGION_1, 1 << EDMA3_CC0_CORE0_TSPS_CHA);

    // NOTE: CIC0 is used to connect EMDA finish interrupt to CPU
    // nCICId = 0;
    CpIntc_clearSysInt(0, EDMA3_CC0_CORE0_TSPS_SYSEVT);
	CpIntc_enableSysInt(0, EDMA3_CC0_CORE0_TSPS_SYSEVT);
	CpIntc_mapSysIntToHostInt(0, EDMA3_CC0_CORE0_TSPS_SYSEVT, CORE0_INTC_TSPS_HOSTINT);
	CpIntc_enableHostInt(0, CORE0_INTC_TSPS_HOSTINT);
	CpIntc_enableAllHostInts(0);

    m_bInitDone = true;
	return 0;
}

int CTspsManager::startTranspose(
    void *restrict pSrc, 
    void *restrict pDst, 
    int nSrcWidth, 
    int nSrcHeight, 
    size_t nUnit)
{
    CSL_Status status;
    CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;

    if(!pSrc || !pDst || !m_bInitDone){
		return -1;
	}

    Cache_wb(pSrc, nSrcWidth * nSrcHeight * nUnit, Cache_Type_ALLD, TRUE);

	hParam = CSL_edma3GetParamHandle((CSL_Edma3Handle)m_hCha, EDMA3_CC0_CORE0_TSPS_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC0_CORE0_TSPS_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)pSrc;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(nUnit, nSrcHeight); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)pDst;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(nSrcWidth * nUnit, nUnit); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(nUnit, nSrcHeight * nUnit); // (src, dst)
	paramSetup.cCnt = nSrcWidth;
	CSL_edma3ParamSetup(hParam, &paramSetup);

    CSL_edma3SetDMAChannelEvent((CSL_Edma3Handle)m_hCha, CSL_EDMA3_REGION_1, EDMA3_CC0_CORE0_TSPS_CHA);

    return 0;
}

int CTspsManager::startSubWindowExtract(
        void *restrict pSrc,
        void *restrict pDst,
        int nSrcStride,
		int nDstStride,
        int nBlockWidth,
        int nBlockHeight,
        size_t nUnit)
{
	CSL_Status status;
    CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;

    if(!pSrc || !pDst || !m_bInitDone){
		return -1;
	}

    Cache_wb(pSrc, nBlockWidth * nBlockHeight * nUnit, Cache_Type_ALLD, TRUE);

	hParam = CSL_edma3GetParamHandle((CSL_Edma3Handle)m_hCha, EDMA3_CC0_CORE0_TSPS_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC0_CORE0_TSPS_CHA, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)pSrc;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(nUnit * nBlockWidth, nBlockHeight); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)pDst;
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(nSrcStride, nDstStride); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(0, 0); // (src, dst)
	paramSetup.cCnt = 1;
	CSL_edma3ParamSetup(hParam, &paramSetup);

    CSL_edma3SetDMAChannelEvent((CSL_Edma3Handle)m_hCha, CSL_EDMA3_REGION_1, EDMA3_CC0_CORE0_TSPS_CHA);

    return 0;
}

void CTspsManager::ClearInterruptFlag()
{
    CSL_edma3ClearLoPendingInterrupts((CSL_Edma3Handle)m_hCha, m_hCha->region, 1 << EDMA3_CC0_CORE0_TSPS_CHA);
    CpIntc_clearSysInt(0, EDMA3_CC0_CORE0_TSPS_SYSEVT);
}
