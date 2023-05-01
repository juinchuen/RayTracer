setenv LMC_TIMEUNIT -9
vlib work 
vmap work work

# compile
vlog -work work "../fifo.sv"
vlog -work work "../fifo_math/fifo_array.sv"
vlog -work work "../fifo_math/dot/dot.sv"
vlog -work work "../fifo_math/subtract/sub.sv"
vlog -work work "../divide/divide.sv"
vlog -work work "p_hit_1.sv"
vlog -work work "p_hit_1_tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.tb -wlf divide.wlf


# wave
add wave -noupdate -group tb
add wave -noupdate -group tb -radix hexadecimal /tb/*
add wave -noupdate -group tb/u_p_hit_1
add wave -noupdate -group tb/u_p_hit_1 -radix hexadecimal /tb/u_p_hit_1/*
# add wave -noupdate -group tb/fifo_array_y
# add wave -noupdate -group tb/fifo_array_y -radix hexadecimal /tb/fifo_array_y/*
# add wave -noupdate -group tb/u_dot
# add wave -noupdate -group tb/u_dot -radix hexadecimal /tb/u_dot/*

# add wave -noupdate -group tb/u_dot/u_dot_module
# add wave -noupdate -group tb/u_dot/u_dot_module -radix hexadecimal /tb/u_dot/u_dot_module/*

# add wave -noupdate -group tb/u_divide_top/u_divide_module
# add wave -noupdate -group tb/u_divide_top/u_divide_module -radix hexadecimal /tb/u_divide_top/u_divide_module/*

run -all