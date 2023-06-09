setenv LMC_TIMEUNIT -9
vlib work 
vmap work work

# compile
vlog -work work "../fifo.sv"
vlog -work work "../fifo_math.sv"
vlog -work work "hit_bool.sv"
vlog -work work "hit_bool_tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.hit_bool_tb -wlf hit_bool_tb.wlf

# wave
add wave -noupdate -group hit_bool_tb
add wave -noupdate -group hit_bool_tb -radix hexadecimal /hit_bool_tb/*
add wave -noupdate -group hit_bool_tb/p_hit_fifo_array
add wave -noupdate -group hit_bool_tb/p_hit_fifo_array -radix hexadecimal /hit_bool_tb/p_hit_fifo_array/*
add wave -noupdate -group hit_bool_tb/u_hit_bool
add wave -noupdate -group hit_bool_tb/u_hit_bool -radix hexadecimal /hit_bool_tb/u_hit_bool/*

add wave -noupdate -group hit_bool_tb/u_hit_bool/u_hit_bool_fifo
add wave -noupdate -group hit_bool_tb/u_hit_bool -radix hexadecimal /hit_bool_tb/u_hit_bool/u_hit_bool_fifo/*

#add wave -noupdate -group hit_bool_tb/u_hit_bool/u_sub_3
#add wave -noupdate -group hit_bool_tb/u_hit_bool -radix hexadecimal /hit_bool_tb/u_hit_bool/u_sub_3/*


run -all