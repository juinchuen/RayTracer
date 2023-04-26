setenv LMC_TIMEUNIT -9
vlib work 
vmap work work

# compile
vlog -work work "../../fifo.sv"
vlog -work work "../fifo_array.sv"
vlog -work work "scale.sv"
vlog -work work "scale_tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.tb -wlf scale.wlf


# wave
add wave -noupdate -group tb
add wave -noupdate -group tb -radix hexadecimal /tb/*
add wave -noupdate -group tb/fifo_array_x
add wave -noupdate -group tb/fifo_array_x -radix hexadecimal /tb/fifo_array_x/*
add wave -noupdate -group tb/fifo_y
add wave -noupdate -group tb/fifo_y -radix hexadecimal /tb/fifo_y/*
add wave -noupdate -group tb/u_scale
add wave -noupdate -group tb/u_scale -radix hexadecimal /tb/u_scale/*

add wave -noupdate -group tb/u_scale/u_scale_module
add wave -noupdate -group tb/u_scale/u_scale_module -radix hexadecimal /tb/u_scale/u_scale_module/*

# add wave -noupdate -group tb/u_divide_top/u_divide_module
# add wave -noupdate -group tb/u_divide_top/u_divide_module -radix hexadecimal /tb/u_divide_top/u_divide_module/*

run -all