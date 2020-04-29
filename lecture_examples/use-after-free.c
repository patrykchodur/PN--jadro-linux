#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void type_in_password(char* pass) {
	strcpy(pass, "12345678");
}

char verify_password(const char* pass) {
	return strcmp(pass, "12345678") == 0;
}

void other_function(void) {
	char* password = malloc(0x20);
	puts(password);
	free(password);
}

void check_in(void) {

}

int main(void) {

	char* private_password = malloc(0x20);
	type_in_password(private_password);
	if (verify_password(private_password))
		check_in();

	free(private_password);

	other_function();
}

