#include<stdio.h>
#include<stdlib.h>
#include"bmp.h"
#include"ray_tracer.h"



int main_test() {

	float eye[] = { 0.0, 0.0, 0.0 };
	float dir[] = { 1.0, 0.0, 0.0 };

	float start_pos[] = {0.0, 0.0, 0.0};
	float x_incr[] = { 0.0, 0.0, 0.0 };
	float y_incr[] = { 0.0, 0.0, 0.0 };

	int res[] = { 256, 256 };
	float size[] = { 2.0, 2.0 };

	char* img_buf = initialize_img_buffer(256, 256, 24);

	frame_vectors(start_pos, x_incr, y_incr, eye, dir, res, size, 4);

	//print_vector(start_pos);
	//print_vector(x_incr);
	//print_vector(y_incr);

	float triangle[] = { 6, -0.5, -0.5,
						 5,  0.5,  1.0,
						 5, -0.5,  1.0 };

	float triangle_normal[] = {0.8321, 0, 0.5547};

	float ray_origin[] = { 0.0, 0.0, 0.0 };
	float x_offset[] = { 0.0, 0.0, 0.0 };
	float y_offset[] = { 0.0, 0.0, 0.0 };
	float ray_dir[] = { 0.0, 0.0, 0.0 };
	
	float p_hit[] = { 0.0, 0.0, 0.0 };
	float distance[] = { 0.0, 0.0, 0.0 };
	bool hit;

	for (int i = 0; i < 256; i++) {

		for (int j = 0; j < 256; j++) {

			scale(x_offset, x_incr, j);
			scale(y_offset, y_incr, i);

			add(ray_origin, start_pos, x_offset);
			add(ray_origin, ray_origin, y_offset);

			subtract(ray_dir, ray_origin, eye);
			normalize(ray_dir, ray_dir);

			hit = ray_triangle_intersect(p_hit, triangle, triangle_normal, ray_origin, ray_dir);

			if (hit) {

				subtract(distance, p_hit, eye);

				*(img_buf + 3 * (256 * i + j) + 1) = 0xFF;

			}

		}

	}

	write_bmp(img_buf, 256, 256, 24, "ray_trace_example.bmp");

}