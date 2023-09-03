extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
    push rbp
    mov rbp, rsp

    xor rax, rax ;=0

    cmp byte [rdi], 0
    je .check_b

.loop:
    ; Cargo en al y en bl el primer char
    mov al, byte [rdi]
    mov bl, byte [rsi]
    ; Compara al y bl
    cmp al, bl
    ; Si son diferentes salto
    jne .not_equal

    ; Si alguno de los caracteres es nulo, devuelvo
    cmp al, 0
    je .check_b

    inc rdi
    inc rsi
    ; Vuelve a comparar
    jmp .loop

.not_equal:
    ; Se fija si a > b
    jae .greater
    mov rax, -1
    jmp .end

.check_b:
    ;
    cmp byte [rsi], 0
    je .equal

.greater:
    ; Si a > b, salta a .greater
    mov rax, 1
    jmp .end

.equal:
    ; rax=0;
    xor rax, rax

.end:
    pop rbp
    ret
	;deje pq ya estoy mezclandome todo

; char* strClone(char* a)
strClone:
	ret

; void strDelete(char* a)
strDelete:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
	ret


