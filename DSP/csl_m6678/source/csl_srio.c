#include <csl_srio.h>
#include <csl_utils.h>

//#pragma CODE_SECTION (CSL_srioInit, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioInit, ".text:csl_section:srio")
CSL_SrioHandle CSL_srioInit(CSL_SrioObj *srioObj, int instNum)
{
    Uint32 srioBase;
    if(srioObj == NULL){
        return NULL;
    }
    else if(instNum == CSL_SRIO_0){
        srioBase = CSL_SRIO0_PBUS_REGS;
    }
    else if(instNum == CSL_SRIO_1){
        srioBase = CSL_SRIO1_PBUS_REGS;
    }
    else{
        return NULL;
    }
    srioObj->currentWindow = CSL_SRIO_APB_RAB0;
    srioObj->PbusRegs = (CSL_SrioPbusRegsOvly)srioBase;
    srioObj->PhyRegs = (CSL_SrioPhyRegsOvly)(srioBase + 0x10000);
    srioObj->RstdRegs = (CSL_SrioApbRstdRegsOvly)(srioBase + 0x20800);
    srioObj->Grio0Regs = (CSL_SrioApbGrio0RegsOvly)(srioBase + 0x20800);
    srioObj->Grio1Regs = (CSL_SrioApbGrio1RegsOvly)(srioBase + 0x20800);
    srioObj->Rab0Regs = (CSL_SrioApbRab0RegsOvly)(srioBase + 0x20000);
    srioObj->Rab1Regs = (CSL_SrioApbRab1RegsOvly)(srioBase + 0x20800);
    return srioObj;
}

//#pragma CODE_SECTION (CSL_srioPhyInit, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioPhyInit, ".text:csl_section:srio")
CSL_Status CSL_srioPhyInit(
    CSL_SrioHandle hSrio,
    CSL_SrioRateMode rateMode,
    CSL_SrioLaneMode laneMode
){
    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }
    CSL_FINS(hSrio->PbusRegs->PBUSCTRL5, SRIO_PBUSCTRL5_RATEMODE, rateMode);
    CSL_FINS(hSrio->PbusRegs->PBUSCTRL5, SRIO_PBUSCTRL5_LANEMODE, laneMode);
    //Start Auto Config
    CSL_FINS(hSrio->PbusRegs->PBUSCTRL5, SRIO_PBUSCTRL5_START, 1);
    while(!CSL_FEXT(hSrio->PbusRegs->PBUSCTRL5, SRIO_PBUSCTRL5_PHYCFGDONE))
        ;
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioChangeApbPage, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioChangeApbPage, ".text:csl_section:srio")
CSL_Status CSL_srioChangeApbPage(
    CSL_SrioHandle hSrio,
    CSL_SrioApbWindow apbWind
){
    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }
    hSrio->currentWindow = apbWind;
    switch (apbWind)
    {
    case CSL_SRIO_APB_RSTD:
        hSrio->Rab0Regs->RAB_APB_CSR = CSL_FMKT(SRIO_RAB_APB_CSR_PAGE, RSTD);
        break;
    case CSL_SRIO_APB_GRIO0:
        hSrio->Rab0Regs->RAB_APB_CSR = CSL_FMKT(SRIO_RAB_APB_CSR_PAGE, GRIO0);
        break;
    case CSL_SRIO_APB_GRIO1:
        hSrio->Rab0Regs->RAB_APB_CSR = CSL_FMKT(SRIO_RAB_APB_CSR_PAGE, GRIO1);
        break;
    case CSL_SRIO_APB_RAB0:
        hSrio->Rab0Regs->RAB_APB_CSR = CSL_FMKT(SRIO_RAB_APB_CSR_PAGE, RAB0);
        break;
    case CSL_SRIO_APB_RAB1:
        hSrio->Rab0Regs->RAB_APB_CSR = CSL_FMKT(SRIO_RAB_APB_CSR_PAGE, RAB1);
        break;
    default:
        break;
    }
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioRPIOMap, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioRPIOMap, ".text:csl_section:srio")
CSL_Status CSL_srioRPIOMap(
    CSL_SrioHandle hSrio
)
{
    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }
    /*
    Encoding 	Size    Translated AXI address
	0000 		1M 		{LUTN[31:14], RIO_Address[19:0]}
	0001 		2M 		{LUTN[31:15], RIO_Address[20:0]}
	0010 		4M 		{LUTN[31:16], RIO_Address[21:0]}
	0011 		8M 		{LUTN[31:17], RIO_Address[22:0]}
	0100 		16M 	{LUTN[31:18], RIO_Address[23:0]}
	0101 		32M 	{LUTN[31:19], RIO_Address[24:0]}
	0110 		64M 	{LUTN[31:20], RIO_Address[25:0]}
	0111 		128M 	{LUTN[31:21], RIO_Address[26:0]}
	1000 		256M 	{LUTN[31:22], RIO_Address[27:0]}
    */
    int i;

    hSrio->Rab0Regs->RPIO[0].RAB_RPIO_CTRL = CSL_FMKT(SRIO_RPIO_CTRL_RPIOEN, ENABLE) |
    											 CSL_FMKT(SRIO_RPIO_CTRL_RELAXODR, ENABLE);

    for (i = 0; i < 16; i++){
        hSrio->Rab0Regs->RAB_RIO_AMAP_LUT[i] = CSL_FMKT(SRIO_RAB_RIO_AMAP_LUT_MAPEN, ENABLE) |
                                               CSL_FMKT(SRIO_RAB_RIO_AMAP_LUT_WINDSIZE, SIZE256M) |
                                               CSL_FMK(SRIO_RAB_RIO_AMAP_LUT_AXI_HIGH_ADDR_256M, i);
    }
    hSrio->Rab0Regs->RAB_RIO_AMAP_IDSL = CSL_FMKT(SRIO_RAB_RIO_AMAP_IDSL_INDEX, ADDRS31E28);
    hSrio->Rab0Regs->RAB_RIO_AMAP_BYPS = CSL_FMKT(SRIO_RAB_RIO_AMAP_BYPS_INDSEL, ADDR);
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioAPIOMap, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioAPIOMap, ".text:csl_section:srio")
CSL_Status CSL_srioAPIOMap(
    CSL_SrioHandle hSrio,
    CSL_SrioAPIOWindSetup* windSetup
){
    CSL_SrioRabApioAmapRegs *pApioCfgRegs;

    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }
    else if(windSetup->windNum>15){
        return CSL_ESYS_INVPARAMS;
    }
    else{
        pApioCfgRegs = &(hSrio->Rab0Regs->ApioAmap[windSetup->windNum]);
        pApioCfgRegs->RAB_APIO_AMAP_CTRL = CSL_FMKT(SRIO_RAB_APIO_AMAP_CTRL_MAPEN, ENABLE) |
                                           CSL_FMK(SRIO_RAB_APIO_AMAP_CTRL_TTYPE, windSetup->tType) |
                                           CSL_FMK(SRIO_RAB_APIO_AMAP_CTRL_PRI, windSetup->pri) |
                                           CSL_FMK(SRIO_RAB_APIO_AMAP_CTRL_XADDR, ((windSetup->RioBaseAddr >> 32) & 0x3)) |
                                           CSL_FMK(SRIO_RAB_APIO_AMAP_CTRL_CRF, windSetup->CRF) |
                                           CSL_FMK(SRIO_RAB_APIO_AMAP_CTRL_DSTID, windSetup->dstID);
        pApioCfgRegs->RAB_APIO_AMAP_SIZE = windSetup->windSize;
        pApioCfgRegs->RAB_APIO_AMAP_ABAR = windSetup->AxiBaseAddr >> 10;
        if(windSetup->tType){
            pApioCfgRegs->RAB_APIO_AMAP_RBAR = (windSetup->RioBaseAddr & 0xFFFFFFFF) >> 10;
        }
        else{
            pApioCfgRegs->RAB_APIO_AMAP_RBAR = (windSetup->hopCnt << 14) | ((windSetup->RioBaseAddr & 0xFFFFFFFF) >> 10);
        }
    }
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioConfig, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioConfig, ".text:csl_section:srio")
CSL_Status CSL_srioConfig(
    CSL_SrioHandle hSrio,
    CSL_SrioIDLen idLen,
    Uint16 ID
){
    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }
    // setup ID
    CSL_srioChangeApbPage(hSrio, CSL_SRIO_APB_RSTD);
    if(idLen == CSL_SRIO_IDLEN_16){
        ID = (ID & 0xFF) << 8 | (ID >> 8); // change to big-endian
        hSrio->PbusRegs->PBUSCTRL1 = CSL_FMKT(SRIO_PBUSCTRL1_KEY, TOKEN) |
								     CSL_FMKT(SRIO_PBUSCTRL1_CTLS, ENABLE);
        hSrio->RstdRegs->BDIDCSR = CSL_FMK(SRIO_BDIDCSR_BDID, 0x00) |
							       CSL_FMK(SRIO_BDIDCSR_LBDID, ID);
    }
    else if(idLen == CSL_SRIO_IDLEN_8){
        hSrio->PbusRegs->PBUSCTRL1 = CSL_FMKT(SRIO_PBUSCTRL1_KEY, TOKEN) |
								     CSL_FMKT(SRIO_PBUSCTRL1_CTLS, DISABLE);
        hSrio->RstdRegs->BDIDCSR = CSL_FMK(SRIO_BDIDCSR_BDID, (ID & 0xFF)) |
							       CSL_FMK(SRIO_BDIDCSR_LBDID, 0x0000);
    }
    // enable all function
    hSrio->Rab0Regs->RAB_CTRL = CSL_FMKT(SRIO_RAB_CTRL_APIOEN, ENABLE) |
								CSL_FMKT(SRIO_RAB_CTRL_RPIOEN, ENABLE) |
								CSL_FMKT(SRIO_RAB_CTRL_WDMAEN, ENABLE) |
								CSL_FMKT(SRIO_RAB_CTRL_RDMAEN, ENABLE);
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioReceiveDBSetup, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioReceiveDBSetup, ".text:csl_section:srio")
CSL_Status CSL_srioReceiveDBSetup(
    CSL_SrioHandle hSrio,
    CSL_SrioChkList* chkList
){
    int i;
    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }
    else if(chkList->checkInfoNum>30){
        return CSL_ESYS_INVPARAMS;
    }
    hSrio->Rab0Regs->RAB_IB_DB_CSR = CSL_FMKT(SRIO_RAB_IB_DB_CSR_DBRECEN, ENABLE);
	
    for (i = 0; i < chkList->checkInfoNum;i++){
        hSrio->Rab0Regs->RAB_IB_DB_CHK[i] = CSL_FMKT(SRIO_RAB_IB_DB_CHK_IBDBEN, ENABLE) |
										    CSL_FMK(SRIO_RAB_IB_DB_CHK_INFO, *(chkList->pInfoList+i));
    }
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioSendDB, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioSendDB, ".text:csl_section:srio")
CSL_Status CSL_srioSendDB(
    CSL_SrioHandle hSrio,
    Uint16 Info,
    Uint16 targetDevID,
    Uint8 dbChannel
){
    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }
    else if(dbChannel > 14){
        return CSL_ESYS_INVPARAMS;
    }

    hSrio->Rab0Regs->RAB_INTR_STAT_MISC = CSL_FMKT(SRIO_RAB_INTR_STAT_MISC_OUTDB, CLEAR);

    hSrio->Rab0Regs->ObDb[dbChannel].RAB_OB_DB_INFO = CSL_FMK(SRIO_RAB_OB_DB_INFO, Info);
    hSrio->Rab0Regs->ObDb[dbChannel].RAB_OB_DB_CSR = CSL_FMKT(SRIO_RAB_OB_DB_CSR_SEND, ENABLE) |
                                                     CSL_FMK(SRIO_RAB_OB_DB_CSR_PRI, 1) |
                                                     CSL_FMK(SRIO_RAB_OB_DB_CSR_CRF, 0) |
                                                     CSL_FMK(SRIO_RAB_OB_DB_CSR_DSTID, targetDevID);

    while(!CSL_FEXT(hSrio->Rab0Regs->RAB_INTR_STAT_MISC, SRIO_RAB_INTR_STAT_MISC_OUTDB));
    hSrio->Rab0Regs->RAB_INTR_STAT_MISC = CSL_FMKT(SRIO_RAB_INTR_STAT_MISC_OUTDB, CLEAR);
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioIntConfig, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioIntConfig, ".text:csl_section:srio")
CSL_Status CSL_srioIntConfig(
    CSL_SrioHandle hSrio
){
    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }

    hSrio->Rab0Regs->RAB_INTR_ENAB_MISC = CSL_FMKT(SRIO_RAB_INTR_ENAB_MISC_DB, ENABLE);

    hSrio->Rab0Regs->RAB_INTR_ENAB_WDMA = CSL_FMKT(SRIO_RAB_INTR_ENAB_WDMA_LISTDONE, ENABLE) |
                                          CSL_FMKT(SRIO_RAB_INTR_ENAB_WDMA_DONE, DISABLE) |
                                          CSL_FMKT(SRIO_RAB_INTR_ENAB_WDMA_CANCEL, DISABLE) |
                                          CSL_FMKT(SRIO_RAB_INTR_ENAB_WDMA_DBERR, DISABLE);

    hSrio->Rab0Regs->RAB_INTR_ENAB_GNRL = CSL_FMKT(SRIO_RAB_INTR_ENAB_GNRL_MISC, ENABLE) |
                                          CSL_FMKT(SRIO_RAB_INTR_ENAB_GNRL_WDMA, ENABLE);
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioWdmaDbSetup, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioWdmaDbSetup, ".text:csl_section:srio")
CSL_Status CSL_srioWdmaDbSetup(
    CSL_SrioHandle hSrio,
    Uint16 Info,
    Uint16 targetDevID,
    Uint8 dbChannel
){
    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }
    hSrio->Rab0Regs->ObDb[dbChannel].RAB_OB_DB_INFO = CSL_FMK(SRIO_RAB_OB_DB_INFO, Info);
    hSrio->Rab0Regs->ObDb[dbChannel].RAB_OB_DB_CSR = CSL_FMKT(SRIO_RAB_OB_DB_CSR_SEND, DISABLE) |
                                                     CSL_FMK(SRIO_RAB_OB_DB_CSR_PRI, 1) |
                                                     CSL_FMK(SRIO_RAB_OB_DB_CSR_CRF, 0) |
                                                     CSL_FMKT(SRIO_RAB_OB_DB_CSR_AUTOSEND, ENABLE) |
                                                     CSL_FMK(SRIO_RAB_OB_DB_CSR_WDMANUM, 0) |
                                                     CSL_FMK(SRIO_RAB_OB_DB_CSR_DSTID, targetDevID);
    return CSL_SOK;
}

//#pragma CODE_SECTION (CSL_srioWdma, ".text:csl_section:srio");
CSL_SET_CSECT(CSL_srioWdma, ".text:csl_section:srio")
CSL_Status CSL_srioWdma(
    CSL_SrioHandle hSrio,
    CSL_SrioWDMASetup *wdmaSetup
){
    int usingRegDesc;

    if(hSrio == NULL){
        return CSL_ESYS_BADHANDLE;
    }

    usingRegDesc = (wdmaSetup->extraDesc == 0) ? 1 : 0;
    CSL_srioChangeApbPage(hSrio, CSL_SRIO_APB_RAB1);
    hSrio->Rab1Regs->RAB_WDMA_CTRL = CSL_FMK(SRIO_RAB_DMA_CTRL_DSTID, wdmaSetup->dstID) |
                                     CSL_FMK(SRIO_RAB_DMA_CTRL_PRI, wdmaSetup->pri) |
                                     CSL_FMK(SRIO_RAB_DMA_CTRL_CRF, wdmaSetup->CRF) |
                                     CSL_FMK(SRIO_RAB_DMA_CTRL_LOCDESCVLD, usingRegDesc) |
                                     CSL_FMK(SRIO_RAB_DMA_CTRL_ENDB, wdmaSetup->dbEnable) |
                                     CSL_FMKT(SRIO_RAB_DMA_CTRL_START, DISABLE);
    
    hSrio->Rab1Regs->RAB_WDMA_ADDR = wdmaSetup->extraDesc;
    hSrio->Rab1Regs->RAB_WDMA_ADDR_EXT = 0x00000000;

    hSrio->Rab1Regs->RAB_DMA_IADDR_DESC_SEL = CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_SEL_WR, WRITE) |
                                              CSL_FMK(SRIO_RAB_DMA_IADDR_DESC_SEL_DMANUM, 0) |
                                              CSL_FMK(SRIO_RAB_DMA_IADDR_DESC_SEL_DESCNUM, 0);
    hSrio->Rab1Regs->RAB_DMA_IADDR_DESC_CTRL = CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_DESCVLD, ENABLE) |
                                               CSL_FMKT(SRIO_RAB_DMA_IADDR_DESC_CTRL_NXTDESCVLD, ENABLE) |
                                               CSL_FMK(SRIO_RAB_DMA_IADDR_DESC_CTRL_SIZE, (wdmaSetup->dataLen >> 2));
    hSrio->Rab1Regs->RAB_DMA_IADDR_DESC_SRC_ADDR = wdmaSetup->srcAddr >> 2;
    hSrio->Rab1Regs->RAB_DMA_IADDR_DESC_DEST_ADDR = wdmaSetup->dstAddr >> 2;
    hSrio->Rab1Regs->RAB_DMA_IADDR_DESC_NEXT_ADDR = 0x00000000;

    hSrio->Rab1Regs->RAB_WDMA_CTRL = CSL_FMK(SRIO_RAB_DMA_CTRL_DSTID, wdmaSetup->dstID) |
                                     CSL_FMK(SRIO_RAB_DMA_CTRL_PRI, wdmaSetup->pri) |
                                     CSL_FMK(SRIO_RAB_DMA_CTRL_CRF, wdmaSetup->CRF) |
                                     CSL_FMK(SRIO_RAB_DMA_CTRL_LOCDESCVLD, usingRegDesc) |
                                     CSL_FMK(SRIO_RAB_DMA_CTRL_ENDB, wdmaSetup->dbEnable) |
                                     CSL_FMKT(SRIO_RAB_DMA_CTRL_START, ENABLE);
    return CSL_SOK;
}
