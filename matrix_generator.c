
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char **argv){

	FILE *out = fopen(argv[1], "w");

	int rows = atoi(argv[2]);
	int cols = atoi(argv[3]);

	srand(time(NULL));
	
	int counter = 0;
	int inner = 0;

	fprintf(out, "%d %d\n", rows, cols);

	for(counter = 0; counter < rows; counter++){

		for(inner = 0; inner < cols; inner++){
			fprintf(out, "%d ", (int)rand() % 10);
		}

		fprintf(out, "\n");
	}

	fclose(out);
	return 0;
}

