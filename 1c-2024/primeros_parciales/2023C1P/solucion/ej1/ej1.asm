%define OFFSET_LADO_LARGO 0 
%define OFFSET_NOMBRE 8
%define OFFSET_LADO_CORTO 16

%define SIZE_TEMPLO 24

global templosClasicos
global cuantosTemplosClasicos

extern malloc

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;templo* templosClasicos(templo *temploArr, size_t temploArr_len);
; rdi -> array templos, rsi -> size array
templosClasicos:
    ; prologo
    push rbp
    mov rbp, rsp
    push r12
    push r13 ; stack alineado

    mov r12, rdi ; r12 -> puntero array templos
    mov r13, rsi ; r13 -> size array
    
    call cuantosTemplosClasicos ; rax -> cant templos clasicos

    xor r9, r9 
    mov r9, SIZE_TEMPLO 

    mul r9 ; rax -> cant templos clasicos * size templo
    mov rdi, rax
    call malloc ; rax -> puntero a array res

    xor rdx, rdx ; rdx -> offset array resultado
    xor rcx, rcx ; rcx -> offset array input

    .ciclo:
        cmp r13, 0
        je .end

        xor r8, r8 ; r8 -> lados cortos en byte
        xor r9, r9 ; r9 -> lados largos en byte

        mov r8b, [r12 + rcx + OFFSET_LADO_CORTO] ; r8b -> lado corto
        mov r9b, [r12 + rcx + OFFSET_LADO_LARGO] ; r9b -> lado largo

        shl r8, 1 ; r8b -> 2N
        inc r8 ; r8b -> 2N + 1

        cmp r8, r9
        jne .siguiente ; si no son iguales, no es templo clasico

        ; son iguales, lo copio a res
        mov r8b, [r12 + rcx + OFFSET_LADO_CORTO] ; r8b -> lado corto 
        mov [rax + rdx + OFFSET_LADO_CORTO], r8b ; mando a memoria

        mov r8b, [r12 + rcx + OFFSET_LADO_LARGO] ; r8b -> lado largo 
        mov [rax + rdx + OFFSET_LADO_LARGO], r8b ; mando a memoria

        mov r8b, [r12 + rcx + OFFSET_NOMBRE] ; r8 -> nombre 
        mov [rax + rdx + OFFSET_NOMBRE], r8b ; mando a memoria

        add rdx, SIZE_TEMPLO ; muevo puntero res

        .siguiente:
            dec r13
            add rcx, SIZE_TEMPLO ; muevo puntero array original y decremento size array
            jmp .ciclo

    .end:
        ; epilogo
        pop r13
        pop r12
        pop rbp
        ret


;uint32_t cuantosTemplosClasicos(templo *temploArr, size_t temploArr_len);
; rdi -> array templos, rsi -> tamanio del array
cuantosTemplosClasicos:
    ; prologo
    push rbp
    mov rbp, rsp

    xor rax, rax ; rax -> acumulador
    xor rcx, rcx ; rcx -> offset array 
    
    .ciclo: 
        cmp rsi, 0 ; fin del array
        je .end

        xor r8, r8 ; r8 -> lados cortos en byte
        xor r9, r9 ; r9 -> lados largos en byte

        mov r8b, [rdi + rcx + OFFSET_LADO_CORTO] ; r8b -> lado corto
        mov r9b, [rdi + rcx + OFFSET_LADO_LARGO] ; r9b -> lado largo

        shl r8, 1 ; r8b -> 2N
        inc r8 ; r8b -> 2N + 1

        cmp r8, r9
        jne .siguiente ; si no son iguales, no es templo clasico
        inc rax ; son iguales, aumento contador

        .siguiente:
            add rcx, SIZE_TEMPLO  ; rcx -> proximo puntero a templo
            dec rsi ; rsi -> size - 1
            jmp .ciclo

    ; epilogo
    .end:
        pop rbp
        ret

