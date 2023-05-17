setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -work work "dummy_memory_tb.sv"
vlog -work work "dummy_memory.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.memory_tb -wlf memory_tb.wlf

# wave
add wave -noupdate -group tb_wires
add wave -noupdate -group tb_wires -radix decimal /memory_tb/*

add wave -noupdate -group tb_wires -radix hexadecimal /memory_tb/data_out


run -all