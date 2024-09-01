#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    if(string == NULL) return;
    char* vocales = calloc(65, sizeof(char));
    char* consonantes = calloc(65, sizeof(char));
    memset(vocales, '\0', 65);
    memset(consonantes, '\0', 65);
    int i = 0, v = 0, c = 0;
    while(string[i] != '\0'){
        if( string[i] == 'a' || string[i] == 'e' || string[i] == 'i' || string[i] == 'o' || string[i] == 'u' ||
            string[i] == 'A' || string[i] == 'E' || string[i] == 'I' || string[i] == 'O' || string[i] == 'U'){
            vocales[v] = string[i];
            v++;
        } else{
            consonantes[c] = string[i];
            c++;
        }
        i++;
    }
    vowels_and_cons[0] = vocales;
    vowels_and_cons[1] = consonantes;

}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for(int i = 0; i < size_of_array; i++){
        char** vowels_and_cons = calloc(2, sizeof(char*));
        classify_chars_in_string(array[i].string, vowels_and_cons);
        array[i].vowels_and_consonants = vowels_and_cons;
    }
}
