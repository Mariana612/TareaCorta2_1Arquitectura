section .bss
	number resb 101; Reserva 30 bytes para el numero a convertir (cambiar si se quiere hacer mas grande)
	num1 resb 101
	num2 resb 101
	num3 resb 101

section .data
		text1 db "Ingrese un numero", 0xA ;len 18
		newl db " ", 0xA ;len 2
		errorCode db "Error: Ingrese un numero valido", 0xA; len 31
	
section .text

global _start

_start:
	call _printText1
	call _getText

	;sdf
	mov [num2], rax
	xor rax, rax
	mov byte[num1], 0
	
	call _printText1
	call _getText

	;	
	mov [num3], rax
	call _process
	
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
	call _inputCheck
	call _AtoiStart

_AtoiStart:
	xor rbx, rbx
	xor rax, rax
	lea rcx, [num1]
	jmp _Atoi

_Atoi:
	mov bl, byte[rcx]
	cmp bl, 0xA		
	je _exitFunction

	sub rbx,30h
	imul rax, 10 
	add rax, rbx


	xor rbx,rbx
	inc rcx
	jmp _Atoi

_exitFunction: 
	ret

_inputCheck:
	; Check input for non-numeric characters
    	mov rsi, num1  ; address of the input buffer
    	xor rcx, rcx   ; Clear counter
    check_input:
        	movzx rax, byte [rsi + rcx]  ; Load the current byte
        	cmp rax, 0xA
        	je input_valid      ; End of string reached
        	cmp rax, '0'
        	jb _finishError    ; Check for non-printable characters
        	cmp rax, '9'
        	ja _finishError    ; Check for non-printable characters
        	inc rcx             ; Move to the next byte
        	jmp check_input
    input_valid:
	ret


_process:
	mov rax, [num2]
	sub rax, [num3]
	call _startItoa
	
	call _clearBuffer

	mov rax, [num2]
	add rax, [num3]
	call _startItoa

	ret

_clearBuffer:
    ; Resetting the number buffer
    mov rsi, number    ; Load the address of the number buffer into rsi
    mov rcx, 101       ; Set the loop counter to the size of the buffer
    xor al, al         ; Set al register to zero (null character)

reset_loop:
    mov [rsi], al      ; Store the value of al (zero) into the current byte of the buffer
    inc rsi            ; Move to the next byte in the buffer
    loop reset_loop    ; Continue the loop until rcx becomes zero

ret


_startItoa:
	; inicializa el valor inicial en rax
	;mov rax, 1
	; Carga la direccion de memoria de "number" en rsi
	mov rsi, number
	; Llama a la funcion para convertir a caracteres ASCII
	call __to_string
	
	;Imprimir el resultado
	mov rax, 1
	mov rdi, 1
	mov rsi, number
	mov rdx, 101  ; cambiar esto si se quiere un num mas grande
	syscall
	
	mov rax, 1
	mov rdi, 1
	mov rsi, newl
	mov rdx, 2 ; cambiar esto si se quiere un num mas grande
	syscall
	
	ret
	
	
__to_string:
	push rax ; Guarda el valor de rax en la pila
	
	mov rdi, 1
	mov rcx, 1 ; contador de digitos a 1
	mov rbx, 10 ; base para la division
	get_divisor:
		xor rdx, rdx ; limpia rdx para preparar la division
		div rbx  ; divide rax por 10, resultado en rax y residuo en rdx
		
		cmp rax, 0 ; comprueba si el cociente es cero
		je _after ; termina bucle si es 0
		imul rcx, 10  ; multiplica contador por 10
		inc rdi ; incrementa el contador
		jmp get_divisor ; vuelve al inicio del bucle
		
		
	_after:
		pop rax ; recupera el valor original de rax
		push rdi ; guarda el contador de digitos en la pila
		
	to_string:
		xor rdx, rdx ; limpia rdx para preparar la division
		div rcx ; divide el valor original de rax por el contador de digitos
		
		add al, "0" ; Convierte digito a su representacion en ASCII
		mov [rsi], al ; almacena digito a la posicion de memoria
		inc rsi ; incrementa el puntero a la siguiente posicion de memoria
		
		push rdx ; guarda el residuo de la division en la pila
		xor rdx, rdx ; limpia rdx
		mov rax, rcx ; restaura rax
		mov rbx, 10 ; establece la base para la division siguiente
		div rbx ; divide el valor original de rax por 10
		mov rcx, rax ; actualiza el contador con el nuevo valor de rax
		
		pop rax ; recupera el residuo de la pila
		
		cmp rcx, 0 ; Comprueba que se han procesado todos los digitos
		jg to_string ; continua el bucle si aun no se procesan todos los digitos
		
	pop rdx ; limpia residuo de la pila
	ret ; retorna de la funcion

_finishError:			;finaliza codigo
	mov rax, 1
	mov rdi, 1
	mov rsi, errorCode
	mov rdx, 32
	syscall 

_finishCode:			;finaliza codigo
	mov rax, 60
	mov rdi, 0
	syscall
