#include "bmp.h"
#include "ray_tracer.h"
#include "obj_parser.h"

#include <stdio.h>
#include <stdlib.h>

#define x_res 64
#define y_res 64

int main() {

	//lopunny camera
	//float eye[] = { -70.0, -2.0, 10.0 };
	
	//tree camera
	//float eye[] = { -30.0, 0.0, 5.0 };
	
	//cube camera
	float eye[] = {-10.0, 0.0, 1.0};
	
	float dir[] = { 1.0, 0.0, 0.0 };
	float up[] = {0.0, 0.0, 1.0};

	float start_pos[3] = {0.0};
	float x_incr[3] = {0.0};
	float y_incr[3] = {0.0};

	int res[] = { x_res, y_res };
	float size[] = { 2.0, 2.0 };

	char* img_buf = initialize_img_buffer(res[0], res[1], 24);
	
	float* z_buf = calloc(x_res * y_res, sizeof(float));

	float dist_vec[] = {0.0};
	float dist;
	float pix_val_f;
	char pix_val;
	
	//size_t t_hit_buf [x_res][y_res];
	
	size_t* t_hit_buf = calloc(x_res * y_res, sizeof(size_t));
	
	initialize_z_buffer(z_buf, x_res * y_res);

	frame_vectors(start_pos, x_incr, y_incr, eye, dir, res, size, 4);

	//print_vector(start_pos);
	//print_vector(x_incr);
	//print_vector(y_incr);
	
	float triangle_buf[triangle_limit * 12];
	
	int triangle_index = obj_parser(triangle_buf, "cube.obj");

	//for (int i = 0; i < triangle_index; i++){
		
		//printf("Vertex 1: %10.2f %10.2f %10.2f\n", triangle_buf[i * 12 + 0],
												   //triangle_buf[i * 12 + 1],
												   //triangle_buf[i * 12 + 2]);
		
		//printf("Vertex 2: %10.2f %10.2f %10.2f\n", triangle_buf[i * 12 + 3],
												   //triangle_buf[i * 12 + 4],
												   //triangle_buf[i * 12 + 5]);
												   
		//printf("Vertex 3: %10.2f %10.2f %10.2f\n", triangle_buf[i * 12 + 6],
												   //triangle_buf[i * 12 + 7],
												   //triangle_buf[i * 12 + 8]);
												   
		//printf("Normal\t: %10.2f %10.2f %10.2f\n\n", triangle_buf[i * 12 + 9 ],
												   //triangle_buf[i * 12 + 10],
												   //triangle_buf[i * 12 + 11]);
	//}	

	float ray_origin[3] = {0.0};
	float x_offset[3] = {0.0};
	float y_offset[3] = {0.0};
	float ray_dir[3] = {0.0};
	
	float p_hit[3] = {0.0};
	
	bool hit;

	for (int i = 0; i < res[0]; i++) {
		
		if ( (i%10) == 0){
			printf("Rendering Row %d\n", i);
		}

		for (int j = 0; j < res[1]; j++) {
			
			scale(x_offset, x_incr, j);
			scale(y_offset, y_incr, i);

			add(ray_origin, start_pos, x_offset);
			add(ray_origin, ray_origin, y_offset);

			subtract(ray_dir, ray_origin, eye);
			normalize(ray_dir, ray_dir);
			
			for (int k = 0; k < triangle_index; k++){
				
				//printf("%f %f\n", triangle_buf[12 * k], triangle_buf[12 * k + 9]);

				hit = ray_triangle_intersect(p_hit,
											 &triangle_buf[12 * k],
											 &triangle_buf[12 * k + 9],
											 ray_origin,
											 ray_dir);

				if (hit) {
					
					subtract(dist_vec, p_hit, ray_origin);
					
					dist = norm(dist_vec);

					if (dist < z_buf[i * x_res + j]){
						
						z_buf[i * x_res + j] = dist;
						
						t_hit_buf[i * x_res + j] = k;
						
					}

				}
			
			}
			
			if (z_buf[i * x_res + j] < 1e30){
				
				pix_val_f = dot(&triangle_buf[12*t_hit_buf[i * x_res + j] + 9], &up);

				pix_val = (char)(255.0 * (0.5 * (pix_val_f + 1.0)));
				
				*(img_buf + 3 * (res[0] * i + j) + 0) = pix_val;
				*(img_buf + 3 * (res[0] * i + j) + 1) = pix_val;
				*(img_buf + 3 * (res[0] * i + j) + 2) = pix_val;
				
				
			}

		}

	}

	write_bmp(img_buf, res[0], res[1], 24, "ray_trace_cube.bmp");
	
	return 0;

}
