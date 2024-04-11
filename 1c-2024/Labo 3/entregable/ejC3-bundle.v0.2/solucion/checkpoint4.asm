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
; 0 si son iguales
; 1 si a < b
; -1 si a > b
; int32_t strCmp(char* a, char* b)
strCmp:

	ret

; char* strClone(char* a)
strClone:
	;prologo
	push rbp 
	mov rbp, rsp 

	push r12 ; registro para preservar el puntero al llamar a strLen
	push r13 ; alineadita la pila
	mov r12, rdi ; guardamos el puntero al string a copiar
	
	call strLen
	
	mov rdi, rax ; pasamos a rdi el largo del string para llamar a malloc, que toma como parametro la cant de bytes.
	call malloc ; en rax tenemos el puntero a la memoria reservada
	mov r13, rax ; movemos el puntero al string a devolver a r13 para iterar sobre el. En rax queda el puntero que vamos a retornar
	xor rdi, rdi ; limpiamos rdi porque lo vamos a usar para almacenar el char a copiar.
	
.loop:
	cmp [r12], byte 0
	je .end ; si son iguales, entonces llegamos al final del string, terminamos.
	mov dil, byte [r12] ; Traemos el char a copiar y lo copiamos en el destino
	mov byte [r13], dil	
	inc r12 ; Incrementamos punteros
	inc r13
	jmp .loop

.end:
	;epilogo
	pop r13
	pop r12
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
	;prologo
	push rbp 
	mov rbp, rsp 

	xor rax,rax

.is_null:
	cmp rdi, 0 ; comparamos el puntero con null para ver si empezamos a iterar
	je .end
	cmp	[rdi], byte 0  ; comparamos el puntero con el string vacio (no va el /0)
	je .end
	
.loop:
	inc rax ; aumentamos el contador
	inc rdi	; movemos el puntero
 ; 
	cmp [rdi], byte 0 ; 
	jne .loop

.end:
	;epilogo
	pop rbp
	ret