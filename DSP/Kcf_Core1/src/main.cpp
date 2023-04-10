/**
 * @file main.cpp
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-12-26
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#include "main.h"

extern "C" {
	Void FFTDoneCbck(UInt16 procId, UInt16 lineId, UInt32 eventId, UArg arg, UInt32 payload);
}

int main()
{
	Int status;

    // Ipc initialization
	status = Ipc_start();
	if(status < 0){
		System_abort("Ipc start failed\n");
	}

	// Notify initialization
	status = Notify_registerEventSingle(MultiProc_getId("CORE3"), NOTIFY_LINEID, FFT_DONE_EVTID, FFTDoneCbck, NULL);
	if(status < 0){
		System_abort("Notify register failed\n");
	}

	// register heap
    MessageQ_registerHeap(SharedRegion_getHeap(0), MSGQ_SR0_HEAPID);

	BIOS_start();
}

Void FFTDoneCbck(UInt16 procId, UInt16 lineId, UInt32 eventId, UArg arg, UInt32 payload)
{
	Semaphore_post(hFFTDoneSem);
}
