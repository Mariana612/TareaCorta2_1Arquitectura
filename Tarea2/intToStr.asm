section .data
	text1 db "Ingrese un numero", 0xA ;len 18
	digitos db '0123456789ABCDEF'

section .bss
	number resb 21
	num1 resb 101
	
section .text
global _start

_start:
	call _printText1	;Imprime el texto inicial
	call _getText		;Obtiene el texto del teclado
	call _ATOI
	

	;call __to_string

	call _finishCode

_printText1:			;texto inicial
	mov rax, 1
	mov rdi, 1
	mov rsi, text1
	mov rdx, 18
	syscall 
	ret

_getText:			;obtiene el texto
	mov rax, 0
	mov rdi, 0
	mov rsi, num1
	mov rdx, 101
	syscall 
	ret

_ATOI:
	mov rax, num1
	xor rbx, rbx
	xor rax, rax
	lea rcx, [num1]
	mov bl, byte[rcx]
	ret

__to_string:
	push rax
	
	mov rdi, 1
	mov rcx, 1
	mov rbx, 10
	get_divisor:
		xor rdx, rdx
		div rbx  ; rax = 4
		
		cmp rax, 0 ; false
		je _after
		imul rcx, 10  ; 100
		inc rdi
		jmp get_divisor
		
		
	_after:
		pop rax
		push rdi
		
	to_string:
		xor rdx, rdx
		div rcx ; RDX = 32, RAX = 4
		
		add al, "0" ;52 = "4"
		mov [rsi], al
		inc rsi
		
		push rdx
		xor rdx, rdx
		mov rax, rcx
		mov rbx, 10
		div rbx
		mov rcx, rax
		
		pop rax
		
		cmp rcx, 0
		jg to_string
		
	pop rdx
	ret

_finishCode:			;finaliza codigo
	mov rax, 60
	mov rdi, 0
	syscall