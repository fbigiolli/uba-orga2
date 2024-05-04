%define SIZE_PIXEL 4

global combinarImagenes_asm

maskblend1: DB 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00  
maskblend2: DB 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00
maskAlpha: DB 0x00, 0x00, 0x00, 0xFF,  0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF 
todos128: times 16 db 128
shuffle_img2: DB 0x02, 0x01, 0x00, 0x03, 0x06, 0x05, 0x04, 0x07, 0x0A, 0x09, 0x08, 0x0B, 0x0E, 0x0D, 0x0C, 0x0F 

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void combinarImagenes(uint8_t *src1, uint8_t *src2, uint8_t *dst,
;uint32_t width, uint32_t height)
; rdi ->  src1,
; rsi ->  src2, 
; rdx -> dst,
; rcx -> width, 
; r8 -> height 
combinarImagenes_asm:
    ; prologo
    push rbp ; stack alineado
    mov rbp, rsp
    mov r10, rdx

    mov eax, r8d ; eax -> height
    mul ecx ; eax -> width * height
    shr eax, 2 ; -> divido por 4 porque traigo de a 4 pixeles
    mov r8d, eax 

    xor rax, rax

    movdqu xmm7, [maskAlpha]
    movdqu xmm8, [todos128]
    movdqu xmm9, [shuffle_img2]

    .ciclo:
        movdqu xmm1, [rdi + rax]
        movdqu xmm2, [rsi + rax]

        pshufb xmm2, xmm9 ; shift componentes pixeles
        ; componente blue
        movdqu xmm3, xmm1
        paddusb xmm3, xmm2 

        ; componente green
        movdqu xmm4, xmm1 ; xmm4 -> pixeles A
        movdqu xmm0, xmm1 ; xmm0 -> pixeles A
        movdqu xmm6, xmm1 ; xmm6 -> pixeles A
        ; calculo ambos casos posibles
        pavgb xmm4, xmm2 ; average
        psubusb xmm6, xmm2 ; resta

        movdqu xmm5, xmm2
        ; desplazo en 128 los numeros para poder usar comp signada 
        paddb xmm5, xmm8 
        paddb xmm0, xmm8

        ; compare y uso el resultado como mascara para acumular en xmm4 la comp g
        pcmpgtb xmm0, xmm5 
        pblendvb xmm4, xmm6

        ; componente red
        movdqu xmm5, xmm2
        psubusb xmm5, xmm1

        ; merge tres componentes
        movdqu xmm0, [maskblend1]
        pblendvb xmm3, xmm4

        movdqu xmm0, [maskblend2]
        pblendvb xmm3, xmm5

        por xmm3, xmm7
        movdqu [r10 + rax], xmm3

        add rax, 16

        ; loopeo
        dec r8w
        jnz .ciclo

    pop rbp
    ret

