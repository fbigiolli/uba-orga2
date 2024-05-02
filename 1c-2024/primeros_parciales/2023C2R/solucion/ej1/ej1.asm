; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

;/** defines size lista y nodo **/
%define SIZE_LISTA 16
%define SIZE_NODO 32

;/** defines offsets nodo y lista **/
%define OFFSET_FIRST_LISTA 0
%define OFFSET_LAST_LISTA 8
%define OFFSET_NEXT_NODO 0
%define OFFSET_PREVIOUS_NODO 8
%define OFFSET_TYPE_NODO 16
%define OFFSET_HASH_NODO 24

section .data

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat


; string_proc_list* string_proc_list_create_asm(void);
string_proc_list_create_asm:
    ;prologo
    push rbp ; stack alineado
    mov rbp, rsp

    mov rdi, SIZE_LISTA
    call malloc

    mov qword [rax + OFFSET_FIRST_LISTA], NULL
    mov qword [rax + OFFSET_LAST_LISTA], NULL

    ;epilogo
    pop rbp
    ret

;string_proc_node* string_proc_node_create_asm(uint8_t type, char* hash);
; rdi -> type, rsi -> hash
string_proc_node_create_asm:
    ;prologo
    push rbp ; stack alineado
    mov rbp, rsp

    push rdi
    push rsi ; stack alineado
    
    mov rdi, SIZE_NODO
    call malloc

    pop rsi
    pop rdi ; recupero valores con los que llamaron a la funcion

    mov qword [rax + OFFSET_NEXT_NODO], NULL
    mov qword [rax + OFFSET_PREVIOUS_NODO], NULL
    mov [rax + OFFSET_TYPE_NODO], rdi
    mov [rax + OFFSET_HASH_NODO], rsi

    ; epilogo
    pop rbp
    ret


string_proc_list_add_node_asm:
    ; prologo
    push rbp ; stack alineado
    mov rbp, rsp
    push rdi
    sub rsp, 8 ; stack alineado

    mov rdi, rsi
    mov rsi, rdx

    call string_proc_node_create_asm ; rax -> nodo*

    add rsp, 8 ; ahora rsp apunta al valor viejo de rdi
    pop rdi ; stack alineado 
    
    mov rsi, [rdi + OFFSET_LAST_LISTA] ; rsi -> pointer al last de la lista
    cmp rsi, NULL
    je .listaVacia

    ; sigue ejecucion, lista no vacia
    .listaNoVacia:
        mov rsi, [rdi + OFFSET_LAST_LISTA] ; rsi -> pointer al last de la lista

        mov [rax + OFFSET_PREVIOUS_NODO], rsi ; previous del nuevo nodo es last de la lista
        mov [rsi + OFFSET_NEXT_NODO], rax ; next del last de la lista es el nuevo nodo
        mov [rdi + OFFSET_LAST_LISTA], rax ; last de la lista es el nuevo nodo
        jmp .end 

    .listaVacia: ; se define como first y last de la lista, previous y next del nodo quedan en null
        mov [rdi + OFFSET_FIRST_LISTA], rax
        mov [rdi + OFFSET_LAST_LISTA], rax
        jmp .end ; no hace falta pero por declaratividad

    .end: ; epilogo
    pop rbp
    ret

;char* string_proc_list_concat_asm(string_proc_list* list, uint8_t type, char* hash);
; rdi -> list*, rsi -> type, rdx -> hash
string_proc_list_concat_asm:
    ; prologo
    push rbp ; stack alineado
    mov rbp, rsp
    push r12
    push r13 ; stack alineado
    push r14 
    push r15 ; stack alineado

    mov r12, rdi ; r12 -> puntero a lista
    mov r13, rdx ; r13 -> hash   
    mov r14, rsi ; r14 -> type

    ; PIDO MEMORIA Y YA MANDO HASH A MEMORIA
    mov rdi, 1 ; pido 1 byte para el str vacio
    call malloc
    mov byte [rax], 0 ; string vacio
    mov r15, rax ; r15 -> puntero temporal al string vacio
    mov rdi, rax ; rdi -> str vacio
    mov rsi, r13 ; rsi -> hash
    call str_concat ; rax -> hash en heap
    mov r13, rax ; r13 -> hash en heap
    mov rdi, r15 ; libera memoria del string vacio
    call free
    mov rax, r13 

    ; LISTA VACIA
    cmp qword [r12 + OFFSET_FIRST_LISTA], NULL ; check lista vacia
    je .end ; me voy al epilogo, en rax ya esta hash en heap

    ; no es vacia, accedo al primer nodo, me guardo puntero al heap en no volatil y entro al ciclo
    mov r12, [r12 + OFFSET_FIRST_LISTA]
    mov r13, rax ; r13 -> hash en heap

    .ciclo:
        cmp r12, NULL ; el nodo actual es null
        je .end

        cmp [r12 + OFFSET_TYPE_NODO], r14 ; chequeo si son del mismo tipo
        je .concat

        .avanzarNodo:
            mov r12, [r12 + OFFSET_NEXT_NODO] ; r12 -> nodo next
            jmp .ciclo

        .concat:
            mov rdi, r13 ; muevo hash a rdi para pasarlo como parametro
            mov rsi, [r12 + OFFSET_HASH_NODO] ; muevo el hash del nodo
            call str_concat ; en rax tengo el str concatenado
            mov rdi, r13 ; en rdi ahora tengo el antiguo hash
            mov r13, rax ; guardo en r13 el str concatenado nuevo
            call free ; libero la  memoria del str anterior
            mov rax, r13 ; rax -> hashes concatenados
            jmp .avanzarNodo

    .end: ; epilogo  
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret
