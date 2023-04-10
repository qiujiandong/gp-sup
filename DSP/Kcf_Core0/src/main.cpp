/**
 * @file main.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-12-25
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#include "main.h"

#include <stdio.h>
#include <csl_psc.h>
#include "CRxBufManager.h"

#if TIME_TEST
#include <c6x.h>
#endif

extern "C" {
	Void MainTskFxn(UArg a0, UArg a1);
	Void C1KcfTskFxn(UArg a0, UArg a1);
	Void C2KcfTskFxn(UArg a0, UArg a1);
}

Void SimRxDataHandler(UArg a0);

#pragma DATA_SECTION(".images")
uint8_t img[FRAME_NUM*FRAME_SIZE];

int main()
{
	Int status;

	// init
	CSL_pscModuleEnable(PSC_MD_MSMC, PSC_PWR_PERI);
	CSL_pscModuleEnable(PSC_MD_FFT, PSC_PWR_PERI);
	CSL_pscModuleEnable(PSC_MD_DMA0, PSC_PWR_PERI);
    CSL_pscModuleEnable(PSC_MD_DMA1, PSC_PWR_PERI);

	// IPC initialization
	status = Ipc_start();
	if(status < 0){
		System_abort("Ipc start failed\n");
	}

	// register heap
	MessageQ_registerHeap(SharedRegion_getHeap(0), MSGQ_SR0_HEAPID);

	// System test, get data from SRIO
#if !SELF_TEST
	// TODO SRIO HW init
#endif

    BIOS_start();
}

/**
 * @brief Manage receiving data, control the program pace
 * 
 * @param a0 
 * @param a1 
 * @return Void 
 */
Void MainTskFxn(UArg a0, UArg a1)
{
	Hwi_Params hwiParams;
	Hwi_Handle hSimRxDataHwi;
	Error_Block eb;

	Task_Params taskParams;
	Task_Handle hC1KcfTsk;
	Task_Handle hC2KcfTsk;

#if TIME_TEST
	UInt64 startRxTimes[FRAME_NUM - 1];
	TSCL = 0;
#endif

	// allocate Rx buffer
	CRxBufManager rxBufMgr(FRAME_SIZE, SharedRegion_getHeap(1));
	Uint8 *pSrcData = img;
	
#if SELF_TEST & MODE_MASTER
	// the index of the frame which is receiving or have received. 
	int nFrameCnt = 0;
#endif

	rxBufMgr.HwInit();

	Error_init(&eb);
	Hwi_Params_init(&hwiParams);

	hwiParams.arg = (UArg)(&rxBufMgr);
	hwiParams.eventId = CORE0_INTC_DATACARRY_INTCEVT;
	hSimRxDataHwi = Hwi_create(CORE0_INTC_DATACARRY_INT, SimRxDataHandler, &hwiParams, &eb);
	if(hSimRxDataHwi == NULL){
		System_abort("Hwi create failed\n");
	}

	Task_Params_init(&taskParams);
	taskParams.stackSize = 2048;
	taskParams.arg0 = (UArg)(&rxBufMgr);
	taskParams.priority = 3;
	hC1KcfTsk = Task_create((Task_FuncPtr)C1KcfTskFxn, &taskParams, &eb);
	if(hC1KcfTsk == NULL){
		System_abort("Task create failed\n");
	}

	taskParams.priority = 2;
	hC2KcfTsk = Task_create((Task_FuncPtr)C2KcfTskFxn, &taskParams, &eb);
	if(hC2KcfTsk == NULL){
		System_abort("Task create failed\n");
	}

	// prepare the first frame, start carry data!
	rxBufMgr.SimStartRxData(pSrcData);
	// Semaphore_post(hDataReadySem);

#if !SELF_TEST
	// TODO waiting for PC command to start KCF, determin master mode or slave mode, if master mode, request data
#endif

	for (;;){

#if DEBUG
		System_printf("Frame %d had Rx\n", nFrameCnt);
#endif

#if SELF_TEST

#if MODE_MASTER
		// wait for KCF task all start
		Event_pend(hKcfHasStartEvt, C1START_EVTID + C2START_EVTID, Event_Id_NONE, BIOS_WAIT_FOREVER);
#if TIME_TEST
		// record time
		startRxTimes[nFrameCnt] = _itoll(TSCH, TSCL);
#endif
		++nFrameCnt;
		rxBufMgr.SimStartRxData(pSrcData + FRAME_SIZE * nFrameCnt);

#endif
// in slave mode, a timer is assigned to carry data automatically.

// system test
#else
		// TODO If master mode, request data first
#endif

#if SELF_TEST & MODE_MASTER
		// the frame FRAME_NUM - 1 is receiving
		if(nFrameCnt == FRAME_NUM - 1){
			break;
		}
#endif
	}

	Event_pend(hAllDoneEvt, C1DONE_EVTID + C2DONE_EVTID, Event_Id_NONE, BIOS_WAIT_FOREVER);

#if DEBUG
			System_printf("All Done!\n");
#endif

#if TIME_TEST
	for (int i = 0; i < FRAME_NUM - 1; ++i){
		// System_printf("Frame %d, Start Rx data Time: %f\n", i + 1, startRxTimes[i] * 1.0);
		printf("Frame %d, Start Rx data Time: %llu\n", i + 1, startRxTimes[i]);
	}
	System_printf("Average interval: %f ms\n", (startRxTimes[FRAME_NUM - 2] - startRxTimes[1]) * 1.0 / (FRAME_NUM - 3) / 1000000);
#endif
}

/**
 * @brief Data for simulation receiving handler
 * 
 * @param a0 
 * @return Void 
 */
Void SimRxDataHandler(UArg a0)
{
	((CRxBufManager *)a0)->flipIndex();
	((CRxBufManager *)a0)->ClearInterruptFlag();
	Semaphore_post(hC1DataReadySem);
	Semaphore_post(hC2DataReadySem);
}

/**
 * @brief Core1 Kcf manager
 * 
 * @param a0 
 * @param a1 
 * @return Void 
 */
Void C1KcfTskFxn(UArg a0, UArg a1)
{
	KcfMsgHandle hCore1Msg;

	MessageQ_Handle hMsgQC0C1;
	MessageQ_QueueId core1QueueId;

	Int status;
	Int nCnt = 0;

#if SHOW_RESULT
	CvRect c1Results[FRAME_NUM];
#endif

	// using default SyncSem
	hMsgQC0C1 = MessageQ_create(MSGQ_C0C1_NAME, NULL);
	if(hMsgQC0C1 == NULL){
		System_abort("MessageQ create failed\n");
	}

	do{
		status = MessageQ_open(MSGQ_CORE1_NAME, &core1QueueId);
		if(status < 0){
			Task_sleep(1);
		}
	} while (status < 0);

	// init message
	hCore1Msg = (KcfMsgHandle)MessageQ_alloc(MSGQ_SR0_HEAPID, sizeof(KcfMsg));
	if(hCore1Msg == NULL){
		System_abort("MessageQ_alloc failed\n");
	}
	MessageQ_setMsgId(hCore1Msg, MSG_C0C1_ID);
	MessageQ_setReplyQueue(hMsgQC0C1, (MessageQ_Msg)hCore1Msg);

	for (;;){
		Semaphore_pend(hC1DataReadySem, BIOS_WAIT_FOREVER);

		++nCnt;

		hCore1Msg->pAddr = ((CRxBufManager *)a0)->getOpBuf();
		hCore1Msg->bInit = false;
		hCore1Msg->status = 0;
		if(nCnt == 1){
			hCore1Msg->roi = cvRect(352, 253, 20, 20);
			hCore1Msg->bInit = true;
		}

		status = MessageQ_put(core1QueueId, (MessageQ_Msg)hCore1Msg);
		if(status < 0){
			System_abort("MessageQ put failed\n");
		}

		Event_post(hKcfHasStartEvt, C1START_EVTID);

		MessageQ_get(hMsgQC0C1, (MessageQ_Msg *)&hCore1Msg, MessageQ_FOREVER);
	
#if SHOW_RESULT
		c1Results[nCnt - 1] = hCore1Msg->roi;
#endif

		// TODO analysis return status
		// tracking error
		// if(hCore1Msg->status < 0){
		// 	break;
		// }

		// the frame FRAME_NUM - 1 has done
		if(nCnt == FRAME_NUM){
			break;
		}
	}

#if SHOW_RESULT
	for (int i = 0; i < FRAME_NUM; ++i){
		System_printf("Core1 frame: %d, x: %d, y: %d, width: %d. height: %d\n", i, c1Results[i].x, c1Results[i].y, c1Results[i].width, c1Results[i].height);
	}
#endif

	Event_post(hAllDoneEvt, C1DONE_EVTID);
}

/**
 * @brief Core2 Kcf manager
 * 
 * @param a0 
 * @param a1 
 * @return Void 
 */
Void C2KcfTskFxn(UArg a0, UArg a1)
{
	KcfMsgHandle hCore2Msg;

	MessageQ_Handle hMsgQC0C2;
	MessageQ_QueueId core2QueueId;

	Int status;
	Int nCnt = 0;

#if SHOW_RESULT
	CvRect c2Results[FRAME_NUM];
#endif
	// using default SyncSem
	hMsgQC0C2 = MessageQ_create(MSGQ_C0C2_NAME, NULL);
	if(hMsgQC0C2 == NULL){
		System_abort("MessageQ create failed\n");
	}

	do{
		status = MessageQ_open(MSGQ_CORE2_NAME, &core2QueueId);
		if(status < 0){
			Task_sleep(1);
		}
	} while (status < 0);

	hCore2Msg = (KcfMsgHandle)MessageQ_alloc(MSGQ_SR0_HEAPID, sizeof(KcfMsg));
	if(hCore2Msg == NULL){
		System_abort("MessageQ_alloc failed\n");
	}
	MessageQ_setMsgId(hCore2Msg, MSG_C0C2_ID);
	MessageQ_setReplyQueue(hMsgQC0C2, (MessageQ_Msg)hCore2Msg);

	for (;;){
		Semaphore_pend(hC2DataReadySem, BIOS_WAIT_FOREVER);

		++nCnt;

		hCore2Msg->pAddr = ((CRxBufManager *)a0)->getOpBuf();
		hCore2Msg->bInit = false;
		hCore2Msg->status = 0;
		if(nCnt == 1){
			hCore2Msg->roi = cvRect(352, 253, 20, 20);
			hCore2Msg->bInit = true;
		}

		status = MessageQ_put(core2QueueId, (MessageQ_Msg)hCore2Msg);
		if(status < 0){
			System_abort("MessageQ put failed\n");
		}

		Event_post(hKcfHasStartEvt, C2START_EVTID);

		MessageQ_get(hMsgQC0C2, (MessageQ_Msg *)&hCore2Msg, MessageQ_FOREVER);

#if SHOW_RESULT
		c2Results[nCnt - 1] = hCore2Msg->roi;
#endif

		// TODO analysis return status
		// tracking error
		// if(hCore2Msg->status < 0){
		// 	break;
		// }

		// the frame FRAME_NUM - 1 has done
		if(nCnt == FRAME_NUM){
			break;
		}
	}

#if SHOW_RESULT
	for (int i = 0; i < FRAME_NUM; ++i){
		System_printf("Core2 frame: %d, x: %d, y: %d, width: %d. height: %d\n", i, c2Results[i].x, c2Results[i].y, c2Results[i].width, c2Results[i].height);
	}
#endif

	Event_post(hAllDoneEvt, C2DONE_EVTID);
}
