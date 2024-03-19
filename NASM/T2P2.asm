section .bss
	number resb 101; Reserva 30 bytes para el numero a convertir (cambiar si se quiere hacer mas grande)
	num1 resb 101
	num2 resb 101
	num3 resb 101
	
	

section .data
		text1 db "Ingrese un numero", 0xA ;len 18
		newl db " ", 0xA ;len 2
		negSign db "-" ;len 2
		errorCode db "Error: El caracter debe ser un numero", 0xA; len 37
		overflowMsg db "ERROR: Overflow de la suma", 0xA
		overflowMsg2 db "ERROR: Overflow de la resta", 0xA
		sizeErrorMsg db "ERROR: El numero es demasiado grande", 0xA
		flag1 db 0
		msgRes db "El resultado es: ", 0xA

section .text

global _start

_start:
	call _printText1	;Hace print inicial
	call _getText		;Consigue el texto del usuario


	mov [num2], rax		;carga el primer numero en num2
	xor rax, rax		;reinicia rax
	mov byte[num1], 0	;reinicia num1
	
	call _printText1	;Hace print inicial
	call _getText		;Consigue el texto del usuario

		
	mov [num3], rax		;carga el primer numero en num3
	call _process		;procesa las formulas necesarias
	
	call _finishCode	;finaliza el codigo
	


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
	call _checkNumSize      ; checkea que el numero no sea demasiado grande
	call _inputCheck	;se asegura de que se ingrese unicamente numeros
	call _AtoiStart

_AtoiStart:
	xor rbx, rbx		;reinicia el registro
	xor rax, rax		;reinicia el registro
	lea rcx, [num1]		;ingresa el numero 1 a rcx
	jmp _Atoi

_Atoi:
	mov bl, byte[rcx]
	cmp bl, 0xA		
	je _exitFunction	;se asegura de que sea el final del string

	sub rbx,30h		;resta 30h al string para volverlo el numero
	imul rax, 10 		;multiplica el numero almacenado en rax x 10 para volverlo decimal
	add rax, rbx		;agrega el ultimo numero obtenido a rax (ej: 10+3=13)	


	xor rbx,rbx		;reinicia el registro
	inc rcx			;incrementa x 1 el rcx (obtiene el siguiente caracter
	jmp _Atoi		;realiza loop

_exitFunction: 
	ret

_inputCheck:
				
	mov rsi, num1		; direccion del buffer de ingreso
    	xor rcx, rcx		; Clear counter

	check_input:
		movzx rax, byte [rsi + rcx]		;Carga el byte actual
        	cmp rax, 0xA
        	je input_valid				;Final del string alcanzado
        	cmp rax, '0'
        	jb _finishError				;Revisa caracteres no imprimibles
        	cmp rax, '9'
        	ja _finishError				;Revisa caracteres no imprimibles
        	inc rcx					;Mover al siguente byte
        	jmp check_input

	input_valid:
		ret

_checkNumSize:
    mov rax, 0          ; Limpia a rax
    mov rsi, num1       
    xor rcx, rcx        ; limpia rcx

    ; Loop to count the number of digits
    count_digits:
        movzx rbx, byte [rsi + rcx]   ; carga el byte a [rsi + rcx]
        cmp rbx, 0xA                   ; checkea end of loop
        je end_count                   ; si es sale loop
        inc rcx                        ; incrementa el contador
        jmp count_digits               ; continua el loop

    end_count:
        cmp rcx, 20                    ; checkea que el numero no se amas grande que 19
        jg _numTooBig                  ; si lo es jump a _numTooBig
        ret

_numTooBig:
    mov rax, 1
    mov rdi, 1
    mov rsi, sizeErrorMsg
    mov rdx, 37
    syscall
    jmp _finishCode                   ; Exit
_process:

    mov rax, [num2]
    add rax, [num3]   ; Hace la suma
    jo _overflowDetected
    call _startItoa
    
_continueProcess:
    call _clearBuffer

    mov rax, [num2]
    sub rax, [num3]     ; Hace la resta
    jo _overflowDetected2
    call _startItoa     ; Convierte a ASCII e imprime
    ret

_overflowDetected:
	mov rax, 1
	mov rdi, 1
	mov rsi, overflowMsg
	mov rdx, 27
	syscall
	jmp _continueProcess

_overflowDetected2:
	mov rax, 1
	mov rdi, 1
	mov rsi, overflowMsg2
	mov rdx, 28
	syscall
	jmp _finishCode
	
	

_clearBuffer:
    ; Resetea el buffer de numeros
    mov rsi, number    ; Carga la direccion del buffer de numeros al rsi
    mov rcx, 101       ; Coloca el ciclo contador del mismo tamano del buffer
    xor al, al         ; Coloca cada registro en cero (null character)

reset_loop:
    mov [rsi], al      ; Guarda el valor de  al (zero) en el byte actual del buffer
    inc rsi            ; Mueve al siguiente byte del buffer
    loop reset_loop    ; Continua el ciclo hasta que rcx se convierte en cero

ret


_startItoa:
	mov rsi, number	;Carga la direccion de memoria de "number" en rsi
	call _firstNeg	;Llama a la funcion para convertir a caracteres ASCII

	mov rax, 1		;realiza el print del mensaje
	mov rdi, 1
	mov rsi, msgRes		;print mensaje resultado
	mov rdx, 17
	syscall
	
	cmp byte[flag1], 1	;se asegura de que el primer numero sea o no negativo
	je _printNeg		;realiza print del simbolo negativo

_continueItoa:		

	mov rax, 1		;realiza print del numerno
	mov rdi, 1
	mov rsi, number		;print resultado
	mov rdx, 101  
	syscall

	mov rax, 1		;realiza print del numerno
	mov rdi, 1
	mov rsi, newl		;print de enter
	mov rdx, 2		
	syscall

	mov byte[flag1], 0	;reinicia flag 
	ret

_printNeg:
	mov rax, 1
	mov rdi, 1
	mov rsi, negSign
	mov rdx, 1 ; 
	syscall
	jmp _continueItoa

_firstNeg:
	test rax, rax		;realiza test a ver si el numero es negativo
    	jns __to_string  	;si no es negativo salta a string directamente
	neg rax			;vuelve positivo el numero
	mov byte[flag1], 1

	
__to_string:
	push rax		;Guarda el valor de rax en la pila
	
	mov rdi, 1
	mov rcx, 1		;contador de digitos a 1

	mov rbx, 10		;base para la division
	get_divisor:
		xor rdx, rdx	;limpia rdx para preparar la division
		div rbx 	;divide rax por 10, resultado en rax y residuo en rdx
		
		cmp rax, 0	;comprueba si el cociente es cero
		je _after	;termina bucle si es 0
		imul rcx, 10	;multiplica contador por 10
		inc rdi		;incrementa el contador
		jmp get_divisor ;vuelve al inicio del bucle
		
		
	_after:
		pop rax 	;recupera el valor original de rax
		push rdi 	;guarda el contador de digitos en la pila
		
	to_string:
		xor rdx, rdx 	;limpia rdx para preparar la division
		div rcx 	;divide el valor original de rax por el contador de digitos
		
		add al, "0" 	;Convierte digito a su representacion en ASCII
		mov [rsi], al 	;almacena digito a la posicion de memoria
		inc rsi 	;incrementa el puntero a la siguiente posicion de memoria
		
		push rdx 	;guarda el residuo de la division en la pila
		xor rdx, rdx 	;limpia rdx
		mov rax, rcx 	;restaura rax
		mov rbx, 10 	;establece la base para la division siguiente
		div rbx 	;divide el valor original de rax por 10
		mov rcx, rax 	;actualiza el contador con el nuevo valor de rax
		
		pop rax 	;recupera el residuo de la pila
		
		cmp rcx, 0 	;Comprueba que se han procesado todos los digitos
		jg to_string 	;continua el bucle si aun no se procesan todos los digitos
		
	pop rdx 		;limpia residuo de la pila
	ret 			;retorna de la funcion

_finishError:			;finaliza codigo
	mov rax, 1
	mov rdi, 1
	mov rsi, errorCode
	mov rdx, 38
	syscall 

_finishCode:			;finaliza codigo
	mov rax, 60
	mov rdi, 0
	syscall
