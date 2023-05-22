setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -work work "../sramb.sv"
vlog -work work "../streamer/streamer.sv"
vlog -work work "../fifo.sv"
vlog -work work "top.sv"
vlog -work work "top_tb.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.top_tb -wlf top_tb.wlf

# wave
add wave -noupdate -group ALLES -radix hexadecimal /top_tb/*

add wave -noupdate -group IO -radix hexadecimal /top_tb/ray_in
add wave -noupdate -group IO -radix hexadecimal /top_tb/instruction_read
add wave -noupdate -group IO -radix hexadecimal /top_tb/DUT_INST0/wr_streamer_phit
add wave -noupdate -group IO -radix hexadecimal /top_tb/DUT_INST0/addr_streamer_mem


run -all