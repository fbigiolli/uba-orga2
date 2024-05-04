PAGO_SIZE equ 24
PAGO_MONTO_OFFSET equ 0
PAGO_COMERCIO_OFFSET equ 8
PAGO_CLIENTE_OFFSET equ 16
PAGO_APROBADO_OFFSET equ 17
CANTIDAD_CLIENTES equ 10
SIZE_INT_32 equ 4

; NO VOLATILES RBX, RBP, R12, R13, R14 y R15

global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

;########### SECCION DE TEXTO (PROGRAMA)
section .text

extern calloc
extern strcmp

; uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
; rdi = cantidadDePagos, rsi = *arr_pagos
acumuladoPorCliente_asm:
	push rbp ; alineada
	mov rbp, rsp 
	; primero deberia crear el array de 10 elementos,una posicion por cliente, cada elemento son 4 bytes como maximo, entonces tengo que hacer 40 bytes?

	push r12 
	push r13 

	xor r10, r10
	xor r12, r12
	xor r13, r13
	xor rcx, rcx

	mov r12b, dil ; en r12 tengo la cantidad de pagos
	mov r13, rsi ; en r12 tengo el puntero al arreglo de pagos

	mov rdi, CANTIDAD_CLIENTES
	mov rsi, SIZE_INT_32
	call calloc

	.ciclo:
		cmp r12,0
		je .end

		mov r10b, byte [r13 + PAGO_APROBADO_OFFSET] ; le ponmgo byte porque sino traigo cosas de más
		cmp r10, 1 ; me fijo si esta aprobado
		jne .siguiente

		;aca tengo que cargar el monto en el cliente
		mov r11b, [r13 + PAGO_CLIENTE_OFFSET] ; me traigo el NUMERO de cliente
		mov cl, [r13 + PAGO_MONTO_OFFSET] ; me traigo el monto que tambien es byte
		add dword [rax + r11 * 4], ecx ; lo muevo a memoria, esa es la posicion ya que es le numero de cliente * 4 debido a que por cada cliente tengo 4 byets
		

		.siguiente:
	    add r13, PAGO_SIZE ; me muevp en el puntero de pagos
		dec r12

	.end:
	pop r13
	pop r12
	pop rbp
	ret


; uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){

;rdi : puntero a comercio
;rsi : puntero a lista de comercios
;rdx = dl : tamaño de la lista, parte baja de rdx
en_blacklist_asm:
    push rbp
	mov rbp, rsp

	push r12
    push r13
    push r14
	push r15

	xor r12, r12
	xor r13, r13
    xor r14, r14
	xor r15, r15

	mov r12, rdi ;r12 : puntero a comercio
	mov r13, rsi ;r13 : puntero a lista de comercios
	mov r14b, dl ;r14b : tamaño de la lista, parte baja de rcx

	.ciclo:
		cmp r14b,0
        je .end

		mov rdi, [r13 + r15]
		mov rsi, r12 
		call strcmp ; cmpara los strings, devuleve 0 SI SON IGUALES

		cmp rax, 0 ; da 0, termine devuelvo 1
		je .soniguales

		.siguiente:
		add r15, 8
		dec r14b

	.soniguales:
	xor rax, rax
	mov byte al, 1
	.end:
	pop r15
	pop r14
    pop r13
    pop r12
	pop rbp
	ret


blacklistComercios_asm:
    ; push rbp



	; pop rbp
	ret