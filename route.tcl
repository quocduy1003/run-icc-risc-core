#source Duy_Scripts/common_settings.tcl

open_mw_lib $my_mw_lib

copy_mw_cel -from_library $my_mw_lib -from ${DESIGN_NAME}_cts -to_library $my_mw_lib -to ${DESIGN_NAME}_route

open_mw_cel ${DESIGN_NAME}_route

current_mw_cel ${DESIGN_NAME}_route
 
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}                                                                
set_object_snap_type -enabled false 

set_si_options -delta_delay true \
        -static_noise true \
        -timing_window true \
        -reselect true \
        -min_delta_delay true \
        -static_noise_threshold_above_low 0.2 \
        -static_noise_threshold_below_high 0.2 \
        -route_xtalk_prevention true \
        -route_xtalk_prevention_threshold 0.2 \
        -analysis_effort medium \
        -max_transition_mode total_slew

route_opt -initial_route_only
insert_zrt_redundant_vias -effort high; #Replaces  single-cut  vias with multiple-cut via arrays

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie

update_timing

route_opt -skip_initial_route -effort high -xtalk_reduction

#############################################
###########Incremental Routing###############
#############################################

#route_opt -incremental -only_hold_time
#route_opt -incremental -only_xtalk_reduction
#route_opt -incremental -only_area_recovery
#route_opt -incremental -only_power_recovery
#route_opt -incremental -only_design_rule

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie

save_mw_cel -as ${DESIGN_NAME}_route
