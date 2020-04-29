#include <stdio.h>
#include <signal.h>
#include <unistd.h>

typedef void (*sig_t)(int);

char loop = 1;

void sig_handler(int signal_nr) {
	switch (signal_nr) {
		case SIGINT:
			loop = 0;
			printf("sigint\n");
			return;
		case SIGWINCH:
			printf("sigwinch\n");
			return;
		case SIGSEGV:
			printf("sigsegv\n");
			return;
	}
}


int main(int argc, const char* argv[]) {
	signal(SIGINT, sig_handler);
	signal(SIGWINCH, sig_handler);
	signal(SIGSEGV, sig_handler);

	while(loop)
		usleep(10);

	int test = *(volatile int*)0;
}
