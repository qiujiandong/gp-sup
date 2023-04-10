# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXIL_AW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXIL_DW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_AW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_DW" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DELAY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IMAGE_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IMAGE_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IMGX" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IMGY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PARAM_GAMA" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PARAM_TRUNCATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "P_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "QN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TOTAL_BIT_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXIL_AW { PARAM_VALUE.AXIL_AW } {
	# Procedure called to update AXIL_AW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIL_AW { PARAM_VALUE.AXIL_AW } {
	# Procedure called to validate AXIL_AW
	return true
}

proc update_PARAM_VALUE.AXIL_DW { PARAM_VALUE.AXIL_DW } {
	# Procedure called to update AXIL_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIL_DW { PARAM_VALUE.AXIL_DW } {
	# Procedure called to validate AXIL_DW
	return true
}

proc update_PARAM_VALUE.AXI_AW { PARAM_VALUE.AXI_AW } {
	# Procedure called to update AXI_AW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_AW { PARAM_VALUE.AXI_AW } {
	# Procedure called to validate AXI_AW
	return true
}

proc update_PARAM_VALUE.AXI_DW { PARAM_VALUE.AXI_DW } {
	# Procedure called to update AXI_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_DW { PARAM_VALUE.AXI_DW } {
	# Procedure called to validate AXI_DW
	return true
}

proc update_PARAM_VALUE.DELAY { PARAM_VALUE.DELAY } {
	# Procedure called to update DELAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DELAY { PARAM_VALUE.DELAY } {
	# Procedure called to validate DELAY
	return true
}

proc update_PARAM_VALUE.IMAGE_SIZE { PARAM_VALUE.IMAGE_SIZE } {
	# Procedure called to update IMAGE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IMAGE_SIZE { PARAM_VALUE.IMAGE_SIZE } {
	# Procedure called to validate IMAGE_SIZE
	return true
}

proc update_PARAM_VALUE.IMAGE_WIDTH { PARAM_VALUE.IMAGE_WIDTH } {
	# Procedure called to update IMAGE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IMAGE_WIDTH { PARAM_VALUE.IMAGE_WIDTH } {
	# Procedure called to validate IMAGE_WIDTH
	return true
}

proc update_PARAM_VALUE.IMGX { PARAM_VALUE.IMGX } {
	# Procedure called to update IMGX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IMGX { PARAM_VALUE.IMGX } {
	# Procedure called to validate IMGX
	return true
}

proc update_PARAM_VALUE.IMGY { PARAM_VALUE.IMGY } {
	# Procedure called to update IMGY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IMGY { PARAM_VALUE.IMGY } {
	# Procedure called to validate IMGY
	return true
}

proc update_PARAM_VALUE.PARAM_GAMA { PARAM_VALUE.PARAM_GAMA } {
	# Procedure called to update PARAM_GAMA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PARAM_GAMA { PARAM_VALUE.PARAM_GAMA } {
	# Procedure called to validate PARAM_GAMA
	return true
}

proc update_PARAM_VALUE.PARAM_TRUNCATE { PARAM_VALUE.PARAM_TRUNCATE } {
	# Procedure called to update PARAM_TRUNCATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PARAM_TRUNCATE { PARAM_VALUE.PARAM_TRUNCATE } {
	# Procedure called to validate PARAM_TRUNCATE
	return true
}

proc update_PARAM_VALUE.P_WIDTH { PARAM_VALUE.P_WIDTH } {
	# Procedure called to update P_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.P_WIDTH { PARAM_VALUE.P_WIDTH } {
	# Procedure called to validate P_WIDTH
	return true
}

proc update_PARAM_VALUE.QN { PARAM_VALUE.QN } {
	# Procedure called to update QN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.QN { PARAM_VALUE.QN } {
	# Procedure called to validate QN
	return true
}

proc update_PARAM_VALUE.TOTAL_BIT_WIDTH { PARAM_VALUE.TOTAL_BIT_WIDTH } {
	# Procedure called to update TOTAL_BIT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TOTAL_BIT_WIDTH { PARAM_VALUE.TOTAL_BIT_WIDTH } {
	# Procedure called to validate TOTAL_BIT_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.AXIL_AW { MODELPARAM_VALUE.AXIL_AW PARAM_VALUE.AXIL_AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_AW}] ${MODELPARAM_VALUE.AXIL_AW}
}

proc update_MODELPARAM_VALUE.AXIL_DW { MODELPARAM_VALUE.AXIL_DW PARAM_VALUE.AXIL_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_DW}] ${MODELPARAM_VALUE.AXIL_DW}
}

proc update_MODELPARAM_VALUE.AXI_AW { MODELPARAM_VALUE.AXI_AW PARAM_VALUE.AXI_AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_AW}] ${MODELPARAM_VALUE.AXI_AW}
}

proc update_MODELPARAM_VALUE.AXI_DW { MODELPARAM_VALUE.AXI_DW PARAM_VALUE.AXI_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_DW}] ${MODELPARAM_VALUE.AXI_DW}
}

proc update_MODELPARAM_VALUE.IMAGE_SIZE { MODELPARAM_VALUE.IMAGE_SIZE PARAM_VALUE.IMAGE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IMAGE_SIZE}] ${MODELPARAM_VALUE.IMAGE_SIZE}
}

proc update_MODELPARAM_VALUE.IMAGE_WIDTH { MODELPARAM_VALUE.IMAGE_WIDTH PARAM_VALUE.IMAGE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IMAGE_WIDTH}] ${MODELPARAM_VALUE.IMAGE_WIDTH}
}

proc update_MODELPARAM_VALUE.QN { MODELPARAM_VALUE.QN PARAM_VALUE.QN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.QN}] ${MODELPARAM_VALUE.QN}
}

proc update_MODELPARAM_VALUE.TOTAL_BIT_WIDTH { MODELPARAM_VALUE.TOTAL_BIT_WIDTH PARAM_VALUE.TOTAL_BIT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TOTAL_BIT_WIDTH}] ${MODELPARAM_VALUE.TOTAL_BIT_WIDTH}
}

proc update_MODELPARAM_VALUE.P_WIDTH { MODELPARAM_VALUE.P_WIDTH PARAM_VALUE.P_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.P_WIDTH}] ${MODELPARAM_VALUE.P_WIDTH}
}

proc update_MODELPARAM_VALUE.DELAY { MODELPARAM_VALUE.DELAY PARAM_VALUE.DELAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DELAY}] ${MODELPARAM_VALUE.DELAY}
}

proc update_MODELPARAM_VALUE.PARAM_TRUNCATE { MODELPARAM_VALUE.PARAM_TRUNCATE PARAM_VALUE.PARAM_TRUNCATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PARAM_TRUNCATE}] ${MODELPARAM_VALUE.PARAM_TRUNCATE}
}

proc update_MODELPARAM_VALUE.PARAM_GAMA { MODELPARAM_VALUE.PARAM_GAMA PARAM_VALUE.PARAM_GAMA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PARAM_GAMA}] ${MODELPARAM_VALUE.PARAM_GAMA}
}

proc update_MODELPARAM_VALUE.IMGX { MODELPARAM_VALUE.IMGX PARAM_VALUE.IMGX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IMGX}] ${MODELPARAM_VALUE.IMGX}
}

proc update_MODELPARAM_VALUE.IMGY { MODELPARAM_VALUE.IMGY PARAM_VALUE.IMGY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IMGY}] ${MODELPARAM_VALUE.IMGY}
}

