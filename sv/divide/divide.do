setenv LMC_TIMEUNIT -9
vlib work 
vmap work work

# compile
vlog -work work "../fifo.sv"
vlog -work work "divide.sv"
vlog -work work "divide_top.sv"
vlog -work work "tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.tb -wlf divide.wlf


# wave
add wave -noupdate -group tb
add wave -noupdate -group tb -radix hexadecimal /tb/*
add wave -noupdate -group tb/fifo_in_1
add wave -noupdate -group tb/fifo_in_1 -radix hexadecimal /tb/fifo_in_1/*
add wave -noupdate -group tb/fifo_in_2
add wave -noupdate -group tb/fifo_in_2 -radix hexadecimal /tb/fifo_in_2/*
add wave -noupdate -group tb/u_divide_top
add wave -noupdate -group tb/u_divide_top -radix hexadecimal /tb/u_divide_top/*

add wave -noupdate -group tb/u_divide_top/u_divide_module
add wave -noupdate -group tb/u_divide_top/u_divide_module -radix hexadecimal /tb/u_divide_top/u_divide_module/*

run -all