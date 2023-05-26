history clear
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/top/top.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/accumulate/accumulate_v2.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/sramb.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/streamer/streamer.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/fifo.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/fifo_math.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/divide/divide.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/divide/divide_top.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/p_hit/p_hit_1.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/p_hit/p_hit_2.sv
add_file -verilog /home/jco1147/ray_tracer/github/RayTracer/sv/hit_bool/hit_bool.sv
project -run  
project -save proj_1 /home/jco1147/ray_tracer/github/RayTracer/sv/top/top.prj
project -close /home/jco1147/ray_tracer/github/RayTracer/sv/top/top.prj
