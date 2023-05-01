#include<stdlib.h>
#include<stdio.h>
#include<math.h>

void write_bmp(char* buf, int width, int height, int bits_per_pixel, char* file_name) {

	//WRITE_BMP
	//creates a bmp file, overwrites existing file
	//assumes integer number of bytes per pixel, i.e. bits_per_pixel is multiple of 8

	int padding = (int)ceil(width * bits_per_pixel / 4.0 / 8.0) * 4 - width * bits_per_pixel / 8;

	char* empty_buf = (char*)malloc(sizeof(int));

	*(int*)empty_buf = 0;

	int pixel_size = (width * bits_per_pixel / 8 + padding) * height;

	int file_size = 56 + pixel_size;

	printf("padding = %d, pixel_size = %d, file_size = %d\n", padding, pixel_size, file_size);

	// FILE* img_file;

	// fopen_s(&img_file, file_name, "wb");
	FILE* img_file = fopen(file_name, "wb");

	//img_file = fopen(file_name, "wb");

	char bmp_header[] = { 0x42, 0x4D,				//header field
						  0x40, 0x00, 0x00, 0x00,	//BMP file size
					      0x00, 0x00,				//reserved
					      0x00, 0x00,				//reserved
					      0x38, 0x00, 0x00, 0x00 };	//offset to image data

	*(int*)(bmp_header + 2) = file_size;

	char dib_header[] = { 0x28, 0x00, 0x00, 0x00,	//size of this header (40)
						  0x00, 0x00, 0x00, 0x00,	//bitmap width
						  0x00, 0x00, 0x00, 0x00,	//bitmap height
						  0x01, 0x00,				//number of color planes (must be 1)
						  0x10, 0x00,				//number of bits per pixel
						  0x00, 0x00, 0x00, 0x00,	//compression method used (none)
						  0x00, 0x00, 0x00, 0x00,	//image size, dummy value of 0
						  0x01, 0x00, 0x00, 0x00,	//horizontal resolution
						  0x01, 0x00, 0x00, 0x00,	//vertical resolution
						  0x00, 0x00, 0x00, 0x00,	// number of colors in palette
						  0x00, 0x00, 0x00, 0x00,	//number of important colors
						  0x00, 0x00 };				//padding (not part of header)

	*(int*)(dib_header + 4) = width;
	*(int*)(dib_header + 8) = height;
	*(short*)(dib_header + 14) = (short)bits_per_pixel;

	fwrite(bmp_header, sizeof(char), 14, img_file);
	fwrite(dib_header, sizeof(char), 42, img_file);

	for (int i = 0; i < height; i++) {

		fwrite(buf + width * bits_per_pixel / 8 * i, sizeof(char), width * bits_per_pixel / 8, img_file);
		fwrite(empty_buf, sizeof(char), padding, img_file);

	}

	free(empty_buf);
	fclose(img_file);

}

void write_bmp_demo() {

	char* pixel_array = malloc(1024 * 1024 * 3);

	for (int i = 0; i < 1024 * 1024 * 3; i++) {

		*(pixel_array + i) = 0;

	}

	for (int i = 0; i < 1024; i++) {

		for (int j = 0; j < 1024; j++) {

			*(pixel_array + 3 * (1024 * i + j) + 0) = i;
			*(pixel_array + 3 * (1024 * i + j) + 1) = j;
			*(pixel_array + 3 * (1024 * i + j) + 2) = i;

		}

	}

	write_bmp(pixel_array, 1024, 1024, 24, "write_bmp_demo.bmp");

};

char* initialize_img_buffer(int width, int height, int bits_per_pixel) {

	int size = width * height * bits_per_pixel / 8;

	char* buf = (char*)malloc(size);

	for (int i = 0; i < size; i++) {

		*(buf + i) = 0x00;

	}

	return buf;

}