%define orderingTableOffsetTableSize    0
%define orderingTableOffsetTable        8
%define orderingTableSize               16

%define nodoDisplayListOffsetPrimitiva  0
%define nodoDisplayListOffsetX          8
%define nodoDisplayListOffsetY          9
%define nodoDisplayListOffsetZ          10
%define nodoDisplayListOffsetSiguiente  16
%define nodoDisplayListSize             24

%define nodoOrderingTableOffsetDisplayElement   0
%define nodoOrderingTableOffsetSiguiente        8
%define nodoOrderingTableSize                   16


section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free


;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size);
; table_size -> rdi
inicializar_OT_asm:
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

    mov r15, rdi

    mov rdi, orderingTableSize
    shl rdi, 3

    call malloc

    mov r14, rax

    sub rsp, 8
    push rax ;puntero al ordering table

    mov rdi, r15
    mov byte [r14], dil

    shl rdi, 3 ; multiplico por 8 por sizeof puntero

    call malloc

    mov r13, rax ; puntero a ordering table
    mov [r14+orderingTableOffsetTable], r13 ; guardo el puntero a nodo_ot**
    cmp r15,0
    jne .ciclo
    mov qword[r14+orderingTableOffsetTable], 0
    jmp .fin
.ciclo:
    cmp r15, r12
    je .fin
    xor rdi, rdi
    mov rdi, nodoOrderingTableSize

    call malloc
    
    mov rbx, [r13]
    mov rbx, rax
    mov qword[rbx+nodoOrderingTableOffsetSiguiente], 0
    mov qword[rbx+nodoOrderingTableOffsetDisplayElement], 0

    inc r12
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

; void* calcular_z_asm(nodo_display_list_t* nodo, uint8_t z_size);
; nodoDisplayList -> rdi,  z_size -> rsi
calcular_z_asm:
    push rbp
    mov rbp, rsp
    
    push r15
    push r14

    xor r15, r15
    xor r14, r14

    mov r15, rdi ; nodo displat list
    mov r14, rsi ; z_size
    mov rdx, rsi

.loop:
    cmp r15, 0
    je .fin
    xor rdx, rdx
    mov dil, byte [r15+nodoDisplayListOffsetX] 
    mov sil, byte [r15+nodoDisplayListOffsetY] 
    mov rdx, r14
    mov rax, [r15+nodoDisplayListOffsetPrimitiva]
    call rax

    mov byte[r15+nodoDisplayListOffsetZ], al
    mov r15, [r15+nodoDisplayListOffsetSiguiente]
    jmp .loop

.fin:
    pop r14
    pop r15
    pop rbp
    ret


; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
; orderingTable -> rdi,    nodoDisplayList -> rsi
ordenar_display_list_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi    ; r12 -> orderingTable
    mov r13, rsi    ; r13 -> nodoDisplayList

    .loop:
        cmp r13, 0   ; r13 -> puntero a nodoDisplayList
        je .end

        mov rdi, r13    ; nodoDisplayList
        mov rsi, [r12 + orderingTableOffsetTableSize]  ; tableSize

        call calcular_z_asm     ; Le calculo el z al nodo

        xor r10, r10
        mov r10b, [r13 + nodoDisplayListOffsetZ]     ; r10 -> z del nodo

        ; Traigo la tabla
        mov r14, [r12 + orderingTableOffsetTable]   

        ; r14 -> array de nodo_ot_t*

        mov r11, r10  ; Z del nodo para iterar


        push r11
        sub rsp, 8

        ; Traigo el puntero en esa posicion del arreglo
        mov r15, [r14 + r11 * 8]

        mov rdi, nodoOrderingTableSize  ; Pido la memoria para crear ese nodo
        call malloc

        add rsp, 8
        pop r11

        ; Armo el nodo
        xor r10, r10
        mov [rax + nodoOrderingTableOffsetDisplayElement], r13
        mov [rax + nodoOrderingTableOffsetSiguiente], r10
        
        cmp r15, 0
        jne .miniloop

        ; Es el primer nodo de esa posicion

        mov [r14 + r11 * 8], rax

        mov r13, [r13 + nodoDisplayListOffsetSiguiente]

        jmp .loop 

        .miniloop:

            ; No es el primer nodo de esa posicion

            cmp r15, 0
            je .miniend

            mov r8, r15  ; me guardo el nodo que estoy visitando
            mov r15, [r15 + nodoOrderingTableOffsetSiguiente] ; voy al siguiente

            jmp .miniloop

        .miniend:

            ; ya estoy en un puntero nulo, y tengo en r8 el ultimo
            mov [r8 + nodoOrderingTableOffsetSiguiente], rax  ; agrego el de ahora como siguiente
            
            mov r13, [r13 + nodoDisplayListOffsetSiguiente]

            jmp .loop

    .end:
        pop r15
        pop r14
        pop r13
        pop r12

        pop rbp
        ret