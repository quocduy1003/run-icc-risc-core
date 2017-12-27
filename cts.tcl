#source Duy_Scripts/common_settings.tcl

open_mw_lib $my_mw_lib

copy_mw_cel -from_library $my_mw_lib -from ${DESIGN_NAME}_placement -to_library $my_mw_lib -to ${DESIGN_NAME}_cts

open_mw_cel ${DESIGN_NAME}_cts

current_mw_cel ${DESIGN_NAME}_cts
 
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}                                                                
set_object_snap_type -enabled false   

reset_clock_tree_references
remove_ideal_network [all_fanout -flat -clock_tree]

define_routing_rule NDR_double_spacing -default_reference_rule -multiplier_spacing 2
#A net is considered as leaf net if it drives at least one flip-flop or latch clock input pin that is a sink pin or float or stop pin

##############################################
################CTS Options###################
##############################################

set_clock_tree_options -layer_list M2 M3 M4 ; #Specifies the layers that can be used for routing the clock nets in  the  specified clock trees
set_clock_tree_options -layer_list_for_sinks M2 M3 M4 ; #Specifies the layers that can be used for routing the clock leaf nets in the specified clock trees
set_clock_tree_options -target_early_delay 0 ; # Specifies the minimum insertion delay constraint in design unit for the specified clock trees
set_clock_tree_options -target_skew 0 ; #Specifies the required value for maximum skew in design unit for the specified clock trees.
set_clock_tree_options -max_capacitance 0.6 ; #Specifies the maximum capacitance design rule constraint in main library units for the specified clock trees
set_clock_tree_options -max_transition 0.5 ; #Specifies  the maximum transition time design rule constraint in main library unit for the buffers and inverters used while  compiling the specified clock trees
set_clock_tree_options -max_fanout 20
#set_clock_tree_options -max_rc_delay_constraint 0 ; #Specifies the maximum RC delay constraint from a driver pin to each receiver pin while compiling the specified clock trees. This constraint is for  the  delay  from a driver pin to each receiver pin.
#set_clock_tree_options -max_rc_scale_factor scale_factor; #Enables  the  maximum  RC delay constraint by specifying a scale factor while compiling the specified clock trees.  The  true  RC delay  constraint is determined by multiplying this scale factor by an internally derived RC delay. This constraint  is  for  the delay from a driver pin to each receiver pin.
set_clock_tree_options -routing_rule NDR_double_spacing ; #Specifies  the  nondefault  routing  rule to be used for routing nets in the specified clock trees.
set_clock_tree_options -use_default_routing_for_sinks 1 ; #Forces the default routing rule to be used on the leaf nets that drive the clock tree sinks and nets at the bottom n-1 levels  ofthe  clock tree.
#set_clock_tree_options -routing_rule_for_sinks rule_name ; #Specifies the nondefault routing rule to  be  used  for  routing clock  leaf nets in the specified clock trees. This option over-rides the -routing_rule option  when  routing  leaf-level clock nets, if both options are specified.
set_clock_tree_options -buffer_relocation true 
set_clock_tree_options -buffer_sizing true 
set_clock_tree_options -gate_relocation true 
set_clock_tree_options -gate_sizing false 
set_clock_tree_options -logic_level_balance false 
#set_clock_tree_options -ocv_clustering false 
#set_clock_tree_options -ocv_path_sharing true 
#set_clock_tree_options -advanced_drc_fixing false 
#set_clock_tree_options -config_file_read file_name 
#set_clock_tree_options -config_file_write file_name 
set_clock_tree_options -operating_condition max

##############################################
############Clock_Opt only CTS################
##############################################
clock_opt -only_cts -no_clock_route

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie

##############################################
############Clock_Opt only Psyn###############
##############################################
set_fix_hold [all_clocks]
set_fix_hold_options -preferred_buffer

set_app_var timing_remove_clock_reconvergence_pessimism true

clock_opt -no_clock_route -only_psyn -area_recovery

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie

##############################################
###########Clock_Opt only Route##############
##############################################
route_zrt_group -all_clock_nets -max_detail_route_iterations 40 -reuse_existing_global_route true -stop_after_global_route true -route_nondefault_nets_first true

preroute_focal_opt -setup_endpoints all -effort high
preroute_focal_opt -hold_endpoints all -effort high
preroute_focal_opt -high_fanout_nets -effort high
preroute_focal_opt -layer_optimization -effort high

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie

route_zrt_group -all_clock_nets -max_detail_route_iterations 40 -reuse_existing_global_route true -stop_after_global_route false -route_nondefault_nets_first true

optimize_clock_tree -routed_clock_stage detail

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie

save_mw_cel -as ${DESIGN_NAME}_cts 
