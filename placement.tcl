#source Duy_Scripts/common_settings.tcl

open_mw_lib $my_mw_lib

copy_mw_cel -from_library $my_mw_lib -from ${DESIGN_NAME}_floorplan -to_library $my_mw_lib -to ${DESIGN_NAME}_placement

open_mw_cel ${DESIGN_NAME}_placement

current_mw_cel ${DESIGN_NAME}_placement
 
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}                                                                
set_object_snap_type -enabled false   

if { [all_macro_cells] != ""} {
        remove_keepout_margin all
        set_keepout_margin -type hard -all_macros -outer {13 13 13 13} ;#{lx by rx ty}
        set_keepout_margin -type soft -all_macros -outer {13 13 13 13}
}

remove_pnet_options
set_pnet_options -partial "M5 M6" ; #Allows standard cells to be placed under pnets, but the pins in the standard cells are checked to prevent shorts with the pnets.

set_ideal_network [all_fanout -flat -clock_tree]

place_opt -area_recovery -effort high

psynopt -power

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie
preroute_standard_cells -do_not_route_over_macros -remove_floating_pieces -extend_for_multiple_connections -extension_gap 2

preroute_focal_opt -high_fanout_nets -layer_optimization -effort high

report_design
report_design -physical
report_design_physical -utilization

save_mw_cel -as ${DESIGN_NAME}_placement

