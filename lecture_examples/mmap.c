#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdio.h>

#include <string.h>

int main(void) {
	int fildes = open("mmap_file.txt", O_RDWR);

	char* file_bytes = mmap(NULL, 0x100, PROT_READ | PROT_WRITE,
			MAP_FILE | MAP_SHARED, fildes, 0);

	puts(file_bytes);

	strncpy(strstr(file_bytes, "cztery,"), "siedem,", strlen("siedem,"));

	munmap(file_bytes, 0x100);

	close(fildes);
}
