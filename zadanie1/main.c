#include <stdlib.h>

char* global_res;

void set_handler(void);

int main(void) {
	volatile char* local_res;

	set_handler();

	global_res = malloc(4);
	local_res = malloc(2);

	int segv = *(volatile int*)0;

	free((void*)local_res);
	free(global_res);
}

