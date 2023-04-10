/**
 * @file Srio2PcieLLD.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-02-27
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#ifndef _SRIO2PCIE_LLD_H_
#define _SRIO2PCIE_LLD_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "Emif2Axil.h"

typedef struct
{
    volatile Uint32 IDENTIFY;
    volatile Uint32 SRIO_CSR;
    volatile Uint32 SRIO_MODE;
    volatile Uint32 SW_SIZE;
    volatile Uint32 SW_DST;
    volatile Uint32 SW_SRC;
    volatile Uint32 DB_TXINFO;
    volatile Uint32 MSI_CSR;
    volatile Uint32 MSI_INFO[16];
} Srio2PcieRegs;

typedef Srio2PcieRegs *Srio2PcieHandle;

static inline Srio2PcieHandle getSrio2PcieHandle(Uint32 offset){
    Uint32 nTemp;

    Srio2PcieHandle hSrio2Pcie = (Srio2PcieHandle)offset;
    nTemp = readReg(&(hSrio2Pcie->IDENTIFY));
    if(nTemp == 0x10370918u){
        return hSrio2Pcie;
    }
    return NULL;
}

static inline int startDbTxFromFPGA(Srio2PcieHandle hSrio2Pcie, Uint16 info){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->DB_TXINFO));
    writeReg(&(hSrio2Pcie->DB_TXINFO), (nTemp & 0xFFFF0000u) | info);

    // check db not busy
    nTemp = readReg(&(hSrio2Pcie->SRIO_CSR));
    if(nTemp & 0x1){
        return -1;
    }
    writeReg(&(hSrio2Pcie->SRIO_CSR), (nTemp & 0xFFFFFFFE) | 0x1);
    return 0;
}

static inline int startSwTxFromPC(
    Srio2PcieHandle hSrio2Pcie, 
    Uint32 nSizeDW,
    Uint32 nDstAddr,
    Uint32 info
){
    Uint32 nCsrVal;
    Uint32 nTemp;
    if(nSizeDW > 0x8000000 || (nDstAddr & 0xFF)){
        return -1;
    }
    // check sw not busy
    nCsrVal = readReg(&(hSrio2Pcie->SRIO_CSR));
    if((nCsrVal & 0x2) >> 1){
        return -2;
    }
    
    writeReg(&(hSrio2Pcie->SW_SIZE), nSizeDW - 1);
    writeReg(&(hSrio2Pcie->SW_DST), nDstAddr);
    nTemp = readReg(&(hSrio2Pcie->DB_TXINFO));
    writeReg(&(hSrio2Pcie->DB_TXINFO), (nTemp & 0x0000FFFFu) | (info << 16));

    nTemp = readReg(&(hSrio2Pcie->SRIO_MODE));
    writeReg(&(hSrio2Pcie->SRIO_MODE), nTemp & 0xFFFFFFFDu);
    
    writeReg(&(hSrio2Pcie->SRIO_CSR), (nCsrVal & 0xFFFFFFFDu) | 0x2);
    return 0;
}

static inline int startSwTxFromFPGA(
    Srio2PcieHandle hSrio2Pcie,
    Uint32 nSizeDW,
    Uint32 nDstAddr,
    Uint32 nSrcAddr,
    Uint32 info
){
    Uint32 nCsrVal;
    Uint32 nTemp;
    if(nSizeDW > 0x8000000 || (nDstAddr & 0xFF) || (nSrcAddr & 0xFF)){
        return -1;
    }
    // check sw not busy
    nCsrVal = readReg(&(hSrio2Pcie->SRIO_CSR));
    if((nCsrVal & 0x2) >> 1){
        return -2;
    }
    
    writeReg(&(hSrio2Pcie->SW_SIZE), nSizeDW - 1);
    writeReg(&(hSrio2Pcie->SW_DST), nDstAddr);
    writeReg(&(hSrio2Pcie->SW_SRC), nSrcAddr);
    nTemp = readReg(&(hSrio2Pcie->DB_TXINFO));
    writeReg(&(hSrio2Pcie->DB_TXINFO), (nTemp & 0x0000FFFFu) | (info << 16));

    nTemp = readReg(&(hSrio2Pcie->SRIO_MODE));
    writeReg(&(hSrio2Pcie->SRIO_MODE), (nTemp & 0xFFFFFFFDu) | 0x2);
    
    writeReg(&(hSrio2Pcie->SRIO_CSR), (nCsrVal & 0xFFFFFFFDu) | 0x2);
    return 0;
}

static inline void setupNwTxToPC(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->SRIO_MODE));
    writeReg(&(hSrio2Pcie->SRIO_MODE), nTemp & 0xFFFFFFFBu);
}

static inline void setupNwTxToFPGA(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->SRIO_MODE));
    writeReg(&(hSrio2Pcie->SRIO_MODE), (nTemp & 0xFFFFFFFBu) | 0x4);
}

static inline Bool isNwCross4kBoundary(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->SRIO_CSR));
    return (Bool)((nTemp & 0x00040000) >> 18);
}

static inline Bool isNwUnalign(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->SRIO_CSR));
    return (Bool)((nTemp & 0x00080000) >> 19);
}

static inline Bool isSwDstUnalign(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->SRIO_CSR));
    return (Bool)((nTemp & 0x00100000) >> 20);
}

static inline Bool isSwSrcUnalign(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->SRIO_CSR));
    return (Bool)((nTemp & 0x00200000) >> 21);
}

static inline void enableDB2MSI(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->SRIO_MODE));
    writeReg(&(hSrio2Pcie->SRIO_MODE), nTemp & 0xFFFFFFFEu);
}

static inline void disableDB2MSI(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->SRIO_MODE));
    writeReg(&(hSrio2Pcie->SRIO_MODE), (nTemp & 0xFFFFFFFEu) | 0x1);
}

static inline int startMsiTxToPC(
    Srio2PcieHandle hSrio2Pcie, 
    Uint32 nInd,
    Uint32 info
){
    Uint32 nTemp;
    if(nInd < 2 || nInd > 15){
        return -1;
    }
    writeReg(&(hSrio2Pcie->MSI_INFO[nInd]), info);

    nTemp = readReg(&(hSrio2Pcie->MSI_CSR));
    if((nTemp & (1 << nInd)) >> nInd ){
        return -2;
    }
    writeReg(&(hSrio2Pcie->MSI_CSR), (nTemp & ~(1 << nInd)) | (1 << nInd));
    return 0;
}

static inline Uint32 readMsiInfo(
    Srio2PcieHandle hSrio2Pcie, 
    Uint32 nInd
){
    if(nInd < 2 || nInd > 15){
        return 0xFFFFFFFF;
    }
    return readReg(&(hSrio2Pcie->MSI_INFO[nInd]));
}

static inline Bool isDb2MsiBusy(Srio2PcieHandle hSrio2Pcie){
    Uint32 nTemp;
    nTemp = readReg(&(hSrio2Pcie->MSI_CSR));
    return (Bool)(nTemp & 0x1);
}

#ifdef __cplusplus
}
#endif

#endif
