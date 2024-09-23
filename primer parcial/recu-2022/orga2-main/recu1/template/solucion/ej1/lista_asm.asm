extern malloc
section .data

%define OFFSET_NEXT  0
%define OFFSET_SUM   8
%define OFFSET_SIZE  16
%define OFFSET_ARRAY 24
%define SIZE_OF_LIST 32
%define SIZE_UINT32 4

BITS 64

section .text


; uint32_t proyecto_mas_dificil(lista_t*)
;
; Dada una lista enlazada de proyectos devuelve el `sum` más grande de ésta.
;
; - El `sum` más grande de la lista vacía (`NULL`) es 0.
;
global proyecto_mas_dificil
proyecto_mas_dificil:
	push rbp
	mov rbp, rsp

	xor rax, rax
	mov rsi, rdi

.ciclo:
	cmp rsi, 0
	je .fin
	mov ecx, dword [rsi + OFFSET_SUM]
	cmp ecx, eax
	jg .mayor
	mov rsi, [rsi]
	jmp .ciclo
.mayor:
	mov eax, ecx
	jmp .ciclo

.fin:
	pop rbp
	ret

; void tarea_completada(lista_t*, size_t)
;
; Dada una lista enlazada de proyectos y un índice en ésta setea la i-ésima
; tarea en cero.
; 
; - La implementación debe "saltearse" a los proyectos sin tareas
; - Se puede asumir que el índice siempre es válido
; - Se debe actualizar el `sum` del nodo actualizado de la lista
;
global marcar_tarea_completada
marcar_tarea_completada:
	push rbp
	mov rbp, rsp

	mov rcx, rdi

.ciclo:
	cmp rcx, 0
	je .fin
	xor rax, rax
	xor rdx, rdx
	mov eax, dword [rcx+OFFSET_SIZE]
	cmp eax, 0
	je .vacio
	cmp esi, eax
	jl .estaEnArray
	sub esi, eax
	mov rcx, [rcx]
	jmp .ciclo

.estaEnArray:
	mov r8d, dword[rcx+OFFSET_SUM]
	mov r9, [rcx+OFFSET_ARRAY]
	mov r10d, dword[r9+SIZE_UINT32*rsi]
	sub dword[rcx+OFFSET_SUM],r10d
	mov dword[r9+SIZE_UINT32*rsi], 0
	jmp .fin

.vacio:
	mov rcx, [rcx]
	jmp .ciclo

.fin:
	pop rbp
	ret

; uint64_t* tareas_completadas_por_proyecto(lista_t*)
;
; Dada una lista enlazada de proyectos se devuelve un array que cuenta
; cuántas tareas completadas tiene cada uno de ellos.
;
; - Si se provee a la lista vacía como parámetro (`NULL`) la respuesta puede
;   ser `NULL` o el resultado de `malloc(0)`
; - Los proyectos sin tareas tienen cero tareas completadas
; - Los proyectos sin tareas deben aparecer en el array resultante
; - Se provee una implementación esqueleto en C si se desea seguir el
;   esquema implementativo recomendado
;
global tareas_completadas_por_proyecto
tareas_completadas_por_proyecto:
	push rbp
	mov rbp, rsp

	sub rsp, 8
	push r15
	push r14
	push r13

	xor r15, r15
	xor r14, r14
	xor r13, r13
	

	mov r15, rdi

	call lista_len

	mov r12, rax ; tamaño del array
	mov rdi, 8
	mul rdi
	mov rdi, rax

	call malloc

	mov r14, rax ; puntero a la nueva lista
	mov r13, r14; puntero a la lista
.ciclo:
	cmp r12, 0
	je .fin
	mov rdi, [r15+OFFSET_ARRAY]
	mov rsi, [r15+OFFSET_SIZE]

	call tareas_completadas

	mov [r13], rax
	mov r15, [r15]
	dec r12
	add r13, 8
	jmp .ciclo

.fin:
	mov rax, r14
	pop r13
	pop r14
	pop r15
	add rsp, 8
	pop rbp
	ret

; uint64_t lista_len(lista_t* lista)
;
; Dada una lista enlazada devuelve su longitud.
;
; - La longitud de `NULL` es 0
;
lista_len:
	push rbp
	mov rbp, rsp

	xor rax, rax

.ciclo:
	cmp rdi, 0
	je .fin
	inc rax
	mov rdi, [rdi]
	jmp .ciclo

.fin:
	pop rbp
	ret

; uint64_t tareas_completadas(uint32_t* array, size_t size) {
;
; Dado un array de `size` enteros de 32 bits sin signo devuelve la cantidad de
; ceros en ese array.
;
; - Un array de tamaño 0 tiene 0 ceros.
tareas_completadas:
	push rbp
	mov rbp, rsp

	xor rax, rax
	
	
.ciclo:
	cmp rsi, 0
	je .fin
	mov edx, dword[rdi]
	cmp edx, 0
	je .completada
	add rdi, 4
	dec rsi
	jmp .ciclo

.completada:
	inc rax
	add rdi, 4
	dec rsi
	jmp .ciclo

.fin:
	pop rbp
	ret