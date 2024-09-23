extern malloc
global filtro

%define mask_1 0x1b
;              00 01 10 11
%define mask_2 0xe4
;              11 10 01 00
%define OFFSET 2
;              16 bits

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; OBSERVACION:
; ./runTester.sh marca que hay diferencias, pero el archivo de salida de "propios" marca todos OK lo cual
; quiere decir que pasa todos los tests.

; nos entran 8 valores de 16 bits en un registro XMM (de 128 bits). Por lo tanto, en cada iteracion procesaremos 8 entradas a la vez
; vamos a necesitar 3 registros xmm:
; uno para los valores de la 1era y 3era linea de la salida (ya que podemos sumarlos/restarlos a los otros 2)
; uno para los de la 2da linea
; uno para los de la 4ta linea

; FIGURA 1
;  |(e[i] +   | (e[i+1] + | (e[i+2] + | (e[i+3] + |(e[i] -   | (e[i+1] - | (e[i+2] - | (e[i+3] - |
;  | e[i+7])* |  e[i+6])* |  e[i+5])* |  e[i+4])* | e[i+7])* |  e[i+6])* |  e[i+5])* |  e[i+4])* | 
;  |(e[i] -   | (e[i+1] - | (e[i+2] - | (e[i+3] - |(e[i] +   | (e[i+1] + | (e[i+2] + | (e[i+3] + |
;  | e[i+4]   |  e[i+5]   | e[i+6]    |  e[i+7]   | e[i+4]   |  e[i+5]   | e[i+6]    |  e[i+7]   | 

; Por conmutatividad de la multiplicacion, lo de arriba es igual a:

; FIGURA 2
;  |(e[i] +   | (e[i+1] + | (e[i+2] + | (e[i+3] + |(e[i] +   | (e[i+1] + | (e[i+2] + | (e[i+3] + |
;  | e[i+7])* |  e[i+6])* |  e[i+5])* |  e[i+4])* | e[i+4])* |  e[i+5])* |  e[i+6])* |  e[i+7])* | 
;  |(e[i] -   | (e[i+1] - | (e[i+2] - | (e[i+3] - |(e[i] -   | (e[i+1] - | (e[i+2] - | (e[i+3] - |
;  | e[i+4]   |  e[i+5]   | e[i+6]    |  e[i+7]   | e[i+7]   |  e[i+6]   | e[i+5]    |  e[i+4]   | 

; Esto nos facilitara las cuentas

;int16_t* operaciones_asm (const int16_t* entrada, unsigned size)
                                          ;rdi              ;rsi
filtro:
push rbp
mov rbp, rsp

push rdi ; lo preservamos ya que lo vamos a usar de parametro
push rsi ; lo preservamos porque al ser no volatil malloc podria cambiarlo
; pila alineada

mov rdi, rsi
sal rdi, 1    ; multiplico por 2 para pedir memoria (necesitare 2 bytes por cada elemento)

call malloc   
; nos queda en rax el puntero a nuestro bloque de memoria
pop rsi    ; recuperamos el size
sub rsp, 8 ; alineamos la pila

shr rsi, 3    ; dividimos por 8 el size ya que procesamos 8 entradas a la vez

add rsp, 8
pop rdi       ; recuperamos rdi (entrada)

push rax      ; guardamos el comienzo del arreglo de salida para devolverlo al fnial
sub rsp, 8    ; alineamos pila

.loop:
cmp rsi, 0
je .fin
movdqu xmm0, [rdi] ; cargamos los 8 valores


movdqu xmm2, xmm0
movdqu xmm4, xmm0  ; copiamos xmm0 a xmm4 y xmm2

movlhps xmm0, xmm0 ; copiamos la parte baja de xmm0 a su parte alta
movhlps xmm4, xmm4 ; copiamos la parte alta de xmm4 a su parte baja
movhlps xmm2, xmm2 ; copiamos la parte alta de xmm2 a su parte baja

pshufhw xmm2, xmm2, mask_2 ; shuffleamos las words de manera tal que queden como FIGURA 2
pshuflw xmm2, xmm2, mask_1 ; En xmm2 nos quedaron los valores de la 2da linea

pshufhw xmm4, xmm4, mask_1 ; shuffleamos las words de manera tal que queden como FIGURA 2
pshuflw xmm4, xmm4, mask_2 ; En xmm4 nos quedaron los valores de la 4ta linea

paddw xmm2, xmm0 ; realizamos la suma y la resta correspondientes segun FIGURA 2
psubw xmm0, xmm4

pmullw xmm0, xmm2 ; realizamos la multiplicacion, nos quedamos con la low word del resultado

movdqu [rax], xmm0 ; copiamos a la salida los resultados

add rdi, 8*OFFSET ; avanzamos de a 8 ya que procesamos 8
add rax, 8*OFFSET
dec rsi
jmp .loop

.fin:
add rsp, 8
pop rax
pop rbp
ret