#include <stdio.h>
#include <string.h>

#define a 0
#define b 1
#define c 2

#define vertex_limit 1000
#define triangle_limit 2000

int getline_sex(char* buf, size_t num_char, FILE* input_file_pointer);
size_t obj_parser(float* triangle_buf, char* file_name);
