setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -work work "acc_tb.sv"
vlog -work work "accumulate.sv"
vlog -work work "../fifo.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.acc_tb -wlf acc_tb.wlf

# wave
add wave -noupdate -group acc_tb
add wave -noupdate -group acc_tb -radix decimal /acc_tb/*
add wave -noupdate -group acc_tb -radix decimal /acc_tb/read_p_hit
add wave -noupdate -group acc_tb -radix decimal /acc_tb/write_p_hit
add wave -noupdate -group acc_tb -radix decimal /acc_tb/p_hit_min

add wave -noupdate -group acc_tb -radix decimal /acc_tb/DUT_INST0/d2
add wave -noupdate -group acc_tb -radix decimal /acc_tb/DUT_INST0/state

#add wave -noupdate -group acc_tb -radix decimal /acc_tb/fifo_in_0/*
#add wave -noupdate -group acc_tb -radix decimal /acc_tb/fifo_in_1/*
#add wave -noupdate -group acc_tb -radix decimal /acc_tb/fifo_in_2/*

run -all