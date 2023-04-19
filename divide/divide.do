setenv LMC_TIMEUNIT -9
vlib work 
vmap work work

# compile
vlog -work work "divide.sv"
vlog -work work "tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.tb -wlf divide.wlf


# wave
add wave -noupdate -group tb
add wave -noupdate -group tb -radix hexadecimal /tb/*
add wave -noupdate -group tb/divide_inst
add wave -noupdate -group tb/divide_inst -radix hexadecimal /tb/divide_inst/*

run -all