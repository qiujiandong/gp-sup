/**
 * @file CSrioManager.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-10-04
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#include <csl_psc.h>
#include <csl_pllc.h>
#include <csl_bootcfg.h>
#include <ti/sysbios/family/c66/tci66xx/CpIntc.h>

#include "common.h"
#include "CSrioManager.h"

#define SRIO0_SYSEVT (46)
#define SRIO1_SYSEVT (47)

CSrioManager::CSrioManager():
    m_hSrio(0),
    m_bInitDone(false)
{
}

CSrioManager::~CSrioManager()
{
}

int CSrioManager::HwInit(int DevNum, Uint8 nRxDbNum, Uint16 *pDbChkList)
{
    CpIntc_clearSysInt(0, SRIO1_SYSEVT);
	CpIntc_enableSysInt(0, SRIO1_SYSEVT);
	CpIntc_mapSysIntToHostInt(0, SRIO1_SYSEVT, CORE0_INTC_SRIO_HOSTINT);
	CpIntc_enableHostInt(0, CORE0_INTC_SRIO_HOSTINT);
	CpIntc_enableAllHostInts(0);

    CSL_pllcPASSPLLPre();
	CSL_bootcfgPASSPLLCTLConfig(80, 1, 1, 1);
	CSL_pllcPASSPLLPost();

    CSL_pscModuleDisable(PSC_MD_SRIO1, PSC_PWR_PERI);
    for (int i = 0; i < 1000; i++){
        for (int j = 0; j < 2000; j++)
            asm(" nop ");
    }
	CSL_pscModuleEnable(PSC_MD_SRIO1, PSC_PWR_PERI);

    m_hSrio = CSL_srioInit(&m_Obj, CSL_SRIO_1);
    CSL_srioPhyInit(m_hSrio, CSL_SRIO_RATE_3G125, CSL_SRIO_LANE_4X);
    while(!CSL_FEXT(m_hSrio->RstdRegs->PnESCSR, SRIO_PnESCSR_INITDONE));

    if(CSL_FEXT(m_hSrio->RstdRegs->PnCCSR, SRIO_PnCCSR_CURRLINKWD) != 2)
        return -1;

    CSL_srioConfig(m_hSrio, CSL_SRIO_IDLEN_16, (Uint16)SRIO_DEVICEID);

    CSL_srioChangeApbPage(m_hSrio, CSL_SRIO_APB_RAB0);

    m_hSrio->Rab0Regs->RAB_INTR_ENAB_MISC = CSL_FMKT(SRIO_RAB_INTR_ENAB_MISC_DB, ENABLE);
    // TODO check field
    // m_hSrio->Rab0Regs->RAB_INTR_ENAB_WDMA = CSL_FMKT(SRIO_RAB_INTR_ENAB_WDMA_LISTDONE, ENABLE) |
    //                                         CSL_FMKT(SRIO_RAB_INTR_ENAB_WDMA_DONE, DISABLE) |
    //                                         CSL_FMKT(SRIO_RAB_INTR_ENAB_WDMA_CANCEL, DISABLE) |
    //                                         CSL_FMKT(SRIO_RAB_INTR_ENAB_WDMA_DBERR, DISABLE);
    m_hSrio->Rab0Regs->RAB_INTR_ENAB_GNRL = CSL_FMKT(SRIO_RAB_INTR_ENAB_GNRL_MISC, ENABLE);

    CSL_SrioChkList chkList;
	chkList.checkInfoNum = nRxDbNum;
	chkList.pInfoList = pDbChkList;
	CSL_srioReceiveDBSetup(m_hSrio, &chkList);

    CSL_srioRPIOMap(m_hSrio);

    return 0;
}

int CSrioManager::startTxData(
    void *pSrc,
    void *pDst,
    Uint32 nLen,
    Uint16 nDbInfo
){
    CSL_SrioWDMASetup wdmaSetup;

    if(((uint32_t)pSrc) & 0x7 != 0 || ((uint32_t)pDst) & 0x7 != 0){
        return -1;
    }

	wdmaSetup.srcAddr = (uint32_t)pSrc;
	wdmaSetup.dstAddr = (uint32_t)pDst;
	wdmaSetup.dstID = SRIO_TARGET_DEVICEID;
	wdmaSetup.pri = CSL_SRIO_PRI_1;
	wdmaSetup.CRF = 0;
	wdmaSetup.dbChannel = WDMA_DB_CHANNEL;
	wdmaSetup.dbEnable = TRUE;
    wdmaSetup.extraDesc = 0;

    CSL_srioWdmaDbSetup(m_hSrio, nDbInfo, SRIO_TARGET_DEVICEID, WDMA_DB_CHANNEL);

	wdmaSetup.dataLen = nLen;
	CSL_srioWdma(m_hSrio, &wdmaSetup);

	return 0;
}

int CSrioManager::ClearInterruptFlag()
{
	int ret = 0;

    // if is Doorbell interrupt, than get info
    if(CSL_FEXT(m_hSrio->Rab0Regs->RAB_INTR_STAT_GNRL, SRIO_RAB_INTR_STAT_GNRL_MISC)){
        m_nDbInfo = (m_hSrio->Rab0Regs->RAB_IB_DB_INFO & 0xFFFF);
        m_hSrio->Rab0Regs->RAB_INTR_STAT_MISC = m_hSrio->Rab0Regs->RAB_INTR_STAT_MISC;
        ret |= 1;
    }

    // clear wdma interrupt flag
    // if(CSL_FEXT(m_hSrio->Rab0Regs->RAB_INTR_STAT_GNRL, SRIO_RAB_INTR_STAT_GNRL_WDMA)){
    //     m_hSrio->Rab0Regs->RAB_INTR_STAT_WDMA = m_hSrio->Rab0Regs->RAB_INTR_STAT_WDMA;
    //     ret |= 2;
    // }
    
    CpIntc_clearSysInt(0, SRIO1_SYSEVT);

    return ret;
}
