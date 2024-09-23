global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm
extern malloc  
extern strcmp
extern CantEnBlacklist

section .data 
%define SIZE_UINT32_T 4
%define OFFSET_MONTO 0
%define OFFSET_COMERCIO 8
%define OFFSET_CLIENTE 16
%define OFFSET_APROBADO 17
%define SIZE_STRUCT 24
%define SIZE_PUNTERO_A_PAGO 8


;########### SECCION DE TEXTO (PROGRAMA)
section .text

; rdi cantidadDePagos, rsi arr_pagos
acumuladoPorCliente_asm:
	push rbp 
	mov rbp, rsp

	push r14
	push r13
	push r12
	sub rsp, 8
	
	xor r14,r14
	xor r13,r13
	xor r12,r12

	mov r14, rdi ; cantidad de pagos
	mov r13, rsi ; puntero a pagos

	mov rdi, 10
	imul rdi, SIZE_UINT32_T

	call malloc	
	mov rdi, rax
	mov r12, rdi ; puntero a uint32_t 

	mov rcx, 10
	
.loop1:
	mov dword [rdi], 0
	add rdi, SIZE_UINT32_T
	loop .loop1

	mov rcx, r14

	;mov r9 , r12 ; puntero a uint32_t 
.ciclo:
	xor rax, rax
	xor rdi, rdi
	mov al, byte[r13 + OFFSET_APROBADO] 
	mov dil, byte[r13 + OFFSET_MONTO]

	cmp al, 0
	je .siguiente
	mov al, byte[r13 + OFFSET_CLIENTE]
	add [r12 + rax*SIZE_UINT32_T], edi
.siguiente:
	add r13, SIZE_STRUCT  
    loop .ciclo
	
	mov rax, r12
	add rsp, 8

	pop r12
	pop r11
	pop r10
	pop rbp
	ret

en_blacklist_asm:
	push rbp
	mov rbp, rsp

	sub rsp, 8
	push r12
	push r13
	push r14
	
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor rax, rax

	mov r12, rdi ; comercio
	mov r13, rsi ; lista
	mov r14, rdx ; n

.ciclo:
	cmp r14, 0
	je .fin
	
	mov rdi, [r13]; puntero a char
	mov rsi, r12

	call strcmp

	cmp rax, 0
	je .enLista
	xor rax, rax
	dec r14
	add r13, 8
	jmp .ciclo
.enLista:
	mov rax, 1
.fin:
	pop r14
	pop r13
	pop r12
	add rsp, 8
	pop rbp
	ret

blacklistComercios_asm:
	push rbp
	mov rbp, rsp

	sub rsp, 16
	push r15
	push r14
	push r13
	push r12
	push rbx

	xor r15, r15
	xor r14, r14
	xor r13, r13
	xor r12, r12
	xor rbx, rbx

	mov r15, rdi ; cantidad de pagos
	mov r14, rsi ; arr_pagos
	mov r13, rdx ; arr_comercios
	mov r12, rcx ; size_comercios
	
	call CantEnBlacklist
	mov rdi, rax
	imul rdi, SIZE_PUNTERO_A_PAGO

	call malloc
	push rax
	mov rbx, rax ; puntero a pago_t
	 ; con este hago la iteracion
	
.ciclo:
	xor rax, rax
	cmp r15, 0
	je .fin
	mov rdi, [r14+OFFSET_COMERCIO]
	mov rsi, r13
	mov rdx, r12

	call en_blacklist_asm

	cmp rax, 1
	jne .siguiente
	mov [rbx], r14
	add rbx, SIZE_PUNTERO_A_PAGO
	add r14, SIZE_STRUCT
	dec r15
	jmp .ciclo
	jmp .fin
.siguiente:	
	add r14, SIZE_STRUCT
	dec r15
	jmp .ciclo

.fin:
	pop rax
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	add rsp, 16
	pop rbp
	ret
