/*
 * csl_pcie.c
 *
 *  Created on: 2021��11��11��
 *      Author: jayden
 */

#include <csl_pcie.h>
#include <csl_utils.h>


//#pragma CODE_SECTION (CSL_pcieLinkUp, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieLinkUp, ".text:csl_section:pcie")
Uint8 CSL_pcieLinkUp()
{
    CSL_FINS(hPcieRc->CMD_STATUS, PCIE_CMD_STATUS_LTSSM_EN, 1);
    while(CSL_FEXT(hPcieRc->PCIE_CORE_STATUS8, PCIE_PCIE_CORE_STATUS8_LTSSM)!=0x11)
        ;
    return CSL_FEXT(hPcieRc->LINK_STAT_CTL, PCIE_LINK_STAT_CTL_CLINKSPD);
}

//#pragma CODE_SECTION (CSL_pcieRcInit, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieRcInit, ".text:csl_section:pcie")
void CSL_pcieRcInit()
{
    CSL_FINS(hPcieRc->DBI_RO_WEN, PCIE_DBI_RO_WEN_WREN, 1);
    hPcieRc->BUS_CFG = CSL_FMK(PCIE_BUS_CFG_SUB, 0) |
                       CSL_FMK(PCIE_BUS_CFG_SEC, 1) |
                       CSL_FMK(PCIE_BUS_CFG_PRIM, 0);
//    hPcieRc->MEM_LIMIT_BASE = CSL_FMK(PCIE_MEM_LIMIT_BASE_MEM_LIMIT, 0x6FF) |
//						CSL_FMK(PCIE_MEM_LIMIT_BASE_MEM_BASE, 0x600);
    hPcieRc->PREF_CFG = CSL_FMK(PCIE_PREF_CFG_MEM_LIMIT, 0x6FF) |
                        CSL_FMK(PCIE_PREF_CFG_MEM_BASE, 0x600);
    hPcieRc->PREF_BASE_UPPER = 0x00000000;
    hPcieRc->PREF_LIMIT_UPPER = 0x00000000;
    hPcieRc->STAT_CMD = CSL_FMK(PCIE_STAT_CMD_CAP_LIST, 1) |
                        CSL_FMK(PCIE_STAT_CMD_BME, 1) |
                        CSL_FMK(PCIE_STAT_CMD_MSE, 1) |
                        CSL_FMK(PCIE_STAT_CMD_IO_EN, 1);
    hPcieRc->DEV_STAT_CTL = CSL_FMKT(PCIE_DEV_STAT_CTL_RELAXODR, ENABLE) |
                            CSL_FMKT(PCIE_DEV_STAT_CTL_MAX_RDPAYLD, SIZE128B);
    return;
}

//#pragma CODE_SECTION (CSL_pcieEpInit, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieEpInit, ".text:csl_section:pcie")
CSL_Status CSL_pcieEpInit(CSL_PcieEpBAR* pBar)
{
    int i;
    if(pBar == NULL || pBar->barNum>6){
        return CSL_FALSE;
    }
    for (i = 0; i < pBar->barNum; i++){
        hPcieEp->BAR[i] = pBar->BAR[i];
    }
    hPcieEp->STAT_CMD = CSL_FMK(PCIE_STAT_CMD_CAP_LIST, 1) |
                      CSL_FMK(PCIE_STAT_CMD_BME, 1) |
                      CSL_FMK(PCIE_STAT_CMD_MSE, 1) |
                      CSL_FMK(PCIE_STAT_CMD_IO_EN, 1);
    hPcieEp->DEV_CTRL = CSL_FMKT(PCIE_DEV_CTRL_RELAXODR, ENABLE) |
                        CSL_FMKT(PCIE_DEV_CTRL_MAX_RDPAYLD, SIZE128B);
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_pcieMsiInit, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieMsiInit, ".text:csl_section:pcie")
void CSL_pcieMsiInit(CSL_PcieMsiInfo* pMsgInfo)
{
    pMsgInfo->MsgCap = CSL_FEXT(hPcieEp->MSI_CAP_CTRL_PTR, PCIE_MSI_CAP_CTRL_PTR_MESGCAP);
    pMsgInfo->NxtPtr = CSL_FEXT(hPcieEp->MSI_CAP_CTRL_PTR, PCIE_MSI_CAP_CTRL_PTR_NXT);
    pMsgInfo->ID = CSL_FEXT(hPcieEp->MSI_CAP_CTRL_PTR, PCIE_MSI_CAP_CTRL_PTR_ID);
    
    hPcieEp->MSI_CAP_CTRL_PTR = CSL_FMK(PCIE_MSI_CAP_CTRL_PTR_ADDR64, 1) |
                                CSL_FMKT(PCIE_MSI_CAP_CTRL_PTR_MESGNUM, 32) |
                                CSL_FMK(PCIE_MSI_CAP_CTRL_PTR_MSIEN, 1);
    hPcieEp->MSI_ADDR_LOW = 0x42000000;
    hPcieEp->MSI_ADDR_HIGH = 0x00000000;
    // hPcieEp->MSI_DATA = 0x00000000;
    hPcieRc->MSI_CTRL_ADDR_LOW = 0x42000000;
    hPcieRc->MSI_CTRL_ADDR_HIGH = 0x00000000;
    hPcieRc->MSI_CTRL_INT_EN = 0xFFFFFFFF;
    hPcieRc->MSI_CTRL_INT_MASK = 0x00000000;
}

//#pragma CODE_SECTION (CSL_pcieDmaReadLocalInt, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieDmaReadLocalInt, ".text:csl_section:pcie")
void CSL_pcieDmaWriteLocalInt(
    Uint8 chNum,
    Uint32 dmaSize,
    Uint32 srcAddr,
    Uint32 dstAddr
){
    CSL_FINS(hPcieRc->DMA_WR_EN, PCIE_DMA_WR_EN, 1);
    hPcieRc->DMA_WR_INT_MASK = CSL_FMK(PCIE_DMA_INT_ABORT, 0) |
                               CSL_FMK(PCIE_DMA_INT_DONE, 0);
    hPcieRc->DMA_VIEWPORT_SEL = CSL_FMKT(PCIE_DMA_VIEWPORT_SEL_CHANNEL_DIR, WRITE) |
                                CSL_FMK(PCIE_DMA_VIEWPORT_SEL_CHANNEL_NUM, chNum);
    hPcieRc->DMA_CH_CTRL1 = CSL_FMK(PCIE_DMA_CH_CTRL1_TD, 1) |
                            CSL_FMK(PCIE_DMA_CH_CTRL1_LIE, 1);
    hPcieRc->DMA_SIZE = dmaSize;
    hPcieRc->DMA_SRC_LOW = srcAddr;
    hPcieRc->DMA_SRC_HIGH = 0x00000000;
    hPcieRc->DMA_DST_LOW = dstAddr;
    hPcieRc->DMA_DST_HIGH = 0x00000000;
    hPcieRc->DMA_WR_DB = CSL_FMK(PCIE_DMA_WR_DB_WR_STOP, 0) |
                         CSL_FMK(PCIE_DMA_WR_DB_DB_NUM, chNum);
}

//#pragma CODE_SECTION (CSL_pcieDmaReadLocalInt, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieDmaReadLocalInt, ".text:csl_section:pcie")
void CSL_pcieDmaReadLocalInt(
    Uint8 chNum,
    Uint32 dmaSize,
    Uint32 srcAddr,
    Uint32 dstAddr
)
{
    CSL_FINS(hPcieRc->DMA_RD_EN, PCIE_DMA_RD_EN, 1);
    hPcieRc->DMA_RD_INT_MASK = CSL_FMK(PCIE_DMA_INT_ABORT, 0) |
                               CSL_FMK(PCIE_DMA_INT_DONE, 0);
    hPcieRc->DMA_VIEWPORT_SEL = CSL_FMKT(PCIE_DMA_VIEWPORT_SEL_CHANNEL_DIR, READ) |
                                CSL_FMK(PCIE_DMA_VIEWPORT_SEL_CHANNEL_NUM, chNum);
    hPcieRc->DMA_CH_CTRL1 = CSL_FMK(PCIE_DMA_CH_CTRL1_TD, 1) |
                            CSL_FMK(PCIE_DMA_CH_CTRL1_LIE, 1);
    hPcieRc->DMA_SIZE = dmaSize;
    hPcieRc->DMA_SRC_LOW = srcAddr;
    hPcieRc->DMA_SRC_HIGH = 0x00000000;
    hPcieRc->DMA_DST_LOW = dstAddr;
    hPcieRc->DMA_DST_HIGH = 0x00000000;
    hPcieRc->DMA_RD_DB = CSL_FMK(PCIE_DMA_RD_DB_WR_STOP, 0) |
                         CSL_FMK(PCIE_DMA_RD_DB_DB_NUM, chNum);
}

//#pragma CODE_SECTION (CSL_pcieInBoundSetup, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieInBoundSetup, ".text:csl_section:pcie")
void CSL_pcieInBoundSetup(
    Uint8 region, 
    Uint32 srcLowAddr, 
    Uint32 srcHighAddr, 
    Uint32 limitAddr,
    Uint32 targetAddr
){
    hPcieRc->IATU_VIEWPORT = CSL_FMKT(PCIE_IATU_VIEWPORT_DIR, INBOUND) |
                             CSL_FMK(PCIE_IATU_VIEWPORT_INDEX, region);

    hPcieRc->IATU_LWR_BASE_ADDR = srcLowAddr;
    hPcieRc->IATU_UPR_BASE_ADDR = srcHighAddr;
    hPcieRc->IATU_LIMIT_ADDR = limitAddr;
    hPcieRc->IATU_LWR_TARGET_ADDR = targetAddr;
    hPcieRc->IATU_UPR_TARGET_ADDR = 0x00000000;
    hPcieRc->IATU_REGION_CTRL1 = CSL_FMKT(PCIE_IATU_REGION_CTRL1_TYPE, MRW);
    hPcieRc->IATU_REGION_CTRL2 = CSL_FMKT(PCIE_IATU_REGION_CTRL2_REGIONEN, ENABLE) |
                                 CSL_FMKT(PCIE_IATU_REGION_CTRL2_MATCHMODE, ADDR) |
                                 CSL_FMKT(PCIE_IATU_REGION_CTRL2_INVMODE, DISABLE) |
                                 CSL_FMKT(PCIE_IATU_REGION_CTRL2_CFGSHIFT, DISABLE) |
                                 CSL_FMKT(PCIE_IATU_REGION_CTRL2_FUZZYTYPEMATCH, DISABLE) |
                                 CSL_FMK(PCIE_IATU_REGION_CTRL2_BARNUM, 0) |
                                 CSL_FMK(PCIE_IATU_REGION_CTRL2_MSGCODE, 0);
}

//#pragma CODE_SECTION (CSL_pcieOutBoundSetup, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieOutBoundSetup, ".text:csl_section:pcie")
void CSL_pcieOutBoundSetup(
    Uint8 region, 
    Uint32 targetLowAddr,
    Uint32 targetHighAddr,
    Uint32 limitAddr,
    Uint32 srcAddr
){
    hPcieRc->IATU_VIEWPORT = CSL_FMKT(PCIE_IATU_VIEWPORT_DIR, OUTBOUND) |
                             CSL_FMK(PCIE_IATU_VIEWPORT_INDEX, region);

    hPcieRc->IATU_LWR_BASE_ADDR = srcAddr;
    hPcieRc->IATU_UPR_BASE_ADDR = 0x00000000;
    hPcieRc->IATU_LIMIT_ADDR = limitAddr;
    hPcieRc->IATU_LWR_TARGET_ADDR = targetLowAddr;
    hPcieRc->IATU_UPR_TARGET_ADDR = targetHighAddr;
    hPcieRc->IATU_REGION_CTRL1 = CSL_FMKT(PCIE_IATU_REGION_CTRL1_TYPE, MRW);
    hPcieRc->IATU_REGION_CTRL2 = CSL_FMKT(PCIE_IATU_REGION_CTRL2_REGIONEN, ENABLE) |
                                 CSL_FMKT(PCIE_IATU_REGION_CTRL2_INVMODE, DISABLE) |
                                 CSL_FMKT(PCIE_IATU_REGION_CTRL2_CFGSHIFT, DISABLE) |
                                 CSL_FMK(PCIE_IATU_REGION_CTRL2_MSGCODE, 0);
}

//#pragma CODE_SECTION (CSL_pcieRcConfig, ".text:csl_section:pcie");
CSL_SET_CSECT(CSL_pcieRcConfig, ".text:csl_section:pcie")
void CSL_pcieRcConfig()
{
    CSL_FINST(hPcieRc->LANE_CTL1 , PCIE_LANE_CTL1_LINKCAP, x4);
    CSL_FINS(hPcieRc->LANE_CTL2, PCIE_LANE_CTL2_NUMOFLANE, 4);

    CSL_FINS(hPcieRc->LINK_CTL2, PCIE_LINK_CTL2_TGTSPD, 2);
    CSL_FINS(hPcieRc->LANE_CTL2, PCIE_LANE_CTL2_DIRECTSPDCHG, 0);
    CSL_FINS(hPcieRc->LANE_CTL2, PCIE_LANE_CTL2_DIRECTSPDCHG, 1);
    return;
}
