# Run with quartus_sh -t <x_cons.tcl>

# Global assignments 
set_global_assignment -name TOP_LEVEL_ENTITY "|ray_tracer_top"
set_global_assignment -name ROUTING_BACK_ANNOTATION_MODE NORMAL
set_global_assignment -name FAMILY "CYCLONE V"
set_global_assignment -name DEVICE "5CSEBA6U23A7"
set_global_assignment -section_id ray_tracer_top -name EDA_DESIGN_ENTRY_SYNTHESIS_TOOL "SYNPLIFY"
set_global_assignment -section_id eda_design_synthesis -name EDA_USE_LMF synplcty.lmf
set_global_assignment -name TAO_FILE "myresults.tao"
set_global_assignment -name SOURCES_PER_DESTINATION_INCLUDE_COUNT "1000" 
#set_global_assignment -name EDA_RESYNTHESIS_TOOL "AMPLIFY"
set_global_assignment -name ENABLE_CLOCK_LATENCY "ON"
set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER ON
set_global_assignment -name SDC_FILE "hit_bool.scf"

if {[file exists intel_par_option.tcl]} {
	source intel_par_option.tcl
}
if {[file exists altera_par.tcl]} {
	source altera_par.tcl
}
if {[file exists ___quartus_options.tcl]} {
	source ___quartus_options.tcl
}


# Incremental Compilation
    # this will synchronize any existing partitions declared in Synpilfy
    # with partitions existing in Quartus. If partitions exist,
    # incremental compilation will be enabled
     set Design_Name "ray_tracer_top" 
    variable compile_point_list
    set compile_point_list [list]
    source "/vol/synopsys/fpga/O-2018.09-SP1/lib/altera/qic.tcl"
