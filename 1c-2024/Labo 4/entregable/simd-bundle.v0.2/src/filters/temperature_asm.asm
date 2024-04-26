global temperature_asm

section .data

mascaraSinTransparencia:  dd 0x00FFFFFF, 0x00FFFFFF, 0x00FFFFFF, 0x00FFFFFF 
mascaraDivisionTres: times 4 dd 0x00000003

; OJO PUEDE ESTAR MAL
mascara32:  times 4 dd 0x0000001F   ; 31, si es > 31 entonces es >= 32. Negado es < 32
mascara96:  times 4 dd 0x0000005F   ; 95  idem 
mascara160: times 4 dd 0x0000009F   ; 159 idem
mascara224: times 4 dd 0x000000DF   ; 223 idem

mascaraTodosUnos: times 4 dd 0xFFFFFFFF   ; 223 idem

mascaraShuffleT: dd 0x01010101, 0x00000000, 0x01010101, 0x00000000 ; tal vez sea al reves, ojo
                    
section .text
;void temperature_asm(unsigned char *src,   -> rdi
;              unsigned char *dst,          -> rsi
;              int width,                   -> rdx 
;              int height,                  -> rcx
;              int src_row_size,            -> r8
;              int dst_row_size);           -> r9

; En memoria se guarda en el orden B, G, R, A

temperature_asm:
    push rbp
	mov rbp, rsp 
    
    imul rcx, rdx ; en rcx vamos a tener la cantidad de pixeles totales

    movdqu xmm8, [mascaraShuffleT]
    movdqu xmm9, [mascaraTodosUnos]

    movdqu xmm10, [mascaraSinTransparencia]
    movdqu xmm11, [mascaraDivisionTres]
    cvtdq2ps xmm11, xmm11 ; lo pasamos a float porque lo vamos a usar para dividir

    movdqu xmm12, [mascara32]
    movdqu xmm13, [mascara96]
    movdqu xmm14, [mascara160]
    movdqu xmm15, [mascara224]

    .loop:

        cmp rcx, 0  ; Cantidad de pixeles restantes
        je .end

        movq xmm0, [rdi] ; Trae de memoria 4 pixeles
        ; xmm0 = | -- | -- | -- | -- | -- | -- | -- | -- | B1 | G1 | R1 | A1 | B0 | G0 | R0 | A0 |
        
        pand xmm0, xmm10 ; sacamos la componente A de cada pixel
        ; xmm0 = | -- | -- | -- | -- | -- | -- | -- | -- | B1 | G1 | R1 | 00 | B0 | G0 | R0 | 00 |

        pmovzxbw xmm1, xmm0 ; Extendemos a words
        ; xmm1 = |   B1    |    G1   |    R1   |    00   |    B0   |    G0   |    R0   |    00   |

        phaddw xmm1, xmm1 ; Hacemmos las sumas horizontales 
        ; xmm1 = | B1 + G1 | R1 + 00 | B0 + G0 | R0 + 00 | B1 + G1 | R1 + 00 | B0 + G0 | R0 + 00 | 
        phaddw xmm1, xmm1
        ; xmm1 = |B1+G1+R1+00|B0+G0+R0+00|B1+G1+R1+00|B0+G0+R0+00|B1+G1+R1+00|B0+G0+R0+00|B1+G1+R1+00|B0+G0+R0+00|  
        
        pmovzxwd xmm1, xmm1 ; extendemos a double word las sumas
        ; xmm1 = |B1+G1+R1+00|B0+G0+R0+00|B1+G1+R1+00|B0+G0+R0+00|

        cvtdq2ps xmm1, xmm1 ; Convert packed double integers to packed single precision floating point values
        divps xmm1, xmm11 ; dividimos los valores por 3 con la mascara

        cvttps2dq xmm1, xmm1  ; Convertimos a entero 
        ; xmm1 = |  t1  |  t0  |  t1  |  t0  |

        packssdw xmm1, xmm1  ; Packs 32 bits (signado) a 16 bits (signado) usando saturation
        packuswb xmm1, xmm1  ; Packs 16 bits (signado) a 8 bits (sin signo) usando saturation
        ; xmm1 = | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 | t1 | t0 |
               
        pshufb xmm1, xmm8
        ; xmm1 = | t1 | t1 | t1 | t1 | t0 | t0 | t0 | t0 | t1 | t1 | t1 | t1 | t0 | t0 | t0 | t0 |

        .armarResultados:
        ; xmm3 - xmm7
        
        
        .comparaciones:

            ; CASO 1, t menor a 32
            movdqu xmm2, xmm1

            ; Compare packed signed int for greater than
            pcmpgtd xmm2, xmm12   ; t > 31, es igual a t >= 32
            pxor xmm2, xmm9       ; !(t > 31) -> t <= 31 -> t < 32
    



        sub rcx, 2   
        jmp .loop    
    
    
    .end:
        pop rbp
        ret
