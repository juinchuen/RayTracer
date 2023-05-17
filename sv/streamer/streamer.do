setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -work work "streamer_tb.sv"
vlog -work work "streamer.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.streamer_tb -wlf streamer_tb.wlf

# wave
add wave -noupdate -group streamer_tb
add wave -noupdate -group streamer_tb -radix decimal /streamer_tb/*
add wave -noupdate -group streamer_tb -radix decimal /streamer_tb/DUT_INST0/*


add wave -noupdate -group streamer_tb -radix decimal /streamer_tb/mem_data
add wave -noupdate -group streamer_tb -radix decimal /streamer_tb/ray_in
add wave -noupdate -group streamer_tb -radix decimal /streamer_tb/instruction_out


run -all