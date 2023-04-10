/**
 * @file CSrioManager.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-10-04
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#ifndef INCLUDE_CSRIOMANAGER_H_
#define INCLUDE_CSRIOMANAGER_H_

#include <csl_srio.h>

#define SRIO_DEVICEID   (0x7801)
#define SRIO_TARGET_DEVICEID    (0xF201)

#define WDMA_DB_CHANNEL (0)

class CSrioManager
{
protected:
    CSL_SrioHandle m_hSrio;
    CSL_SrioObj m_Obj;
    Bool m_bInitDone;

public:
    Uint16 m_nDbInfo;

    CSrioManager();
    ~CSrioManager();

    int HwInit(int DevNum, Uint8 nRxDbNum, Uint16 *pDbChkList);

    int startTxData(
        void *pSrc,
        void *pDst,
        Uint32 nLen,
        Uint16 nDbInfo);

    int startTxDoorbell(Uint16 nDbInfo){
        int status;
        status = CSL_srioSendDB(m_hSrio, nDbInfo, SRIO_TARGET_DEVICEID, 0);
        if(status != CSL_SOK){
            return -1;
        }
        return 0;
    }
    /**
     * if get Doorbell, then return 1
     * else return 0
     */
    int ClearInterruptFlag();

    Uint32 readWdamStatus(){
        CSL_srioChangeApbPage(m_hSrio, CSL_SRIO_APB_RAB1);
        return getWdmaStatus(m_hSrio);
    }
};

#endif /* INCLUDE_CSRIOMANAGER_H_ */
