#include "obj_parser.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int getline(char* buf, size_t num_char, FILE* input_file_pointer) {

    size_t num_read = 0;

    char read;

    while (!feof(input_file_pointer)) {

        read = fgetc(input_file_pointer);
        buf[num_read] = read;
        num_read++;
        
        if (read == '\n'){
			
			buf[num_read] = '\0';
			break;
			
		}

    }

    return num_read;

}

size_t obj_parser(float* triangle_buf, char* file_name) {

    FILE* input_file;

    fopen_s(&input_file, file_name, "r");

    float vertex_buf [vertex_limit * 3];
    float normal_buf [triangle_limit * 3];
    
    char face0_read [10];
    char face1_read [10];
    char face2_read [10];
    char face3_read [10];
    char face4_read [10];
    char face5_read [10];
    char face6_read [10];
    char face7_read [10];
    char face8_read [10];
    
    int v0, v1, v2;
    int N;
    
    size_t vertex_index = 0;
    size_t triangle_index = 0;
    size_t normal_index = 0;

    char read_in[100];
    size_t num_read = 0;

    while (!feof(input_file)) {
        
        num_read = getline(read_in, 100, input_file);
        
        //printf("fuck\n");
        
        if (num_read == 0){
			break;
		}
        
        switch(read_in[0]){

			case 'v' :
				if (read_in[1] == ' '){
					
					sscanf(read_in, "v %f %f %f\n", &vertex_buf[vertex_index * 3 + a],
													&vertex_buf[vertex_index * 3 + b],
													&vertex_buf[vertex_index * 3 + c]);
					
					//printf("%f %f %f\n", vertex_buf[vertex_index * 3    ],
										 //vertex_buf[vertex_index * 3 + 1],
										 //vertex_buf[vertex_index * 3 + 2]);							
													
					vertex_index++;
					
				} else if (read_in[1] == 'n') {
					
					sscanf(read_in, "vn %f %f %f\n", &normal_buf[normal_index * 3 + a],
													 &normal_buf[normal_index * 3 + b],
													 &normal_buf[normal_index * 3 + c]);
													 
					//printf("%f %f %f\n", normal_buf[normal_index * 3    ],
										 //normal_buf[normal_index * 3 + 1],
										 //normal_buf[normal_index * 3 + 2]);	
					
					normal_index++;
				} else if (read_in[1] == 't') {
					
					//No need to read texture coordinates for now
					
				} else {
					
				}
					
				break;
				
			case 'f' :
				
				sscanf(read_in, "f %[^/]/%[^/]/%s %[^/]/%[^/]/%s %[^/]/%[^/]/%s\n", &face0_read,
																					&face1_read,
																					&face2_read,
																					&face3_read,
																					&face4_read,
																					&face5_read,
																					&face6_read,
																					&face7_read,
																					&face8_read);
					
				//printf("%s %s %s %s %s %s %s %s %s\n", face0_read,
													   //face1_read,
													   //face2_read,
													   //face3_read,
													   //face4_read,
													   //face5_read,
													   //face6_read,
													   //face7_read,
													   //face8_read);
													   
				v0 = atoi(face0_read);
				v1 = atoi(face3_read);
				v2 = atoi(face6_read);
				
				N = atoi(face2_read);
				
				//printf("%d %d %d %d\n", v0, v1, v2, N);
				
				//write first v0 to triangle_buf
				triangle_buf[triangle_index * 12 + 0] = vertex_buf[(v0 - 1) * 3 + 0];
				triangle_buf[triangle_index * 12 + 1] = vertex_buf[(v0 - 1) * 3 + 1];
				triangle_buf[triangle_index * 12 + 2] = vertex_buf[(v0 - 1) * 3 + 2];
																		 
				//write first v1 to triangle_buf                         
				triangle_buf[triangle_index * 12 + 3] = vertex_buf[(v1 - 1) * 3 + 0];
				triangle_buf[triangle_index * 12 + 4] = vertex_buf[(v1 - 1) * 3 + 1];
				triangle_buf[triangle_index * 12 + 5] = vertex_buf[(v1 - 1) * 3 + 2];
																		 
				//write first v2 to triangle_buf                         
				triangle_buf[triangle_index * 12 + 6] = vertex_buf[(v2 - 1) * 3 + 0];
				triangle_buf[triangle_index * 12 + 7] = vertex_buf[(v2 - 1) * 3 + 1];
				triangle_buf[triangle_index * 12 + 8] = vertex_buf[(v2 - 1) * 3 + 2];
				
				//write normal vector to triangle_buf
				triangle_buf[triangle_index * 12 + 9 ] = normal_buf[(N - 1) * 3 + 0];
				triangle_buf[triangle_index * 12 + 10] = normal_buf[(N - 1) * 3 + 1];
				triangle_buf[triangle_index * 12 + 11] = normal_buf[(N - 1) * 3 + 2];
				
				triangle_index++;
				
				
				break;

			default :
				break;
			
		}
		
		

    }
    
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

    fclose(input_file);
    return triangle_index;

}
