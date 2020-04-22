#include <stdio.h>
#include <stdint.h>

// intptr_t jest tu po to, aby nie dodawać niepotrzebnego
// debugowania w przypadku dziwact związanych z konwersjami

intptr_t max_value(intptr_t* tab, int size);
intptr_t sum(intptr_t* tab, int size);

intptr_t tab[0x40] = {
	1, 2, 3, 4, 5,
	6, 7, 8, 1, 2,
	3, 4, 5, 6, 7,
	8, 9, 2, 3, 4,
	5, 6, 7, 8, 1,
	2, 3, 4, 5, 6,
	7, 8, 1, 2, 3,
	4, 5, 6, 7, 8,
	1, 2, 3, 2, 5,
	6, 7, 8, 1, 2,
	3, 4, 5, 6, 7,
	8, 1, 2, 3, 4,
	5, 6, 7, 8,
};

int main(void) {
	printf("Największa wartość: %d\nSuma wszystkich elementów: %d\n",
			(int)max_value(tab, sizeof(tab)/sizeof(*tab)),
			(int)sum(tab, sizeof(tab)/sizeof(*tab)));
}
