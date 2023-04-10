/**
 * @file KcfTask.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-12-26
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#include "main.h"

#if TOTAL_TIME || PARTIAL_TIME
#include <c6x.h>
#endif

#include "CKcfTracker.h"

extern "C" {
    Void KcfTskFxn(UArg a0, UArg a1);
}

Void TspsDoneHandler(UArg a0);

Void KcfTskFxn(UArg a0, UArg a1)
{
    Int status;

    MessageQ_Handle hMsgQ;
    KcfMsgHandle hRxMsg;
    MessageQ_QueueId replyQueueId;
    MessageQ_QueueId fftQueueId;

    CvMat src;
    
    Hwi_Params hwiParams;
	Hwi_Handle hSimRxDataHwi;
	Error_Block eb;

    // using default synchronizer SyncSem
	hMsgQ = MessageQ_create(MSGQ_CORE1_NAME, NULL);
	if(hMsgQ == NULL){
		System_abort("MessageQ create failed\n");
	}

    do{
		status = MessageQ_open(MSGQ_FFTCMD_NAME, &fftQueueId);
		if(status < 0){
			Task_sleep(1);
		}
	} while (status < 0);

    // Matrix transpose
    CTspsManager tspsMgr(1); // CORE1
    tspsMgr.HwInit();
    
    // create tracker
    CKcfTracker tracker(&tspsMgr, MSGQ_SR0_HEAPID, MultiProc_getId("CORE1"), fftQueueId);

    Error_init(&eb);
	Hwi_Params_init(&hwiParams);

	hwiParams.arg = (UArg)(&tspsMgr);
	hwiParams.eventId = CORE1_INTC_TSPS_INTCEVT;
	hSimRxDataHwi = Hwi_create(CORE1_INTC_TSPS_INT, TspsDoneHandler, &hwiParams, &eb);
	if(hSimRxDataHwi == NULL){
		System_abort("Hwi create failed\n");
	}

    tracker.createHanningMats();
    tracker.createGaussianPeak();

#if TOTAL_TIME || PARTIAL_TIME
    TSCL = 0;
#endif

    // wait for message to conduct procedure
    for (;;){
        MessageQ_get(hMsgQ, (MessageQ_Msg *)&hRxMsg, MessageQ_FOREVER);
#if DEBUG
        System_printf("Data Address: %p\n", hRxMsg->pAddr);
#endif

        Cache_inv(hRxMsg->pAddr, FRAME_SIZE, Cache_Type_ALLD, TRUE);
        cvInitMatHeader(&src, SRC_HEIGHT, SRC_WIDTH, CV_8UC1, hRxMsg->pAddr);
        
        if(hRxMsg->bInit){
            //init
            tracker.init(hRxMsg->roi, src);
        }
        else{
            // update
            hRxMsg->roi =  tracker.update(src);
        }

        // TODO modify reply message status
        
        // result reply
        replyQueueId = MessageQ_getReplyQueue(hRxMsg);
        if(replyQueueId == MessageQ_INVALIDMESSAGEQ){
            System_abort("Invalid reply queue\n");
        }
        status = MessageQ_put(replyQueueId, (MessageQ_Msg)hRxMsg);
        if(status < 0){
            System_abort("MessageQ put failed\n");
        }
    }
}

Void TspsDoneHandler(UArg a0)
{
	((CTspsManager *)a0)->ClearInterruptFlag();
	Semaphore_post(hTspsDoneSem);
}
