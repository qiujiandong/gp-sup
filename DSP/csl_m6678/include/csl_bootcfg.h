#ifndef _CSL_BOOTCFG_H_
#define _CSL_BOOTCFG_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <soc.h>
#include <csl.h>
#include <cslr_bootcfg.h>

/**
 *  Handle to access BOOTCFG registers.
 */
#define hBootCfg     ((CSL_BootcfgRegs*)CSL_BOOT_CFG_REGS)

/*******************************************************************************
*函数名：CSL_bootcfgMainPLLCTLConfig
*功    能：主时钟配置，配置主PLL主要用来给CorePacs和部分外设部件提供时钟
*参    数：PLLM为倍频系数，PLLD、POSTDIV2和POSTDIV1为分频系数
*******************************************************************************/
// +---------------------+---------------+--------+--------+------------+-----------+
// | Desired             | (CLK) Input   |        |        |            |           |
// | Device Speed (MHz)  |  Clock (MHz)  | PLLM   | PLLD   | POSTDIV2   | POSTDIV1  |
// +---------------------+---------------+--------+--------+------------+-----------+
// | 1000                | 25(DSK)       | 40     | 1      |       1    |     1     |
// | 800                 |               | 32     | 1      |       1    |     1     |
// | 600                 |               | 48     | 1      |       1    |     2     |
// | 100                 |               | 48     | 1      |       2    |     6     |
// +---------------------+---------------+--------+--------+------------+-----------+
/* FOUTPOSTDIV=(CLK/PLLD*PLLM)/POSTDIV2/POSTDIV1
**在参数配置时需要注意参数的限定条件：1MHz<=CLK<=2GHz
**						1MHz<=CLK/PLLD<=40MHz
**						800MHz<=CLK/PLLD*PLLM<=3.2GHz**/
CSL_Status CSL_bootcfgMainPLLCTLConfig(Uint8 pllm, Uint8 plld, Uint8 postdiv1, Uint8 postdiv2);

/*******************************************************************************
*函数名：CSL_bootcfgDDRPLLCTLConfig
*功    能：DDR时钟配置，配置DDRPLL用来专门给DDR部件提供参考时钟DDR_REFCLK、DDR_REFCLK2。
*参    数：PLLM为倍频系数，PLLD、POSTDIV2和POSTDIV1为分频系数
*******************************************************************************/
// +--------------------+---------------+--------+--------+------------+-----------+
// | DDR3 PLL VCO       | (DDRCLK) Input|        |        |            |           |
// | Rate (MHz)         | Clock (MHz)   | PLLM   | PLLD   | POSTDIV2   | POSTDIV1  |
// +--------------------+---------------+--------+--------+------------+-----------+
// | 400                | 25(DSK)       | 32     | 1      |       1    |     2     |
// | 666                |               | 133    | 5      |       1    |     4     |
// | 800                |               | 32     | 1      |       1    |     1     |
// +--------------------+---------------+--------+--------+------------+-----------+

/* DDRPLL_FOUTPOSTDIV=(DDRCLK/PLLD*PLLM)/POSTDIV2/POSTDIV1
**在参数配置时需要注意参数的限定条件：1MHz<=DDRCLK<=2GHz
**						1MHz<=DDRCLK/PLLD<=40MHz
**						800MHz<=DDRCLK/PLLD*PLLM<=3.2GHz**/
CSL_Status CSL_bootcfgDDRPLLCTLConfig(Uint8 pllm, Uint8 plld, Uint8 postdiv1, Uint8 postdiv2);

/*******************************************************************************
*函数名：CSL_bootcfgPASSPLLCTLConfig
*功    能：PASSPLL主要用来给PCIe、SRIO、GMAC三大外设部件提供时钟
*参    数：无。
*******************************************************************************/
// +--------------------+---------------+--------+--------+------------+-----------+
// | PASSPLL VCO        |(PASSCLK) Input|        |        |            |           |
// | Rate (MHz)         | Clock (MHz)   |   PLLM | PLLD   | POSTDIV2   | POSTDIV1  |
// +--------------------+---------------+--------+--------+------------+-----------+
// | FOUT3              | 25(DSK)       |   80   |   1    |    1       |    1      |
// | FOUT4              |               |   80   |   1    |    1       |    1      |
// +-------------------+----------------+--------+--------+------------+-----------+
/* FOUT3=(PASSCLK/PLLD*PLLM)/POSTDIV2/POSTDIV1/6
**FOUT4=(PASSCLK/PLLD*PLLM)/POSTDIV2/POSTDIV1/8
**在参数配置时需要注意参数的限定条件：1MHz<=PASSCLK<=2GHz
**						1MHz<=PASSCLK/PLLD<=40MHz
**						800MHz<=PASSCLK/PLLD*PLLM<=3.2GHz**/
CSL_Status CSL_bootcfgPASSPLLCTLConfig(Uint8 pllm, Uint8 plld, Uint8 postdiv1, Uint8 postdiv2);

/**
@}
*/

#ifdef __cplusplus
}
#endif

#endif /* _CSL_BOOTCFG_H_ */


