
################################################################
# This is a generated script based on design: pdb_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source pdb_bd_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7vx690tffg1927-2
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name pdb_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:user:hog_mdl_only_axi_lite:1.0\
littleball:littleball:srio_pcie_bridge:1.0\
xilinx.com:ip:mig_7series:4.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xadc_wiz:3.3\
littleball:littleball:emif2axil:1.0\
xilinx.com:ip:srio_gen2:4.1\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:xdma:4.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}


##################################################################
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_pdb_bd_mig_7series_0_0 { str_mig_prj_filepath } {

   file mkdir [ file dirname "$str_mig_prj_filepath" ]
   set mig_prj_file [open $str_mig_prj_filepath  w+]

   puts $mig_prj_file {ï»?<?xml version="1.0" encoding="UTF-8" standalone="no" ?>}
   puts $mig_prj_file {<Project NoOfControllers="1">}
   puts $mig_prj_file {  }
   puts $mig_prj_file {<!-- IMPORTANT: This is an internal file that has been generated by the MIG software. Any direct editing or changes made to this file may result in unpredictable behavior or data corruption. It is strongly advised that users do not edit the contents of this file. Re-run the MIG GUI with the required settings if any of the options provided below need to be altered. -->}
   puts $mig_prj_file {  <ModuleName>pdb_bd_mig_7series_0_0</ModuleName>}
   puts $mig_prj_file {  <dci_inouts_inputs>1</dci_inouts_inputs>}
   puts $mig_prj_file {  <dci_inputs>1</dci_inputs>}
   puts $mig_prj_file {  <Debug_En>OFF</Debug_En>}
   puts $mig_prj_file {  <DataDepth_En>1024</DataDepth_En>}
   puts $mig_prj_file {  <LowPower_En>ON</LowPower_En>}
   puts $mig_prj_file {  <XADC_En>Disabled</XADC_En>}
   puts $mig_prj_file {  <TargetFPGA>xc7vx690t-ffg1927/-2</TargetFPGA>}
   puts $mig_prj_file {  <Version>4.2</Version>}
   puts $mig_prj_file {  <SystemClock>Differential</SystemClock>}
   puts $mig_prj_file {  <ReferenceClock>Use System Clock</ReferenceClock>}
   puts $mig_prj_file {  <SysResetPolarity>ACTIVE LOW</SysResetPolarity>}
   puts $mig_prj_file {  <BankSelectionFlag>FALSE</BankSelectionFlag>}
   puts $mig_prj_file {  <InternalVref>0</InternalVref>}
   puts $mig_prj_file {  <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}
   puts $mig_prj_file {  <dci_cascade>0</dci_cascade>}
   puts $mig_prj_file {  <Controller number="0">}
   puts $mig_prj_file {    <MemoryDevice>DDR3_SDRAM/Components/MT41J128M16XX-125</MemoryDevice>}
   puts $mig_prj_file {    <TimePeriod>1250</TimePeriod>}
   puts $mig_prj_file {    <VccAuxIO>2.0V</VccAuxIO>}
   puts $mig_prj_file {    <PHYRatio>4:1</PHYRatio>}
   puts $mig_prj_file {    <InputClkFreq>200</InputClkFreq>}
   puts $mig_prj_file {    <UIExtraClocks>1</UIExtraClocks>}
   puts $mig_prj_file {    <MMCM_VCO>800</MMCM_VCO>}
   puts $mig_prj_file {    <MMCMClkOut0>10.000</MMCMClkOut0>}
   puts $mig_prj_file {    <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {    <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {    <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {    <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {    <DataWidth>64</DataWidth>}
   puts $mig_prj_file {    <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {    <DataMask>1</DataMask>}
   puts $mig_prj_file {    <ECC>Disabled</ECC>}
   puts $mig_prj_file {    <Ordering>Normal</Ordering>}
   puts $mig_prj_file {    <BankMachineCnt>8</BankMachineCnt>}
   puts $mig_prj_file {    <CustomPart>FALSE</CustomPart>}
   puts $mig_prj_file {    <NewPartName/>}
   puts $mig_prj_file {    <RowAddress>14</RowAddress>}
   puts $mig_prj_file {    <ColAddress>10</ColAddress>}
   puts $mig_prj_file {    <BankAddress>3</BankAddress>}
   puts $mig_prj_file {    <MemoryVoltage>1.5V</MemoryVoltage>}
   puts $mig_prj_file {    <C0_MEM_SIZE>1073741824</C0_MEM_SIZE>}
   puts $mig_prj_file {    <UserMemoryAddressMap>ROW_BANK_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {    <PinSelection>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="C15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="D15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="E12" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="D12" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="E14" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="C14" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="B15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="A15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="B13" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="B12" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="A14" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="A13" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="C13" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="C12" SLEW="" VCCAUX_IO="HIGH" name="ddr3_addr[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="F15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_ba[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="F14" SLEW="" VCCAUX_IO="HIGH" name="ddr3_ba[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="F13" SLEW="" VCCAUX_IO="HIGH" name="ddr3_ba[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="M13" SLEW="" VCCAUX_IO="HIGH" name="ddr3_cas_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="H14" SLEW="" VCCAUX_IO="HIGH" name="ddr3_ck_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="H15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_ck_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="K14" SLEW="" VCCAUX_IO="HIGH" name="ddr3_cke[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="L13" SLEW="" VCCAUX_IO="HIGH" name="ddr3_cs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="P20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dm[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="M20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dm[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="H19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dm[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="A20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dm[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="C17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dm[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="J17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dm[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="M17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dm[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dm[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="R21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="J22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="N19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="L21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="N20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="K21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="N22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[15]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="J21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[16]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="F21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[17]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="J20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[18]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="F20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[19]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="P22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="G20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[20]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="F19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[21]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="J19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[22]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="H20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[23]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="B21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[24]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="D20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[25]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="B20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[26]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="D21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[27]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="C20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[28]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="E22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[29]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="T21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="A21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[30]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="D22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[31]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="A18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[32]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="A16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[33]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="A19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[34]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="B16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[35]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="C18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[36]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="D17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[37]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="B18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[38]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="B17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[39]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="P21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="G18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[40]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="E17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[41]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="H17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[42]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="F18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[43]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="E16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[44]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="E19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[45]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="H18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[46]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="E18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[47]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="J16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[48]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="N15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[49]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="R22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="L18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[50]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="P15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[51]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="K17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[52]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="M16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[53]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="M18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[54]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="L16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[55]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="R16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[56]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="P16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[57]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="U18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[58]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="R18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[59]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="R19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="T16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[60]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="T18" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[61]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="V15" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[62]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="R17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[63]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="U20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="T19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="L20" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15_T_DCI" PADName="M22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dq[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="U21" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="K19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_n[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="G22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_n[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="B22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_n[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="C19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_n[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="F16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_n[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="N17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_n[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="U16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_n[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="U22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="L19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_p[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="H22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_p[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="C22" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_p[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="D19" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_p[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="G16" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_p[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="P17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_p[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15_T_DCI" PADName="U17" SLEW="" VCCAUX_IO="HIGH" name="ddr3_dqs_p[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="L14" SLEW="" VCCAUX_IO="HIGH" name="ddr3_odt[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="G12" SLEW="" VCCAUX_IO="HIGH" name="ddr3_ras_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="LVCMOS15" PADName="R14" SLEW="" VCCAUX_IO="HIGH" name="ddr3_reset_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="H12" SLEW="" VCCAUX_IO="HIGH" name="ddr3_we_n"/>}
   puts $mig_prj_file {    </PinSelection>}
   puts $mig_prj_file {    <System_Clock>}
   puts $mig_prj_file {      <Pin Bank="38" PADName="J15/J14(CC_P/N)" name="sys_clk_p/n"/>}
   puts $mig_prj_file {    </System_Clock>}
   puts $mig_prj_file {    <System_Control>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="sys_rst"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="init_calib_complete"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="tg_compare_error"/>}
   puts $mig_prj_file {    </System_Control>}
   puts $mig_prj_file {    <TimingParameters>}
   puts $mig_prj_file {      <Parameters tcke="5" tfaw="40" tras="35" trcd="13.75" trefi="7.8" trfc="160" trp="13.75" trrd="7.5" trtp="7.5" twtr="7.5"/>}
   puts $mig_prj_file {    </TimingParameters>}
   puts $mig_prj_file {    <mrBurstLength name="Burst Length">8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {    <mrBurstType name="Read Burst Type and Length">Sequential</mrBurstType>}
   puts $mig_prj_file {    <mrCasLatency name="CAS Latency">11</mrCasLatency>}
   puts $mig_prj_file {    <mrMode name="Mode">Normal</mrMode>}
   puts $mig_prj_file {    <mrDllReset name="DLL Reset">No</mrDllReset>}
   puts $mig_prj_file {    <mrPdMode name="DLL control for precharge PD">Slow Exit</mrPdMode>}
   puts $mig_prj_file {    <emrDllEnable name="DLL Enable">Enable</emrDllEnable>}
   puts $mig_prj_file {    <emrOutputDriveStrength name="Output Driver Impedance Control">RZQ/7</emrOutputDriveStrength>}
   puts $mig_prj_file {    <emrMirrorSelection name="Address Mirroring">Disable</emrMirrorSelection>}
   puts $mig_prj_file {    <emrCSSelection name="Controller Chip Select Pin">Enable</emrCSSelection>}
   puts $mig_prj_file {    <emrRTT name="RTT (nominal) - On Die Termination (ODT)">RZQ/4</emrRTT>}
   puts $mig_prj_file {    <emrPosted name="Additive Latency (AL)">0</emrPosted>}
   puts $mig_prj_file {    <emrOCD name="Write Leveling Enable">Disabled</emrOCD>}
   puts $mig_prj_file {    <emrDQS name="TDQS enable">Enabled</emrDQS>}
   puts $mig_prj_file {    <emrRDQS name="Qoff">Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {    <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh">Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {    <mr2CasWriteLatency name="CAS write latency">8</mr2CasWriteLatency>}
   puts $mig_prj_file {    <mr2AutoSelfRefresh name="Auto Self Refresh">Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {    <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate">Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {    <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)">Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {    <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {    <AXIParameters>}
   puts $mig_prj_file {      <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {      <C0_S_AXI_ADDR_WIDTH>30</C0_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_DATA_WIDTH>512</C0_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_ID_WIDTH>5</C0_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_SUPPORTS_NARROW_BURST>1</C0_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {    </AXIParameters>}
   puts $mig_prj_file {  </Controller>}
   puts $mig_prj_file {</Project>}

   close $mig_prj_file
}
# End of write_mig_file_pdb_bd_mig_7series_0_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: hier_xdma
proc create_hier_cell_hier_xdma { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_hier_xdma() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M00_AXIS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_LITE

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S00_AXIS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt_rtl_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_ref_clk


  # Create pins
  create_bd_pin -dir O -type clk ACLK
  create_bd_pin -dir I -type clk ACLK1
  create_bd_pin -dir O -type rst ARESETN
  create_bd_pin -dir I -type rst ARESETN1
  create_bd_pin -dir I -type rst pcie_nrst
  create_bd_pin -dir O -from 15 -to 0 usr_irq_ack
  create_bd_pin -dir I -from 15 -to 0 usr_irq_req

  # Create instance: axis_interconnect_0, and set properties
  set axis_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axis_interconnect_0

  # Create instance: axis_interconnect_1, and set properties
  set axis_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axis_interconnect_1

  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $util_ds_buf

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [ list \
   CONFIG.axi_data_width {256_bit} \
   CONFIG.axilite_master_en {true} \
   CONFIG.axisten_freq {125} \
   CONFIG.cfg_mgmt_if {false} \
   CONFIG.dedicate_perst {false} \
   CONFIG.pcie_blk_locn {X0Y1} \
   CONFIG.pciebar2axibar_axil_master {0x44A00000} \
   CONFIG.pciebar2axibar_axist_bypass {0x0000000000000000} \
   CONFIG.pf0_interrupt_pin {NONE} \
   CONFIG.pf0_msi_cap_multimsgcap {32_vectors} \
   CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
   CONFIG.pl_link_cap_max_link_width {X8} \
   CONFIG.xdma_axi_intf_mm {AXI_Stream} \
   CONFIG.xdma_axilite_slave {false} \
   CONFIG.xdma_num_usr_irq {16} \
   CONFIG.xdma_rnum_rids {32} \
   CONFIG.xdma_wnum_rids {16} \
 ] $xdma_0

  # Create interface connections
  connect_bd_intf_net -intf_net axis_interconnect_0_M00_AXIS [get_bd_intf_pins M00_AXIS] [get_bd_intf_pins axis_interconnect_0/M00_AXIS]
  connect_bd_intf_net -intf_net axis_interconnect_1_M00_AXIS [get_bd_intf_pins axis_interconnect_1/M00_AXIS] [get_bd_intf_pins xdma_0/S_AXIS_C2H_0]
  connect_bd_intf_net -intf_net diff_clock_rtl_0_1 [get_bd_intf_pins pcie_ref_clk] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net srio_pcie_bridge_0_m_axis_c2h [get_bd_intf_pins S00_AXIS] [get_bd_intf_pins axis_interconnect_1/S00_AXIS]
  connect_bd_intf_net -intf_net xdma_0_M_AXIS_H2C_0 [get_bd_intf_pins axis_interconnect_0/S00_AXIS] [get_bd_intf_pins xdma_0/M_AXIS_H2C_0]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins M_AXI_LITE] [get_bd_intf_pins xdma_0/M_AXI_LITE]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_pins pcie_7x_mgt_rtl_0] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net reset_rtl_0_1 [get_bd_pins pcie_nrst] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net rst_srio_gen2_0_156M_peripheral_aresetn [get_bd_pins ARESETN1] [get_bd_pins axis_interconnect_0/M00_AXIS_ARESETN] [get_bd_pins axis_interconnect_1/ARESETN] [get_bd_pins axis_interconnect_1/S00_AXIS_ARESETN]
  connect_bd_net -net srio_gen2_0_log_clk_out [get_bd_pins ACLK1] [get_bd_pins axis_interconnect_0/M00_AXIS_ACLK] [get_bd_pins axis_interconnect_1/ACLK] [get_bd_pins axis_interconnect_1/S00_AXIS_ACLK]
  connect_bd_net -net srio_pcie_bridge_0_usr_irq_req [get_bd_pins usr_irq_req] [get_bd_pins xdma_0/usr_irq_req]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins util_ds_buf/IBUF_OUT] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins ACLK] [get_bd_pins axis_interconnect_0/ACLK] [get_bd_pins axis_interconnect_0/S00_AXIS_ACLK] [get_bd_pins axis_interconnect_1/M00_AXIS_ACLK] [get_bd_pins xdma_0/axi_aclk]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins ARESETN] [get_bd_pins axis_interconnect_0/ARESETN] [get_bd_pins axis_interconnect_0/S00_AXIS_ARESETN] [get_bd_pins axis_interconnect_1/M00_AXIS_ARESETN] [get_bd_pins xdma_0/axi_aresetn]
  connect_bd_net -net xdma_0_usr_irq_ack [get_bd_pins usr_irq_ack] [get_bd_pins xdma_0/usr_irq_ack]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hier_srio
proc create_hier_cell_hier_srio { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_hier_srio() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 INITIATOR_REQ

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 INITIATOR_RESP

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 MAINT_IF

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 TARGET_REQ

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 TARGET_RESP

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 srio_ref_clk


  # Create pins
  create_bd_pin -dir O -type clk log_clk_out
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir I srio_rxn0_0
  create_bd_pin -dir I srio_rxn1_0
  create_bd_pin -dir I srio_rxn2_0
  create_bd_pin -dir I srio_rxn3_0
  create_bd_pin -dir I srio_rxp0_0
  create_bd_pin -dir I srio_rxp1_0
  create_bd_pin -dir I srio_rxp2_0
  create_bd_pin -dir I srio_rxp3_0
  create_bd_pin -dir O srio_txn0_0
  create_bd_pin -dir O srio_txn1_0
  create_bd_pin -dir O srio_txn2_0
  create_bd_pin -dir O srio_txn3_0
  create_bd_pin -dir O srio_txp0_0
  create_bd_pin -dir O srio_txp1_0
  create_bd_pin -dir O srio_txp2_0
  create_bd_pin -dir O srio_txp3_0
  create_bd_pin -dir I -from 0 -to 0 sys_nrst

  # Create instance: rst_srio_gen2_0_156M, and set properties
  set rst_srio_gen2_0_156M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_srio_gen2_0_156M ]

  # Create instance: srio_gen2_0, and set properties
  set srio_gen2_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:srio_gen2:4.1 srio_gen2_0 ]
  set_property -dict [ list \
   CONFIG.device_id {F201} \
   CONFIG.device_id_width {16_bit} \
   CONFIG.link_width {4} \
   CONFIG.rx_buffer_depth {16} \
   CONFIG.transfer_frequency {3.125} \
   CONFIG.tx_buffer_depth {16} \
 ] $srio_gen2_0

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net DIFF_CLK_0_1 [get_bd_intf_pins srio_ref_clk] [get_bd_intf_pins srio_gen2_0/DIFF_CLK]
  connect_bd_intf_net -intf_net srio_gen2_0_INITIATOR_RESP [get_bd_intf_pins INITIATOR_RESP] [get_bd_intf_pins srio_gen2_0/INITIATOR_RESP]
  connect_bd_intf_net -intf_net srio_gen2_0_TARGET_REQ [get_bd_intf_pins TARGET_REQ] [get_bd_intf_pins srio_gen2_0/TARGET_REQ]
  connect_bd_intf_net -intf_net srio_pcie_bridge_0_m_axis_ireq [get_bd_intf_pins INITIATOR_REQ] [get_bd_intf_pins srio_gen2_0/INITIATOR_REQ]
  connect_bd_intf_net -intf_net srio_pcie_bridge_0_m_axis_tresp [get_bd_intf_pins TARGET_RESP] [get_bd_intf_pins srio_gen2_0/TARGET_RESP]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M00_AXI [get_bd_intf_pins MAINT_IF] [get_bd_intf_pins srio_gen2_0/MAINT_IF]

  # Create port connections
  connect_bd_net -net reset_rtl_0_0_1 [get_bd_pins sys_nrst] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net rst_srio_gen2_0_156M_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins rst_srio_gen2_0_156M/peripheral_aresetn]
  connect_bd_net -net srio_gen2_0_log_clk_out [get_bd_pins log_clk_out] [get_bd_pins rst_srio_gen2_0_156M/slowest_sync_clk] [get_bd_pins srio_gen2_0/log_clk_out]
  connect_bd_net -net srio_gen2_0_log_rst_out [get_bd_pins rst_srio_gen2_0_156M/ext_reset_in] [get_bd_pins srio_gen2_0/log_rst_out]
  connect_bd_net -net srio_gen2_0_srio_txn0 [get_bd_pins srio_txn0_0] [get_bd_pins srio_gen2_0/srio_txn0]
  connect_bd_net -net srio_gen2_0_srio_txn1 [get_bd_pins srio_txn1_0] [get_bd_pins srio_gen2_0/srio_txn1]
  connect_bd_net -net srio_gen2_0_srio_txn2 [get_bd_pins srio_txn2_0] [get_bd_pins srio_gen2_0/srio_txn2]
  connect_bd_net -net srio_gen2_0_srio_txn3 [get_bd_pins srio_txn3_0] [get_bd_pins srio_gen2_0/srio_txn3]
  connect_bd_net -net srio_gen2_0_srio_txp0 [get_bd_pins srio_txp0_0] [get_bd_pins srio_gen2_0/srio_txp0]
  connect_bd_net -net srio_gen2_0_srio_txp1 [get_bd_pins srio_txp1_0] [get_bd_pins srio_gen2_0/srio_txp1]
  connect_bd_net -net srio_gen2_0_srio_txp2 [get_bd_pins srio_txp2_0] [get_bd_pins srio_gen2_0/srio_txp2]
  connect_bd_net -net srio_gen2_0_srio_txp3 [get_bd_pins srio_txp3_0] [get_bd_pins srio_gen2_0/srio_txp3]
  connect_bd_net -net srio_rxn0_0_1 [get_bd_pins srio_rxn0_0] [get_bd_pins srio_gen2_0/srio_rxn0]
  connect_bd_net -net srio_rxn1_0_1 [get_bd_pins srio_rxn1_0] [get_bd_pins srio_gen2_0/srio_rxn1]
  connect_bd_net -net srio_rxn2_0_1 [get_bd_pins srio_rxn2_0] [get_bd_pins srio_gen2_0/srio_rxn2]
  connect_bd_net -net srio_rxn3_0_1 [get_bd_pins srio_rxn3_0] [get_bd_pins srio_gen2_0/srio_rxn3]
  connect_bd_net -net srio_rxp0_0_1 [get_bd_pins srio_rxp0_0] [get_bd_pins srio_gen2_0/srio_rxp0]
  connect_bd_net -net srio_rxp1_0_1 [get_bd_pins srio_rxp1_0] [get_bd_pins srio_gen2_0/srio_rxp1]
  connect_bd_net -net srio_rxp2_0_1 [get_bd_pins srio_rxp2_0] [get_bd_pins srio_gen2_0/srio_rxp2]
  connect_bd_net -net srio_rxp3_0_1 [get_bd_pins srio_rxp3_0] [get_bd_pins srio_gen2_0/srio_rxp3]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins srio_gen2_0/sys_rst] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins srio_gen2_0/force_reinit] [get_bd_pins srio_gen2_0/phy_link_reset] [get_bd_pins srio_gen2_0/phy_mce] [get_bd_pins srio_gen2_0/s_axi_maintr_rst] [get_bd_pins srio_gen2_0/sim_train_en] [get_bd_pins xlconstant_0/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hier_emif
proc create_hier_cell_hier_emif { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_hier_emif() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv littleball:littleball:emif_rtl:1.0 emif_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axil


  # Create pins
  create_bd_pin -dir O -type clk aclk
  create_bd_pin -dir O -type rst aresetn
  create_bd_pin -dir O busy
  create_bd_pin -dir I -type clk eclk
  create_bd_pin -dir O full
  create_bd_pin -dir O rd_fifo_empty
  create_bd_pin -dir I -type rst sys_nrst

  # Create instance: emif2axil_0, and set properties
  set emif2axil_0 [ create_bd_cell -type ip -vlnv littleball:littleball:emif2axil:1.0 emif2axil_0 ]
  set_property -dict [ list \
   CONFIG.AXIL_ADDR_BASE {0x44A00000} \
   CONFIG.AXIL_ADDR_WIDTH {18} \
 ] $emif2axil_0

  # Create instance: rst_eclk_62M, and set properties
  set rst_eclk_62M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_eclk_62M ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins emif_0] [get_bd_intf_pins emif2axil_0/emif]
  connect_bd_intf_net -intf_net emif2axil_0_m_axil [get_bd_intf_pins m_axil] [get_bd_intf_pins emif2axil_0/m_axil]

  # Create port connections
  connect_bd_net -net eclk_0_1 [get_bd_pins eclk] [get_bd_pins emif2axil_0/eclk] [get_bd_pins rst_eclk_62M/slowest_sync_clk]
  connect_bd_net -net emif2axil_0_aclk [get_bd_pins aclk] [get_bd_pins emif2axil_0/aclk]
  connect_bd_net -net emif2axil_0_aresetn [get_bd_pins aresetn] [get_bd_pins emif2axil_0/aresetn]
  connect_bd_net -net emif2axil_0_busy [get_bd_pins busy] [get_bd_pins emif2axil_0/busy]
  connect_bd_net -net emif2axil_0_full [get_bd_pins full] [get_bd_pins emif2axil_0/full]
  connect_bd_net -net emif2axil_0_rd_fifo_empty [get_bd_pins rd_fifo_empty] [get_bd_pins emif2axil_0/rd_fifo_empty]
  connect_bd_net -net reset_rtl_0_0_1 [get_bd_pins sys_nrst] [get_bd_pins rst_eclk_62M/ext_reset_in]
  connect_bd_net -net rst_eclk_62M_peripheral_aresetn [get_bd_pins emif2axil_0/nrst] [get_bd_pins rst_eclk_62M/peripheral_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hier_ddr
proc create_hier_cell_hier_ddr { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_hier_ddr() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ddr_ref_clk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_lite


  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir I -type rst ARESETN
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn1
  create_bd_pin -dir I -type rst sys_nrst
  create_bd_pin -dir O -type clk ui_addn_clk_0
  create_bd_pin -dir O -type clk ui_clk

  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0 ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]
  set str_mig_file_name mig_a.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}

  write_mig_file_pdb_bd_mig_7series_0_0 $str_mig_file_path

  set_property -dict [ list \
   CONFIG.BOARD_MIG_PARAM {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.XML_INPUT_FILE {mig_a.prj} \
 ] $mig_7series_0

  # Create instance: rst_mig_7series_0_200M, and set properties
  set rst_mig_7series_0_200M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_mig_7series_0_200M ]

  # Create instance: rst_mig_7series_0_80M, and set properties
  set rst_mig_7series_0_80M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_mig_7series_0_80M ]

  # Create instance: xadc_wiz_0, and set properties
  set xadc_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.3 xadc_wiz_0 ]
  set_property -dict [ list \
   CONFIG.ENABLE_TEMP_BUS {true} \
 ] $xadc_wiz_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]
  connect_bd_intf_net -intf_net SYS_CLK_0_1 [get_bd_intf_pins ddr_ref_clk] [get_bd_intf_pins mig_7series_0/SYS_CLK]
  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_pins DDR3_0] [get_bd_intf_pins mig_7series_0/DDR3]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M02_AXI [get_bd_intf_pins s_axi_lite] [get_bd_intf_pins xadc_wiz_0/s_axi_lite]

  # Create port connections
  connect_bd_net -net mig_7series_0_mmcm_locked [get_bd_pins mig_7series_0/mmcm_locked] [get_bd_pins rst_mig_7series_0_200M/dcm_locked] [get_bd_pins rst_mig_7series_0_80M/dcm_locked]
  connect_bd_net -net mig_7series_0_ui_addn_clk_0 [get_bd_pins ui_addn_clk_0] [get_bd_pins mig_7series_0/ui_addn_clk_0] [get_bd_pins rst_mig_7series_0_80M/slowest_sync_clk]
  connect_bd_net -net mig_7series_0_ui_clk [get_bd_pins ui_clk] [get_bd_pins mig_7series_0/ui_clk] [get_bd_pins rst_mig_7series_0_200M/slowest_sync_clk]
  connect_bd_net -net mig_7series_0_ui_clk_sync_rst [get_bd_pins mig_7series_0/ui_clk_sync_rst] [get_bd_pins rst_mig_7series_0_200M/ext_reset_in]
  connect_bd_net -net reset_rtl_0_0_1 [get_bd_pins sys_nrst] [get_bd_pins mig_7series_0/sys_rst] [get_bd_pins rst_mig_7series_0_80M/ext_reset_in]
  connect_bd_net -net rst_mig_7series_0_200M_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins mig_7series_0/aresetn] [get_bd_pins rst_mig_7series_0_200M/peripheral_aresetn]
  connect_bd_net -net rst_mig_7series_0_80M_peripheral_aresetn [get_bd_pins peripheral_aresetn1] [get_bd_pins rst_mig_7series_0_80M/peripheral_aresetn]
  connect_bd_net -net xadc_wiz_0_temp_out [get_bd_pins mig_7series_0/device_temp_i] [get_bd_pins xadc_wiz_0/temp_out]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins ACLK] [get_bd_pins xadc_wiz_0/s_axi_aclk]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins ARESETN] [get_bd_pins xadc_wiz_0/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR3_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3_0 ]

  set ddr_ref_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ddr_ref_clk ]

  set emif [ create_bd_intf_port -mode Slave -vlnv littleball:littleball:emif_rtl:1.0 emif ]

  set pcie_7x_mgt_rtl_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt_rtl_0 ]

  set pcie_ref_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_ref_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $pcie_ref_clk

  set srio_ref_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 srio_ref_clk ]


  # Create ports
  set busy [ create_bd_port -dir O busy ]
  set eclk [ create_bd_port -dir I -type clk -freq_hz 62500000 eclk ]
  set full [ create_bd_port -dir O full ]
  set pcie_nrst [ create_bd_port -dir I -type rst pcie_nrst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_nrst
  set rd_fifo_empty [ create_bd_port -dir O rd_fifo_empty ]
  set rdwr_done [ create_bd_port -dir O -from 1 -to 0 rdwr_done ]
  set srio_rxn0_0 [ create_bd_port -dir I srio_rxn0_0 ]
  set srio_rxn1_0 [ create_bd_port -dir I srio_rxn1_0 ]
  set srio_rxn2_0 [ create_bd_port -dir I srio_rxn2_0 ]
  set srio_rxn3_0 [ create_bd_port -dir I srio_rxn3_0 ]
  set srio_rxp0_0 [ create_bd_port -dir I srio_rxp0_0 ]
  set srio_rxp1_0 [ create_bd_port -dir I srio_rxp1_0 ]
  set srio_rxp2_0 [ create_bd_port -dir I srio_rxp2_0 ]
  set srio_rxp3_0 [ create_bd_port -dir I srio_rxp3_0 ]
  set srio_txn0_0 [ create_bd_port -dir O srio_txn0_0 ]
  set srio_txn1_0 [ create_bd_port -dir O srio_txn1_0 ]
  set srio_txn2_0 [ create_bd_port -dir O srio_txn2_0 ]
  set srio_txn3_0 [ create_bd_port -dir O srio_txn3_0 ]
  set srio_txp0_0 [ create_bd_port -dir O srio_txp0_0 ]
  set srio_txp1_0 [ create_bd_port -dir O srio_txp1_0 ]
  set srio_txp2_0 [ create_bd_port -dir O srio_txp2_0 ]
  set srio_txp3_0 [ create_bd_port -dir O srio_txp3_0 ]
  set sys_nrst [ create_bd_port -dir I -type rst sys_nrst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $sys_nrst

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.S00_HAS_DATA_FIFO {2} \
   CONFIG.S01_HAS_DATA_FIFO {2} \
 ] $axi_mem_intercon

  # Create instance: hier_ddr
  create_hier_cell_hier_ddr [current_bd_instance .] hier_ddr

  # Create instance: hier_emif
  create_hier_cell_hier_emif [current_bd_instance .] hier_emif

  # Create instance: hier_srio
  create_hier_cell_hier_srio [current_bd_instance .] hier_srio

  # Create instance: hier_xdma
  create_hier_cell_hier_xdma [current_bd_instance .] hier_xdma

  # Create instance: hog_mdl_only_axi_lite_0, and set properties
  set hog_mdl_only_axi_lite_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:hog_mdl_only_axi_lite:1.0 hog_mdl_only_axi_lite_0 ]
  set_property -dict [ list \
   CONFIG.PARAM_GAMA {"0000000000000000000000000000011110001"} \
   CONFIG.PARAM_TRUNCATE {"0000000000000000000000000000011001100"} \
   CONFIG.QN {10} \
   CONFIG.TOTAL_BIT_WIDTH {37} \
 ] $hog_mdl_only_axi_lite_0

  # Create instance: srio_pcie_bridge_0, and set properties
  set srio_pcie_bridge_0 [ create_bd_cell -type ip -vlnv littleball:littleball:srio_pcie_bridge:1.0 srio_pcie_bridge_0 ]

  # Create instance: xdma_0_axi_periph, and set properties
  set xdma_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 xdma_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {4} \
   CONFIG.NUM_SI {2} \
 ] $xdma_0_axi_periph

  # Create interface connections
  connect_bd_intf_net -intf_net DIFF_CLK_0_1 [get_bd_intf_ports srio_ref_clk] [get_bd_intf_pins hier_srio/srio_ref_clk]
  connect_bd_intf_net -intf_net SYS_CLK_0_1 [get_bd_intf_ports ddr_ref_clk] [get_bd_intf_pins hier_ddr/ddr_ref_clk]
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins hier_ddr/S_AXI]
  connect_bd_intf_net -intf_net axis_interconnect_0_M00_AXIS [get_bd_intf_pins hier_xdma/M00_AXIS] [get_bd_intf_pins srio_pcie_bridge_0/s_axis_h2c]
  connect_bd_intf_net -intf_net diff_clock_rtl_0_1 [get_bd_intf_ports pcie_ref_clk] [get_bd_intf_pins hier_xdma/pcie_ref_clk]
  connect_bd_intf_net -intf_net emif2axil_0_m_axil [get_bd_intf_pins hier_emif/m_axil] [get_bd_intf_pins xdma_0_axi_periph/S01_AXI]
  connect_bd_intf_net -intf_net emif_0_1 [get_bd_intf_ports emif] [get_bd_intf_pins hier_emif/emif_0]
  connect_bd_intf_net -intf_net hog_mdl_only_axi_lite_0_m_axi [get_bd_intf_pins axi_mem_intercon/S01_AXI] [get_bd_intf_pins hog_mdl_only_axi_lite_0/m_axi]
  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_ports DDR3_0] [get_bd_intf_pins hier_ddr/DDR3_0]
  connect_bd_intf_net -intf_net srio_gen2_0_INITIATOR_RESP [get_bd_intf_pins hier_srio/INITIATOR_RESP] [get_bd_intf_pins srio_pcie_bridge_0/s_axis_iresp]
  connect_bd_intf_net -intf_net srio_gen2_0_TARGET_REQ [get_bd_intf_pins hier_srio/TARGET_REQ] [get_bd_intf_pins srio_pcie_bridge_0/s_axis_treq]
  connect_bd_intf_net -intf_net srio_pcie_bridge_0_m_axi [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins srio_pcie_bridge_0/m_axi]
  connect_bd_intf_net -intf_net srio_pcie_bridge_0_m_axis_c2h [get_bd_intf_pins hier_xdma/S00_AXIS] [get_bd_intf_pins srio_pcie_bridge_0/m_axis_c2h]
  connect_bd_intf_net -intf_net srio_pcie_bridge_0_m_axis_ireq [get_bd_intf_pins hier_srio/INITIATOR_REQ] [get_bd_intf_pins srio_pcie_bridge_0/m_axis_ireq]
  connect_bd_intf_net -intf_net srio_pcie_bridge_0_m_axis_tresp [get_bd_intf_pins hier_srio/TARGET_RESP] [get_bd_intf_pins srio_pcie_bridge_0/m_axis_tresp]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins hier_xdma/M_AXI_LITE] [get_bd_intf_pins xdma_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M00_AXI [get_bd_intf_pins hier_srio/MAINT_IF] [get_bd_intf_pins xdma_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M01_AXI [get_bd_intf_pins srio_pcie_bridge_0/s_axil] [get_bd_intf_pins xdma_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M02_AXI [get_bd_intf_pins hier_ddr/s_axi_lite] [get_bd_intf_pins xdma_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M03_AXI [get_bd_intf_pins hog_mdl_only_axi_lite_0/s_axil] [get_bd_intf_pins xdma_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_7x_mgt_rtl_0] [get_bd_intf_pins hier_xdma/pcie_7x_mgt_rtl_0]

  # Create port connections
  connect_bd_net -net M00_ACLK_1 [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins hier_ddr/ui_clk]
  connect_bd_net -net M00_ARESETN_1 [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins hier_ddr/peripheral_aresetn]
  connect_bd_net -net M03_ACLK_1 [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins hier_ddr/ui_addn_clk_0] [get_bd_pins hog_mdl_only_axi_lite_0/aclk] [get_bd_pins xdma_0_axi_periph/M03_ACLK]
  connect_bd_net -net S01_ACLK_1 [get_bd_pins hier_emif/aclk] [get_bd_pins xdma_0_axi_periph/S01_ACLK]
  connect_bd_net -net eclk_0_1 [get_bd_ports eclk] [get_bd_pins hier_emif/eclk]
  connect_bd_net -net emif2axil_0_aresetn [get_bd_pins hier_emif/aresetn] [get_bd_pins xdma_0_axi_periph/S01_ARESETN]
  connect_bd_net -net emif2axil_0_busy [get_bd_ports busy] [get_bd_pins hier_emif/busy]
  connect_bd_net -net emif2axil_0_full [get_bd_ports full] [get_bd_pins hier_emif/full]
  connect_bd_net -net emif2axil_0_rd_fifo_empty [get_bd_ports rd_fifo_empty] [get_bd_pins hier_emif/rd_fifo_empty]
  connect_bd_net -net hog_mdl_only_axi_lite_0_rd1_wr1_done [get_bd_ports rdwr_done] [get_bd_pins hog_mdl_only_axi_lite_0/rd1_wr1_done]
  connect_bd_net -net reset_rtl_0_0_1 [get_bd_ports sys_nrst] [get_bd_pins hier_ddr/sys_nrst] [get_bd_pins hier_emif/sys_nrst] [get_bd_pins hier_srio/sys_nrst]
  connect_bd_net -net reset_rtl_0_1 [get_bd_ports pcie_nrst] [get_bd_pins hier_xdma/pcie_nrst]
  connect_bd_net -net rst_mig_7series_0_80M_peripheral_aresetn [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins hier_ddr/peripheral_aresetn1] [get_bd_pins hog_mdl_only_axi_lite_0/arest_n] [get_bd_pins xdma_0_axi_periph/M03_ARESETN]
  connect_bd_net -net rst_srio_gen2_0_156M_peripheral_aresetn [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins hier_srio/peripheral_aresetn] [get_bd_pins hier_xdma/ARESETN1] [get_bd_pins srio_pcie_bridge_0/aresetn] [get_bd_pins xdma_0_axi_periph/ARESETN] [get_bd_pins xdma_0_axi_periph/M00_ARESETN] [get_bd_pins xdma_0_axi_periph/M01_ARESETN]
  connect_bd_net -net srio_gen2_0_log_clk_out [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins hier_srio/log_clk_out] [get_bd_pins hier_xdma/ACLK1] [get_bd_pins srio_pcie_bridge_0/aclk] [get_bd_pins xdma_0_axi_periph/ACLK] [get_bd_pins xdma_0_axi_periph/M00_ACLK] [get_bd_pins xdma_0_axi_periph/M01_ACLK]
  connect_bd_net -net srio_gen2_0_srio_txn0 [get_bd_ports srio_txn0_0] [get_bd_pins hier_srio/srio_txn0_0]
  connect_bd_net -net srio_gen2_0_srio_txn1 [get_bd_ports srio_txn1_0] [get_bd_pins hier_srio/srio_txn1_0]
  connect_bd_net -net srio_gen2_0_srio_txn2 [get_bd_ports srio_txn2_0] [get_bd_pins hier_srio/srio_txn2_0]
  connect_bd_net -net srio_gen2_0_srio_txn3 [get_bd_ports srio_txn3_0] [get_bd_pins hier_srio/srio_txn3_0]
  connect_bd_net -net srio_gen2_0_srio_txp0 [get_bd_ports srio_txp0_0] [get_bd_pins hier_srio/srio_txp0_0]
  connect_bd_net -net srio_gen2_0_srio_txp1 [get_bd_ports srio_txp1_0] [get_bd_pins hier_srio/srio_txp1_0]
  connect_bd_net -net srio_gen2_0_srio_txp2 [get_bd_ports srio_txp2_0] [get_bd_pins hier_srio/srio_txp2_0]
  connect_bd_net -net srio_gen2_0_srio_txp3 [get_bd_ports srio_txp3_0] [get_bd_pins hier_srio/srio_txp3_0]
  connect_bd_net -net srio_pcie_bridge_0_usr_irq_req [get_bd_pins hier_xdma/usr_irq_req] [get_bd_pins srio_pcie_bridge_0/usr_irq_req]
  connect_bd_net -net srio_rxn0_0_1 [get_bd_ports srio_rxn0_0] [get_bd_pins hier_srio/srio_rxn0_0]
  connect_bd_net -net srio_rxn1_0_1 [get_bd_ports srio_rxn1_0] [get_bd_pins hier_srio/srio_rxn1_0]
  connect_bd_net -net srio_rxn2_0_1 [get_bd_ports srio_rxn2_0] [get_bd_pins hier_srio/srio_rxn2_0]
  connect_bd_net -net srio_rxn3_0_1 [get_bd_ports srio_rxn3_0] [get_bd_pins hier_srio/srio_rxn3_0]
  connect_bd_net -net srio_rxp0_0_1 [get_bd_ports srio_rxp0_0] [get_bd_pins hier_srio/srio_rxp0_0]
  connect_bd_net -net srio_rxp1_0_1 [get_bd_ports srio_rxp1_0] [get_bd_pins hier_srio/srio_rxp1_0]
  connect_bd_net -net srio_rxp2_0_1 [get_bd_ports srio_rxp2_0] [get_bd_pins hier_srio/srio_rxp2_0]
  connect_bd_net -net srio_rxp3_0_1 [get_bd_ports srio_rxp3_0] [get_bd_pins hier_srio/srio_rxp3_0]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins hier_ddr/ACLK] [get_bd_pins hier_xdma/ACLK] [get_bd_pins xdma_0_axi_periph/M02_ACLK] [get_bd_pins xdma_0_axi_periph/S00_ACLK]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins hier_ddr/ARESETN] [get_bd_pins hier_xdma/ARESETN] [get_bd_pins xdma_0_axi_periph/M02_ARESETN] [get_bd_pins xdma_0_axi_periph/S00_ARESETN]
  connect_bd_net -net xdma_0_usr_irq_ack [get_bd_pins hier_xdma/usr_irq_ack] [get_bd_pins srio_pcie_bridge_0/usr_irq_ack]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces hog_mdl_only_axi_lite_0/m_axi] [get_bd_addr_segs hier_ddr/mig_7series_0/memmap/memaddr] -force
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces srio_pcie_bridge_0/m_axi] [get_bd_addr_segs hier_ddr/mig_7series_0/memmap/memaddr] -force
  assign_bd_address -offset 0x44A30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces hier_emif/emif2axil_0/m_axil] [get_bd_addr_segs hog_mdl_only_axi_lite_0/s_axil/reg0] -force
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces hier_emif/emif2axil_0/m_axil] [get_bd_addr_segs hier_srio/srio_gen2_0/MAINT_IF/Reg] -force
  assign_bd_address -offset 0x44A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces hier_emif/emif2axil_0/m_axil] [get_bd_addr_segs srio_pcie_bridge_0/s_axil/reg0] -force
  assign_bd_address -offset 0x44A20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces hier_emif/emif2axil_0/m_axil] [get_bd_addr_segs hier_ddr/xadc_wiz_0/s_axi_lite/Reg] -force
  assign_bd_address -offset 0x44A30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces hier_xdma/xdma_0/M_AXI_LITE] [get_bd_addr_segs hog_mdl_only_axi_lite_0/s_axil/reg0] -force
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces hier_xdma/xdma_0/M_AXI_LITE] [get_bd_addr_segs hier_srio/srio_gen2_0/MAINT_IF/Reg] -force
  assign_bd_address -offset 0x44A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces hier_xdma/xdma_0/M_AXI_LITE] [get_bd_addr_segs srio_pcie_bridge_0/s_axil/reg0] -force
  assign_bd_address -offset 0x44A20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces hier_xdma/xdma_0/M_AXI_LITE] [get_bd_addr_segs hier_ddr/xadc_wiz_0/s_axi_lite/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


