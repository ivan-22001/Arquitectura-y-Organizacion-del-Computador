section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
filtroRojos: times 4 dd 0.2126
filtroVerdes: times 4 dd 0.7152
filtroAzules: times 4 dd 0.0722
	   ; |r1	|r2	   |r3    |r4    |
	   ;*|0.2126|0.2126|0.2126|0.2126|
	   ;+|g1	|g2	   |g3    |g4    |
	   ;*|0.7152|0.7152|0.7152|0.7152|
	   ;+|r1	|r2	   |r3    |r4    |
	   ;*|0.0722|0.0722|0.0722|0.0722|
	   ; |l1	|l2	   |l3    |l4    |

; |0x00|0x01|0x02|0x03|0x04|0x05|0x06|0x07|0x08|0x09|0x0A|0x0B|0x0C|0x0D|0x0E|0x0F|
; | r1 | g1 | b1 | a1 | r2 | g2 | b2 | a2 | r3 | g3 | b3 | a3 | r4 | g4 | b4 | a4 |

;rojos:  db 0x00,0x04,0x08,0x0C,0x80,0x80,0x80,0x80
;	    db 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

rojos:  db 0x00,0x80,0x80,0x80,0x04,0x80,0x80,0x80 ; |r4|r3|r2|r1|
	    db 0x08,0x80,0x80,0x80,0x0C,0x80,0x80,0x80

;verdes.  db 0x01,0x05,0x09,0x0D,0x80,0x80,0x80,0x80
	     ;db 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

verdes:	 db 0x01,0x80,0x80,0x80,0x05,0x80,0x80,0x80
	     db 0x09,0x80,0x80,0x80,0x0D,0x80,0x80,0x80		 		 

;azules:  db 0x02,0x06,0x0A,0x0E,0x80,0x80,0x80,0x80
	    ; db 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

azules:  db 0x02,0x80,0x80,0x80,0x06,0x80,0x80,0x80
	     db 0x0A,0x80,0x80,0x80,0x0E,0x80,0x80,0x80

;mascara: db 0x0C,0x0C,0x0C,0x80,0x08,0x08,0x08,0x80 ; hago el ultimo shuffle para quedarme con los pixeles de cada li
;	     db 0x04,0x04,0x04,0x80,0x00,0x00,0x00,0x80

mascara: db 0x00,0x00,0x00,0x80,0x04,0x04,0x04,0x80 ; hago el ultimo shuffle para quedarme con los pixeles de cada li
	     db 0x08,0x08,0x08,0x80,0x0C,0x0C,0x0C,0x80

mascara2: times 4 db 0x00,0xFF,0xFF,0xFF
mascara3: times 4 db 0x00,0x00,0x00,0xFF
section .text


FALSE EQU 0

TRUE  EQU 1


global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.



; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej1
ej1:
	; r/m64 = rgba_t*  dst [rdi]
	; r/m64 = rgba_t*  src [rsi]
	; r/m32 = uint32_t width [rdx]
	; r/m32 = uint32_t height [rcx]
	push rbp
	mov rbp, rsp
	mov rax, rcx ;Muevo la altura a rax
	mul rdx ; rax = rax * rdx (width * height)

	mov    rcx , rax  ; (width * height) / 16 tomo 4 pixeles a la vez
	movups xmm0, [filtroRojos] 
	movups xmm1, [filtroVerdes]
	movups xmm2, [filtroAzules]

ciclo:
	movdqu xmm3, [rsi] ; | r1 | g1 | b1 | a1 | r2 | g2 | b2 | a2 | r3 | g3 | b3 | a3 | r4 | g4 | b4 | a4 | 	 

	movdqu xmm4, [rojos] 
	movdqu xmm5, xmm3 
	pshufb xmm5 , xmm4 ; |...|r1|r2|r3|r4|

	movdqu xmm4, [verdes]
	movdqu xmm6, xmm3 
	pshufb xmm6 , xmm4 ; |....|g1|g2|g3|g4|

	movdqu xmm4, [azules]
	movdqu xmm7, xmm3 
	pshufb xmm7 , xmm4 ; |b1|b2|b3|b4|
	
	;aca extiendo a double words para asi poder trabajarlos con float
	;pmovzxbd xmm5, xmm5  
	;pmovzxbd xmm6, xmm6 ;
	;pmovzxbd xmm7, xmm7 ;
	; los paso a float
	
	cvtdq2ps xmm5, xmm5  
	cvtdq2ps xmm6, xmm6
	cvtdq2ps xmm7, xmm7
	; multiplico cada uno por su valor correspondido 
	; 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul
	;
	mulps xmm5, xmm0 ; |r1*0.2126|r2*0.2126|r3*0.2126|r4*0.2126|
	mulps xmm6, xmm1 ; |g1*0.7152|g2*0.7152|g3*0.7152|g4*0.7152|
	mulps xmm7, xmm2 ; |b1*0.0722|b2*0.0722|b3*0.0722|b4*0.0722|

	addps xmm5, xmm6 ; |r1*0.2126|r2*0.2126|r3*0.2126|r4*0.2126|
					 ;+|g1*0.7152|g2*0.7152|g3*0.7152|g4*0.7152|		
	addps xmm5, xmm7 ; |r1*0.2126|r2*0.2126|r3*0.2126|r4*0.2126|
					 ;+|g1*0.7152|g2*0.7152|g3*0.7152|g4*0.7152|
					 ;+|b1*0.0722|b2*0.0722|b3*0.0722|b4*0.0722| = |l1|l2|l3|l4|
	
	cvtps2dq xmm5, xmm5 ; fijarse aca ya que este lo pasa a signed int y necesitamos unsigned
	movdqu xmm4, [mascara]
	pshufb xmm5, xmm4
	;movdqu xmm4, [signo]
	;paddb xmm5, xmm4
	;movdqu xmm4, [mascara2]
	;pand xmm5, xmm4
	movdqu xmm4, [mascara3]
	por xmm5, xmm4
	movdqu [rdi], xmm5
	add rdi, 16
	add rsi, 16
	sub rcx, 4
	jnz ciclo



	pop rbp
	ret

