
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

%define NULL 			0

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista	[?]
cantidad_total_de_elementos:
    xor rax, rax  ; Inicializa el contador a 0

contando:
    ; Verificar si el nodo actual es NULL
    cmp qword [rdi + 0], NULL
    je fin  ; Si es NULL, salir del bucle

    ; Obtener el puntero al nodo actual desde la lista
    mov rsi, [rdi]

    ; Sumar la longitud del arreglo en el nodo actual al contador
    add rax, [rsi + 0x18] ; Offset de longitud en el nodo (ajusta esto según tu estructura)

    ; Avanzar al siguiente nodo
    mov rdi, [rsi] ; Siguiente nodo en la lista

    jmp contando  ; Continuar en el bucle

fin:
    ret


;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
    xor rax, rax ; Inicializar el contador a 0

	contandoPacked:
		; Verificar si la lista ha terminado (lista == NULL)
		cmp qword [rdi], 0
		je finPacked ; Si es NULL, salir del bucle

		; Sumar la longitud del arreglo en el nodo actual al contador
		add rax, [rdi + 16] ; Offset de longitud en el nodo packed (ajusta esto según tu estructura)

		; Avanzar al siguiente nodo
		mov rdi, [rdi] ; Siguiente nodo en lista packed
		jmp contandoPacked

		;si no hace el jump hace el ret
	finPacked:
		ret


