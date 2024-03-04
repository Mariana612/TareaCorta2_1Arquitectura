section .data
	text1 db "Ingrese la palabra a cambiar", 0xA

section .bss
	textoC resb 101

section .text
	global _main

_main:
	call _printText1
	call _getText
	call _toLowerCase
	;call _printFinalText

	mov rax, 60
	mov rdi, 0
	syscall

_printText1:
	mov rax, 1
	mov rdi, 1
	mov rsi, text1
	mov rdx, 29
	syscall 
	ret

_getText:
	mov rax, 0
	mov rdi, 0
	mov rsi, textoC
	mov rdx, 101
	syscall 
	ret

_toLowerCase:
	mov al, byte[esi]
	cmp al, 0
	je _printFinalText
	sub al, 32
	mov byte[esi],al
	jmp _toLowerCase

_printFinalText:
	mov rax, 1
	mov rdi, 1
	mov rsi, textoC
	mov rdx, 101
	;syscall 
	;ret
	mov rax, 60
	mov rdi, 0
	syscall
