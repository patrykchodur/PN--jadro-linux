#include <stdio.h>
#include <signal.h>
#include <unistd.h>

int signal_handler_invoked;

void signal_handler(int signal_nr) {
	switch (signal_nr) {
		case SIGINT:
			puts("Ctrl-C pressed");
	}
	++signal_handler_invoked;
}

int main(void) {
	signal(SIGINT, signal_handler);

	while (signal_handler_invoked < 5)
		usleep(100);

}

