%define OFFSET_NEXT  0
%define OFFSET_SUM   8
%define OFFSET_SIZE  16
%define OFFSET_ARRAY 24
%define OFFSET_TAREA 4
%define OFFSET_SALIDA 8 
; ^ (ejercicio 3) 8bytes de OFFSET entre los elementos del array de salida, ya que son de 64 bits
; como las tareas son de 32 bits, hay 4 bytes de offset entre elementos del array de tareas

extern malloc

BITS 64

section .text


; uint32_t proyecto_mas_dificil(lista_t*)
;
; Dada una lista enlazada de proyectos devuelve el `sum` más grande de ésta.
;
; - El `sum` más grande de la lista vacía (`NULL`) es 0.
;
; rdi: lista_t* lista
global proyecto_mas_dificil
proyecto_mas_dificil:
	; armamos stack frame
	push rbp
	mov rbp, rsp 

	push r12 ; pila desalineada
	push r13 ; pila alineada

	xor r13d,r13d ; aca guardaremos el valor mas grande. usamos r13d y r12d porque sum es de 32bytes
	cmp rdi, 0	  ; hacemos una prueba inicial de que la lista no este vacia
	je .fin 	  ; r13d empieza en 0 asi que devolvera 0

	.buscarMasDificil:
	cmp rdi, 0
	je .fin	      ; salimos cuando hayamos terminado de recorrer la lista
	mov r12d, [rdi + OFFSET_SUM]
	cmp r12d, r13d
	jg .actualEsMayor
	mov rdi, [rdi + OFFSET_NEXT]
	jmp .buscarMasDificil

	.actualEsMayor:
	mov r13d, r12d
	mov rdi, [rdi + OFFSET_NEXT]
	jmp .buscarMasDificil
	
	.fin:
	mov eax, r13d

	pop r13
	pop r12
	pop rbp
	ret

; void tarea_completada(lista_t*, size_t)
;
; Dada una lista enlazada de proyectos y un índice en ésta setea la i-ésima
; tarea en cero.
;
; - La implementación debe "saltearse" a los proyectos sin tareas
; - Se puede asumir que el índice siempre es válido
; - Se debe actualizar el `sum` del nodo actualizado de la lista
;

; Al ser siempre valido el indice, podemos asumir que
; no nos pueden pasar una lista vacia, ya que cualquier indice seria invalido 
; (nos piden marcar el primer (0) elemento de una lista sin elementos)


; rdi: lista_t* lista, rsi: size_t indice
global marcar_tarea_completada
marcar_tarea_completada:
	push rbp
	mov rbp, rsp

	push r12	
	push r13 

	.recorrerLista:
	mov r12, [rdi + OFFSET_ARRAY]   ; r12: puntero al elemento actual del array
	mov r13d, [rdi + OFFSET_SIZE]   ; r13: size del array del nodo actual

	.recorrerArray:
	; Vamos a recorrer el array del proyecto actual hasta que lleguemos a su fin, y ahi pasaremos al siguiente proyecto
	cmp r13d, 0		   ; primero nos fijamos si el proyecto tiene tareas, ya que si no tiene no corresponderia marcar la actual
	je .avanzarEnLista ; si no tiene tareas, salteamos este proyecto
	cmp rsi, 0
	je .marcarActual   ; si el indice llego a 0 debemos marcar la tarea
	dec r13d
	dec rsi
	add r12, OFFSET_TAREA
	jmp .recorrerArray

	.avanzarEnLista:
	mov rdi, [rdi + OFFSET_NEXT]
	jmp .recorrerLista

	.marcarActual:
	mov dword [r12], 0 ; marcamos la tarea como terminada

	mov r12, [rdi + OFFSET_ARRAY] ; volvemos al primer elemento del array
	mov r13, [rdi + OFFSET_SIZE]  ; volvemos al valor original del tamaño del array para iterar nuevamente

	xor eax, eax ; contador
	.calcularSum:
	; Nuevamente recorremos el array pero esta vez para calcular la suma
	cmp r13, 0
	je .actualizarSum
	add eax, [r12]
	add r12, OFFSET_TAREA
	dec r13
	jmp .calcularSum

	.actualizarSum:
	mov [rdi + OFFSET_SUM], eax		; modificamos en el proyecto actual el valor de la suma

	pop r13
	pop r12
	pop rbp
	ret

; uint64_t* tareas_completadas_por_proyecto(lista_t*)
;
; Dada una lista enlazada de proyectos se devuelve un array que cuenta
; cuántas tareas completadas tiene cada uno de ellos.
;
; - Si se provee a la lista vacía como parámetro (`NULL`) la respuesta puede
;   ser `NULL` o el resultado de `malloc(0)`
; - Los proyectos sin tareas tienen cero tareas completadas
; - Los proyectos sin tareas deben aparecer en el array resultante
; - Se provee una implementación esqueleto en C si se desea seguir el
;   esquema implementativo recomendado
;

; Como debemos devolver un array, vamos a necesitar pedir memoria dinamica con malloc
; rdi: lista_t* lista
global tareas_completadas_por_proyecto
tareas_completadas_por_proyecto:
	push rbp
	mov rbp, rsp
	
	push r12
	push r13
	push r14
	push r15

	push rdi   ; preservamos rdi que es el puntero al inicio de la lista, asi podemos iterar
	   	 	   ; sobre el y tambien usarlo para pasar parametro a malloc
	sub rsp, 8 ; alineamos pila, MUY importante ya que vamos a necesitar usar malloc

	xor rcx, rcx ; rcx sera nuestro contador. es volatil asi que no hace falta preservarlo
				 ; vamos a tener tantos elementos en el array de salida como proyectos (nodos) en nuestra lista
	.largoLista:
	cmp rdi, 0
	je .asignarMemoria
	inc rcx
	mov rdi, [rdi + OFFSET_NEXT]
	jmp .largoLista

	.asignarMemoria:
	sal rcx, 3 ; multiplicamos por 8 ya que cada elemento del array de salida ocupa 64bits=8bytes.
	mov rdi, rcx
	
	call malloc  ; le pasamos rdi a malloc para que nos otorgue el bloque de memoria necesario para nuestro array. lo devuelve en rax
	mov r14, rax ; lo guardamos en un registro no volatil
	
	add rsp, 8
	pop rdi    ; recuperamos rdi habiendo recorrido la lista, volviendo al principio de ella

	push r14   ; guardamos la posicion inicial del espacio asignado para poder volver, ya que iteraremos por el
	sub rsp, 8 ; alineamos la pila

	.recorrerLista:
	xor r15, r15 ; contador de tareas completadas en el proyecto actual

	cmp rdi, 0
	je .finLista

	mov r12, [rdi + OFFSET_ARRAY]  ; r12: elemento actual del array
	mov r13d, [rdi + OFFSET_SIZE]  ; r13d: tamaño del array del nodo actual

	.recorrerArray:
	; Vamos a recorrer el array del proyecto actual hasta que lleguemos a su fin, y ahi pasaremos al siguiente proyecto
	cmp r13d, 0		   ; si size es 0 es que o no tenia tareas o terminamos de recorrer
	je .avanzarEnLista ; si no tiene tareas o terminamos de recorrer, pasamos al proximo elemento de la lista
	cmp dword [r12], 0
	je .incrementarCompletadas
	.volver:
	dec r13d ; en cada iteracion decrementamos el largo del array
	add r12, OFFSET_TAREA ; avanzamos en array
	jmp .recorrerArray
	.incrementarCompletadas:
	inc r15
	jmp .volver

	.avanzarEnLista:
	mov [r14], r15
	add r14, OFFSET_SALIDA		
	mov rdi, [rdi + OFFSET_NEXT]
	jmp .recorrerLista

	.finLista:
	add rsp, 8
	pop r14 ; restauramos el puntero al inicio del arreglo de salida
	mov rax, r14

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; uint64_t lista_len(lista_t* lista)
;
; Dada una lista enlazada devuelve su longitud.
;
; - La longitud de `NULL` es 0
;
lista_len:
	; OPCIONAL: Completar si se usa el esquema recomendado por la cátedra
	ret

; uint64_t tareas_completadas(uint32_t* array, size_t size) {
;
; Dado un array de `size` enteros de 32 bits sin signo devuelve la cantidad de
; ceros en ese array.
;
; - Un array de tamaño 0 tiene 0 ceros.
tareas_completadas:
	; OPCIONAL: Completar si se usa el esquema recomendado por la cátedra
