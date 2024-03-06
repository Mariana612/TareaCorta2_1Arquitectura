section .data
	text1 db "Ingrese la palabra a cambiar", 0xA
	text2 db "Error: Ingrese elementos validos", 0xA

section .bss
	textoC resb 101

section .text
	global _main

_main:
	call _printText1	;Imprime el texto inicial
	call _getText		;Obtiene el texto del teclado
	call _compareTexts	;compara las letras a ver si son mayusculas o minusculas


_printText1:			;texto inicial
	mov rax, 1
	mov rdi, 1
	mov rsi, text1
	mov rdx, 29
	syscall 
	ret

_getText:			;obtiene el texto
	mov rax, 0
	mov rdi, 0
	mov rsi, textoC
	mov rdx, 101
	syscall 
	ret

_compareTexts:
	mov al, byte[esi]	;obtiene el caracter menos significativo
	cmp al, 0xA		;se asegura de que sea el final
	je _printFinalText	;fin
	cmp al, ' '
	je _addSpace
	cmp al,'A'		;le resta al caracter 41 si es menos de 41 entonces no es valido
	jb _finishCodeError	;da error
	cmp al,'Z'		;le resta al caracter 5A si es superior entonces puede ser que sea una letra minuscula
	ja _compareTextsLower	;envia a check de minuscula
	jmp _toLowerCase 	;cambia a minuscula el caracter

_compareTextsLower:
	cmp al,'a'		;le resta al caracter 61 si es menos de 61 entonces no es valido
	jb _finishCodeError	;da error
	cmp al,'z'		;le resta al caracter 7A si es superior entonces da error
	ja _finishCodeError	;da error
	jmp _toUpperCase	;cambia a mayuscula el caracter

_addSpace:
	mov byte[esi],al
	inc esi
	jmp _compareTexts
		
	
_toUpperCase:			;cambia a mayuscula
	mov al, byte[esi]
	sub al, 32		;resta 32 bits al caracter volviendolo mayuscula
	mov byte[esi],al
	inc esi			;se obtiene el siguiente caracter
	jmp _compareTexts

_toLowerCase:			;cambia a minuscula
	mov al, byte[esi]
	add al, 32		;agrega 32 bits al caracter volviendolo minuscula
	mov byte[esi],al
	inc esi
	jmp _compareTexts

_printFinalText:		;print final
	mov rax, 1
	mov rdi, 1
	mov rsi, textoC
	mov rdx, 101
	syscall 
	call _finishCode

_finishCodeError:		;print de error
	mov rax, 1
	mov rdi, 1
	mov rsi, text2
	mov rdx, 33
	syscall 
	call _finishCode

_finishCode:			;finaliza codigo
	mov rax, 60
	mov rdi, 0
	syscall
