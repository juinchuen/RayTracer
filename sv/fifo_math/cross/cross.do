setenv LMC_TIMEUNIT -9
vlib work 
vmap work work

# compile
vlog -work work "../../fifo.sv"
vlog -work work "../fifo_array.sv"
vlog -work work "cross.sv"
vlog -work work "cross_tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.tb -wlf cross.wlf


# wave
add wave -noupdate -group tb
add wave -noupdate -group tb -radix hexadecimal /tb/*
add wave -noupdate -group tb/fifo_array_x
add wave -noupdate -group tb/fifo_array_x -radix hexadecimal /tb/fifo_array_x/*
add wave -noupdate -group tb/fifo_array_y
add wave -noupdate -group tb/fifo_array_y -radix hexadecimal /tb/fifo_array_y/*
add wave -noupdate -group tb/u_cross
add wave -noupdate -group tb/u_cross -radix hexadecimal /tb/u_cross/*

add wave -noupdate -group tb/u_cross/u_cross_module
add wave -noupdate -group tb/u_cross/u_cross_module -radix hexadecimal /tb/u_cross/u_cross_module/*

run -all