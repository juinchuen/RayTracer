setenv LMC_TIMEUNIT -9
vlib work 
vmap work work

# compile
vlog -work work "../../fifo.sv"
vlog -work work "../fifo_array.sv"
vlog -work work "add.sv"
vlog -work work "add_tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.tb -wlf add.wlf


# wave
add wave -noupdate -group tb
add wave -noupdate -group tb -radix hexadecimal /tb/*
add wave -noupdate -group tb/fifo_array_x
add wave -noupdate -group tb/fifo_array_x -radix hexadecimal /tb/fifo_array_x/*
add wave -noupdate -group tb/fifo_array_y
add wave -noupdate -group tb/fifo_array_y -radix hexadecimal /tb/fifo_array_y/*
add wave -noupdate -group tb/u_add
add wave -noupdate -group tb/u_add -radix hexadecimal /tb/u_add/*

add wave -noupdate -group tb/u_add/u_add_module
add wave -noupdate -group tb/u_add/u_add_module -radix hexadecimal /tb/u_add/u_add_module/*

# add wave -noupdate -group tb/u_divide_top/u_divide_module
# add wave -noupdate -group tb/u_divide_top/u_divide_module -radix hexadecimal /tb/u_divide_top/u_divide_module/*

run -all