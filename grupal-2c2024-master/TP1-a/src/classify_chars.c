#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int is_vowel(char c) {
    return (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u'
    || c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U');
}

void classify_chars_in_string(char* string, char** vowels_and_cons) {
    if(string == NULL) return;
    char* ch = string;
    int v = 0;
    int c = 0;
    while(*ch != '\0'){
        if(is_vowel(*ch)){
            vowels_and_cons[0][v++] = *ch;
        }
        else{
            vowels_and_cons[1][c++] = *ch;
        }
        ch++;
    }
    vowels_and_cons[0][v] = '\0';
    vowels_and_cons[1][c] = '\0';
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {

    for(uint64_t i = 0; i < size_of_array ; i++){
        array[i].vowels_and_consonants = malloc(2*sizeof(char*));
        array[i].vowels_and_consonants[0] = malloc(strlen(array[i].string) * sizeof(char*));
        array[i].vowels_and_consonants[1] = malloc(strlen(array[i].string) * sizeof(char*));
        classify_chars_in_string(array[i].string,array[i].vowels_and_consonants);
    }
}
