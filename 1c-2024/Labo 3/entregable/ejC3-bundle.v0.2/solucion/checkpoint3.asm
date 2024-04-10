

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	0x20
LONGITUD_OFFSET	EQU	0x18

PACKED_NODO_LENGTH	EQU	0x15
PACKED_LONGITUD_OFFSET	EQU	0x11

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos:
	push rbp 
	mov rbp, rsp 

	xor r8, r8
	mov rax, [rdi] ; Muevo a rax la posicion apuntada por el puntero, estoy parado en el puntero al nodo head

.loop:
	add r8, [rax + LONGITUD_OFFSET]
	mov rax, [rax] ; Actualizo rax entrando el nodo next
	cmp rax, 0
	jne .loop

	mov rax, r8

	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
		push rbp 
	mov rbp, rsp 
	
	xor r8, r8
	mov rax, [rdi] ; Muevo a rax la posicion apuntada por el puntero, estoy parado en el puntero al nodo head

.loop:
	add r8, [rax + PACKED_LONGITUD_OFFSET]
	mov rax, [rax] ; Actualizo rax entrando el nodo next
	cmp rax, 0
	jne .loop

	mov rax, r8

	pop rbp
	ret

