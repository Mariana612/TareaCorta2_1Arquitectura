section .data
	text1 db "Ingrese la palabra a cambiar", 0xA
	text2 db "Error: Ingrese elementos validos", 0xA

section .bss
	textoC resb 101

section .text
	global _main

_main:
	call _printText1
	call _getText
	call _compareTexts


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

_compareTexts:
	mov al, byte[esi]
	cmp al, 0xA
	je _printFinalText
	;je _finishCode
	cmp al,'A'
	jb _finishCodeError
	cmp al,'Z'
	ja _compareTextsLower
	jmp _toLowerCase

_compareTextsLower:
	cmp al,'a'
	jb _finishCodeError
	cmp al,'z'
	ja _compareTextsLower
	jmp _toUpperCase
	
	
_toUpperCase:
	mov al, byte[esi]
	cmp al, 0xA
	je _printFinalText
	sub al, 32
	mov byte[esi],al
	inc esi
	jmp _compareTexts

_toLowerCase:
	mov al, byte[esi]
	cmp al, 0xA
	je _printFinalText
	add al, 32
	mov byte[esi],al
	inc esi
	jmp _compareTexts

_printFinalText:
	mov rax, 1
	mov rdi, 1
	mov rsi, textoC
	mov rdx, 101
	syscall 
	call _finishCode

_finishCodeError:
	mov rax, 1
	mov rdi, 1
	mov rsi, text2
	mov rdx, 33
	syscall 

	mov rax, 60
	mov rdi, 0
	syscall

_finishCode:
	mov rax, 60
	mov rdi, 0
	syscall
