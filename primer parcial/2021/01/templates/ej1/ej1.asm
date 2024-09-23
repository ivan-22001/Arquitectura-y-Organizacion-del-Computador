global agrupar
extern str_cat
extern memcpy
extern str_copy
extern malloc
extern str_concat

%define OFFSET_TEXT 0
%define OFFSET_ LEN 8
%define OFFSET_TAG 16
%define SIZE_STRUCT 24

;########### SECCION DE DATOS
section .data


;########### SECCION DE TEXTO (PROGRAMA)
section .text
; rdi puntero a mensajes, rsi largo del nuevo array
agrupar:
    push rbp
    mov rbp, rsp

    push r15
    push r14
    push r13
    push r12

    xor r15, r15
    xor r14, r14
    xor r13, r13
    xor r12, r12

    mov r15, rdi ; puntero a mensajes
    mov r14, rsi
    mov r12, 4

    mov rdi , 4
    shl rdi, 3

    call malloc

    sub rsp, 8
    push rax ; pusheo el puntero a  char* 

    mov r13, rax
    ; ahora tengo que inicializar todos sus valores en string vacios
    xor rcx, rcx
.inicializar:
    cmp r12, 0
    je .seguir   
    mov rdi, 1
    call malloc 
    mov [r13], rax
    mov byte [rax], 0
    add r13, 8 ; me muevo a la siguiente
    dec r12
    jmp .inicializar
.seguir:
    pop rax

    xor r13, r13
    mov r13, rax

    push rax


.ciclo:
    cmp r14, 0
    je .fin
    xor r8, r8
    mov rsi, [r15+OFFSET_TEXT]
    mov r8d, dword[r15+OFFSET_TAG]
    mov rdi, [r13+r8*8] ; 8 por puntero a char

    call str_cat
    xor r8, r8
    mov r8d, dword[r15+OFFSET_TAG]
    mov rdi, [r13+r8*8]
    mov rsi, rax

    call str_copy

    add r15, SIZE_STRUCT
    dec r14
    jmp .ciclo

.fin:
    pop rax
    add rsp, 8
    pop r12
    pop r13
    pop r14
    pop r15 
    pop rbp
    ret
