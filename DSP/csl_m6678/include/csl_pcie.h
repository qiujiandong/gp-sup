/*
 * csl_pcie.h
 *
 *  Created on: 2021��11��11��
 *      Author: jayden
 */

#ifndef _CSL_PCIE_H_
#define _CSL_PCIE_H_

#include <soc.h>
#include <csl.h>
#include <cslr_pcie.h>

#define hPcieRc ((CSL_PcieRcRegsOvly)CSL_PCIE_RC_REGS)
#define hPcieEp ((CSL_PcieEpRegsOvly)CSL_PCIE_EP_REGS)

typedef struct 
{
    Uint8 MsgCap;
    Uint8 NxtPtr;
    Uint8 ID;
    /* data */
}CSL_PcieMsiInfo;

typedef struct 
{
    Uint32 barNum;
    Uint32 BAR[6];
}CSL_PcieEpBAR;

typedef struct 
{
    Bool flag;
    Uint32 RdStatus;
    Uint32 WrStatus;
    /* data */
}CSL_PcieDmaIntStatus;


Uint8 CSL_pcieLinkUp();
void CSL_pcieRcInit();
CSL_Status CSL_pcieEpInit(CSL_PcieEpBAR* pBar);
void CSL_pcieMsiInit(CSL_PcieMsiInfo* pMsgInfo);
void CSL_pcieInBoundSetup(
    Uint8 region,
    Uint32 srcLowAddr,
    Uint32 srcHighAddr,
    Uint32 limitAddr,
    Uint32 targetAddr);
void CSL_pcieOutBoundSetup(
	Uint8 region,
	Uint32 targetLowAddr,
	Uint32 targetHighAddr,
	Uint32 limitAddr,
	Uint32 srcAddr);
void CSL_pcieDmaWriteLocalInt(
    Uint8 chNum,
    Uint32 dmaSize,
    Uint32 srcAddr,
    Uint32 dstAddr);
void CSL_pcieDmaReadLocalInt(
    Uint8 chNum,
    Uint32 dmaSize,
    Uint32 srcAddr,
    Uint32 dstAddr);

void CSL_pcieRcConfig();

#endif /* INC_CSL_CSL_PCIE_H_ */
