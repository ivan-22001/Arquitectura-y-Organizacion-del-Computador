#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t* lista = malloc(sizeof(lista_t));
    return lista;
}

uint32_t longitud(lista_t* lista) {
    nodo_t* tmp = lista->head;
    uint32_t n = 0;
    while(tmp != NULL){
        n++; tmp = tmp->next;
    }
    return n;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    nodo_t* newNode = malloc(sizeof(nodo_t));
    uint32_t* newArray = malloc(longitud*sizeof(uint32_t));
    for(uint64_t i = 0; i < longitud; i++){
        newArray[i] = arreglo[i];
    }
    newNode->arreglo = newArray;
    newNode->longitud = longitud;
    newNode->next = NULL;
    if(lista->head == NULL) lista->head = newNode;
    else {
        nodo_t* tmp = lista->head;
        while(tmp->next!= NULL){
            tmp = tmp->next;
        }
        tmp->next = newNode;
    }
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    nodo_t* tmp = lista->head;
    while(i>0){
        tmp = tmp->next;
        i--; 
    }
    return tmp;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
    if(lista->head == NULL) return 0;
    uint64_t n = 0;
    nodo_t* temp = lista->head;
    while(temp != NULL){
        n += temp->longitud;
        temp = temp->next;
    }
    return n;
}

void imprimir_lista(lista_t* lista) {
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    for(uint64_t i = 0; i < size_of_array; i++){
        if(array[i] == elemento_a_buscar) return array[i];
    }
    return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
    nodo_t* tmp = lista->head;
    while(tmp != NULL){
        int val = array_contiene_elemento(tmp->arreglo, tmp->longitud, elemento_a_buscar);
        if(val != 0) return 1;
        tmp = tmp->next;
    }
    return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
    nodo_t* temp = lista->head;
    while(temp != NULL){
        nodo_t* temp2 = temp;
        temp = temp->next;
        free(temp2->arreglo);
        free(temp2);
        
    }
  
    free(lista);
}
