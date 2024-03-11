section .bss
	number resb 30 ; Reserva 30 bytes para el numero a convertir (cambiar si se quiere hacer mas grande)
	
section .text
global _start

_start:
	; inicializa el valor inicial en rax
	mov rax, 4327890  
	; Carga la direccion de memoria de "number" en rsi
	mov rsi, number
	; Llama a la funcion para convertir a caracteres ASCII
	call __to_string
	
	;Imprimir el resultado
	mov rax, 1
	mov rdi, 1
	mov rsi, number
	mov rdx, 30  ; cambiar esto si se quiere un num mas grande
	syscall
	
	;Salir del programa
	mov rax, 60
	mov rdi, 0
	syscall
	
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
