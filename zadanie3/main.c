#include <stdio.h>
#include <string.h>
#include "memory_counter.h"
#include <stdlib.h>

#define TEST_SIZE 10000

#define MALLOC my_malloc
#define FREE my_free

void* my_malloc(size_t);
void my_free(void*);


int main(void) {
	init_counter();

	char* test = MALLOC(20);
	strcpy(test, "test_string");
	puts(test);
	FREE(test);


	char* *all_blocks;
	all_blocks = MALLOC(TEST_SIZE * sizeof(char*));

	size_t all_allocated = 0;

	for (int iter = 0; iter < TEST_SIZE; ++iter) {
		all_blocks[iter] = MALLOC(1 + iter % 4000);
		all_allocated += 1 + iter % 4000;
		all_blocks[iter][0] = 'a';
	}

	for (int iter = 0; iter < TEST_SIZE; ++iter)
		FREE(all_blocks[iter]);


	for (int iter = 0; iter < TEST_SIZE; ++iter) {
		all_blocks[iter] = MALLOC(1 + iter % 4000);
		all_allocated += 1 + iter % 4000;
		all_blocks[iter][0] = 'a';
	}

	for (int iter = 0; iter < TEST_SIZE; ++iter)
		FREE(all_blocks[iter]);

	for (int iter = 0; iter < TEST_SIZE; ++iter) {
		all_blocks[iter] = MALLOC(1 + iter % 4000);
		all_allocated += 1 + iter % 4000;
		all_blocks[iter][0] = 'a';
	}

	for (int iter = 0; iter < TEST_SIZE; ++iter)
		FREE(all_blocks[iter]);

	size_t single_allocated = 0;
	for (int iter = 0; iter < TEST_SIZE; ++iter) {
		all_blocks[iter] = MALLOC(1 + iter % 4000);
		all_allocated += 1 + iter % 4000;
		single_allocated += 1 + iter % 4000;
		all_blocks[iter][0] = 'a';
	}

	for (int iter = 0; iter < TEST_SIZE; ++iter)
		FREE(all_blocks[iter]);

	FREE(all_blocks);

	fprintf(stdout,
			"number of bytes allocated during this session:\n"
			"bytes in single sequence: %ld\n"
			"bytes during all session: %ld\n",
			single_allocated, all_allocated
		   );

}

