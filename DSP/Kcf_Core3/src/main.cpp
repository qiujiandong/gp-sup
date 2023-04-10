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

int main()
{
	Int status;

	// IPC initialization
	status = Ipc_start();
	if(status < 0){
		System_abort("Ipc start failed\n");
	}

	// register heap
	MessageQ_registerHeap(SharedRegion_getHeap(0), MSGQ_SR0_HEAPID);

    BIOS_start();
}
