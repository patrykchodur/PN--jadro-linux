# Patryk Chodur - Jądro systemu na przykładzie Linux

Repozytorium to jest projektem na przedmiot **programowanie niskopoziomowe**,
zawierającym przygotowane zadania z tego tematu.

Zadania te są projektowane pod dowolny 64-bitowy system operacyjny oparty na jądrze Linux,
choć rozwiązanie drugiego i trzeciego powinno być przenośne na dowolny system zgodny z POSIX.

Aby ściągnąć repozytorium można użyć polecenia
`curl -S https://raw.githubusercontent.com/patrykchodur/PN--jadro-linux/master/run_chodur_patryk.sh > run_chodur_patryk.sh && chmod 755 run_chodur_patryk.sh && ./run_chodur_patryk.sh clone`

Po wykonaniu polecenia `./run_chodur_patryk.sh run` uruchomi nam się `docker`,
jednakże polecam wykorzystać do napisania tych zadań taurusa, gdyż jest to bardziej
wygodne.

## Zadania

Projekt składa się z 3 zadań, które należy rozwiązać uzupełniając pliki zad1.c,
zad2.c oraz zad3.c. Do zadań dołączone są bardzo proste pliki Makefile, które można
edytować (np. aby dodać plik źródłowy).

### 1. Sygnały, handlery i stos

Zadanie polega na napisaniu handlera dla sygnału `SIGSEGV`, który jest 
wysyłany do programu podczas naruszenia ochrony pamięci 
(tutaj linijka 15 w `main.c`)

Na początku funkcji `main()` wywoływana jest funkcja `set_handler()`,
którą należy zaimplementować. Powinna ona rejestrować handler dla
`SIGSEGV`, który także trzeba napisać. Handler można zarejestrować
za pomocą funkcji `signal()` (prostsza) lub `sigaction()` (dająca
więcej możliwości).

[Prezentacja - sygnały i handlery](https://youtu.be/R1jmbzWdpAU?t=1996)

Handler ten powinien umożliwić poprawne zamknięcie programu, a także
użycie `free()` na `global_res` i `local_res`. Program można zakończyć
w handlerze, jednakże proszę używać `_exit()` zamiast `exit()`.
Zainteresowanych zachęcam do poczytania na temat różnic.

Zwolnienie `global_res` nie powinno stanowić żadnego wyzwania (wystarczy
przypomnieć sobie jak działa słówko kluczowe `extern`), jednakże `local_res`
wymaga znacznie więcej kombinowania, dlatego nie jest wymagane.

Można tego dokonać na 2 sposoby. Znajdując pozycję `local_res` na stosie,
lub umożliwiając wykonanie `free()` z końca funkcji `main()`. W obu przypadkach
konieczne jest ustalenie kodu asemblera na którym pracujemy, dlatego do kompilacji
używany jest plik main.s, a nie main.c.

#### Pierwszy sposób

Jeśli chcemy znaleść `local_res` na stosie, to należy zauważyć, że `rbp` na samym
początku wywołania naszego handlera ma taką samą wartość jak przez całą funkcję main.
Jest to spowodowane tym, że kernel Linuxa podczas context switcha przed wpuszczeniem
nas do handlera zmienił `rsp` na stos do obsługi handlerów, jednakże nie zmienił `rbp`.
Najprościej więc napisać handler asemblerze, jednakże da się to zrobić także w `C`.

##### W assemblerze

Jeśli piszemy handler w assemblerze, to najprościej stworzyć osobny plik zawierający
sam tylko handler. W przypadku inline assembly musimy się liczyć z tym, że nasz
kompilator mógł dokonać zmiany ramki stosu, więc nasz aktualny `rbp` wskazuje na
inny adres niż `rbp` w funkcji `main()`. W funkcji `main()` widzimy wywołanie
funkcji `malloc()` z biblioteki standardowej `C`. Następna linijka to przekopiowanie
rezultatu do miejsca na stosie, w którym trzymana jest zmienna `local_res`. Bardzo
łatwo jest więc przekopiować wartość spod tego adresu i wywołać funkcję `free()`. Aby 
użyć funkcji z `C` w asemblerze wystarczy zadeklarować funkcję jako zewnętrzny symbol
(`extern free` w NASM, w przypadku GAS każdy nieznany symbol jest traktowany jako
zewnętrzny, więc nie trzeba tego robić). Finalnie kompilujemy plik za pomocą `gcc`, 
więc biblioteka standardowa C będzie zlinkowana. Po pierwszych labolatoriach każdy 
powinien wiedzieć jak korzystać z funkcji z asemblera w `C`, ale przypomnę, że 
należy nazwę funkcji zadeklarować jako symbol globalny (`global` w NASM, `.globl` w GAS).

##### W C

Aby wykonać to zadanie w `C` należy rozumieć jak kompilator przekłada kod napisany
w `C` do asemblera. Sugeruję, aby robić to zadanie z wyłączonymi optymalizacjami.
Wtedy jeśli w handlerze zadeklarujemy zmienną 64-bitową, to tuż za nią znajdziemy
wartość `rbp` z funkcji `main()`, umieszczony tam podczas zmiany ramki stosu.
Rozwiązanie to wymaga dosyć agresywnego rzutowania, które w `C++` dokonywalibyśmy 
za pomocą `reinterpret_cast`. Zależnie jak zapiszemy logikę będziemy się przesuwać
o 1, albo o 8.

#### Drugi sposób

Zauważmy, że jeśli zwyczajnie opuścimy nasz handler, to procesor próbuje na nowo
wykonać instrukję, która doprowadziła do naruszenia ochrony pamięci. Zmiana następnej
instrukcji po wyściu z handlera powinna więc umożliwić prawidłowe wywołanie obu `free()`
i poprawne wyjście z programu. Gdy spojrzymy do kodu asemblera (właściwie do main.c także)
zauważymy, że rezultat instrukcji, która wywołała `SIGSEGV` nie jest nam w ogóle potrzebny.
Nic się więc nie stanie, jeśli pominiemy tę instrukcję.

Drugie rozwiązanie zakłada użycie `sigaction()` zamiast `signal()`. Gdy zajrzymy
do manuala, zobaczymy że nasz handler powinien przyjmować 3 argumenty. Interesuje
nas tutaj najbardziej ostatni, czyli `void* ucontext`. Manual odsyła nas do strony
`getcontext(3)`. Struktura `ucontext_t` zawiera w sobie inną strukturę - `mcontext_t`,
która nie jest już opisana, poza informacją, że zawiera rejestry (w tym `rip`).

Jako, że struktura ta musi być gdzieś opisana logicznym posunięciem zdaje się udanie
do źródła, czyli biblioteki standardowej
[glibc](https://code.woboq.org/userspace/glibc/sysdeps/unix/sysv/linux/x86/sys/ucontext.h.html).
Zobaczymy tutaj, że struktura ta zawiera wszystkie rejestry procesora, w tym `rip`.

W dowolnym deasemblerze, na przykład tym w gdb, możemy bardzo łatwo zobaczyć ile
zajmuje dowolna instrukcja. W tym przypadku możemy przesunąć `rip` o 2 lub 5, ale
piszę tylko po to, aby nie zniechęciła nikogo nieznajomość obsługi debuggera. Polecam
więc każdemu sprawdzić samemu, a także zobaczyć dlaczego podałem 2 wartości.

Aby korzystać z wyżej wymienionych funkcjonalności glibc należy zdefiniować
`_GNU_SOURCE` na początku programu (za pomocą `#define`).

### 2. Wielowątkowość

Jest to proste zadanie z wielowątkowości, ktorego celem jest nauczenie podstaw
korzystania z wątków POSIX. Należy napisać funkcje `max_value()`, `sum()` a także
funkcje pomocnicze, za pomocą których rekurencyjnie dzieląc tablicę na 2 części
znajdziemy największą wartość, a także obliczymy sumę wszystkich elementów tablicy.
Teoretycznie można to zadanie wykonać za pomocą `va_list`, jednakże najprościej
stworzyć lokalne struktury przechowujące parametry kolejnych wywołań, i przekazywać
wskaźniki do nich rzutowane na `void*`. Funkcję w nowym wątku wywołujemy za pomocą
`pthread_create`, a wyniki otrzymujemy za pomocą `pthread_join`, które bardzo dokładnie
opisane są w manualu. Tablica przechowuje zmienne całkowite o rozmiarze wskaźnika aby
oszczędzić debugowanie możliwych konwersji. Za warunek kończący rekurencję można uznać
rozmiar tablicy mniejszy bądź równy 2.

[Prezentacja - wątki POSIX](https://youtu.be/R1jmbzWdpAU?t=1402)

### 3. Malloc

Zadanie to polega na napisaniu prostego menedżera pamięci. Implementujemy
funkcje `my_malloc()` oraz `my_free()`, które dystrybuują pamięć uzyskaną
za pomocą funkcji `mmap()`, `brk()` bądź `sbrk()`. Aby dostać ładne podsumowanie
należy tuż po użyciu tych funkcji wywołać `mmap_used()`, `munmap_used()`,
`brk_used()` oraz `sbrk_used()`. Dwie pierwsze funkcje przyjmują rozmiar blocku
pamięci podany do odpowiednio `mmap()` oraz `munmap()`, a pozostałe przyjmują
dokładnie takie same argumenty jak `brk()` i `sbrk()`.

Aby rozdystrybuować pamięć w ramach działania funkcji `my_malloc()` najpierw musimy dostać
od systemu większy blok pamięci. Tak jak opisałem to wcześniej, można do tego użyć funkcji
POSIXowych `brk()`, `sbrk()`, czy `mmap()`. Funkcje te są najczęściej zwykłymi wrapperami
na około wywołań systemowych. Biblioteka standardowa glibc na Linuxie w implementacji `malloc()`
korzysta z funkcji `brk()` i `sbrk()`, jednakże funkcje te zostały usunięte w standardzie
POSIX.1-2001 i obecnie uznawane są za przestarzałe. Z tego powodu sugeruję, aby wykorzystać
`mmap()`, którego przykład użycia znajdziecie w [prezentacji](https://youtu.be/R1jmbzWdpAU?t=847).
Należy użyć `MAP_ANONYMOUS` (blok niepowiązany żadnym plikiem) oraz `MAP_SHARED` (pamięć
współdzielona pomiędzy procesami).

Sugeruję, aby na początku napisać system do otrzymywania (i zwalniania) bloków pamięci z `mmap()`.
System ten musi być w stanie ustalić rozmiar danego bloku pamięci, dlatego można
stworzyć strukturę do trzymania takich danych. Dobrym pomysłem jest wykorzystanie
funkcji `atexit()`, aby mieć pewność, że użyliśmy `munmap()` na wszystkich trzymanych
blokach. System ten mógłby być wykorzystywany przez bardziej szczegółowy alokator, który
przydziela mniejsze obszary pamięci. 

Gdy otrzymamy już blok pamięci musimy go podzielić na mniejsze, aby nie przydzielać niepotrzebnie
dużych bloków, gdy potrzebne jest nam na przykład 16 bajtów. Istnieje wiele schematów zarządzania 
pamięcią, są one po krótce opisane w artykule na 
[wikipedii](https://pl.wikipedia.org/wiki/Zarządzanie_pamięcią) oraz w prezentacji 
kolegi z drugiej grupy [slab allocator i buddy system](https://youtu.be/9qwW-VgKIz0?t=1466).
Do buddy system można wykorzystać drzewo binarne, które sprawdza, czy jakiś rodzic,
bądź potomek, danego obszaru został już zaalokowany (1), czy nie (0).

Zaimplementowane przez nas `my_free()` powinno dawać informację alokatorowi,
że dany obszar pamięci może zostać ponownie przydzielony. Musimy być więc w stanie
określić dany blok pamięci na postawie jego adresu, a także zapisać informację,
że jest wolny.


## Materiały

[Prezentacja](https://youtu.be/R1jmbzWdpAU)

Do rozwiązania zadań powinna wystarczyć wiedza z manualla.

- [signal](http://man7.org/linux/man-pages/man7/signal.7.html)

- [sigaction](http://man7.org/linux/man-pages/man2/sigaction.2.html)

- [pthread\_create](http://man7.org/linux/man-pages/man3/pthread_create.3.html)

- [pthread\_join](http://man7.org/linux/man-pages/man3/pthread_join.3.html)

- [mmap/munmap](http://man7.org/linux/man-pages/man2/mmap.2.html)

- [brk/sbrk](http://man7.org/linux/man-pages/man2/brk.2.html)


## Errata

- Choć standard **C** nie mówi nic o procesach (z tego co przeglądałem draft) to
  `malloc()` w bibliotece glibc, gdy korzysta z `mmap()` 
  ([M\_MMAP\_THRESHOLD](https://www.gnu.org/software/libc/manual/html_node/Malloc-Tunable-Parameters.html)),
  używa `MAP_PRIVATE` zamiast `MAP_SHARED`, więc można użyć `MAP_PRIVATE`
  (nie ma to wpływu na rozwiązanie).

- Zapomniałem dodać, że `malloc()` powinien zwracać pamięć [wyrównaną](https://en.cppreference.com/w/c/language/object#Alignment)
  dla typu o największych wymaganiach wyrównania. Przykładowo w architekturze x64 adres
  32-bitowego integera powinien być wielokrotnością 4, chara 1, a wskaźnika,
  czy 64-bitowego integera 8. `malloc()` musi więc zwracać adres będący wielokrotnością
  ósemki. Przenośnym sposobem na określenie wymagań `malloc()` jest użycie operatora `_Alignof()`
  z argumentem [max\_align\_t](https://en.cppreference.com/w/c/types/max_align_t).
  Instnieje specjalne macro, zdefiniowane w `stdalign.h`, które pozwala używać tego
  operatora jako `alignof()`. Osobne macro jest konieczne, gdyż `_Alignof()` został dodany
  w **C11**, ale identyfikator `alignof` nie był
  [zarezerwowany](https://en.cppreference.com/w/c/language/identifier#Reserved_identifiers).

