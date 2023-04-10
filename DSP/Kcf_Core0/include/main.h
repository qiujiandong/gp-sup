/**
 * @file main.h
 * @author Jiandong Qiu (1335521934@qq.com)
 * @brief 
 * @version 0.1
 * @date 2022-12-25
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#ifndef _MAIN_H_
#define _MAIN_H_

#include "common.h"

// #include <ti/sysbios/family/c66/Cache.h> 
#include <xdc/runtime/System.h>
#include <xdc/runtime/Memory.h>
#include <xdc/runtime/Error.h> 
#include <xdc/cfg/global.h>
#include <ti/sysbios/family/c64p/Hwi.h> 
#include <ti/sysbios/family/c66/Cache.h>

#include <ti/ipc/Ipc.h>
#include <ti/ipc/Notify.h>
#include <ti/ipc/MultiProc.h>
#include <ti/ipc/GateMP.h>
#include <ti/ipc/SharedRegion.h>

// 1 for Self test, 0 for system test
#define SELF_TEST (1)

// 1 for master mode, 0 for slave mode, only used in self test
#define MODE_MASTER (1)

#define TIME_TEST (1)

#define SHOW_RESULT (1)

#define C1START_EVTID Event_Id_00
#define C2START_EVTID Event_Id_01

#define C1DONE_EVTID Event_Id_00
#define C2DONE_EVTID Event_Id_01

#endif
