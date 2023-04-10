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

#include <stdint.h>

typedef struct
{
    volatile uint32_t IDENTIFY;
    volatile uint32_t SRIO_CSR;
    volatile uint32_t SRIO_MODE;
    volatile uint32_t SW_SIZE;
    volatile uint32_t SW_DST;
    volatile uint32_t SW_SRC;
    volatile uint32_t DB_TXINFO;
    volatile uint32_t MSI_CSR;
    volatile uint32_t MSI_INFO[16];
} Srio2PcieRegs;

typedef Srio2PcieRegs *Srio2PcieHandle;

static inline int startDbTxFromFPGA(Srio2PcieHandle hSrio2Pcie, uint16_t info){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->DB_TXINFO;
    hSrio2Pcie->DB_TXINFO = (nTemp & 0xFFFF0000u) | info;

    // check db not busy
    nTemp = hSrio2Pcie->SRIO_CSR;
    if(nTemp & 0x1){
        return -1;
    }
    hSrio2Pcie->SRIO_CSR = (nTemp & 0xFFFFFFFE) | 0x1;
    return 0;
}

static inline int startSwTxFromPC(
    Srio2PcieHandle hSrio2Pcie, 
    uint32_t nSizeDW,
    uint32_t nDstAddr,
    uint16_t info
){
    uint32_t nTemp;
    if(nSizeDW > 0x8000000 || (nDstAddr & 0xFF)){
        return -1;
    }
    // check sw not busy
    nTemp = hSrio2Pcie->SRIO_CSR;
    if((nTemp & 0x2) >> 1){
        return -2;
    }

    hSrio2Pcie->SW_SIZE = nSizeDW - 1;
    hSrio2Pcie->SW_DST = nDstAddr;

    nTemp = hSrio2Pcie->DB_TXINFO;
    hSrio2Pcie->DB_TXINFO = (nTemp & 0x0000FFFFu) | (info << 16);

    nTemp = hSrio2Pcie->SRIO_MODE;
    hSrio2Pcie->SRIO_MODE = nTemp & 0xFFFFFFFDu;

    nTemp = hSrio2Pcie->SRIO_CSR;
    hSrio2Pcie->SRIO_CSR = (nTemp & 0xFFFFFFFDu) | 0x2;
    return 0;
}

static inline int startSwTxFromFPGA(
    Srio2PcieHandle hSrio2Pcie,
    uint32_t nSizeDW,
    uint32_t nDstAddr,
    uint32_t nSrcAddr,
    uint16_t info
){
    uint32_t nTemp;
    if(nSizeDW > 0x8000000 || (nDstAddr & 0xFF) || (nSrcAddr & 0xFF)){
        return -1;
    }
    // check sw not busy
    nTemp = hSrio2Pcie->SRIO_CSR;
    if((nTemp & 0x2) >> 1){
        return -2;
    }
    
    hSrio2Pcie->SW_SIZE = nSizeDW - 1;
    hSrio2Pcie->SW_DST = nDstAddr;
    hSrio2Pcie->SW_SRC = nSrcAddr;
    nTemp = hSrio2Pcie->DB_TXINFO;
    hSrio2Pcie->DB_TXINFO = (nTemp & 0x0000FFFFu) | (info << 16);

    nTemp = hSrio2Pcie->SRIO_MODE;
    hSrio2Pcie->SRIO_MODE = (nTemp & 0xFFFFFFFDu) | 0x2;
    
    nTemp = hSrio2Pcie->SRIO_CSR;
    hSrio2Pcie->SRIO_CSR = (nTemp & 0xFFFFFFFDu) | 0x2;
    return 0;
}

static inline void setupNwTxToPC(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->SRIO_MODE;
    hSrio2Pcie->SRIO_MODE = nTemp & 0xFFFFFFFEu;
}

static inline void setupNwTxToFPGA(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->SRIO_MODE;
    hSrio2Pcie->SRIO_MODE = (nTemp & 0xFFFFFFFEu) | 0x1;
}

static inline bool isNwCross4kBoundary(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->SRIO_CSR;
    return (bool)((nTemp & 0x00040000) >> 18);
}

static inline bool isNwUnalign(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->SRIO_CSR;
    return (bool)((nTemp & 0x00080000) >> 19);
}

static inline bool isSwDstUnalign(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->SRIO_CSR;
    return (bool)((nTemp & 0x00100000) >> 20);
}

static inline bool isSwSrcUnalign(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->SRIO_CSR;
    return (bool)((nTemp & 0x00200000) >> 21);
}

static inline void enableDB2MSI(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->SRIO_MODE;
    hSrio2Pcie->SRIO_MODE = nTemp & 0xFFFFFFFEu;
}

static inline void disableDB2MSI(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->SRIO_MODE;
    hSrio2Pcie->SRIO_MODE = (nTemp & 0xFFFFFFFEu) | 0x1;
}

static inline int startMsiTxToPC(
    Srio2PcieHandle hSrio2Pcie, 
    uint32_t nInd,
    uint32_t info
){
    uint32_t nTemp;
    if(nInd < 2 || nInd > 15){
        return -1;
    }
    hSrio2Pcie->MSI_INFO[nInd] = info;

    // check is MSI busy?
    nTemp = hSrio2Pcie->MSI_CSR;
    if((nTemp & (1 << nInd)) >> nInd ){
        return -2;
    }
    hSrio2Pcie->MSI_CSR = (nTemp & ~(1 << nInd)) | (1 << nInd);
    return 0;
}

static inline uint32_t readMsiInfo(
    Srio2PcieHandle hSrio2Pcie, 
    uint32_t nInd
){
    if(nInd < 2 || nInd > 15){
        return 0xFFFFFFFF;
    }
    return hSrio2Pcie->MSI_INFO[nInd];
}

static inline bool isDb2MsiBusy(Srio2PcieHandle hSrio2Pcie){
    uint32_t nTemp;
    nTemp = hSrio2Pcie->MSI_CSR;
    return (bool)(nTemp & 0x1);
}

#ifdef __cplusplus
}
#endif

#endif
