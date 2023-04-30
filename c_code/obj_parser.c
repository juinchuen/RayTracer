#include "obj_parser.h"
#include <stdio.h>
#include <string.h>

void obj_parser(float* faces, char* file_name){

    FILE* input_file = fopen(file_name, "rb");

    float* buf [300];

    char* read_in [100];

    while(!feof(input_file)){

        getline(&buf, 300, input_file);

        printf("%s", buf);

    }

    fclose(input_file);

}

int main (){

    int a = 5;

    obj_parser((float*)&a, "mushroom.obj");

}