/**
 * @file CRxBufManager.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-01-04
 * 
 * @copyright Copyright (c) 2023
 * 
 */

// #include "main.h"
#include "common.h"
#include <xdc/runtime/System.h>
#include <xdc/runtime/Memory.h>
#include <xdc/runtime/Error.h> 
#include <ti/sysbios/family/c66/Cache.h>
#include <ti/sysbios/family/c66/tci66xx/CpIntc.h>

#include "CRxBufManager.h"


CRxBufManager::CRxBufManager():
    m_nRxInd(0),
    m_bInitDone(false),
    m_nSize(0),
    m_pHeapHandle(NULL),
    m_hCha(0)
{
    m_pBuf[0] = NULL;
    m_pBuf[1] = NULL;
}

CRxBufManager::CRxBufManager(size_t bufSz, void *pHeapHandle):
    m_nRxInd(0),
    m_bInitDone(false),
    m_nSize(bufSz),
    m_pHeapHandle(pHeapHandle),
    m_hCha(0)
{
    Error_Block eb;

    Error_init(&eb);

    m_pBuf[0] = (uint8_t *)Memory_calloc((xdc_runtime_IHeap_Handle)pHeapHandle, bufSz, 0, &eb);
    if(m_pBuf[0] == NULL){
        System_abort("Memory calloc faild\n");
    }

    m_pBuf[1] = (uint8_t *)Memory_calloc((xdc_runtime_IHeap_Handle)pHeapHandle, bufSz, 0, &eb);
    if(m_pBuf[0] == NULL){
        System_abort("Memory calloc faild\n");
    }
}

CRxBufManager::~CRxBufManager()
{
    if(m_pBuf[0]){
        Memory_free((xdc_runtime_IHeap_Handle)m_pHeapHandle, m_pBuf[0], m_nSize);
        m_pBuf[0] = NULL;
    }
    if(m_pBuf[1]){
        Memory_free((xdc_runtime_IHeap_Handle)m_pHeapHandle, m_pBuf[1], m_nSize);
        m_pBuf[1] = NULL;
    }
}

int CRxBufManager::HwInit()
{
    CSL_Status status;
	CSL_Edma3ChannelAttr chaAttr;

    CSL_Edma3ChannelObj dmaCha;

    if(m_bInitDone)
		return 0;

    // NOTE: To open a QDMA channel we should add QDMA channel number and total DMA channel number
    chaAttr.chaNum = EDMA3_CC0_CORE0_DATACARRY_QCHA + CSL_EDMA3_TPCC0_NUM_DMACH;
    // NOTE: the Code is used for Core0, so the region is REGION_0
    chaAttr.regionNum = CSL_EDMA3_REGION_0;
    // open cc0 QMDA channel
    m_hCha = CSL_edma3ChannelOpen(&m_ChaObj, CSL_TPCC_0, &chaAttr, &status);

    CSL_edma3HwChannelSetupParam(m_hCha, EDMA3_CC0_CORE0_DATACARRY_PARAM);
    CSL_edma3HwChannelSetupQue(m_hCha, EDMA3_CC0_CORE0_DATACARRY_QUE);
    CSL_edma3HwChannelSetupTriggerWord(m_hCha, CSL_EDMA3_TRIGWORD_CCNT);

    CSL_edma3QDMAChannelEnable((CSL_Edma3Handle)m_hCha, m_hCha->region, EDMA3_CC0_CORE0_DATACARRY_QCHA);

    // NOTE: when using interrupt, also need to open corresponding DMA channel to set IER
    chaAttr.chaNum = EDMA3_CC0_CORE0_DATACARRY_TCC;
    CSL_edma3ChannelOpen(&dmaCha, CSL_TPCC_0, &chaAttr, &status);
    CSL_edma3InterruptLoEnable((CSL_Edma3Handle)m_hCha, m_hCha->region, 1 << EDMA3_CC0_CORE0_DATACARRY_TCC);

    // CIC0 is used to connect EMDA finish interrupt to CPU
    CpIntc_clearSysInt(0, EDMA3_CC0_CORE0_DATACARRY_SYSEVT);
	CpIntc_enableSysInt(0, EDMA3_CC0_CORE0_DATACARRY_SYSEVT);
	CpIntc_mapSysIntToHostInt(0, EDMA3_CC0_CORE0_DATACARRY_SYSEVT, CORE0_INTC_DATACARRY_HOSTINT);
	CpIntc_enableHostInt(0, CORE0_INTC_DATACARRY_HOSTINT);
	CpIntc_enableAllHostInts(0);

    m_bInitDone = true;
	return 0;
}

int CRxBufManager::SimStartRxData(uint8_t *pSrcAddr)
{
    CSL_Status status;
    CSL_Edma3ParamSetup paramSetup;
	CSL_Edma3ParamHandle hParam;

	if(!pSrcAddr){
		return -1;
	}

    // Cache_wb(pSrcAddr, FRAME_SIZE, Cache_Type_ALLD, TRUE);

	hParam = CSL_edma3GetParamHandle((CSL_Edma3Handle)m_hCha, EDMA3_CC0_CORE0_DATACARRY_PARAM, &status);
    paramSetup.option = CSL_EDMA3_OPT_MAKE(CSL_EDMA3_ITCCH_DIS, \
										   CSL_EDMA3_TCCH_DIS, \
										   CSL_EDMA3_ITCINT_DIS, \
										   CSL_EDMA3_TCINT_EN, \
										   EDMA3_CC0_CORE0_DATACARRY_TCC, \
										   CSL_EDMA3_TCC_NORMAL,\
										   CSL_EDMA3_FIFOWIDTH_NONE, \
										   CSL_EDMA3_STATIC_DIS, \
										   CSL_EDMA3_SYNC_AB, \
										   CSL_EDMA3_ADDRMODE_INCR, \
										   CSL_EDMA3_ADDRMODE_INCR);
	paramSetup.srcAddr = (uint32_t)pSrcAddr;
	paramSetup.aCntbCnt = CSL_EDMA3_CNT_MAKE(FRAME_FRACTION_SIZE, FRAME_FRACTIONS); // (acnt, bcnt)
	paramSetup.dstAddr = (uint32_t)getRxBuf();
	paramSetup.srcDstBidx = CSL_EDMA3_BIDX_MAKE(FRAME_FRACTION_SIZE, FRAME_FRACTION_SIZE); // (src, dst)
	paramSetup.linkBcntrld = CSL_EDMA3_LINKBCNTRLD_MAKE(CSL_EDMA3_LINK_NULL, 0);
	paramSetup.srcDstCidx = CSL_EDMA3_CIDX_MAKE(0, 0); // (src, dst)
	paramSetup.cCnt = 1;
	CSL_edma3ParamSetup(hParam, &paramSetup);

	return 0;
}

void CRxBufManager::ClearInterruptFlag()
{
    CSL_edma3ClearLoPendingInterrupts((CSL_Edma3Handle)m_hCha, m_hCha->region, 1 << EDMA3_CC0_CORE0_DATACARRY_TCC);
    CpIntc_clearSysInt(0, EDMA3_CC0_CORE0_DATACARRY_SYSEVT);
}
