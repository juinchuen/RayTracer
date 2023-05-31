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

#   dependencies for shader
vlog -work work "../shader/shader.sv"
vlog -work work "dummy_memory.sv"

# dependencies for hit_bool
vlog -work work "../hit_bool/hit_bool.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.top_tb -wlf top_tb.wlf

# wave
add wave -noupdate -group ALLES -radix hexadecimal /top_tb/*

add wave -noupdate -group SHADER -radix hexadecimal /top_tb/DUT_INST0/SHADE0/state
add wave -noupdate -group SHADER -radix hexadecimal /top_tb/DUT_INST0/SHADE0/read_hit
add wave -noupdate -group SHADER -radix hexadecimal /top_tb/DUT_INST0/SHADE0/read_triangle_ID
add wave -noupdate -group SHADER -radix hexadecimal /top_tb/DUT_INST0/SHADE0/wr_en_in
add wave -noupdate -group SHADER -radix hexadecimal /top_tb/DUT_INST0/SHADE0/triangle_parse
add wave -noupdate -group SHADER -radix hexadecimal /top_tb/DUT_INST0/SHADE0/pix_val
add wave -noupdate -group SHADER -radix hexadecimal /top_tb/DUT_INST0/SHADE0/out_wr_en
add wave -noupdate -group SHADER -radix hexadecimal /top_tb/DUT_INST0/SHADE0/pixel


run -all