extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; a[rdi] b[rsi]
strCmp:
	push rbp
	mov rbp, rsp

	xor rax, rax

	mov dl, [rdi] ; muevo el primer caracter a dl que es un registro de 8 bits
	mov cl, [rsi] ; lo mismo para cl
	cmp dl, 0 ; me fijo si es nulo el primero
	je checkB ; si es vacio el string a entonces verifico que b lo sea
	cmp cl, 0 ; si a no es vacio, verifico si b lo es
	je greater ; si b es vacio entonces la funcion devuelve -1, quiere decir que a > b

	cmp dl, cl ; comparo quien es mayor
	jg greater ; si la comparacion (resta), es mayor que 0 entonces quiere decir que a > b
	jl lesser ; si es negativa b > a
	je equal ; si es igual voy a un loop para ver los demas caracteres

lesser:
	mov rax, 1
	jmp return

greater:
	mov rax, -1
	jmp return

equal:
	inc rdi
	inc rsi
	mov dl, [rdi]
	mov cl, [rsi]
	cmp dl, 0
	je checkB ; si a es vacio verifico si b lo es
	cmp cl, 0 
	je greater  ; si b es vacio a es mas grande
	cmp dl, cl
	jg greater
	jl lesser
	je equal 
checkB:
	cmp cl, 0
	je return
	jmp lesser
	
return:	
		pop rbp
		ret

; char* strClone(char* a)
strClone:
	push rbp
	mov rbp, rsp
	sub rsp, 8 ; dejo un espacio para alinear la pila a 16 bytes ya que voy a pushear r12
	push r12 ; pusheo r12 porque lo voy a usar en esta funcion, pero quiero conservar su valor antiguo
	mov r12, rdi

	call strLen ; calculo el tamaño del string

	mov rdi, rax ; rax contiene el largo
	inc rdi ; incremento un por el \0

	call malloc ; uso malloc para reservar espacio en la memoria donde rdi es el largo y devuelve un
	; puntero a la memoria asignada
	
	mov rsi, rax ; ahora rax apunta al espacio de memoria asignado
	mov rdi, r12 

loop:
	mov dl, [rdi]
	mov BYTE[rsi], dl
	cmp dl, 0
	je fin2 ; si el puntero es vacio termina
	inc rdi
	inc rsi
	jmp loop

fin2:
	pop r12
	add rsp, 8
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp
	
	test rdi, rdi
	jz fin3

	call free ; libero memoria 
	
fin3:
	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
	mov rbp, rsp

	call fprintf

	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp, rsp

	xor rax, rax

	mov dl, [rdi]
	cmp dl, 0
	je fin
largo:
	inc rax
	inc rdi
	mov dl, [rdi]
	cmp dl, 0
	jz fin
	jmp largo

fin:
	pop rbp
	ret


