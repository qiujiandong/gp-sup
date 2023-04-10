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
#include "CFftManager.h"
#include "CTspsManager.h"
#include "CRxBufManager.h"
#include "CSrio2PcieManager.h"
#include "CHwFhogManager.h"
#include <csl_psc.h>
#include "main.h"

CTspsManager *pTspsMgr;
CFftManager *pFftMgr;
CRxBufManager *pRxBufMgr;
CSrio2PcieManager *pSrio2PcieMgr;
CHwFhogManager *pHwFhogMgr;

extern "C" {
	void SimDataRxHandler(UArg a0);
	Void FFTDoneHandler(UArg a0);
	Void TspsDoneHandler(UArg a0);
	Void SrioHandler(UArg a0);
	Void HwFhogDoneHandler(UArg a0);
}

int main()
{
	CSL_pscModuleEnable(PSC_MD_MSMC, PSC_PWR_PERI);
	CSL_pscModuleEnable(PSC_MD_FFT, PSC_PWR_PERI);
	CSL_pscModuleEnable(PSC_MD_DMA0, PSC_PWR_PERI);
    CSL_pscModuleEnable(PSC_MD_DMA1, PSC_PWR_PERI);

	pTspsMgr = CTspsManager::getInstance();
	pFftMgr = CFftManager::getInstance();
	pRxBufMgr = CRxBufManager::getInstance();
	pHwFhogMgr = CHwFhogManager::getInstance();

#if !SIMULATION_MODE
	pSrio2PcieMgr = CSrio2PcieManager::getInstance();

	if(pSrio2PcieMgr->Srio2PcieInit(8) != 0){
		System_abort("Srio2Pcie init failed\n");
	}

	Uint16 rxDbChkList[] = {
		SRIO_DBRX_PC_STARTREQ,
		SRIO_DBRX_SWFROMPC_DONE,
		SRIO_DBRX_SWFROMFPGA_DONE};

	if (pSrio2PcieMgr->HwInit(CSL_SRIO_1, 3, rxDbChkList) != 0){
		System_abort("SRIO init failed\n");
	}
#endif

	pTspsMgr->HwInit(); // DMA0
	pFftMgr->init(FFT_POINT, FFT_POINT);
    pFftMgr->HwInit(); // DMA1
	pRxBufMgr->HwInit();
	pHwFhogMgr->HwInit();

	BIOS_start();
	return 0;
}

void SimDataRxHandler(UArg a0)
{
	pRxBufMgr->ClearInterruptFlag();
	Semaphore_post(hRxSimData);
}

Void FFTDoneHandler(UArg a0)
{
	pFftMgr->ClearInterruptFlag();
	Semaphore_post(hFFTHwiSem);
}

Void TspsDoneHandler(UArg a0)
{
	pTspsMgr->ClearInterruptFlag();
	Semaphore_post(hTspsDoneSem);
}

Void SrioHandler(UArg a0)
{
	pSrio2PcieMgr->ClearInterruptFlag();

	// PC request for start
	if(pSrio2PcieMgr->m_nDbInfo == SRIO_DBRX_PC_STARTREQ){
		Semaphore_post(hRxDbStartReqSem);
	}
	// DSP has received data
	else if(pSrio2PcieMgr->m_nDbInfo == SRIO_DBRX_SWFROMPC_DONE){
		Semaphore_post(hRxDbSwFromPCSem);
	}
	else if(pSrio2PcieMgr->m_nDbInfo == SRIO_DBRX_SWFROMFPGA_DONE){
		Semaphore_post(hRxDbSwFromFPGASem);
	}
}

Void HwFhogDoneHandler(UArg a0)
{
	// pHwFhogMgr->ClearInterruptFlag();
	Semaphore_post(hHwFhogDoneSem);
}
