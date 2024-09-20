section .rodata

rojos:  db 0x00,0x80,0x80,0x80,0x04,0x80,0x80,0x80 ; |r4|r3|r2|r1|
        db 0x08,0x80,0x80,0x80,0x0C,0x80,0x80,0x80


verdes:  db 0x01,0x80,0x80,0x80,0x05,0x80,0x80,0x80
         db 0x09,0x80,0x80,0x80,0x0D,0x80,0x80,0x80


azules:  db 0x02,0x80,0x80,0x80,0x06,0x80,0x80,0x80
         db 0x0A,0x80,0x80,0x80,0x0E,0x80,0x80,0x80

mascara: db 0x00,0x80,0x80,0x80,0x04,0x80,0x80,0x80 ; |r4|r3|r2|r1|
         db 0x08,0x80,0x80,0x80,0x0C,0x80,0x80,0x80

mascara2:db 0x80,0x00,0x80,0x80,0x80,0x04,0x80,0x80 ; |r4|r3|r2|r1|
         db 0x80,0x08,0x80,0x80,0x80,0x0C,0x80,0x80

mascara3:db 0x80,0x80,0x00,0x80,0x80,0x80,0x04,0x80 ; |r4|r3|r2|r1|
         db 0x80,0x80,0x08,0x80,0x80,0x80,0x0C,0x80



cuatro_tres_de_dd: times 4 dd 3.0

cuatro_sesenta_cuatro: times 4 dd 64

cuatro_ciento_veintiocho: times 4 dd 128

cuatro_ciento_noventa_dos: times 4 dd 192

cuatro_trescientos_ochenta_cuatro: times 4 dd 384

cuatro_cero: times 4 dd 0

cuatro_255: times 4 dd 255

mascara_Alfa: times 4 db 0x00, 0x00, 0x00, 0xFF

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2 como hecho (true) o pendiente (false).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por TRUE para correr los tests.

global ej2
ej2:


    push rbp
    mov rbp, rsp
    mov rax, rcx ;Muevo la altura a rax
    mul rdx ; rax = rax * rdx (width * height)
    mov rcx , rax  ; (width * height) / 16 tomo 4 pixeles a la vez

    ;Muevo mascaras
    movdqu xmm0, [rojos] 
    movdqu xmm1, [verdes]
    movdqu xmm2, [azules]
	movdqu xmm8, [cuatro_tres_de_dd]
	movdqu xmm10, [cuatro_ciento_noventa_dos]
	movdqu xmm12, [cuatro_trescientos_ochenta_cuatro]
	movdqu xmm13, [cuatro_cero]
	movdqu xmm15, [cuatro_255]

ciclo:
    movdqu xmm3, [rsi]  ; | r1 | g1 | b1 | a1 | r2 | g2 | b2 | a2 | r3 | g3 | b3 | a3 | r4 | g4 | b4 | a4 |
    
	;Separo color x color
    movdqu xmm5, xmm3 
    pshufb xmm5 , xmm0 ; |r1|r2|r3|r4|

    movdqu xmm6, xmm3 
    pshufb xmm6 , xmm1 ; |g1|g2|g3|g4|

    movdqu xmm7, xmm3 
    pshufb xmm7 , xmm2 ; |b1|b2|b3|b4|

    paddd xmm5, xmm6 ;|r1+g1|r2+g2|r3+g3|r4+g4|
    paddd xmm5, xmm7 ;|r1+g1+b1|r2+g2+b2|r3+g3+b3|r4+g4+b4|

    ; los paso a float
    cvtdq2ps xmm5, xmm5

    ;divido por 3s

    divps xmm5,xmm8 ;|t1|t2|t3|t4|2

	;los paso a int
    cvttps2dq xmm5, xmm5
	
	;aca procesamos los rojos 
	movdqu xmm9, xmm5
	psubd  xmm9, xmm10 ;|t1 - 192 |t2 - 192|t3 - 192|t4 - 192|
	pabsd  xmm9, xmm9  ; |abs(t - 192)
    paddd  xmm9, xmm9  ; |2*abs(t - 192)|
    paddd  xmm9, xmm9  ; |4*abs(t - 192)|
    movdqu xmm14, xmm12 
    psubd  xmm14, xmm9  ;|384 - 4*abs(t - 192)|
	pmaxsd xmm14, xmm13;|max(0,384 - 4*abs(t - 192))
	pminsd xmm14, xmm15;|min(255,max(0,384 - 4*abs(t - 192)))|
    ; xmm14 = |f(t1)|f(t2)|f(t3)|f(t4)|

	;aca procesamos los verdes 
	movdqu xmm9, xmm5
    movdqu xmm6, [cuatro_sesenta_cuatro]
    paddd  xmm9, xmm6
	psubd  xmm9, xmm10 ;|t1 - 192 |t2 - 192|t3 - 192|t4 - 192|
	pabsd  xmm9, xmm9  ; |abs(t - 192)
    paddd  xmm9, xmm9  ; |2*abs(t - 192)|
    paddd  xmm9, xmm9  ; |4*abs(t - 192)|
    movdqu xmm4, xmm12 
    psubd  xmm4, xmm9  ;|384 - 4*abs(t - 192)|
	pmaxsd xmm4, xmm13;|max(0,384 - 4*abs(t - 192))
	pminsd xmm4, xmm15;|min(255,max(0,384 - 4*abs(t - 192)))|
    ; xmm4 = |f(t1+64)|f(t2+64)|f(t3+64)|f(t4+64)|

	;aca procesamos los azul 
	movdqu xmm9, xmm5
    movdqu xmm6, [cuatro_ciento_veintiocho]
    paddd  xmm9, xmm6
	psubd  xmm9, xmm10 ;|t1 - 192 |t2 - 192|t3 - 192|t4 - 192|
	pabsd  xmm9, xmm9  ; |abs(t - 192)
    paddd  xmm9, xmm9  ; |2*abs(t - 192)|
    paddd  xmm9, xmm9  ; |4*abs(t - 192)|
    movdqu xmm3, xmm12 
    psubd  xmm3, xmm9  ;|384 - 4*abs(t - 192)|
	pmaxsd xmm3, xmm13;|max(0,384 - 4*abs(t - 192))
	pminsd xmm3, xmm15;|min(255,max(0,384 - 4*abs(t - 192)))|
    ; xmm3 = |f(t1+128)|f(t2+128)|f(t3+128)|f(t4+128)|

    ;|f(t1)|f(t1+64)|f(t1+128)|255|
    ;|f(t2)|f(t2+64)|f(t2+128)|255|
    ;|f(t3)|f(t3+64)|f(t3+128)|255|
    ;|f(t4)|f(t4+64)|f(t4+128)|255|

    movdqu xmm9, [mascara]
    pshufb xmm14, xmm9
    movdqu xmm9, [mascara2]
    pshufb xmm4, xmm9
    movdqu xmm9, [mascara3]
    pshufb xmm3, xmm9
    
    por xmm14, xmm4
    por xmm14, xmm3

    movdqu xmm9, [mascara_Alfa]
    por xmm14, xmm9

    movdqu [rdi], xmm14
    add rsi, 16
    add rdi, 16
    sub rcx, 4
    cmp rcx, 0
    jnz ciclo


    pop rbp
    ret