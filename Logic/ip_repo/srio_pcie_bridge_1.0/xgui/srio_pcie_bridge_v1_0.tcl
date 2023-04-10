# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set SRIO [ipgui::add_group $IPINST -name "SRIO" -parent ${Page_0}]
  set_property tooltip {SRIO related signals} ${SRIO}
  ipgui::add_param $IPINST -name "C_SRIO_DEV_ID" -parent ${SRIO}
  ipgui::add_param $IPINST -name "C_SRIO_DEST_ID" -parent ${SRIO}

  #Adding Group
  set XDMA [ipgui::add_group $IPINST -name "XDMA" -parent ${Page_0}]
  set_property tooltip {XDMA realated parameters} ${XDMA}
  ipgui::add_param $IPINST -name "MSI_IN_EN" -parent ${XDMA}
  ipgui::add_static_text $IPINST -name "User Irq DW" -parent ${XDMA} -text {Note: User Irq number must not less than 2
usr_irq_req[0] is for SRIO DB
usr_irq_req[1] is for MSI input
}
  set USR_IRQ_DW [ipgui::add_param $IPINST -name "USR_IRQ_DW" -parent ${XDMA}]
  set_property tooltip {User Irq number connected with XDMA} ${USR_IRQ_DW}



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

proc update_PARAM_VALUE.C_SRIO_DEST_ID { PARAM_VALUE.C_SRIO_DEST_ID } {
	# Procedure called to update C_SRIO_DEST_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SRIO_DEST_ID { PARAM_VALUE.C_SRIO_DEST_ID } {
	# Procedure called to validate C_SRIO_DEST_ID
	return true
}

proc update_PARAM_VALUE.C_SRIO_DEV_ID { PARAM_VALUE.C_SRIO_DEV_ID } {
	# Procedure called to update C_SRIO_DEV_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SRIO_DEV_ID { PARAM_VALUE.C_SRIO_DEV_ID } {
	# Procedure called to validate C_SRIO_DEV_ID
	return true
}

proc update_PARAM_VALUE.MSI_IN_EN { PARAM_VALUE.MSI_IN_EN } {
	# Procedure called to update MSI_IN_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MSI_IN_EN { PARAM_VALUE.MSI_IN_EN } {
	# Procedure called to validate MSI_IN_EN
	return true
}

proc update_PARAM_VALUE.USR_IRQ_DW { PARAM_VALUE.USR_IRQ_DW } {
	# Procedure called to update USR_IRQ_DW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USR_IRQ_DW { PARAM_VALUE.USR_IRQ_DW } {
	# Procedure called to validate USR_IRQ_DW
	return true
}


proc update_MODELPARAM_VALUE.C_SRIO_DEV_ID { MODELPARAM_VALUE.C_SRIO_DEV_ID PARAM_VALUE.C_SRIO_DEV_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SRIO_DEV_ID}] ${MODELPARAM_VALUE.C_SRIO_DEV_ID}
}

proc update_MODELPARAM_VALUE.C_SRIO_DEST_ID { MODELPARAM_VALUE.C_SRIO_DEST_ID PARAM_VALUE.C_SRIO_DEST_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SRIO_DEST_ID}] ${MODELPARAM_VALUE.C_SRIO_DEST_ID}
}

proc update_MODELPARAM_VALUE.AXIL_DW { MODELPARAM_VALUE.AXIL_DW PARAM_VALUE.AXIL_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_DW}] ${MODELPARAM_VALUE.AXIL_DW}
}

proc update_MODELPARAM_VALUE.AXIL_AW { MODELPARAM_VALUE.AXIL_AW PARAM_VALUE.AXIL_AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIL_AW}] ${MODELPARAM_VALUE.AXIL_AW}
}

proc update_MODELPARAM_VALUE.USR_IRQ_DW { MODELPARAM_VALUE.USR_IRQ_DW PARAM_VALUE.USR_IRQ_DW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USR_IRQ_DW}] ${MODELPARAM_VALUE.USR_IRQ_DW}
}

