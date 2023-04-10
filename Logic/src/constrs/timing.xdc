set_false_path -from [get_ports sys_nrst]
set_false_path -from [get_ports pcie_nrst]

# SRIO reference clock 125MHz
create_clock -period 8.000 -name srio_ref_clk_clk_p -waveform {0.000 4.000} [get_ports srio_ref_clk_clk_p]
# PCIe reference clock 100MHz
create_clock -period 10.000 -name pcie_ref_clk_clk_p -waveform {0.000 5.000} [get_ports pcie_ref_clk_clk_p]
# EMIF clock 62.5MHz
create_clock -period 16.000 -name eclk -waveform {0.000 8.000} [get_ports eclk]

set_clock_latency -source 0.642 [get_clocks eclk]

create_clock -period 16.000 -name vclk -waveform {0.000 8.000}

# the max delay is 0.67 ns, min delay is 0.6 ns, max tco of EA is 5.1 ns, min tco of EA is 1.3 ns
set_input_delay -clock [get_clocks vclk] -max -add_delay 5.770 [get_ports {emif_emif_addr[*]}]
set_input_delay -clock [get_clocks vclk] -min -add_delay 1.970 [get_ports {emif_emif_addr[*]}]

# the max delay is 0.80 ns, min delay is 0.74 ns, max tco of ED is 7.5 ns, min tco of EA is 1.3 ns
set_input_delay -clock [get_clocks vclk] -max -add_delay 8.300 [get_ports {emif_emif_data[*]}]
set_input_delay -clock [get_clocks vclk] -min -add_delay 1.940 [get_ports {emif_emif_data[*]}]

# delay is 0.65 ns, max tco of CE is 4.9 ns, min tco of EA is 1.3 ns
set_input_delay -clock [get_clocks vclk] -max -add_delay 5.550 [get_ports emif_nce]
set_input_delay -clock [get_clocks vclk] -min -add_delay 1.950 [get_ports emif_nce]

# delay is 0.62 ns, max tco of CE is 4.9 ns, min tco of EA is 1.3 ns
set_input_delay -clock [get_clocks vclk] -max -add_delay 5.520 [get_ports emif_noe]
set_input_delay -clock [get_clocks vclk] -min -add_delay 1.920 [get_ports emif_noe]

# delay is 0.62 ns, max tco of CE is 4.9 ns, min tco of EA is 1.3 ns
set_input_delay -clock [get_clocks vclk] -max -add_delay 5.520 [get_ports emif_nwe]
set_input_delay -clock [get_clocks vclk] -min -add_delay 1.920 [get_ports emif_nwe]

set_false_path -to [get_ports {emif_emif_data[*]}]
set_false_path -to [get_ports busy]
set_false_path -to [get_ports full]
set_false_path -to [get_ports rd_fifo_empty]
