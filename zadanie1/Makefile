all: a.out

a.out: handler.s # main.s 
	gcc main.s handler.s

# main.s:
	# gcc -S main.c

handler.s:
	gcc -S zad1.c -o handler.s

clean:
	rm -f handler.s a.out

