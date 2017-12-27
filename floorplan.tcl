#source Duy_Scripts/common_settings.tcl

open_mw_lib $my_mw_lib

copy_mw_cel -from_library $my_mw_lib -from ${DESIGN_NAME}_init -to_library $my_mw_lib -to ${DESIGN_NAME}_floorplan

open_mw_cel ${DESIGN_NAME}_floorplan

current_mw_cel ${DESIGN_NAME}_floorplan

 
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}                                                                
set_object_snap_type -enabled false   

#########################################
##############Reset Design###############
#########################################
remove_route_by_type -pg_ring -pg_strap -pg_std_cell_pin_conn -pg_macro_io_pin_conn -pg_user -signal_global_route -signal_detail_route 
remove_placement_blockage *
remove_placement -object_type all
remove_stdcell_filler -pad

#########################################
###########Floorplan Variables###########
#########################################
set utilization "0.6" ;#utilization for initital_core
set aspect_ratio "1"

 
##### WIDE PG of TRAP-RING-MACRO
set num_ring 			"2" 	;#number of power/ground lines
set pg_ring_width 		"5" 	;#width power/ground of ring
set pg_trap_width		"0.5"	;#width power/ground of trap

set space2pg			"1"
set core2pg			"2" ;#distance from core to ring pg 
#########################################
############Create Floorplan#############
#########################################
create_floorplan -core_utilization $utilization -core_aspect_ratio $aspect_ratio
		
set io2core [expr $num_ring*($pg_ring_width+$space2pg)+$core2pg]

set left2core $io2core
set bottom2core $io2core
set right2core $io2core
set top2core $io2core

create_floorplan -control_type boundary -start_first_row -flip_first_row \
-left_io2core $left2core -bottom_io2core $bottom2core -right_io2core $right2core -top_io2core $top2core

#################################################
############Derive PG Connection#################
#################################################

derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -reconnect
derive_pg_connection -power_net VDD -ground_net VSS -tie

#################################################
#########Create power/ground ring for ip#########
#################################################
set s_offset $core2pg

create_rectangular_rings  -nets  {VDD} \
-left_segment_layer M5 -left_segment_width $pg_ring_width -extend_ll -extend_lh \
-right_segment_layer M5 -right_segment_width $pg_ring_width -extend_rl -extend_rh \
-bottom_segment_layer M6 -bottom_segment_width $pg_ring_width -extend_bl -extend_bh \
-top_segment_layer M6 -top_segment_width $pg_ring_width -extend_tl -extend_th \
-left_offset $s_offset -right_offset $s_offset -bottom_offset $s_offset -top_offset $s_offset -offset absolute	

set s_offset [expr $space2pg + $s_offset + $pg_ring_width]	

create_rectangular_rings  -nets  {VSS} \
-left_segment_layer M5 -left_segment_width $pg_ring_width -extend_ll -extend_lh \
-right_segment_layer M5 -right_segment_width $pg_ring_width -extend_rl -extend_rh \
-bottom_segment_layer M6 -bottom_segment_width $pg_ring_width -extend_bl -extend_bh \
-top_segment_layer M6 -top_segment_width $pg_ring_width -extend_tl -extend_th \
-left_offset $s_offset -right_offset $s_offset -bottom_offset $s_offset -top_offset $s_offset -offset absolute	

#########################################
############Create PG Straps#############
#########################################
create_power_straps \
         -nets {VDD VSS} \
         -direction vertical \
         -layer M5 \
         -width 2 \
         -start_at 30 \
         -num_placement_strap 3 \
         -increment_x_or_y 50 \
 	 -extend_low_ends to_first_target -extend_high_ends to_first_target

create_power_straps \
         -nets {VDD VSS} \
         -direction horizontal \
         -layer M6 \
         -width 2 \
         -start_at 30 \
         -num_placement_strap 3 \
         -increment_x_or_y 50 \
	 -extend_for_multiple_connections  -extension_gap 2

#################################################
################Pre-route PG#####################
#################################################
preroute_standard_cells -do_not_route_over_macros -remove_floating_pieces -extend_for_multiple_connections -extension_gap 2

preroute_instances -undo

#####
#preroute_instances  -ignore_macros -ignore_cover_cells -connect_instances specified -cells [get_cells -all {vdd1* vss1*}] \
#-route_pins_on_layer $M2 -primary_routing_layer pin \
#-skip_right_side -skip_left_side \
#-extend_for_multiple_connections -extension_gap 2
#
#preroute_instances  -ignore_macros -ignore_cover_cells -connect_instances specified -cells [get_cells -all {vdd1* vss1*}] \
#-route_pins_on_layer $M3 -primary_routing_layer pin \
#-extend_for_multiple_connections -extension_gap 2 \
#-skip_bottom_side -skip_top_side 

save_mw_cel -as ${DESIGN_NAME}_floorplan
#
