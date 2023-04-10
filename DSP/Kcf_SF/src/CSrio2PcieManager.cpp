/**
 * @file CSrio2PcieManager.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-02-27
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "CSrio2PcieManager.h"
#include "Emif2Axil.h"
#include "main.h"

#define SRIO2PCIE_BASE_ADDR (0x7C010000)

CSrio2PcieManager::CSrio2PcieManager():
    m_hSrio2Pcie(NULL)
{
}

CSrio2PcieManager::~CSrio2PcieManager()
{
}

int CSrio2PcieManager::Srio2PcieInit(int EclkRatio)
{
    gpioConfig();
    emifConfig(EclkRatio);

    m_hSrio2Pcie = getSrio2PcieHandle(SRIO2PCIE_BASE_ADDR);
    if(m_hSrio2Pcie == NULL){
        return -1;
    }
    return 0;
}

int CSrio2PcieManager::startTxDbWithMSI(Uint16 nInfo)
{
    int status;
    enableDB2MSI(m_hSrio2Pcie);
    
    while(isDb2MsiBusy(m_hSrio2Pcie))
        ;

    status = CSL_srioSendDB(m_hSrio, nInfo, SRIO_TARGET_DEVICEID, 0);
    if(status != CSL_SOK){
        return -1;
    }
    return 0;
}

int CSrio2PcieManager::startTxDbWithoutMSI(Uint16 nInfo)
{
    int status;
    disableDB2MSI(m_hSrio2Pcie);
    status = CSL_srioSendDB(m_hSrio, nInfo, SRIO_TARGET_DEVICEID, 0);
    if(status != CSL_SOK){
        return -1;
    }
    return 0;
}

int CSrio2PcieManager::startTxNwToPC(void *pSrc, Uint32 nSizeDW)
{
    int status;
    Uint32 nTemp;
    CSL_SrioWDMASetup wdmaSetup;
    int extraDescCnt;
    SrioWdmaDesc *pExtraDesc = NULL;

    if(((Uint32)pSrc) & 0x7 || pSrc == NULL){
        return -2;
    }

    extraDescCnt = ((nSizeDW << 3) + ((1 << 19) - 1)) / (1 << 19);

    if(extraDescCnt > 1){
        pExtraDesc = (SrioWdmaDesc *)memalign(128, sizeof(SrioWdmaDesc) * extraDescCnt);
        if(pExtraDesc == NULL){
            System_abort("pExtraDesc Memory calloc faild\n");
        }

        for (int i = 0; i < extraDescCnt - 1; ++i){
            pExtraDesc[i].ctrl = CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_DESCVLD, ENABLE) |
                                CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_NXTDESCVLD, ENABLE) |
                                CSL_FMK(SRIO_RAB_DMA_IADDR_DESC_CTRL_SIZE, 1 << 17);
            pExtraDesc[i].srcAddr = ((Uint32)pSrc + (i << 19)) >> 2;
            pExtraDesc[i].dstAddr = 0;
            pExtraDesc[i].nextDesc = (Uint32)(pExtraDesc + i + 1) >> 3;
        }

        pExtraDesc[extraDescCnt - 1].ctrl = CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_DESCVLD, ENABLE) |
                                            CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_NXTDESCVLD, ENABLE) |
                                            CSL_FMK(SRIO_RAB_DMA_IADDR_DESC_CTRL_SIZE, ((((nSizeDW << 3) - 1) % (1 << 19)) + 1) >> 2);
        pExtraDesc[extraDescCnt - 1].srcAddr = ((Uint32)pSrc + ((extraDescCnt - 1) << 19)) >> 2;
        pExtraDesc[extraDescCnt - 1].dstAddr = 0;
        pExtraDesc[extraDescCnt - 1].nextDesc = 0;

        Cache_wb(pExtraDesc, sizeof(SrioWdmaDesc) * extraDescCnt, Cache_Type_ALLD, TRUE);
        wdmaSetup.extraDesc = (Uint32)pExtraDesc >> 2;
    }
    else{
        wdmaSetup.dataLen = nSizeDW << 3;
        wdmaSetup.srcAddr = (uint32_t)pSrc;
	    wdmaSetup.dstAddr = 0;
        wdmaSetup.extraDesc = 0;
    }

    wdmaSetup.dstID = SRIO_TARGET_DEVICEID;
    wdmaSetup.pri = CSL_SRIO_PRI_1;
    wdmaSetup.CRF = 0;
    wdmaSetup.dbChannel = WDMA_DB_CHANNEL;
    wdmaSetup.dbEnable = FALSE;
    
    setupNwTxToPC(m_hSrio2Pcie);

    status = startTxDbWithMSI(SRIO_DBTX_PC_STARTC2H);
	if(status != 0){
		return -1;
	}

    CSL_srioChangeApbPage(m_hSrio, CSL_SRIO_APB_RAB1);
    clearWdmaStatus(m_hSrio, 3);
    CSL_srioWdma(m_hSrio, &wdmaSetup);
    do{
        nTemp = getWdmaStatus(m_hSrio);
        if(nTemp & 0x1C){
            return -3;
        }
    } while ((nTemp & 0x1) != 0x1);
    clearWdmaStatus(m_hSrio, 3);

    if(pExtraDesc){
        free(pExtraDesc);
        pExtraDesc = NULL;
    }

    return 0;
}

int CSrio2PcieManager::startTxNwToFPGA(void *pSrc, Uint32 nSizeDW, Uint32 dstAddr)
{
    Uint32 nTemp;
    CSL_SrioWDMASetup wdmaSetup;
    int extraDescCnt;
    SrioWdmaDesc *pExtraDesc = NULL;

    if(((Uint32)pSrc) & 0x7 || pSrc == NULL){
        return -1;
    }

    extraDescCnt = ((nSizeDW << 3) + ((1 << 19) - 1)) / (1 << 19);

    if(extraDescCnt > 1){
        pExtraDesc = (SrioWdmaDesc *)memalign(128, sizeof(SrioWdmaDesc) * extraDescCnt);
        if(pExtraDesc == NULL){
            System_abort("pExtraDesc Memory calloc faild\n");
        }

        for (int i = 0; i < extraDescCnt - 1; ++i){
            pExtraDesc[i].ctrl = CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_DESCVLD, ENABLE) |
                                CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_NXTDESCVLD, ENABLE) |
                                CSL_FMK(SRIO_RAB_DMA_IADDR_DESC_CTRL_SIZE, 1 << 17);
            pExtraDesc[i].srcAddr = ((Uint32)pSrc + (i << 19)) >> 2;
            pExtraDesc[i].dstAddr = (dstAddr + (i << 19)) >> 2;
            pExtraDesc[i].nextDesc = (Uint32)(pExtraDesc + i + 1) >> 3;
        }

        pExtraDesc[extraDescCnt - 1].ctrl = CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_DESCVLD, ENABLE) |
                                            CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_NXTDESCVLD, ENABLE) |
                                            CSL_FMK(SRIO_RAB_DMA_IADDR_DESC_CTRL_SIZE, ((((nSizeDW << 3) - 1) % (1 << 19)) + 1) >> 2);
        pExtraDesc[extraDescCnt - 1].srcAddr = ((Uint32)pSrc + ((extraDescCnt - 1) << 19)) >> 2;
        pExtraDesc[extraDescCnt - 1].dstAddr = (dstAddr + ((extraDescCnt - 1) << 19)) >> 2;
        pExtraDesc[extraDescCnt - 1].nextDesc = 0;

        Cache_wb(pExtraDesc, sizeof(SrioWdmaDesc) * extraDescCnt, Cache_Type_ALLD, TRUE);
        wdmaSetup.extraDesc = (Uint32)pExtraDesc >> 2;
    }
    else{
        wdmaSetup.dataLen = nSizeDW << 3;
        wdmaSetup.srcAddr = (uint32_t)pSrc;
	    wdmaSetup.dstAddr = dstAddr;
        wdmaSetup.extraDesc = 0;
    }

    wdmaSetup.dstID = SRIO_TARGET_DEVICEID;
    wdmaSetup.pri = CSL_SRIO_PRI_1;
    wdmaSetup.CRF = 0;
    wdmaSetup.dbChannel = WDMA_DB_CHANNEL;
    wdmaSetup.dbEnable = FALSE;

    setupNwTxToFPGA(m_hSrio2Pcie);

    CSL_srioChangeApbPage(m_hSrio, CSL_SRIO_APB_RAB1);
    clearWdmaStatus(m_hSrio, 3);
    CSL_srioWdma(m_hSrio, &wdmaSetup);
    do{
        nTemp = getWdmaStatus(m_hSrio);
        if(nTemp & 0x1C){
            return -3;
        }
    } while ((nTemp & 0x1) != 0x1);
    clearWdmaStatus(m_hSrio, 3);

    if(pExtraDesc){
        free(pExtraDesc);
        pExtraDesc = NULL;
    }

	return 0;
}

int CSrio2PcieManager::startTxSeqInfoFromPC(void *dstAddr)
{
    int status;

    //  info PC
    status = startTxDbWithMSI(SRIO_DBTX_PC_STARTREQ);
    if(status != 0){
        return -1;
    }

    status = startSwTxFromPC(m_hSrio2Pcie, 4, (Uint32)dstAddr, SRIO_DBRX_SWFROMPC_DONE);
    return status;
}

int CSrio2PcieManager::startTxFrameFromPC(void *dstAddr, Uint32 nSizeDW)
{
    int status;

    if(dstAddr == NULL){
        return -1;
    }

    //  info PC
    status = startTxDbWithMSI(SRIO_DBTX_PC_STARTH2C);
    if(status != 0){
        return -1;
    }

    // request for tx data while NW is busy
    do{
        status = startSwTxFromPC(m_hSrio2Pcie, nSizeDW, (Uint32)dstAddr, SRIO_DBRX_SWFROMPC_DONE);
    } while (status == -2);

    return status;
}

int CSrio2PcieManager::startTxSwFromFPGA(void *dstAddr, Uint32 nSizeDW, Uint32 srcAddr)
{
    int status;
    if(dstAddr == NULL){
        return -1;
    }

    // request for tx data while NW is busy
    do{
        status = startSwTxFromFPGA(m_hSrio2Pcie, nSizeDW, (Uint32)dstAddr, srcAddr, SRIO_DBRX_SWFROMFPGA_DONE);
    } while (status == -2);
    return status;
}
