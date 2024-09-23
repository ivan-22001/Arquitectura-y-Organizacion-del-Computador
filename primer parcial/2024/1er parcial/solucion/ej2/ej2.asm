global YUYV_to_RGBA

section .rodata
 ; |y1|u1|y2|v1|y3|u2|y4|v2|y5|u3|y6|v3|y7|u4|y8|v4| 0x0F
 ;  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
  
mascara4pixeles: db 0x00, 0x01, 0x03, 0xFF, 0x02, 0x01, 0x03, 0xFF
                 db 0x04, 0x05, 0x07, 0xFF, 0x06, 0x05, 0x07, 0xFF
mascaraRestar128AUyV: dd 0, 128, 128, 0
mascaraResultadoUyVIgualesA127: dd 127, 0, 0, 0 
mascara8bitsMenosSignificativos: times 4 dd 0x000000FF
mascaraAlfa: times 4 db 0, 0, 0, 255 
mascaraError: times 4 db 127,255,0,255

floats: dd 1.370705, 0.698001, 1.732446, 0.337633

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
; rdi -> X,     rsi -> Y,      rdx -> width,        rcx -> height           
YUYV_to_RGBA:
    push rbp
    mov rbp, rsp

    mov rax, rcx
    mul rdx


    movdqu xmm1, [mascara4pixeles]
    movdqu xmm2, [mascaraRestar128AUyV]
    movups xmm3, [floats]
    movdqu xmm4, [mascaraResultadoUyVIgualesA127]
    movdqu xmm8, [mascaraError]
    movdqu xmm9, [mascaraAlfa]

.ciclo:
    cmp eax, 0
    je .fin
    movdqu xmm10, [rdi]
    pshufb xmm10, xmm1
    movdqu xmm11, xmm10
    movdqu xmm12, xmm10
    movdqu xmm13, xmm10
    
    pmovsxbd xmm10, xmm10 ; |y|u|v|0|
    psrldq xmm11, 4 
    psrldq xmm12, 8
    psrldq xmm13, 12
    pmovsxbd xmm11, xmm11
    pmovsxbd xmm12, xmm12
    pmovsxbd xmm13, xmm13

    ; me fijo cuales son iguales a 127
    ; pixel 1
    pshufd xmm5, xmm10, 0xF9 ; |u|v|0|0|
    pshufd xmm6, xmm10, 0xF7 ; |0|u|0|0| 

    paddd xmm6, xmm4 ; |127|v|0|0|

    pcmpeqd xmm5, xmm6 ; comparacion  
    
    pshufd xmm7, xmm5, 0xFD
    pand xmm5, xmm7
    movd ecx, xmm7
    movd xmm0, ecx

    ; pixel 2
    pshufd xmm5, xmm11, 0xF9 ; |u|v|0|0|
    pshufd xmm6, xmm11, 0xF7 ; |0|u|0|0| 

    paddd xmm6, xmm4 ; |127|v|0|0|

    pcmpeqd xmm5, xmm6 ; comparacion  
    
    pshufd xmm7, xmm5, 0xFD
    pand xmm5, xmm7
    movd ecx, xmm7
    pslldq xmm0, 4
    movd xmm0, ecx

    ; pixel 3
    pshufd xmm5, xmm12, 0xF9 ; |u|v|0|0|
    pshufd xmm6, xmm12, 0xF7 ; |0|u|0|0| 

    paddd xmm6, xmm4 ; |127|v|0|0|

    pcmpeqd xmm5, xmm6 ; comparacion  
    
    pshufd xmm7, xmm5, 0xFD
    pand xmm5, xmm7
    movd ecx, xmm7
    pslldq xmm0, 4
    movd xmm0, ecx

    ; pixel 4
    pshufd xmm5, xmm13, 0xF9 ; |u|v|0|0|
    pshufd xmm6, xmm13, 0xF7 ; |0|u|0|0| 

    paddd xmm6, xmm4 ; |127|v|0|0|

    pcmpeqd xmm5, xmm6 ; comparacion  
    
    pshufd xmm7, xmm5, 0xFD
    pand xmm5, xmm7
    movd ecx, xmm7
    pslldq xmm0, 4
    movd xmm0, ecx
    ; 0x11100110

    psubd xmm10, xmm2
    psubd xmm11, xmm2
    psubd xmm12, xmm2
    psubd xmm13, xmm2

    ; 1.370705, 0.698001,  1.732446, 0.337633
    pshufd xmm14, xmm10, 0xC0 ;|y|y|y|0|
    cvtdq2ps xmm14, xmm14
    pshufd xmm5, xmm10, 0xDA ; |v|v|u|0|
    cvtdq2ps xmm5, xmm5
    mulps xmm5, xmm3
    pshufd xmm15, xmm5, 0xEC ;|v|0|u|0|
    pshufd xmm6, xmm5, 0xF7  ;|0|v|0|0|
    addps xmm14, xmm15 
    subps xmm14, xmm6

    pshufd xmm5, xmm10, 0x7F ; |0|0|0|u|
    cvtdq2ps xmm5, xmm5
    mulps xmm5, xmm3
    pshufd xmm7, xmm5, 0x0C  ;|0|u|0|0|
    subps xmm14, xmm7 ; |r|g|b|0
    
    ; ya tengo los resultados, los paso a int 
    cvttps2dq xmm10, xmm14

    ; 1.370705, 0.698001,  1.732446, 0.337633
    pshufd xmm14, xmm11, 0xC0 ;|y|y|y|0|
    cvtdq2ps xmm14, xmm14
    pshufd xmm5, xmm11, 0xDA ; |v|v|u|0|
    cvtdq2ps xmm5, xmm5
    mulps xmm5, xmm3
    pshufd xmm15, xmm5, 0xEC ;|v|0|u|0|
    pshufd xmm6, xmm5, 0xF7  ;|0|v|0|0|
    addps xmm14, xmm15
    subps xmm14, xmm6

    pshufd xmm5, xmm11, 0x7F ; |0|0|0|u|
    cvtdq2ps xmm5, xmm5
    mulps xmm5, xmm3
    pshufd xmm7, xmm5, 0x0C  ;|0|u|0|0|
    subps xmm14, xmm7
    
    ; ya tengo los resultados, los paso a int 
    cvttps2dq xmm11, xmm14

    ; 1.370705, 0.698001,  1.732446, 0.337633
    pshufd xmm14, xmm12, 0xC0 ;|y|y|y|0|
    cvtdq2ps xmm14, xmm14
    pshufd xmm5, xmm12, 0xDA ; |v|v|u|0|
    cvtdq2ps xmm5, xmm5
    mulps xmm5, xmm3
    pshufd xmm15, xmm5, 0xEC ;|v|0|u|0|
    pshufd xmm6, xmm5, 0xF7  ;|0|v|0|0|
    addps xmm14, xmm15
    subps xmm14, xmm6

    pshufd xmm5, xmm12, 0x7F ; |0|0|0|u|
    cvtdq2ps xmm5, xmm5
    mulps xmm5, xmm3
    pshufd xmm7, xmm5, 0x0C  ;|0|u|0|0|
    subps xmm14, xmm7
    
    ; ya tengo los resultados, los paso a int 
    cvttps2dq xmm12, xmm14

    ; 1.370705, 0.698001,  1.732446, 0.337633
    pshufd xmm14, xmm13, 0xC0 ;|y|y|y|0|
    cvtdq2ps xmm14, xmm14
    pshufd xmm5, xmm13, 0xDA ; |v|v|u|0|
    cvtdq2ps xmm5, xmm5
    mulps xmm5, xmm3
    pshufd xmm15, xmm5, 0xEC ;|v|0|u|0|
    pshufd xmm6, xmm5, 0xF7  ;|0|v|0|0|
    addps xmm14, xmm15
    subps xmm14, xmm6

    pshufd xmm5, xmm13, 0x7F ; |0|0|0|u|
    cvtdq2ps xmm5, xmm5
    mulps xmm5, xmm3
    pshufd xmm7, xmm5, 0x0C  ;|0|u|0|0|
    subps xmm14, xmm7
    
    ; ya tengo los resultados, los paso a int 
    cvttps2dq xmm13, xmm14

    ; tengo los resultados de menor a mayor xmm10, xmm11, xmm12, xmm13

    ; uso las instrucciones de empaquetado 

    movdqu xmm7, [mascara8bitsMenosSignificativos]
    pand xmm10, xmm7
    pand xmm11, xmm7
    pand xmm12, xmm7
    pand xmm13, xmm7
    packusdw xmm10, xmm11
    packusdw xmm12, xmm13

    packuswb xmm10, xmm12
    paddb xmm10, xmm9

    blendvps xmm10, xmm8

    movdqu [rsi], xmm10
    add rdi, 8
    add rsi, 16
    sub eax, 2
    jmp .ciclo


    

.fin:
    pop rbp
    ret
