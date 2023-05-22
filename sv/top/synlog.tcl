history clear
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/top/top.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/fifo.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/sramb.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/streamer/streamer.sv
project -run  
set_option -top_module ray_tracer_top
set_option -quartus_version 18.1
project -run  
project -close /home/jco1147/ray_tracer/github/RayTracer/sv/top/proj_1.prj
