;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	0x20 ; 32
LONGITUD_OFFSET	EQU	0x18 ; 24

PACKED_NODO_LENGTH	EQU	0x15
PACKED_LONGITUD_OFFSET	EQU	0x11

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp

	mov rsi, [rdi]
	xor eax, eax
	add eax, [rsi + LONGITUD_OFFSET]

loop: 
	mov rsi, [rsi]
	cmp rsi, 0
	je fin
	add eax, [rsi + LONGITUD_OFFSET] ; tomo la longitud del array actual 
	jmp loop

fin:
	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos_packed:
	
	push rbp
	mov rbp, rsp

	mov rsi, [rdi]
	xor eax, eax
	add eax,  DWORD [rsi + PACKED_LONGITUD_OFFSET]

loop2: 
	mov rsi, [rsi]
	cmp rsi, 0
	je fin2
	add eax, DWORD [rsi + PACKED_LONGITUD_OFFSET] 
	jmp loop2

fin2:
	pop rbp
	ret
