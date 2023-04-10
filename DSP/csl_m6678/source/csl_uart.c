/*
 * csl_uart.c
 *
 *  Created on: 2021��10��11��
 *      Author: jayden
 */

#include <csl_uart.h>
#include <csl_utils.h>

//#pragma CODE_SECTION (CSL_uartSetBaudRate, ".text:csl_section:uart");
CSL_SET_CSECT(CSL_uartSetBaudRate, ".text:csl_section:uart")
CSL_Status CSL_uartSetBaudRate(Uint32 sysclk, Uint32 baudrate)
{
	if(baudrate == 0)
		return CSL_FAIL;

	Uint32 scaler;
	scaler = ((sysclk>>5) - (baudrate>>1))/baudrate;//scaler = (uartclk*10/baudrate*8-5)/10
	CSL_FINS(hUart->SCALE, UART_SCALE_VALUE, scaler);
	return CSL_PASS;
}

//#pragma CODE_SECTION (CSL_uartSetup, ".text:csl_section:uart");
CSL_SET_CSECT(CSL_uartSetup, ".text:csl_section:uart")
CSL_Status CSL_uartSetup(const CSL_uartConfig *hwSetup)
{
	if(hwSetup == NULL)
		return CSL_FAIL;
	Uint32 value;

	value = CSL_FMK(UART_CTRL_DI, hwSetup->DelayIntEn) |
			CSL_FMK(UART_CTRL_RF, hwSetup->ReceiFifoIntEn) |
			CSL_FMK(UART_CTRL_TF, hwSetup->TransFifoIntEn) |
			CSL_FMK(UART_CTRL_LB, hwSetup->LoopBackEn) |
			CSL_FMK(UART_CTRL_PE, hwSetup->ParityEn) |
			CSL_FMK(UART_CTRL_PS, hwSetup->ParityMode) |
			CSL_FMK(UART_CTRL_TI, hwSetup->TransIntEn) |
			CSL_FMK(UART_CTRL_RI, hwSetup->ReceiIntEn) |
			CSL_FMK(UART_CTRL_TE, hwSetup->TransEn) |
			CSL_FMK(UART_CTRL_RE, hwSetup->ReceiEn);
	hUart->CTRL = value;
	return CSL_PASS;
}
