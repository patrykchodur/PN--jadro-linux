# Patryk Chodur - Jądro systemu na przykładzie Linux

Repozytorium to jest projektem na przedmiot *programowanie niskopoziomowe* 
zawierającym przygotowane zadania z tego tematu.

Zadania te są projektowane pod dowolny 64-bitowy system operacyjny oparty na jądrze Linux.

Planuję w ciągu 1 - 2 dni rozszerzyć informacje tu zawarte o opcjonalne wskazówki,
bądź inne informacje pomocne w rozwiązywaniu zadań.

## Zadania

### 1. Sygnały, handlery i stos

Zadanie polega na napisaniu handlera dla sygnału `SIGSEGV`, który jest 
wysyłany do programu podczas naruszenia ochrony pamięci 
(tutaj linijka 15 w `main.c`)

Na początku funkcji `main()` wywoływana jest funkcja `set_handler()`,
którą należy zaimplementować. Powinna ona rejestrować handler dla
`SIGSEGV`, który także trzeba napisać. Handler można zarejestrować
za pomocą funkcji `signal()` (prostsza) lub `sigaction()` (dająca
więcej możliwości).

Handler ten powinien umożliwić poprawne zamknięcie programu, a także
użyć `free()` na `global_res` i `local_res`. Program można zakończyć
w handlerze, jednakże proszę używać `_exit()` zamiast `exit()`.
Zainteresowanych zachęcam do poczytania na temat różnic.

Zwolnienie `global_res` nie powinno stanowić żadnego wyzwania (wystarczy
przypomnieć sobie jak działa słówko kluczowe `extern`), jednakże `local_res`
wymaga znacznie więcej kombinowania, dlatego nie jest wymagane.

Można tego dokonać na 2 sposoby. Znajdując pozycję `local_res` na stosie,
lub umożliwiając wykonanie `free()` z końca funkcji `main()`. W obu przypadkach
konieczne jest ustalenie kodu asemblera na którym pracujemy, dlatego do kompilacji
należy używać pliku main.s, a nie main.c. Jeśli chcemy znaleść `local_res` na stosie
to należy zauważyć, że `rbp` na samym początku wywołania naszego handlera
ma taką samą wartość jak przez całą funkcję main. Najprościej więc napisać handler
w asemblerze, jednakże da się to zrobić także w `C`.

Drugie rozwiązanie zakłada użycie `sigaction()` zamiast `signal()`, abyśmy
w handlerze dostali wskaźnik na `ucontext`, w którym znajduje się `mcontext`.
Możemy za pomocą ostatniego dostać się do rejestrów sprzed context switcha
dokonanego przed w momencie przekazania sterowania do handlera. Nas interesuje
rejestr `rip`. Postaram się to jeszcze dokładniej opsiać w ciągu najbliższych dni.

### 2. Wielowątkowość

Jest to proste zadanie z wielowątkowości, ktorego celem jest nauczenie podstaw
korzystania z wątków POSIX. Należy napisać funkcje `max_value()` oraz `sum()`,
które rekurencyjnie dzielą tablicę na 2 części, a jeśli tablica ma długość
2, bądź mniejszą, dokonują odpowiednich operacji. I tak dla `sum()` należy zsumować
dwa wywołania rekurencyjne uruchomione na 2 różnych wątkach.

### 3. Malloc

Zadanie to polega na napisaniu prostego menedżera pamięci. Implementujemy
funkcje `my_malloc()` oraz `my_free()`, które dystrybuują pamięć uzyskaną
za pomocą funkcji `mmap()`, `brk()` bądź `sbrk()`. Aby dostać ładne podsumowanie
należy tuż po użyciu tych funkcji wywołać `mmap_used()`, `munmap_used()`,
`brk_used()` oraz `sbrk_used()`. Dwie pierwsze funkcje przyjmują rozmiar blocku
pamięci podany do odpowiednio `mmap()` oraz `munmap()`, a pozostałe przyjmują
dokładnie takie same argumenty jak `brk()` i `sbrk()`.


## Materiały

[Prezentacja](https://youtu.be/R1jmbzWdpAU)

Do rozwiązania zadań powinna wystarczyć wiedza z manualla.

- [signal](http://man7.org/linux/man-pages/man7/signal.7.html)

- [sigaction](http://man7.org/linux/man-pages/man2/sigaction.2.html)

- [pthread\_create](http://man7.org/linux/man-pages/man3/pthread_create.3.html)

- [pthread\_join](http://man7.org/linux/man-pages/man3/pthread_join.3.html)

- [mmap/munmap](http://man7.org/linux/man-pages/man2/mmap.2.html)

- [brk/sbrk](http://man7.org/linux/man-pages/man2/brk.2.html)


