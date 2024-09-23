extern malloc
global filtro

;########### SECCION DE DATOS
section .data

filtro_altos:  db 0x0E, 0x0F, 0x0C, 0x0D, 0x0A, 0x0B, 0x08, 0x09
               db 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F

filtro_altos2: db 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
               db 0x0E, 0x0F, 0x0C, 0x0D, 0x0A, 0x0B, 0x08, 0x09

filtro_bajos:  db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07 
               db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;int16_t* operaciones_asm (const int16_t* entrada, unsigned size)
filtro:
    push rbp
    mov rbp, rsp

    sub rsp, 8
    push r15
    push r14
    push r13

    xor r15, r15
    xor r14, r14
    xor r13, r13
    xor rax, rax

    mov r15, rdi
    mov r14, rsi
    mov r13, rsi

    mov rdi, rsi
    sal rdi, 2

    call malloc

    mov r14, rax ; puntero a  la nuevo array
    
    mov rbx, r14

    movdqu xmm7, [filtro_altos]
    movdqu xmm8, [filtro_altos2]
    movdqu xmm15, [filtro_bajos]

.ciclo:
    cmp r13, 0
    je .fin
    movdqu xmm1, [r15] ; |e[i]|e[i+1]|e[i+2]|e[i+3]|
    movdqu xmm2, [r15]
    movdqu xmm3, [r15]

    pshufb xmm1, xmm15 
    pshufb xmm2, xmm7 ; |e[i+7]|e[i+6]|e[i+5]|e[i+4]|
    pshufb xmm3, xmm8 ; |e[i+4]|e[i+5]|e[i+6]|e[i+7]|

    ;pmovsxwd xmm1, xmm1
    ;pmovsxwd xmm2, xmm2
    ;pmovsxwd xmm3, xmm3

    movdqu xmm10, xmm1
    movdqu xmm11, xmm1
    movdqu xmm12, xmm1
    paddw xmm1, xmm3 ; |e[i]  |e[i+1]|e[i+2]|e[i+3]|+
                     ; |e[i+7]|e[i+6]|e[i+5]|e[i+4]|
    psubw xmm10, xmm2

    pmullw xmm1, xmm10
    ;paddd xmm12, xmm8; |e[i]  |e[i+1]|e[i+2]|e[i+3]|+
                     ; |e[i+4]|e[i+5]|e[i+6]|e[i+7]|
    ;psubd xmm10, xmm7; |e[i]  |e[i+1]|e[i+2]|e[i+3]|-
                     ; |e[i+7]|e[i+6]|e[i+5]|e[i+4]|
    ;psubd xmm11, xmm8; |e[i]  |e[i+1]|e[i+2]|e[i+3]|-
                     ; |e[i+4]|e[i+5]|e[i+6]|e[i+7]|

    ;pmulld xmm1, xmm11
    ;pmulld xmm10, xmm12

    
    ;packssdw xmm1, xmm10
    movdqu [rbx], xmm1
    add rbx, 16
    add r15, 16
    sub r13, 8
    jmp .ciclo 
.fin:
    mov rax, r14
    pop r13
    pop r14
    pop r15
    add rsp, 8
    pop rbp 
    ret
