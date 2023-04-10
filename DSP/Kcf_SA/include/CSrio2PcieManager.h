/**
 * @file CSrio2PcieManager.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2023-02-27
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include "CSrioManager.h"
#include "Srio2PcieLLD.h"

#define SRIO_DBRX_PC_STARTREQ (0x0000)
#define SRIO_DBRX_SWFROMPC_DONE (0x1111)
#define SRIO_DBRX_SWFROMFPGA_DONE (0x2222)

#define SRIO_DBTX_PC_STARTREQ (0x0000)
#define SRIO_DBTX_PC_STARTH2C (0x1111)
#define SRIO_DBTX_PC_STARTC2H (0x2222)
#define SRIO_DBTX_PC_PROCDONE (0x3333)

class CSrio2PcieManager: public CSrioManager
{
private:
    Srio2PcieHandle m_hSrio2Pcie;
    CSrio2PcieManager();
public:
    ~CSrio2PcieManager();
    static CSrio2PcieManager *getInstance(){
        static CSrio2PcieManager Srio2PcieMgr;
        return &Srio2PcieMgr;
    }

    int Srio2PcieInit(int EclkRatio);

    int startTxDbWithMSI(Uint16 nInfo);
    int startTxDbWithoutMSI(Uint16 nInfo);

    int startTxNwToPC(void *pSrc, Uint32 nSizeDW);
    int startTxNwToFPGA(void *pSrc, Uint32 nSizeDW, Uint32 dstAddr);

    int startTxDbFromFPGA(Uint16 nInfo){
        return startDbTxFromFPGA(m_hSrio2Pcie, nInfo);
    }
    int startTxSeqInfoFromPC(void *dstAddr);
    int startTxFrameFromPC(void *dstAddr, Uint32 nSizeDW);
    int startTxSwFromFPGA(void *dstAddr, Uint32 nSizeDW, Uint32 srcAddr);
};
