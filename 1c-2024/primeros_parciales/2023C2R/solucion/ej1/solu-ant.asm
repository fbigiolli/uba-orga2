; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0


%define OFFSET_FIRST 0
%define OFFSET_LAST 8

%define OFFSET_NEXT 0
%define OFFSET_PREVIOUS 8
%define OFFSET_TYPE 16
%define OFFSET_HASH 24


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


string_proc_list_create_asm:

    push rbp
    mov rbp, rsp

    mov rdi, 16
    call malloc ;devuelve en rax el puntero 

    mov qword [rax + OFFSET_FIRST], NULL
    mov qword [rax + OFFSET_LAST], NULL

    pop rbp
    ret
    
; • Los par´ametros enteros se pasan de izquierda a derecha en
; RDI, RSI, RDX, RCX, R8, R9 respectivamente
; • Los par´ametros flotantes se pasan de izquierda a derecha en
; XMM0, XMM1, XMM2, XMM3, XMM4, XMM5, XMM6, XMM7
; respectivamente
; • Si no hay registros disponibles para los par´ametros enteros
; y/o flotantes se pasar´an de derecha a izquierda a trav´es de
; la pila haciendo PUSH.
; • Las estructuras se tratan de una forma especial (ver
; referencia). Si son grandes se pasa un puntero a la misma
; como par´ametro.



; en dil esta el type y en rsi el hash
;string_proc_node* string_proc_node_create(uint8_t type, char* hash){
    ; rdi = type, rsi = hash

string_proc_node_create_asm:

    push rbp
    mov rbp, rsp
    push rdi
    push rsi


    ;primero hay que pedir memoria
    mov rdi, 32
    call malloc
    ;en rax estará el puntero
    
    pop rsi
    pop rdi

    mov qword [rax + OFFSET_NEXT], NULL
    mov qword [rax + OFFSET_PREVIOUS], NULL
    mov byte [rax + OFFSET_TYPE], r9b
    mov qword [rax + OFFSET_HASH], rsi

    pop rbp
    ret


;void string_proc_list_add_node(string_proc_list* list, uint8_t type, char* hash){
; list = rdi  type = rsi  char =  rdx

 string_proc_list_add_node_asm:
    push rbp ;alineada la pila
    mov rbp, rsp

    push rdi
    push rsi
    push rdx
    xor r8,r8
    push r8 ; alineo la pila a 16

    mov rdi, rsi
    mov rsi, rdx
    call string_proc_node_create_asm
    ;en rax me queda el puntero al nuevo nodo

    pop r8
    pop rdx
    pop rsi
    pop rdi

    xor r9,r9 
    mov r9, [rdi + OFFSET_FIRST]
    cmp r9, NULL
    je .hayunosolo

    mov r8, [rdi + OFFSET_LAST] ; ahora en r8 tengo el puntero que apunta al ultimo,el cual debo modificar
    mov qword [r8 + OFFSET_NEXT], rax ; muevo el puntero al ultimo
    mov qword [rax + OFFSET_PREVIOUS], r8 ; muevo el puntero a anteultimo 
    mov qword [rdi + OFFSET_LAST], rax ; ahora el último es el creado
    jmp .end
    
    .hayunosolo:
        mov [rdi + OFFSET_FIRST], rax ; ahora el primero es el nuevo

    .end:
        pop rbp
        ret

; char* string_proc_list_concat(string_proc_list* list, uint8_t type , char* hash){
; lsit = rdi, type = rsi, hash = rdx
string_proc_list_concat_asm:

    push rbp
    mov rbp, rsp
    push r12
    push r13
    mov r12b,sil ; guardo en r12b el type del 
    mov r13,rdx ; guardo el hash en r13


    mov r8, [rdi + OFFSET_FIRST] ; en r8 tengo el primer nodo de la lista

    cmp r8, NULL ; veo si el primero es null,entonces devuelvo el hash solo
    je .hayunosolo

    .loop:
        cmp r8, NULL ; veo si currentNode es null
        je .end

        ;chequeo si son del mismo type

        cmp byte [r8 + OFFSET_TYPE], r12b  ; comparo tipos
        je .sigoLoop ; si no son iguales sigo loop

        mov rsi,[r8 + OFFSET_HASH] ; el hash del currentNode
        mov rdi, r13 ; el hash acumulado

        call str_concat ; en rax tengo el nuevo hash
        mov r13,rax ; en r13 me guardo el nuevo
        
        .sigoLoop:
            mov r8, [r8 +  OFFSET_NEXT] ; me muevo al siguiente y loopeo
            jmp .loop

    .hayunosolo:
        mov rax, rdx 
        pop r13
        pop r12
        pop rbp
        ret

    .end:

        mov rax, r13 
        pop r13
        pop r12
        pop rbp
        ret