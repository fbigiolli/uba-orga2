%define SIZE_PAGO 24
%define SIZE_PAGO_SPLITTED 24
%define SIZE_LIST_ELEMENT 24
%define SIZE_LIST 16

%define OFFSET_FIRST_LISTA 0
%define OFFSET_LAST_LISTA 8

%define OFFSET_ELEM_DATA 0
%define OFFSET_ELEM_NEXT 8
%define OFFSET_ELEM_PREV 16

%define OFFSET_PAGO_MONTO 0
%define OFFSET_PAGO_APROBADO 1
%define OFFSET_PAGO_PAGADOR 8
%define OFFSET_PAGO_COBRADOR 16

%define OFFSET_PAGO_SPLITTED_CANT_APROBADOS 0
%define OFFSET_PAGO_SPLITTED_CANT_RECHAZADOS 1
%define OFFSET_PAGO_SPLITTED_APROBADOS 8
%define OFFSET_PAGO_SPLITTED_RECHAZADOS 16

%define NULL 0

section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp


;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; rdi -> puntero list , rsi -> puntero usuario
contar_pagos_aprobados_asm:
    ;prologo
    push rbp ; stack alineado
    mov rbp, rsp
    push r12
    push r13 ; stack alineado
    push r14 
    sub rsp, 8 ; stack alineado
    
    mov r12, [rdi + OFFSET_FIRST_LISTA] ; r12 -> puntero a primer nodo lista
    mov r13, rsi ; r13 -> puntero usuario a buscar
    
    xor r14, r14 ; r14 -> registro acumulador cantidad de pagos

    .ciclo: 
        cmp r12, NULL ; puntero a NULL, termino la lista
        je .end

        xor rsi, rsi ; limpio todo rsi 
        mov rdi, [r12 + OFFSET_ELEM_DATA] ; rdi -> puntero a data
        mov sil, [rdi + OFFSET_PAGO_APROBADO] ; sil -> aprobado o rechazado
        cmp sil, 1 ; si el pago fue aprobado
        jne .siguiente ; si no fue aprobado vamos al proximo

        ;si fue aprobado, chequear si el nombre coincide con el que buscamos
        mov rdi, [rdi + OFFSET_PAGO_COBRADOR] ; rdi -> nombre pagador
        mov rsi, r13 ; rsi -> nombre a buscar
        call strcmp ; devuelve 0 si son iguales (muy poco intuitivo)
        cmp rax, 0 ; si son iguales, tengo que agregarlo
        jne .siguiente ; si no son iguales, vamos al proximo
        inc r14 ; son iguales, r14 -> r14 + 1

        .siguiente:
            mov r12, [r12 + OFFSET_ELEM_NEXT] ; r12 -> current.next
            jmp .ciclo


    .end:
        xor rax, rax
        mov rax, r14 ; rax -> contador pagos acumulados
        ; epilogo
        add rsp, 8
        pop r14
        pop r13
        pop r12
        pop rbp
        ret

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
    ;prologo
    push rbp ; stack alineado
    mov rbp, rsp
    push r12
    push r13 ; stack alineado
    push r14 
    sub rsp, 8 ; stack alineado
    
    mov r12, [rdi + OFFSET_FIRST_LISTA] ; r12 -> puntero a primer nodo lista
    mov r13, rsi ; r13 -> puntero usuario a buscar
    
    xor r14, r14 ; r14 -> registro acumulador cantidad de pagos

    .ciclo: 
        cmp r12, NULL ; puntero a NULL, termino la lista
        je .end

        xor rsi, rsi ; limpio todo rsi 
        mov rdi, [r12 + OFFSET_ELEM_DATA] ; rdi -> puntero a data
        mov sil, [rdi + OFFSET_PAGO_APROBADO] ; sil -> aprobado o rechazado
        cmp sil, 0 ; si el pago fue rechazado
        jne .siguiente ; si no fue rechazado vamos al proximo

        ;si fue rechazado, chequear si el nombre coincide con el que buscamos
        mov rdi, [rdi + OFFSET_PAGO_COBRADOR] ; rdi -> nombre pagador
        mov rsi, r13 ; rsi -> nombre a buscar
        call strcmp ; devuelve 0 si son iguales (muy poco intuitivo)
        cmp rax, 0 ; si son iguales, tengo que agregarlo
        jne .siguiente ; si no son iguales, vamos al proximo
        inc r14 ; son iguales, r14 -> r14 + 1

        .siguiente:
            mov r12, [r12 + OFFSET_ELEM_NEXT] ; r12 -> current.next
            jmp .ciclo


    .end:
        xor rax, rax
        mov rax, r14 ; rax -> contador pagos acumulados
        ; epilogo
        add rsp, 8
        pop r14
        pop r13
        pop r12
        pop rbp
        ret

; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
; rdi -> puntero lista, rsi -> puntero usuario
split_pagos_usuario_asm:
    ;prologo
    push rbp
    mov rbp, rsp
    push r12
    push r13 ; alineado
    push r14
    push r15 ; alineado
    push rbx
    sub rsp, 8 ; alineado

    mov r12, rdi ; r12 -> puntero lista
    mov r13, rsi ; r13 -> puntero user

    mov rdi, SIZE_PAGO_SPLITTED
    call malloc ; rax -> puntero a struct pago splitted
    mov rbx, rax ; rbx -> puntero a la struct a devolver

    mov rdi, r12 ; reestablezco los parametros para llamar contar pagos rechazados
    mov rsi, r13
    call contar_pagos_aprobados_asm ; rax -> cantidad pagos aprobados
    mov byte [rbx + OFFSET_PAGO_SPLITTED_CANT_APROBADOS], al ; setea cantidad aprobados
    mov rdi, rax ; rdi -> cant pagos aprobados
    shl rdi, 3 ; rdi -> cant pagos aprobados * 8 (size punteros)
    call malloc ; rax -> puntero al array de pagos aprobados
    mov r14, rax; r14 -> preserva puntero al array de pagos aprobados
    mov [rbx + OFFSET_PAGO_SPLITTED_APROBADOS], r14 ; establece el puntero a la primera pos del array

    mov rdi, r12 ; reestablezco los parametros para llamar contar pagos rechazados
    mov rsi, r13
    call contar_pagos_rechazados_asm ; rax -> cantidad pagos rechazados
    mov byte [rbx + OFFSET_PAGO_SPLITTED_CANT_RECHAZADOS], al ; setea cantidad rechazados
    mov rdi, rax
    shl rdi, 3 ;  rdi -> cant pagos rechazados * 8 (size punteros)
    call malloc
    mov r15, rax ; r15 -> preserva puntero al array de pagos rechazados
    mov [rbx + OFFSET_PAGO_SPLITTED_RECHAZADOS], r15 ; establece el puntero a la primera pos del array


    ; ahora si, lo divertido !!!

    ; como ya esta preservado en el struct el puntero al inicio de cada array de punteros a pagos aprobados y rechazados,
    ; puedo mover r14 y r15 cada vez que agrego un nuevo pago.  
    mov r12, [r12 + OFFSET_FIRST_LISTA] ; r12 -> puntero a primer nodo lista

    .ciclo:
        cmp r12, NULL ; puntero a NULL, termino la lista
        je .end

        mov rdi, [r12 + OFFSET_ELEM_DATA] ; rdi -> puntero a data
        mov rsi, [rdi + OFFSET_PAGO_COBRADOR] ; rsi -> puntero a cobrador
        mov rdi, r13 ; rdi -> puntero user a comparar
        call strcmp ; rax -> resultado comparacion
        cmp rax, 0 
        jne .siguiente ; no son iguales, voy al proximo user

        ; son iguales, tengo que ver si el pago es rechazado o aceptado
        xor rsi, rsi ; limpio rsi para usar solo la parte baja y no tener errores
        mov rdi, [r12 + OFFSET_ELEM_DATA] ; rdi -> puntero a data
        mov sil, [rdi + OFFSET_PAGO_APROBADO] ; rsi -> pago aprobado (o no)
        cmp sil, 1 ; pago aprobado
        je .pagoAprobado

        ; pago no aprobado
        mov [r15], rdi ; posActualArrayAprobados (r14) = punteroAPagoT(rdi)
        add r15, 8 ; me corro 1 posicion en el array, 8 bytes porque es puntero
        jmp .siguiente

        .pagoAprobado:
            mov [r14], rdi ; posActualArrayAprobados (r15) = punteroAPagoT(rdi)
            add r14, 8 ; me corro 1 posicion en el array, 8 bytes porque es puntero

        .siguiente:
            mov r12, [r12 + OFFSET_ELEM_NEXT] ; r12 -> current.next
            jmp .ciclo

    .end:
        ; epilogo
        mov rax, rbx ; rax -> estructura a devolver
        add rsp, 8
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret
