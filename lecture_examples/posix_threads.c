#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>

struct param_struct {
	int a;
	float b;
};

void func1(struct param_struct *param_struct) {
	sleep(3);
	printf("func1: a = %d, b = %f\n", param_struct->a, param_struct->b);
}

void func2(intptr_t arg) {
	sleep(1);
	printf("func2: arg = %d\n", (int)arg);
}

typedef void* (*pthread_function_ptr)(void*);

int main(void) {
	pthread_t thread1;
	pthread_t thread2;

	struct param_struct params1 = {3, 0.14};
	intptr_t param2 = 420;

	pthread_create(&thread1, NULL, (pthread_function_ptr)func1, &params1);
	pthread_create(&thread2, NULL, (pthread_function_ptr)func2, (void*)param2);

	pthread_join(thread1, NULL);
	pthread_join(thread2, NULL);

}

