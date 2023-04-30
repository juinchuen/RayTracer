#include "ray_tracer.h"

void cross(float* ret_val, float* x, float* y) {

	//CROSS
	//calculates x cross y

	ret_val[0] = x[1] * y[2] - x[2] * y[1];
	ret_val[1] = x[2] * y[0] - x[0] * y[2];
	ret_val[2] = x[0] * y[1] - x[1] * y[0];

	return;
}

float dot(float* x, float* y) {
	//DOT
	//calculates x dot y

	return x[0] * y[0] + x[1] * y[1] + x[2] * y[2];

}

void normalize(float* ret_val, float* x) {
	//NORMALIZE
	//scales vector to unit length

	float div = 1 / sqrt(dot(x, x));

	scale(ret_val, x, div);

}

float norm(float* x){
	
	return sqrt(x[0] * x[0] +
				x[1] * x[1] +
				x[2] * x[2]);
	
}

void print_vector(float* x) {
	//PRINT_VECTOR
	//prints 3 components of vector to terminal

	printf("%f %f %f\n", x[0], x[1], x[2]);

}

void add(float* ret_val, float* x, float* y) {
	//ADD
	//calculates x + y

	ret_val[0] = x[0] + y[0];
	ret_val[1] = x[1] + y[1];
	ret_val[2] = x[2] + y[2];

}

void subtract(float* ret_val, float* x, float* y) {
	//SUBTRACT
	//calculates x - y

	ret_val[0] = x[0] - y[0];
	ret_val[1] = x[1] - y[1];
	ret_val[2] = x[2] - y[2];

}

void scale(float* ret_val, float* x, float a) {
	//SCALE
	//apply scalar to vector
	ret_val[0] = x[0] * a;
	ret_val[1] = x[1] * a;
	ret_val[2] = x[2] * a;

}

bool ray_triangle_intersect(float* p_hit, float* triangle, float* triangle_normal, float* origin, float* dir){
	//RAY_TRIANGLE_INTERSECT
	//determines whether there is ray-triangle intersection
	//and returns the point of intersection

	if (dot(triangle_normal, dir) == 0) {

		return false;

	} else {

		float* v0 = triangle;
		float* v1 = triangle + 3;
		float* v2 = triangle + 6;

		float D = -dot(triangle_normal, v0);

		float t = -(dot(triangle_normal, origin) + D) / dot(triangle_normal, dir);

		scale(p_hit, dir, t);

		add(p_hit, p_hit, origin);

		if (t < 0) {

			return false;

		}

		float e0[3] = { 0.0, 0.0, 0.0 };
		float e1[3] = { 0.0, 0.0, 0.0 };
		float e2[3] = { 0.0, 0.0, 0.0 };

		float c0[3] = { 0.0, 0.0, 0.0 };
		float c1[3] = { 0.0, 0.0, 0.0 };
		float c2[3] = { 0.0, 0.0, 0.0 };

		subtract(e0, v1, v0);
		subtract(e1, v2, v1);
		subtract(e2, v0, v2);

		subtract(c0, p_hit, v0);
		subtract(c1, p_hit, v1);
		subtract(c2, p_hit, v2);

		float cross0[3] = { 0.0, 0.0, 0.0 };
		float cross1[3] = { 0.0, 0.0, 0.0 };
		float cross2[3] = { 0.0, 0.0, 0.0 };

		cross(cross0, e0, c0);
		cross(cross1, e1, c1);
		cross(cross2, e2, c2);

		float check0 = dot(triangle_normal, cross0);
		float check1 = dot(triangle_normal, cross1);
		float check2 = dot(triangle_normal, cross2);

		return ((check0 > 0) && (check1 > 0) && (check2 > 0));

	}

}

void frame_vectors(float* start_pos, float* x_incr, float* y_incr, float* eye, float* dir, int* res, float* size, float distance) {

	float up_vector[] = {0.0, 0.0, 1.0};

	cross(x_incr, dir, up_vector);

	cross(y_incr, x_incr, dir);

	scale(y_incr, y_incr, size[1] / res[1]);

	scale(x_incr, x_incr, size[0] / res[0]);

	scale(start_pos, dir, distance);

	add(start_pos, start_pos, eye);

	float x_incr_start[] = { 0.0, 0.0, 0.0 };
	float y_incr_start[] = { 0.0, 0.0, 0.0 };

	scale(x_incr_start, x_incr, - res[0] / 2.0);
	scale(y_incr_start, y_incr, - res[1] / 2.0);
	
	//scale(y_incr, y_incr, -1);

	add(start_pos, start_pos, x_incr_start);
	add(start_pos, start_pos, y_incr_start);

}

void initialize_z_buffer(float* z_buf, size_t num_elem){
	
	for (int i = 0; i < num_elem; i++){
		
		z_buf[i] = 2e30;
		
	}
}
