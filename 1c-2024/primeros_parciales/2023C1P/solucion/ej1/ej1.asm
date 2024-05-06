%define OFFSET_LADO_LARGO 0 
%define OFFSET_NOMBRE 8
%define OFFSET_LADO_CORTO 16

%define SIZE_TEMPLO 24

global templosClasicos
global cuantosTemplosClasicos



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
    push r14
    push r15 ; stack alineado
    push rbx
    sub rsp, 8

    xor r15, r15 ; r15 -> offset array input
    xor rbx, rbx ; rbx -> offset array resultado

    mov r12, rdi ; r12 -> preserva puntero array templos
    mov r13, rsi ; r13 -> preserva size array

    xor rdx, rdx
    mov rdx, 8

    call cuantosTemplosClasicos ; rax -> cant de templos clasicos
    mul rdx ; rax -> cant de templos clasicos * size puntero
    mov rdi, rax ; rdi -> cant de templos clasicos * size puntero
    call malloc ; rax -> puntero a array a devolver
    mov r14, rax ; r14 -> puntero a array a devolver 

    .ciclo:
        cmp r13, 0 ; termino de recorrer el array
        je .end

        mov al, [r12 + r15 + OFFSET_LADO_CORTO] ; al -> lado corto
        mov cl, [r12 + r15 + OFFSET_LADO_LARGO] ; cl -> lado largo

        mov rdi, 2 ; rdi para multiplicar x2
        mul dil ; al -> 2N
        inc al ; al -> 2N + 1

        cmp al, cl
        jne .siguiente ; si no son iguales, no es templo clasico

        ; son iguales, pido memoria para un templo y lo copio
        mov rdi, SIZE_TEMPLO 
        call malloc ; rax -> puntero a struct templo

        mov cl, [r12 + r15 + OFFSET_LADO_LARGO] ; cl -> lado largo
        mov [rax + OFFSET_LADO_LARGO], cl

        mov rcx, [r12 + r15 + OFFSET_NOMBRE] ; rcx -> nombre
        mov [rax + OFFSET_NOMBRE], rcx
        
        mov cl, [r12 + r15 + OFFSET_LADO_CORTO] ; cl -> lado corto
        mov [rax + OFFSET_LADO_CORTO], cl

        mov [r14 + rbx], rax ; manda a memoria el puntero reservado
        add rbx, 8 ; rbx -> offset a proxima posicion del array

        .siguiente:
            add r15, 8  ; r15 -> proximo puntero a templo
            dec r13
            jmp .ciclo ; loop


    ; epilogo
    .end:
        mov rax, r14 ; rax -> puntero a array res
        add rsp, 8
        pop rbx
        pop r15
        pop r14
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

    xor r8, r8 ; r8 -> offset array
    xor r9, r9 ; r9 -> acumulador
    xor rbx, rbx ; rbx -> tiene el 2 para multiplicar
    xor rax, rax ; rax -> lados cortos en byte   
    xor rcx, rcx ; rcx -> lados largos en byte
    mov rbx, 2

    .ciclo: 
        cmp rsi, 0 ; fin del array
        je .end

        mov al, [rdi + r8 + OFFSET_LADO_CORTO] ; al -> lado corto
        mov cl, [rdi + r8 + OFFSET_LADO_LARGO] ; cl -> lado largo

        mul bl ; al -> 2N
        inc al ; al -> 2N + 1

        cmp al, cl
        jne .siguiente ; si no son iguales, no es templo clasico
        inc r9 ; son iguales, aumento contador

        .siguiente:
            dec rsi ; rsi -> size - 1
            add r8, 8  ; r8 -> proximo puntero a templo
            jmp .ciclo

    ; epilogo
    .end:
        mov rax, r9 ; rax -> total templos clasicos 
        pop rbp
        ret

