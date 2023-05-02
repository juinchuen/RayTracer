#include <stdio.h>

#include <math.h>

#include "obj_parser.h"


// int main () {
	
// 	float triangle_buf[triangle_limit * 12];
	
// 	int triangle_buf_q[triangle_limit * 12];
	
// 	int triangle_index = obj_parser(triangle_buf, "cube.obj");
	
// 	int offset = 0;
	
// 	for (int i = 0; i < triangle_index; i++){
		
// 		for (int j = 0; j < 12; j++){
			
// 			printf("%10.3f ", triangle_buf[offset++]);
			
// 		}
		
// 		printf("\n");
		
// 	}
	
// 	printf("#####################################################");
// 	printf("#####################################################");
// 	printf("\n");
	
// 	for (int i = 0; i < triangle_index * 12; i++){
		
// 		triangle_buf_q[i] = (int)(triangle_buf[i] * 65536.0);
		
// 		//printf("%d\n", triangle_buf_q[i]);
		
// 	}
	
// 	offset = 0;
	
// 	for (int i = 0; i < triangle_index; i++){
		
// 		for (int j = 0; j < 12; j++){
			
// 			printf("%10d ", triangle_buf_q[offset++]);
			
// 		}
		
// 		printf("\n");
		
// 	}
	
// 	return 0;
	
// }
