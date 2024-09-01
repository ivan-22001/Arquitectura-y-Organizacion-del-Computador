#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    uint32_t* nuevoArray = calloc(2, sizeof(uint32_t));
    vector_t* res = malloc(sizeof(vector_t));

    res->size = 0;
    res->capacity = 2;
    res->array = nuevoArray;

    return res;

}

uint64_t get_size(vector_t* vector) {
     return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    if(vector->size == vector->capacity){
        
        uint32_t* nuevoArray = reallocarray(vector->array, vector->capacity * 2, sizeof(uint32_t));
        vector->array = nuevoArray;
        vector->capacity *= 2;
    }
    vector->array[vector->size] = elemento;
    vector->size++;

}

int son_iguales(vector_t* v1, vector_t* v2) {
     if(v1->size != v2->size) return 0;
    for(int i = 0; i < v1->size; i++){
        if(v1->array[i] != v2->array[i]) return 0;
    }
    return 1;

}

uint32_t iesimo(vector_t* vector, size_t index) {
     if(index >= vector->size || index < 0) return 0;
    return vector->array[index];

}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out){
    if(index >= vector->size) return 0;
    *out = vector->array[index];
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    if(longitud_del_array == 0) return 0;
    int max = array_de_vectores[0]->size;
    int maxIndice = 0;
    for(int i = 0; i < longitud_del_array; i++){
        if(array_de_vectores[i]->size > max){ 
            max = array_de_vectores[i]->size;
            maxIndice = i;
        }
    }
    return array_de_vectores[maxIndice];
}
