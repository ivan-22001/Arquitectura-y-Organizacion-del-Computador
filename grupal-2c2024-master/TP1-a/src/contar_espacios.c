#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    if(string == NULL) return 0;
    uint32_t n = 0;
    char* c = string;
    while(*c != '\0'){
        n++;
        c++;
    }
    return n;
}

uint32_t contar_espacios(char* string) {
    if(string == NULL) return 0;
    uint32_t n = 0;
    char* c = string;
    while(*c != '\0'){
        if(*c == ' ') n++;
        c++;
    }
    return n;
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}
*/