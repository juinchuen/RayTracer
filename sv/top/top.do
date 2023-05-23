setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -work work "../sramb.sv"
vlog -work work "../streamer/streamer.sv"
vlog -work work "../fifo.sv"
vlog -work work "top.sv"
vlog -work work "top_tb.sv"
vlog -work work "../accumulate/accumulate_v2.sv"

# dependencies for p_hit
vlog -work work "../fifo_math.sv"
vlog -work work "../divide/divide.sv"
vlog -work work "../divide/divide_top.sv"
vlog -work work "../p_hit/p_hit_1.sv"
vlog -work work "../p_hit/p_hit_2.sv"

# dependencies for hit_bool
vlog -work work "../hit_bool/hit_bool.sv"
vlog -work work "../hit_bool/hit_bool_tb.sv"



vsim -classdebug -voptargs=+acc +notimingchecks -L work work.top_tb -wlf top_tb.wlf

# wave
add wave -noupdate -group ALLES -radix hexadecimal /top_tb/*

add wave -noupdate -group IO -radix hexadecimal /top_tb/ray_data_feed
add wave -noupdate -group IO -radix hexadecimal /top_tb/instruction_read
add wave -noupdate -group IO -radix hexadecimal /top_tb/DUT_INST0/wr_streamer_phit
add wave -noupdate -group IO -radix hexadecimal /top_tb/DUT_INST0/addr_streamer_mem

add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/empty_fifo0_streamer
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/ray_parse_fifo0_streamer
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/full_phit_streamer
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/rd_streamer_fifo0
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/wr_streamer_phit

add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/all_full
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/reset
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/in_full
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/in_full_arr
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/all_full



run -all