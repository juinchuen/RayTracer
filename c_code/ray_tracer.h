#pragma once
#include <stdbool.h>
#include <stdio.h>
#include <math.h>

void cross(float* ret_val, float* x, float* y);

void add(float* ret_val, float* x, float* y);

void subtract(float* ret_val, float* x, float* y);

void scale(float* ret_val, float* x, float a);

float dot(float* x, float* y);

void normalize(float* ret_val, float* x);

float norm(float* x);

void print_vector(float* x);

bool ray_triangle_intersect(float* p_hit, float* triangle, float* triangle_normal, float* origin, float* dir);

void frame_vectors(float* start_pos, float* x_incr, float* y_incr, float* eye, float* dir, int* res, float* size, float distance);

void initialize_z_buffer(float* z_buf, size_t num_elem);
