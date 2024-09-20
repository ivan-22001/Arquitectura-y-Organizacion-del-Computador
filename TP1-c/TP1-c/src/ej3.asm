section .rodata

; |0x00|0x01|0x02|0x03|0x04|0x05|0x06|0x07|0x08|0x09|0x0A|0x0B|0x0C|0x0D|0x0E|0x0F|
; | r1 | g1 | b1 | a1 | r2 | g2 | b2 | a2 | r3 | g3 | b3 | a3 | r4 | g4 | b4 | a4 |
pixel_1: db 0x00,0x01,0x02,0x03,0x80,0x80,0x80,0x80 ; 
	     db 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

pixel_2: db 0x04,0x05,0x06,0x07,0x80,0x80,0x80,0x80 ; 
	     db 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

pixel_3: db 0x08,0x09,0x0A,0x0B,0x80,0x80,0x80,0x80 ; 
	     db 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

pixel_4: db 0x0C,0x0D,0x0E,0x0F,0x80,0x80,0x80,0x80 ; 
	     db 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 3A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3a
global EJERCICIO_3A_HECHO
EJERCICIO_3A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej3a
ej3a:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = int32_t* dst_depth rdi
	; r/m64 = uint8_t* src_depth rsi
	; r/m32 = int32_t  scale rdx
	; r/m32 = int32_t  offset rcx
	; r/m32 = int      width r8
	; r/m32 = int      height r9
	push rbp
	mov rbp, rsp

	movd xmm0, edx
	movd xmm1, ecx
	pshufd xmm0, xmm0, 0x00 ; lleno el registro con dd de scale
	pshufd xmm1, xmm1, 0x00 ; lleno el registro con dd de offset
	mov eax, r8d
	mul r9d
	movdqu xmm10, [pixel_1]
	movdqu xmm11, [pixel_2]
	movdqu xmm12, [pixel_3]
	movdqu xmm13, [pixel_4]
ciclo:
	movd xmm5, [rsi]
	;movdqu xmm6, [rsi+0x04]
	;movdqu xmm7, xmm5
	;movdqu xmm8, xmm5
	; paso cada pixel a un registro
	;pshufb xmm5, xmm10
	;pshufb xmm6, xmm11
	;pshufb xmm7, xmm12
	;pshufb xmm8, xmm13

	; los extiendo a double word con signo
	pmovzxbd xmm5, xmm5
	;pmovsxbd xmm6, xmm6
	;pmovsxbd xmm7, xmm7
	;pmovsxbd xmm8, xmm8

	; hago la multiplicacion de scale
	pmulld xmm5, xmm0
	;pmulld xmm6, xmm0
	;pmulld xmm7, xmm0
	;pmulld xmm8, xmm0

	; sumo los offset
	paddd xmm5, xmm1
	;paddd xmm6, xmm1
	;paddd xmm7, xmm1
	;paddd xmm8, xmm1
	
	movdqu [rdi], xmm5 
	;movdqu [rdi+0x10], xmm6
	;movdqu [rdi+0x20], xmm7
	;movdqu [rdi+0x30], xmm8
	add rdi, 16
	add rsi, 4
	sub eax, 4
	cmp eax, 0
	jnz ciclo

	pop rbp
	ret

; Marca el ejercicio 3B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3b
global EJERCICIO_3B_HECHO
EJERCICIO_3B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej3b
ej3b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst rdi 
	; r/m64 = rgba_t*  a  rsi
	; r/m64 = int32_t* depth_a rdx
	; r/m64 = rgba_t*  b rcx
	; r/m64 = int32_t* depth_b r8
	; r/m32 = int      width r9
	; r/m32 = int      height [rbp+0x10]
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push rdx ; me guardo ya que con el mul pierdo el valor de rdx

	mov eax, dword [rbp+0x10]
	mul r9d
	mov r9d, eax
	pop rdx
	add rsp, 8
	shr r9d, 2
	xor rax, rax

.ciclo:

	movdqu xmm1, [rdx + rax] ; d_a
	movdqu xmm0, [r8  + rax] ; d_b
	movdqu xmm3, [rsi + rax] ; a
	movdqu xmm4, [rcx + rax] ; b

	pcmpgtd xmm0, xmm1
	blendvps xmm4, xmm3

    movdqu [rdi+rax], xmm4
	dec r9d
	add rax, 16
	cmp r9d, 0
	jnz .ciclo


	pop rbp
	ret
