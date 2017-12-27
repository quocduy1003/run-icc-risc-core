#########################
####Common Variables#####
#########################
set DESIGN_NAME         "RISC_CORE"     ;#  The name of the top-level design
set input               "../synthesis/results"

set my_mw_lib $DESIGN_NAME.mw
set tech_file ../libs/astro2/tech/astroTechFile.tf

set tlup_map  ../libs/astro2/tech/tech2itf.map
set tlup_max  ../libs/star_rcxt/tluplus/saed90nm_1p9m_1t_Cmax.tluplus
set tlup_min  ../libs/star_rcxt/tluplus/saed90nm_1p9m_1t_Cmin.tluplus

set verilog_file        $input/$DESIGN_NAME.mapped.v
set sdc_file            $input/$DESIGN_NAME.mapped.sdc
#set ddc_file            ""
#set scandef_file        ""

#set lib_max {}
#set lib_min {}
#set lib_typ {}
#set search_path {}
#set target_library {}
#set link_library {}

#########################
#####Logic Libraries#####
#########################
set sc_max saed90nm_max_lth 
set sc_min saed90nm_min_lth
set sc_typ saed90nm_typ_lth

lappend search_path ../libs/models

set target_library $sc_max.db

###Standard Cell###
lappend link_library \
	$sc_max.db

#lappend lib_max $sc_max.db
#lappend lib_min $sc_min.db
#lappend lib_typ $sc_typ.db


#########################
###Physical Libraries####
#########################

###Standard Cell###
set     mw_ref_libs ../libs/astro2/fram/saed90nm_fr

##########################
set_host_options -max_cores 4
##########################
if { ![file exists cmd]} {sh mkdir cmd}
if { ![file exists reports]} {sh mkdir reports}


