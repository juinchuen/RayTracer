#pragma once

void write_bmp(char* buf, int width, int height, int bits_per_pixel, char* file_name);

char* initialize_img_buffer(int width, int height, int bits_per_pixel);

void write_bmp_demo();