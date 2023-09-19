section .rodata

    divisor: times 4 dd 3 ; Nos definimos 4 palabras con el valor 3, para cargar en un registro xmm    

section .text
global temperature_asm

; TODO LIST:
;            cargar en xmm7 la máscara para borrar las a
;            cargar en xmm6 un 3 cada 32 bits para hacer la división


;void temperature_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

; *src rdi
; *dst rsi
; width rdx 
; height rcx 
; src_row_size r8
; dst_row_size r9

; Cada píxel ocupa 4 bytes (32 bits) -> (b, g, r, a) -> blue, green, red, transparencia. Cada uno ocupa 1 byte y transparencia es siempre 255

; t = (r + g + b) / 3

; dst <r, g, b> = | < 0, 0, 128 + t * 4 >                           si t < 32
;                 | < 0, (t - 32) * 4, 255 >                        si 32 <= t < 96
;                 | < (t - 96) * 4, 255, 255 - (t - 96) * 4 >       si 96 <= t < 160
;                 | < 255, 255 - (t - 160) * 4, 0 >                 si 160 <= t < 224
;                 | < 255 - (t - 224) * 4, 0, 0 >                   si no

; Nos traemos 2 pixeles a la vez, y los extendemos a 16 bits

; Nos quedan los registros así

; |  r1  |  g1  |  b1  |  a1  |  r2  |  g2  |  b2  |  a2  |

; Aplicamos una máscara para poner los valores de a en 0

; |  r1  |  g1  |  b1  |  00  |  r2  |  g2  |  b2  |  00  |

; Hacemos 2 sumas horizontales

; | r1 + g1 | b1 + 00 | r2 + g2 | b2 + 00 | r1 + g1 | b1 + 00 | r2 + g2 | b2 + 00 | r1 + g1 | b1 + 00 | r2 + g2 | b2 + 00 | r1 + g1 | b1 + 00 | r2 + g2 | b2 + 00 |   
; | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 |
 
; Extendemos a 32 bits

; | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 | r1 + g1 + b1 + 00 | r2 + g2 + b2 + 00 |

; Convertimos a float

; Dividimos por 3

; Truncamos los valores, y los agarramos por separado


temperature_asm:
    push rbp
    mov rbp, rsp

    ; Cargamos en xmm6 el valor 3 cada 32 bits, para hacer después la división
    movdqu xmm6, [divisor]

loop_matriz:

	; Comparamos la cantidad de filas restantes para ver si ya terminamos de llenar la matriz
	cmp rcx, 0x0
	je end

	; Armar un registro temporal con width para llevar la cuenta de las posiciones que quedan en la fila
	mov r11, rdx

	; Loopear para las filas
	jmp loop_fila

loop_fila:

	; Nos traemos 2 pixeles, los extendemos a 16 bits y adelantamos el puntero
	PMOVZXBW xmm0, [rdi]
	add rdi, 0x10	

    ; En xmm7 tenemos una máscara para eliminar el valor de a de cada pixel
    pand xmm0, xmm7
    
    ; Hacemos 2 sumas horizontales
    phaddw xmm0, xmm0
    phaddw xmm0, xmm0

    ; Extendemos a 32 bits
    PMOVZXWD xmm0, xmm0

    ; Convertimos a floats
    CVTDQ2PS xmm0, xmm0

    ; Dividimos por 3 (cargados en xmm6 cada 32 bits)
    divps xmm0, xmm6

    ; Truncamos y convertimos a enteros
    ; Manual -> Convert With Truncation Packed Single Precision Floating-Point Values to Packed Dword Integers
    CVTTPS2PI xmm0, xmm0  

    ; Nos traemos 64 bits a un registro separado (t1 y t2)
    movq r10, xmm0
    
    ; Separamos en dos registros de 32 bits, para tener t1 y t2 por separado
    ; Guardamos en eax los 32 bits bajos (t2)
    movd eax, r10
    
    ; Shifteamos r10 a la derecha para poner t1 en la parte baja, y movemos a otro registro
    shr r10,0x20 

    ; Arrancamos las comparaciones

    ; Si es menor a 32
    cmp eax, 32
    jl primer_casouno

    ; Si es mayor o igual a 32 y menor a 96
    cmp eax, 96
    jl primer_casodos

    ; Si es mayor o igual a 96 y menor a 160
    cmp eax, 160
    jl primer_casotres

    ; Si es mayor o igual a 160 y menor a 224
    cmp eax, 224
    jl primer_casocuatro

    jmp primer_casocinco

primer_casouno:

    


    jmp segundo_pixel
primer_casodos:

primer_casotres:

primer_casocuatro:

primer_casocinco:

segundo_pixel:







    
    ; Cargamos los 4 pixeles al destino
	MOVDQU [rsi], xmm0
	add rsi, 0x10	

	; Restamos la cantidad de elementos restantes y volvemos al loop
	sub r11, 0x04
	
	jmp loop_fila


end:
    pop rbp
    ret
