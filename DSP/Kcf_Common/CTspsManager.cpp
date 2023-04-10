/**
 * @file CTspsManager.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-01-08
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "common.h"
#include <ti/sysbios/family/c66/tci66xx/CpIntc.h>
#include <ti/sysbios/family/c66/Cache.h>

#include "CTspsManager.h"

CTspsManager::CTspsManager(Int16 nCoreId):
    m_hCha(0),
    m_bInitDone(false),
    m_nCoreId(nCoreId),
    m_nRegion(0),
    m_nParamNum(0),
    m_eQueNum(CSL_EDMA3_QUE_0),
    m_nChaNum(0),
    m_nSysEvt(0),
    m_nHostInt(0)
{
    if(m_nCoreId == 1){
        m_nRegion = CSL_EDMA3_REGION_1;
        m_nParamNum = EDMA3_CC0_CORE1_TSPS_PARAM;
        m_eQueNum = EDMA3_CC0_CORE1_TSPS_QUE;
        m_nChaNum = EDMA3_CC0_CORE1_TSPS_CHA;
        m_nSysEvt = EDMA3_CC0_CORE1_TSPS_SYSEVT;
        m_nHostInt = CORE1_INTC_TSPS_HOSTINT;
    }
    else if(m_nCoreId == 2){
        m_nRegion = CSL_EDMA3_REGION_2;
        m_nParamNum = EMDA3_CC0_CORE2_TSPS_PARAM;
        m_eQueNum = EMDA3_CC0_CORE2_TSPS_QUE;
        m_nChaNum = EMDA3_CC0_CORE2_TSPS_CHA;
        m_nSysEvt = EMDA3_CC0_CORE2_TSPS_SYSEVT;
        m_nHostInt = CORE2_INTC_TSPS_HOSTINT;
    }
}

CTspsManager::~CTspsManager()
{
}

int CTspsManager::HwInit()
{
    CSL_Status status;
	CSL_Edma3ChannelAttr chaAttr;

    if(m_nCoreId != 1 && m_nCoreId != 2){
        return -1;
    }

    if(m_bInitDone)
		return 0;

    chaAttr.chaNum = m_nChaNum;
    chaAttr.regionNum = m_nRegion;
    m_hCha = CSL_edma3ChannelOpen(&m_ChaObj, CSL_TPCC_0, &chaAttr, &status);

    CSL_edma3HwChannelSetupParam(m_hCha, m_nParamNum);
    CSL_edma3HwChannelSetupQue(m_hCha, m_eQueNum);

    CSL_edma3ClearDMAChannelEvent((CSL_Edma3Handle)m_hCha, m_nRegion, m_nChaNum);
	CSL_edma3DMAChannelEnable((CSL_Edma3Handle)m_hCha, m_nRegion, m_nChaNum);
    CSL_edma3InterruptLoEnable((CSL_Edma3Handle)m_hCha, m_nRegion, 1 << m_nChaNum);

    // NOTE: CIC0 is used to connect EMDA finish interrupt to CPU
    // nCICId = 0;
    CpIntc_clearSysInt(0, m_nSysEvt);
	CpIntc_enableSysInt(0, m_nSysEvt);
	CpIntc_mapSysIntToHostInt(0, m_nSysEvt, m_nHostInt);
	CpIntc_enableHostInt(0, m_nHostInt);
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

	hParam = CSL_edma3GetParamHandle((CSL_Edma3Handle)m_hCha, m_nParamNum, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_EN, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   m_nChaNum, \
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

    CSL_edma3SetDMAChannelEvent((CSL_Edma3Handle)m_hCha, m_nRegion, m_nChaNum);

    return 0;
}

void CTspsManager::ClearInterruptFlag()
{
    CSL_edma3ClearLoPendingInterrupts((CSL_Edma3Handle)m_hCha, m_hCha->region, 1 << m_nChaNum);
    CpIntc_clearSysInt(0, m_nSysEvt);
}
