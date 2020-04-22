#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

static const char *brk_value_beginning;
static const char *brk_value_highest;
static const char *brk_current;

static size_t mmap_highest;
static size_t mmap_current;

static void display_info_at_exit(void) {
	printf("Maksymalne zużycie pamięci:\n"
			"brk: %ld\n"
			"mmap: %ld\n",
			brk_value_highest - brk_value_beginning,
			mmap_highest);
}

void init_counter(void) {
	brk_value_beginning = sbrk(0);
	atexit(display_info_at_exit);
}

void brk_used(const void *ptr) {
	brk_current = (char*)ptr;
	if (brk_current > brk_value_highest)
		brk_value_highest = brk_current;
}

void sbrk_used(int size) {
	brk_current += size;
	if (brk_current > brk_value_highest)
		brk_value_highest = brk_current;
}

static size_t actual_mmap_size(size_t len) {
	static page_size = sysconf(_SC_PAGESIZE);
	size_t page_count = 1 + ((len - 1) / page_size);
	len = page_count * page_size;
	return len;
}

void mmap_used(size_t len) {
	mmap_current += actual_mmap_size(len);
	if (mmap_current > mmap_highest)
		mmap_highest = mmap_current;
}

void munmap_used(size_t len) {
	mmap_current -= actual_mmap_size(len);
}
