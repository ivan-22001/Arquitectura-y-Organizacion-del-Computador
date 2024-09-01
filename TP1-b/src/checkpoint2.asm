extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
; x1 - x2 + x3 - x4
alternate_sum_4:
	;prologo
	push rbp
	mov rbp, rsp

	sub rdi, rsi
	add rdi, rdx
	sub rdi, rcx

	mov eax, edi
	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	mov r13, rdx
	mov r14, rcx

	call restar_c

	mov rdi, rax
	mov rsi, r13

	call sumar_c

	mov rdi, rax
	mov rsi, r14

	call restar_c

	;epilogo
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_simplified:
	;prologo

	mov eax, edi
	sub eax, esi
	add eax, edx
	sub eax, ecx

	;epilogo	
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+0x10], x8[rbp+0x18]
alternate_sum_8:
	;prologo
	push rbp
	mov rbp, rsp

	; x1 - x2 + x3 - x4 + x5 - x6 + x7 - x8
	call alternate_sum_4_simplified

	add r8, rax
	mov rdi, r8
	mov rsi, r9
	mov rdx, [rbp+0x10]
	mov rcx, [rbp+0x18]

	call alternate_sum_4_simplified


	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:

	cvtsi2ss xmm1, rsi ; convertimos el entero en float
	mulss xmm0, xmm1      ; Multiplica XMM1 por XMM0   
	cvttss2si rax, xmm0 ; convertimos el float en entero
	mov [rdi], eax

	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi],
;   , x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx]
;   , f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[rbp+0x10], f6[xmm5], x7[rbp+0x18]
;   , f7[xmm6], x8[rbp+0x20], f8[xmm7],
;	, x9[rbp+0x28], f9[rbp+0x30]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	cvtss2sd xmm0, xmm0 ;convertimos float a double
	cvtss2sd xmm1, xmm1 ;convertimos float a double
	cvtss2sd xmm2, xmm2 ;convertimos float a double
	cvtss2sd xmm3, xmm3 ;convertimos float a double
	cvtss2sd xmm4, xmm4 ;convertimos float a double
	cvtss2sd xmm5, xmm5 ;convertimos float a double
	cvtss2sd xmm6, xmm6 ;convertimos float a double
	cvtss2sd xmm7, xmm7 ;convertimos float a double	

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0, xmm1 ; mulsd para scalar double precision floating point
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7

	cvtss2sd xmm7, [rbp+0x30]
	mulsd xmm0, xmm7


	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	cvtsi2sd xmm1, rsi	
	cvtsi2sd xmm2, rdx	
	cvtsi2sd xmm3, rcx
	cvtsi2sd xmm4, r8	
	cvtsi2sd xmm5, r9
	cvtsi2sd xmm6, [rbp+0x10]		
	cvtsi2sd xmm7, [rbp+0x18]

	mulsd 	 xmm0, xmm1
	mulsd 	 xmm0, xmm2
	mulsd 	 xmm0, xmm3
	mulsd 	 xmm0, xmm4
	mulsd 	 xmm0, xmm5
	mulsd 	 xmm0, xmm6
	mulsd 	 xmm0, xmm7

	cvtsi2sd xmm1, [rbp+0x20]
	cvtsi2sd xmm2, [rbp+0x28]

	mulsd 	 xmm0, xmm1
	mulsd 	 xmm0, xmm2							

	movq [rdi], xmm0
	; epilogo
	pop rbp
	ret


