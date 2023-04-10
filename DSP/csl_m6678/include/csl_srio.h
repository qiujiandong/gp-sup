/*
 * csl_srio.h
 *
 *  Created on: 2021��10��13��
 *      Author: jayden
 */

#ifndef INC_CSL_CSL_SRIO_H_
#define INC_CSL_CSL_SRIO_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <soc.h>
#include <csl.h>
#include <cslr_srio.h>

typedef struct{
    volatile Uint32 ctrl;
    Uint32 srcAddr;
    Uint32 dstAddr;
    Uint32 nextDesc;
} SrioWdmaDesc;

typedef enum
{
    CSL_SRIO_APB_RSTD,
    CSL_SRIO_APB_GRIO0,
    CSL_SRIO_APB_GRIO1,
    CSL_SRIO_APB_RAB0,
    CSL_SRIO_APB_RAB1
} CSL_SrioApbWindow;

typedef struct{
    CSL_SrioApbWindow currentWindow;
    CSL_SrioPbusRegsOvly PbusRegs;
    CSL_SrioPhyRegsOvly PhyRegs;
    CSL_SrioApbRstdRegsOvly RstdRegs;
    CSL_SrioApbGrio0RegsOvly Grio0Regs;
    CSL_SrioApbGrio1RegsOvly Grio1Regs;
    CSL_SrioApbRab0RegsOvly Rab0Regs;
    CSL_SrioApbRab1RegsOvly Rab1Regs;
} CSL_SrioObj;
typedef CSL_SrioObj *CSL_SrioHandle;

typedef enum
{
    CSL_SRIO_RATE_1G25,
    CSL_SRIO_RATE_2G5,
    CSL_SRIO_RATE_3G125,
    CSL_SRIO_RATE_RSVD
} CSL_SrioRateMode;

typedef enum
{
    CSL_SRIO_LANE_4X,
    CSL_SRIO_LANE_2XLANE01,
    CSL_SRIO_LANE_2XLANE23,
    CSL_SRIO_LANE_1XLANE0,
    CSL_SRIO_LANE_1XLANE1,
    CSL_SRIO_LANE_1XLANE2,
    CSL_SRIO_LANE_1XLANE3
} CSL_SrioLaneMode;

typedef enum
{
    CSL_SRIO_TTYPE_MAINTRW,
    CSL_SRIO_TTYPE_NRNW,
    CSL_SRIO_TTYPE_NRNWR,
    CSL_SRIO_TTYPE_NRSW
} CSL_SrioTtype;

typedef enum
{
    CSL_SRIO_PRI_0,
    CSL_SRIO_PRI_1,
    CSL_SRIO_PRI_2
} CSL_SrioPri;

typedef struct 
{
    unsigned long long RioBaseAddr;
    Uint32 windSize;
    Uint32 AxiBaseAddr;
    Uint16 dstID;
    Uint8 windNum;
    Uint8 CRF;
    Uint8 hopCnt;
    CSL_SrioTtype tType;
    CSL_SrioPri pri;
} CSL_SrioAPIOWindSetup;

typedef struct
{
    Bool intFlag;
    Uint32 wdmaStatus;
    Uint32 rdmaStatus;
    Uint32 dbInfo;
} CSL_SrioIntStatus;

typedef enum
{
    CSL_SRIO_IDLEN_8,
    CSL_SRIO_IDLEN_16
} CSL_SrioIDLen;

typedef struct 
{
    Uint8 checkInfoNum;
    Uint16 *pInfoList;
} CSL_SrioChkList;

typedef struct 
{
    Uint32 dstAddr;
    Uint32 srcAddr;
    Uint32 dataLen;
    Uint32 dstID;
    Uint32 extraDesc;
    CSL_SrioPri pri;
    Uint8 CRF;
    Uint8 dbChannel;
    Bool dbEnable;
} CSL_SrioWDMASetup;

CSL_SrioHandle CSL_srioInit(CSL_SrioObj *srioObj, int instNum);
CSL_Status CSL_srioPhyInit(
    CSL_SrioHandle hSrio,
    CSL_SrioRateMode rateMode,
    CSL_SrioLaneMode laneMode);
CSL_Status CSL_srioChangeApbPage(
    CSL_SrioHandle hSrio,
    CSL_SrioApbWindow apbWind);
CSL_Status CSL_srioRPIOMap(
    CSL_SrioHandle hSrio);
CSL_Status CSL_srioAPIOMap(
    CSL_SrioHandle hSrio,
    CSL_SrioAPIOWindSetup *windSetup);
CSL_Status CSL_srioConfig(
    CSL_SrioHandle hSrio,
    CSL_SrioIDLen idLen,
    Uint16 ID);
CSL_Status CSL_srioReceiveDBSetup(
    CSL_SrioHandle hSrio,
    CSL_SrioChkList *chkList);
CSL_Status CSL_srioSendDB(
    CSL_SrioHandle hSrio,
    Uint16 Info,
    Uint16 targetDevID,
    Uint8 dbChannel);
CSL_Status CSL_srioIntConfig(
    CSL_SrioHandle hSrio);
CSL_Status CSL_srioWdmaDbSetup(
    CSL_SrioHandle hSrio,
    Uint16 Info,
    Uint16 targetDevID,
    Uint8 dbChannel);
CSL_Status CSL_srioWdma(
    CSL_SrioHandle hSrio,
    CSL_SrioWDMASetup *wdmaSetup);

// NOTE: change to RAB1 page before call this function
static inline Uint32 getWdmaStatus(CSL_SrioHandle hSrio){
    return hSrio->Rab1Regs->RAB_WDMA_STAT;
}

// NOTE: change to RAB1 page before call this function
static inline void clearWdmaStatus(CSL_SrioHandle hSrio, Uint32 clearMask){
    hSrio->Rab1Regs->RAB_WDMA_STAT = clearMask;
}

#ifdef __cplusplus
}
#endif

#endif /* INC_CSL_CSL_SRIO_H_ */
