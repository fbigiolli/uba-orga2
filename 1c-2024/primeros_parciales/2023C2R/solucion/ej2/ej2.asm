%define SIZE_PIXEL 4

global combinarImagenes_asm

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
    
    mov eax, r8d ; eax -> height
    mul ecx ; eax -> width * height

    .ciclo:
        cmp ecx, 0
        je .end
        
        movdqu xmm0, [rdi]
        movdqu xmm1, [rsi]


        add rdi, 4 * SIZE_PIXEL ; incrementa ambos punteros
        add rsi, 4 * SIZE_PIXEL
        sub ecx, 4 ; quedan 4 pixeles menos por recorrer
        jmp .ciclo


    .end:
        ; epilogo
        pop rbp
        ret