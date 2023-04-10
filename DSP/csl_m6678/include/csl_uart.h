/*
 * csl_uart.h
 *
 *  Created on: 2021Äê10ÔÂ11ÈÕ
 *      Author: jayden
 */

#ifndef INC_CSL_CSL_UART_H_
#define INC_CSL_CSL_UART_H_

#include <soc.h>
#include <csl.h>
#include <cslr_uart.h>

#define hUart ((CSL_UartRegsOvly)CSL_UART_REGS)

//uartclk = sysclk/4/8
#define UART_CLK_DIV8 (31250000)

/* DATA */

static inline Uint32 CSL_uartReadData()
{
	return CSL_FEXT(hUart->DATA, UART_DATA_WORD);
}

static inline void CSL_uartSetData(Uint32 data)
{
	CSL_FINS(hUart->DATA, UART_DATA_WORD, data);
}

/* STAT */
static inline Uint8 CSL_uartGetReceiFifoCount()
{
	return CSL_FEXT(hUart->STAT, UART_STAT_RCNT);
}

static inline Uint8 CSL_uartGetTransFifoCount()
{
	return CSL_FEXT(hUart->STAT, UART_STAT_TCNT);
}

static inline Bool CSL_uartIsReceiFifoFull()
{
	return (Bool)CSL_FEXT(hUart->STAT, UART_STAT_RF);
}

static inline Bool CSL_uartIsTransFifoFull()
{
	return (Bool)CSL_FEXT(hUart->STAT, UART_STAT_TF);
}

static inline Bool CSL_uartIsReceiFifoHalfFull()
{
	return (Bool)CSL_FEXT(hUart->STAT, UART_STAT_RH);
}

static inline Bool CSL_uartIsTransFifoHalfFull()
{
	return (Bool)CSL_FEXT(hUart->STAT, UART_STAT_TH);
}

static inline Bool CSL_uartIsTransFifoEmpty()
{
	return (Bool)CSL_FEXT(hUart->STAT, UART_STAT_TE);
}

static inline Bool CSL_uartIsShiftRegisterEmpty()
{
	return (Bool)CSL_FEXT(hUart->STAT, UART_STAT_TS);
}

static inline Bool CSL_uartIsDataReady()
{
	return (Bool)CSL_FEXT(hUart->STAT, UART_STAT_DR);
}

/* --------------------------------------------- */
typedef enum{
	CSL_UART_PARITY_ODD = 0,
	CSL_UART_PARITY_EVEN
}CSL_uartParityMode;

typedef struct {
	Uint8 TransEn;
	Uint8 ReceiEn;
	CSL_uartParityMode ParityMode;
	Uint8 ParityEn;
	Uint8 LoopBackEn;
	Uint8 TransIntEn;
	Uint8 ReceiIntEn;
	Uint8 TransFifoIntEn;
	Uint8 ReceiFifoIntEn;
	Uint8 DelayIntEn;
}CSL_uartConfig;

/*
 * CSL_UART_HWSETUP_DEFAULTS
 * enable Trans and Recei
 * enable Trans and Recei Interrupt
 * disable Fifo Interrupt
 * disable parity, parity odd mode
 * no loop back mode
 * no delay interrupt
 */
#define CSL_UART_HWSETUP_DEFAULTS { \
	    CSL_UART_CTRL_TE_RESETVAL, \
		CSL_UART_CTRL_RE_RESETVAL, \
	    (CSL_uartParityMode)CSL_UART_CTRL_PS_RESETVAL, \
		CSL_UART_CTRL_PE_RESETVAL, \
		CSL_UART_CTRL_LB_RESETVAL, \
		CSL_UART_CTRL_TI_RESETVAL, \
		CSL_UART_CTRL_RI_RESETVAL, \
		CSL_UART_CTRL_TF_RESETVAL, \
		CSL_UART_CTRL_RF_RESETVAL, \
		CSL_UART_CTRL_DI_RESETVAL  \
	}

CSL_Status CSL_uartSetBaudRate(Uint32 sysclk, Uint32 baudrate);
CSL_Status CSL_uartSetup(const CSL_uartConfig *hwSetup);

#endif /* INC_CSL_CSL_UART_H_ */
