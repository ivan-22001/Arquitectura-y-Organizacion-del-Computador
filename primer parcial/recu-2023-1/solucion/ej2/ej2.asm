global maximosYMinimos_asm

section .data 
;mascara para las transparencias 
; |0x00          |0x01|0x02|0x03|0x04          |0x05|0x06|0x07|0x08          |0x09|0x0A|0x0B|0x0C|0x0D|0x0E|0x0F|
; | r1           | g1 | b1 | a1 | r2           | g2 | b2 | a2 | r3           | g3 | b3 | a3 | r4 | g4 | b4 | a4 |
; | g1           | b1 | a1 | r2 | g2           | b2 | a2 | r3 | g3           | b3 | a3 | r4 | g4 | b4 | a4 |    |
; | b1           | a1 | r2 | g2 | b2           | a2 | r3 | g3 | b3           | a3 | r4 | g4 | b4 | a4 |
; | max(r1,g1,b1)|    |    |    |max(r2,g2,b2) |    |    |    | max(r3,g3,b3)|    |    |    |max(r2,g2,b2) |
mascaraMaximosyMinimos: db 0x00,0x00,0x00,0x80,0x04,0x04,0x04,0x80
                db 0x08,0x08,0x08,0x80,0x0C,0x0C,0x0C,0x80
mascaraParesImpares: times 2 db 0x00,0x00,0x00,0x00,0x80,0x80,0x80,0x80 

mascaraVerde: db 0x01,0x80,0x80,0x80,0x05,0x80,0x80,0x80
              db 0x09,0x80,0x80,0x80,0x0D,0x80,0x80,0x80

mascaraAzul: db 0x02,0x80,0x80,0x80,0x06,0x80,0x80,0x80
              db 0x0A,0x80,0x80,0x80,0x0E,0x80,0x80,0x80
;########### SECCION DE TEXTO (PROGRAMA)
section .text
;void maximosYMinimos_asm(uint8_t *src, uint8_t *dst, uint32_t width, uint32_t height)
;los registros quedan con los siguientes valores: 
;rdi = src
;rsi = dst
;rdx = width
;rcx = height

maximosYMinimos_asm:
    push rbp 
    mov rbp, rsp

    imul rcx, rdx
    shr rcx, 2

    movdqu xmm0, [mascaraParesImpares]
    movdqu xmm1, [mascaraMaximosyMinimos]
    movdqu xmm5, [mascaraVerde]
    movdqu xmm6, [mascaraAzul]

.ciclo:
    movdqu xmm2, [rdi]
    movdqu xmm3, xmm2 ; verde
    movdqu xmm4, xmm2 ; azul

    
    pshufb xmm3, xmm5
    pshufb xmm4, xmm6


    movdqu xmm7, xmm2 
    ; xmm2 maximos
    pmaxub xmm2, xmm3
    pmaxub xmm2, xmm4

    ;xmm7 minimos
    pminub xmm7, xmm3
    pminub xmm7, xmm4

    pshufb xmm2, xmm1 
    pshufb xmm7, xmm1

    pblendvb xmm2, xmm7

    movdqu [rsi], xmm2

    add rdi, 16
    add rsi, 16
    loop .ciclo
   
    pop rbp 
    ret