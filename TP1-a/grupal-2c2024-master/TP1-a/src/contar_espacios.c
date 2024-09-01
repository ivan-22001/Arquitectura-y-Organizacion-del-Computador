#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    uint32_t i = 0;
    if (string == NULL){
        return 0;}
    while (string[i] != '\0'){
        i = i +1; }
    return i;
}

uint32_t contar_espacios(char* string) {
    uint32_t i = 0;
    uint32_t e = 0;
    if (string == NULL){
        return 0;}
    while (string[i] != '\0'){
        if (string[i] == ' '){  
        e++;
        }
    i++;
    }
return e;
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}
*/
