
proc syn_dump_io {} {
	execute_module -tool cdb -args "--back_annotate=pin_device"
}

source "/vol/synopsys/fpga/O-2018.09-SP1/lib/altera/quartus_cons.tcl"
syn_create_and_open_prj streamer
source $::quartus(binpath)/prj_asd_import.tcl
syn_create_and_open_csf streamer
syn_handle_cons streamer
syn_dump_io
