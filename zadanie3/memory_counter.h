#ifndef MEMORY_COUNTER_H
#define MEMORY_COUNTER_H

void init_counter(void);
void brk_used(const void*);
void sbrk_used(int);
void mmap_used(size_t);
void munmap_used(size_t);

#endif
