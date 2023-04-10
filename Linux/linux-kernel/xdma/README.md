# 修改记录

修改libxdma.h，增加：

```c
#define XDMA_CONFIG_BAR_NUM 1
```

libxdma.c中的map_bars函数，新增：

```c
    bar_id_list[0] = 0;
    bar_id_list[1] = 1;
    bar_id_idx = 2;
    config_bar_pos = 1;
    rv = identify_bars(xdev, bar_id_list, bar_id_idx, config_bar_pos);
    if (rv < 0) {
        pr_err("Failed to identify bars\n");
        return rv;
    }
```

指定BAR1是config BAR，即DMA传输相关的配置，BAR0是用户空间，需要用identify_bars函数来识别
