#########################
######Design Setup#######
#########################
#source Duy_Scripts/common_settings.tcl
close_mw_lib
file delete -force $my_mw_lib

create_mw_lib $my_mw_lib -open -technology $tech_file -mw_reference_library $mw_ref_libs

import_designs $verilog_file -format verilog -top $DESIGN_NAME

set_tlu_plus_files -max_tluplus $tlup_max -min_tluplus $tlup_min -tech2itf_map $tlup_map

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie

#source Duy_Scripts/opt_ctrl.tcl

read_sdc $sdc_file

save_mw_cel -as ${DESIGN_NAME}_init
