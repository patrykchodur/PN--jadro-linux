#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

static const char *brk_value_beginning;
static const char *brk_value_highest;
static const char *brk_current;

static size_t mmap_highest;
static size_t mmap_current;

static void display_info_at_exit(void) {
	printf("Max memory usage:\n"
			"brk: %ld\n"
			"mmap: %ld\n",
			brk_value_highest - brk_value_beginning,
			mmap_highest);
}

void init_counter(void) {
	brk_value_beginning = sbrk(0);
	brk_current = brk_value_beginning;
	brk_value_highest = brk_value_beginning;
	atexit(display_info_at_exit);
}

static void update_max(void) {
	size_t current_size = mmap_current;
	current_size += brk_current - brk_value_beginning;

	size_t highest_size = mmap_highest;
	highest_size += brk_value_highest - brk_value_beginning;

	if (current_size > highest_size) {
		mmap_highest = mmap_current;
		brk_value_highest = brk_current;
	}
}

void brk_used(const void *ptr) {
	brk_current = (char*)ptr;
	update_max();
}

void sbrk_used(int size) {
	brk_current += size;
	update_max();
}

static size_t actual_mmap_size(size_t len) {
	static size_t page_size = 0;
	if (!page_size)
		page_size = sysconf(_SC_PAGESIZE);
	size_t page_count = 1 + ((len - 1) / page_size);
	len = page_count * page_size;
	return len;
}

void mmap_used(size_t len) {
	mmap_current += actual_mmap_size(len);
	update_max();
}

void munmap_used(size_t len) {
	mmap_current -= actual_mmap_size(len);
}
