global miraQueCoincidencia

section .rodata

mascaraNegadora: times 16 db 0xFF
mascaraTodos4: times 4 dd 4

floats: dd 0.114, 0.587, 0.299, 0.0 

;########### SECCION DE TEXTO (PROGRAMA)
section .text
;void miraQueCoincidencia( uint8_t *A, uint8_t *B, uint32_t N, uint8_t *laCoincidencia )
; rdi -> puntero A, rsi -> puntero B, rdx -> N, rcx -> puntero dst
miraQueCoincidencia:
    ; prologo
    push rbp
    push r12
    mov rbp, rsp

    mov rax, rdx 
    mul rdx ; rax -> N*N
    shr rax, 1 ; rax -> N*N / 2 , traemos de a 2 pixeles porque hay que extender
    
    xor r8, r8 ; r8 -> offset imgs
    xor r12, r12 ; r12 -> offset dest

    movdqu xmm11, [mascaraNegadora]
    movdqu xmm12, [mascaraTodos4]
    movups xmm13, [floats]

    .ciclo:
        cmp rax, 0
        je .end

        movdqu xmm1, [rdi + r8] ; xmm1 -> 2 pixeles de A
        movdqu xmm2, [rsi + r8] ; xmm2 -> 2 pixeles de B

        pmovzxbd xmm3, xmm1 ; xmm3 -> primer pixel de A, cada componente extendida a dword.
        pmovzxbd xmm4, xmm2 ; xmm4 -> primer pixel de B, cada componente extendida a dword.

        movdqu xmm6, xmm3 ; xmm6 -> copia del primer pixel de la imagen para hacer el calculo despues

        ; xmm3 -> |   B0   |   G0   |   R0   |   A0   |  -> Imagen A
        ; xmm4 -> |   B0   |   G0   |   R0   |   A0   |  -> Imagen B

        psrldq xmm1, 4 ; muevo 4 bytes, en la parte baja me queda el segundo pixel
        psrldq xmm2, 4

        pmovzxbd xmm1, xmm1 ; xmm1 -> segundo pixel de A, cada componente extendida a dword.
        pmovzxbd xmm2, xmm2 ; xmm2 -> segundo pixel de B, cada componente extendida a dword.

        movdqu xmm7, xmm1 ; xmm7 -> copia del segundo pixel de la imagen para hacer el calculo despues

        ; xmm1 -> |   B1   |   G1   |   R1   |   A1   |  -> Imagen A
        ; xmm2 -> |   B1   |   G1   |   R1   |   A1   |  -> Imagen B

        ; no hace falta corregir por 128, estan extendidos

        ; Comparamos los pixeles componente a componente
        ; | 1111 | 1111  | 1111  | 1111 |
        pcmpeqd xmm3, xmm4 ; primeros pixeles
        pcmpeqd xmm1, xmm2 ; segundos pixeles

        ; Shifteamos cada dword a derecha para dejar solo el bit menos significativo
        ;  |   1 |    1  |    1 |    1 | 
        psrld xmm3, 31 
        psrld xmm1, 31
        
        ; Hacemos 2 sumas horizontales y comparamos con 4
        phaddd xmm3, xmm3
        phaddd xmm3, xmm3
        
        phaddd xmm1, xmm1
        phaddd xmm1, xmm1
    
        ; xmm12 -> | 4 | 4 | 4 | 4 |
        pcmpeqd xmm3, xmm12 ; xmm3 -> mascara primer pixel que deja pasar pixeles de imagenes iguales
        pcmpeqd xmm1, xmm12 ; xmm1 -> mascara segundo pixel que deja pasar pixeles de imagenes iguales

        ; | 1111 | 1111 | 1111 | 1111 |
        ; Si quedan todos 1s, los pixeles son iguales. Si son distintos, quedan todos 0s. Hacemos and con el resultado
        pand xmm6, xmm3 ;   xmm6 -> Pixel 0 de imagen A (si son iguales)
        pand xmm7, xmm1 ;   xmm7 -> Pixel 1 de imagen A (si son iguales)

        ; cvtdq2ps: Convert Packed Doubleword Integers to Packed Single Precision Floating-PointValues
        cvtdq2ps xmm6, xmm6 ; xmm6 -> paso a float
        cvtdq2ps xmm7, xmm7 ; xmm7 -> paso a float

        ; xmm13 ->  |  0.114  |  0.587  |  0.299  |  0000  |

        mulps xmm6, xmm13 ; xmm6 -> pixel imgs iguales calculado
        mulps xmm7, xmm13 ; xmm7 -> pixel imgs iguales calculado


        ; cvttps2dq: Convert with truncation packed single precision floating-point values to packed signed doubleword integer values 
        ; cvtps2dq: Convert packed single precision floating-point values to packed signed doubleword integers
 
        haddps xmm6, xmm6 
        haddps xmm6, xmm6 ; xmm6 -> todos los componentes del pixel valen lo mismo (R0*0.299 + G0*0.587 + B0*0.114)
        
        haddps xmm7, xmm7 
        haddps xmm7, xmm7 ; xmm7 -> todos los componentes del pixel valen lo mismo (R1*0.299 + G1*0.587 + B1*0.114)

        cvttps2dq xmm6, xmm6 ; convert a integer para suma horizontal
        cvttps2dq xmm7, xmm7 ; convert a integer para suma horizontal

        ; pasar a byte
        packssdw xmm6, xmm6
        packuswb xmm6, xmm6 ; xmm6 -> pixel de tam normal con (R0*0.299 + G0*0.587 + B0*0.114) en cada componente

        packssdw xmm7, xmm7
        packuswb xmm7, xmm7 ; xmm7 -> pixel de tam normal con (R1*0.299 + G1*0.587 + B1*0.114) en cada componente

        ; Negamos mascaras para tener 1s donde los pixeles son distintos
        pxor xmm3, xmm11 ; mascara primer pixel (xmm6)
        pxor xmm1, xmm11 ; mascara segundo pixel (xmm7)

        pand xmm3, xmm11  
        pand xmm1, xmm11 ; nos deja en 255 aquellos pixeles que no son iguales

        ; pasamos las mascaras a bytes
        ; packssdw xmm3, xmm3
        ; packuswb xmm3, xmm3 

        ; packssdw xmm1, xmm1
        ; packuswb xmm1, xmm1 

        paddb xmm3, xmm6
        paddb xmm1, xmm7

        movq r9, xmm3 
        mov [rcx + r12], r9b

        movq r9, xmm1
        mov [rcx + r12 + 1], r9b
        
        ; movdqu xmm , [rcx + r8] ; lleva a memoria resultado

        .siguiente:
            dec rax
            add r8, 8 ; r8 -> offset pixeles origen
            add r12, 2 ; r12 -> offset proximos 2 pixeles
            jmp .ciclo

    .end:
        ; epilogo
        pop r12
        pop rbp
        ret
