/**
 * @file main.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-09-07
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#include "CSrio2PcieManager.h"
#include <csl_psc.h>
#include "main.h"

CSrio2PcieManager *pSrio2PcieMgr;

extern "C" {
	Void SrioHandler(UArg a0);
}

int main()
{
	CSL_pscModuleEnable(PSC_MD_MSMC, PSC_PWR_PERI);
	CSL_pscModuleEnable(PSC_MD_FFT, PSC_PWR_PERI);
	CSL_pscModuleEnable(PSC_MD_DMA0, PSC_PWR_PERI);
    CSL_pscModuleEnable(PSC_MD_DMA1, PSC_PWR_PERI);

	pSrio2PcieMgr = CSrio2PcieManager::getInstance();

	if(pSrio2PcieMgr->Srio2PcieInit(8) != 0){
		System_abort("Srio2Pcie init failed\n");
	}

	Uint16 rxDbChkList[] = {
		SRIO_DBRX_PC_STARTREQ,
		SRIO_DBRX_SWDONE};

	if (pSrio2PcieMgr->HwInit(CSL_SRIO_1, 2, rxDbChkList) != 0){
		System_abort("SRIO init failed\n");
	}

	BIOS_start();
	return 0;
}

Void SrioHandler(UArg a0)
{
	pSrio2PcieMgr->ClearInterruptFlag();

	// PC request for start
	if(pSrio2PcieMgr->m_nDbInfo == SRIO_DBRX_PC_STARTREQ){
		Semaphore_post(hRxDbStartReqSem);
	}
	// DSP has received data
	else if(pSrio2PcieMgr->m_nDbInfo == SRIO_DBRX_SWDONE){
		Semaphore_post(hRxDbSwDoneSem);
	}
	else if(pSrio2PcieMgr->m_nDbInfo == SRIO_DBRX_NWDONE){
		Semaphore_post(hTxNwDoneSem);
	}

}
