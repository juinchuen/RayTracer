setenv LMC_TIMEUNIT -9
vlib work 
vmap work work

# compile
vlog -work work "../fifo.sv"
vlog -work work "../basic_math.sv"
vlog -work work "hit_bool.sv"
vlog -work work "hit_bool_tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.hit_bool_tb -wlf hit_bool_tb.wlf

# wave
add wave -noupdate -group hit_bool_tb
add wave -noupdate -group hit_bool_tb -radix hexadecimal /hit_bool_tb/*
add wave -noupdate -group hit_bool_tb/u_hit_bool
add wave -noupdate -group hit_bool_tb/u_hit_bool -radix hexadecimal /hit_bool_tb/u_hit_bool/*
add wave -noupdate -group hit_bool_tb/u_fifo_in
add wave -noupdate -group hit_bool_tb/u_fifo_in -radix hexadecimal /hit_bool_tb/u_fifo_in/*
add wave -noupdate -group hit_bool_tb/u_fifo_out
add wave -noupdate -group hit_bool_tb/u_fifo_out -radix hexadecimal /hit_bool_tb/u_fifo_out/*

run -all