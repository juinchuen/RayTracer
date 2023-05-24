setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -work work "../sramb.sv"
vlog -work work "../streamer/streamer.sv"
vlog -work work "../fifo.sv"
vlog -work work "top.sv"
vlog -work work "top_tb.sv"
vlog -work work "../accumulate/accumulate_v2.sv"

# dependencies for p_hit
vlog -work work "../fifo_math.sv"
vlog -work work "../divide/divide.sv"
vlog -work work "../divide/divide_top.sv"
vlog -work work "../p_hit/p_hit_1.sv"
vlog -work work "../p_hit/p_hit_2.sv"

# dependencies for hit_bool
vlog -work work "../hit_bool/hit_bool.sv"
vlog -work work "../hit_bool/hit_bool_tb.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.top_tb -wlf top_tb.wlf

# wave
add wave -noupdate -group ALLES -radix hexadecimal /top_tb/*

add wave -noupdate -group IO -radix hexadecimal /top_tb/ray_data_feed
add wave -noupdate -group IO -radix hexadecimal /top_tb/instruction_read
add wave -noupdate -group IO -radix hexadecimal /top_tb/DUT_INST0/wr_streamer_phit
add wave -noupdate -group IO -radix hexadecimal /top_tb/DUT_INST0/addr_streamer_mem

add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/empty_fifo0_streamer
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/ray_parse_fifo0_streamer
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/full_phit_streamer
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/rd_streamer_fifo0
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/wr_streamer_phit
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/instruction_read
add wave -noupdate -group S2P -radix hexadecimal /top_tb/DUT_INST0/triangle_ID_streamer_phit

add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/tri_normal_in
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/v0_in
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/v1_in
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/v2_in
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/origin
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/dir
add wave -noupdate -group P_HIT -radix hexadecimal /top_tb/DUT_INST0/P_HIT0/triangle_id_in

add wave -noupdate -group STREAM -radix hexadecimal /top_tb/DUT_INST0/STREAMER0/ray_in
add wave -noupdate -group STREAM -radix hexadecimal /top_tb/DUT_INST0/STREAMER0/state
add wave -noupdate -group STREAM -radix hexadecimal /top_tb/DUT_INST0/STREAMER0/instruction_out
add wave -noupdate -group STREAM -radix hexadecimal /top_tb/DUT_INST0/STREAMER0/out_wr_en
add wave -noupdate -group STREAM -radix hexadecimal /top_tb/DUT_INST0/STREAMER0/in_empty
add wave -noupdate -group STREAM -radix hexadecimal /top_tb/DUT_INST0/STREAMER0/in_rd_en
add wave -noupdate -group STREAM -radix hexadecimal /top_tb/DUT_INST0/STREAMER0/triangle_ID_out

add wave -noupdate -group OUTPUT -radix hexadecimal /top_tb/DUT_INST0/hit_acc_shader
add wave -noupdate -group OUTPUT -radix hexadecimal /top_tb/DUT_INST0/phit_acc_shader
add wave -noupdate -group OUTPUT -radix hexadecimal /top_tb/DUT_INST0/triangle_ID_acc_shader
add wave -noupdate -group OUTPUT -radix hexadecimal /top_tb/DUT_INST0/wr_acc_shader

add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/out_wr_en
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/state
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/hit_min
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/p_hit_min
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/triangle_ID_min
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/read_hit
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/read_p_hit
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/read_triangle_ID
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/start_up_flag
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/d2_min
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/d2
add wave -noupdate -group ACC -radix hexadecimal /top_tb/DUT_INST0/ACC0/p_hit_squared

add wave -noupdate -group P2H -radix hexadecimal /top_tb/DUT_INST0/phit_phit_hitb
add wave -noupdate -group P2H -radix hexadecimal /top_tb/DUT_INST0/v0_phit_hitb
add wave -noupdate -group P2H -radix hexadecimal /top_tb/DUT_INST0/v1_phit_hitb
add wave -noupdate -group P2H -radix hexadecimal /top_tb/DUT_INST0/v2_phit_hitb
add wave -noupdate -group P2H -radix hexadecimal /top_tb/DUT_INST0/triangle_ID_phit_hitb
add wave -noupdate -group P2H -radix hexadecimal /top_tb/DUT_INST0/normal_phit_hitb
add wave -noupdate -group P2H -radix hexadecimal /top_tb/DUT_INST0/rd_hitb_phit



run -all