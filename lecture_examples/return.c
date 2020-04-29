#include <stdio.h>
#include <stdint.h>



void funkcja2(void) {
	puts("funkcja2");
}

void funkcja1(void) {
	uintptr_t tmp = 1;
	*(&tmp + 2) = (uintptr_t)funkcja2;
	puts("funkcja1");
}

int main(void) {

	funkcja1();



}
