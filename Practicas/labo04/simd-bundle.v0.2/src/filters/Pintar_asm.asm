
section .rodata

	4blancos: dq 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
4negros:  dq 0x000000FF000000FF, 0x000000FF000000FF
2blancos2negros: dq 0x000000FF000000FF , 0xFFFFFFFFFFFFFFFF
2negros2blancos: dq 0xFFFFFFFFFFFFFFFF, 0x000000FF000000FF

section .text
global Pintar_asm

;void Pintar_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

;  #  #  #  #  #  #
;  #  #  #  #  #  #
;  #  #  #  #  #  #
;  #  #  #  #  #  #
;  #  #  #  #  #  #
;  #  #  #  #  #  #

; *src rdi
; *dst rsi
; width rdx 
; height rcx 
; src_row_size r8
; dst_row_size r9

; Cada píxel ocupa 4 bytes (32 bits) -> (b, g, r, a) -> blue, green, red, transparencia. Cada uno ocupa 1 byte y transparencia es siempre 255

Pintar_asm:
	push rbp
	mov rbp, rsp

	; Nos creamos unos registros que guardan las posibles combinaciones de colores

	; 4 pixeles negros
	movdqa xmm0, [4negros]

	; 4 pixeles blancos
	movdqa xmm1, [4blancos]

	; 2 pixeles negros, 2 pixeles blancos
	movdqa xmm2, [2negros2blancos]

	; 2 pixeles blancos, 2 pixeles negros
	movdqa xmm3, [2blancos2negros] 

	
	; Armar un registro temporal con width para llevar la cuenta de las posiciones que quedan en la fila
	mov r11, rdx

	; Pintamos las 2 primeras filas de negro
	jmp pintar_2filas_negras

loop_matriz:

	; Armar un registro temporal con width para llevar la cuenta de las posiciones que quedan en la fila
	mov r11, rdx

	; Comparamos la cantidad de filas restantes para ver si estamos en las últimas 2 (que son todas negras)
	cmp rcx, 0x2
	je pintar_2filas_negras

	; Comparamos la cantidad de filas restantes para ver si ya terminamos de llenar la matriz
	cmp rcx, 0x0
	je end

	; Loopear para las filas que no son todas negras
	jmp loop_fila

loop_fila:

	; Hacer el compare para ver cuantas filas nos quedan por pintar, si es la primer iteracion, pintamos las dos primeras de negro
	cmp r11, rdx
	je principio_fila

	; Si es la ultima iteracion, pintamos las ultimas dos de negro
	cmp r11, 0x4
	je fin_fila
	
	; Si no, seguimos pintando de blanco
	jmp medio_fila
	

principio_fila:

	; Pintamos 2 pixeles de negro y 2 pixeles de blanco, y adelantamos el puntero
	MOVDQU [rsi], xmm2
	add rsi, 0x10	
	
	; Restamos la cantidad de elementos restantes y volvemos al loop
	sub r11, 0x04
	
	jmp loop_fila

medio_fila:

	; Pintamos 4 pixeles de blanco, y adelantamos el puntero
	MOVDQU [rsi], xmm1
	add rsi, 0x10	

	; Restamos la cantidad de elementos restantes y volvemos al loop
	sub r11, 0x04
	
	jmp loop_fila

fin_fila:

	; Pintamos 2 pixeles de blanco, 2 pixeles de negro, y adelantamos el puntero
	MOVDQU [rsi], xmm3
	add rsi, 0x10	

	; Disminuimos en 1 la cantidad de filas que nos quedan por recorrer en la matriz, y volvemos a loop_matriz
	sub rcx, 0x01

	jmp loop_matriz

pintar_2filas_negras:
	; Pintamos 4 pixeles de negro de 2 filas a la vez (una y la siguiente)
	MOVDQU [rsi], xmm0
	MOVDQU [rsi + r9], xmm0

	; Adelantamos el puntero (rsi), decrementamos la cantidad de pixeles pendientes (r11) y chequeamos si terminamos la fila
	add rsi, 0x10	
	sub r11, 0x04
	cmp r11, 0
	jne pintar_2filas_negras

	; Disminuir en 2 el numero de filas que quedan por pintar
	sub rcx, 0x02
	jmp loop_matriz 
	
end:
	pop rbp
	ret
	