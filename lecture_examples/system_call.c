#include <unistd.h>

int main(void) {
	write(STDOUT_FILENO, "test\n", 5);
}
