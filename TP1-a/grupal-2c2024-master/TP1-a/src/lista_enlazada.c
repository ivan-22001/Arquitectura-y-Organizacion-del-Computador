#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t* ptr = malloc(sizeof(lista_t));
    ptr->head = NULL;
    return ptr;
}

uint32_t longitud(lista_t* lista) {
    if (lista->head == NULL){
        return 0;
    }
    uint32_t i = 0;
    while (lista->head->next != NULL){
    i++;
    }

    return i;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    nodo_t* nuevonodo = malloc(sizeof(nodo_t));
    uint32_t* nuevoarreglo = malloc(longitud*4);
    for (size_t i = 0; i <longitud; i++){ 
        nuevoarreglo[i]=arreglo[i];
    }

    nuevonodo->arreglo = nuevoarreglo;
    nuevonodo->longitud=longitud;

    nuevonodo->next = NULL;
    
    nodo_t* actual = lista->head;
    if (actual == NULL){
        lista->head = nuevonodo;
        }   
    else{
    while (actual->next != NULL){
        actual = actual->next;
    }
    actual->next = nuevonodo;
    }
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    nodo_t* actual = lista->head;
    for (size_t j = 0; j < i; j++)
    {
        actual = actual->next;
    }
    return actual;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
    nodo_t* actual = lista->head;
    if (actual == NULL){
        return 0;
    }
    uint64_t res = actual->longitud;
    while(actual->next != NULL){
        actual= actual->next;
        res = res + actual->longitud;
    }
return res;
}

void imprimir_lista(lista_t* lista) {
    nodo_t* actual = lista->head;
    printf(" ");
while(actual != NULL){
    printf("|%lu| -> ",actual->longitud);
    actual = actual->next;
}
    printf("null");

}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    for (size_t i = 0; i < size_of_array; i++){
    if(array[i] == elemento_a_buscar){
        return 1;
    }
    }
    return 0;

}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
    nodo_t* actual = lista->head;
    while(actual != NULL){
    int hay = array_contiene_elemento(actual->arreglo, actual->longitud, elemento_a_buscar);
    if (hay == 1){
        return 1;
    }
    actual = actual->next;
    }
    return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
nodo_t* actual = lista->head;
while(actual->next != NULL){
    nodo_t* borrar = actual;
    actual = actual->next;
    free(borrar->arreglo);
    free(borrar);
}
free(actual->arreglo);
free(actual);
free(lista);

}
