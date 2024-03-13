.data
    number: .space 101  # Reserva 101 bytes para el número a convertir (cambiar si se quiere hacer más grande)
    num1:   .space 101
    num2:   .space 101
    num3:   .space 101

    text1:      .string "Ingrese un numero\n"
    newl:       .string "\n"
    negSign:    .string "-"
    errorCode:  .string "Error: Ingrese un numero valido\n"
    flag1: 	.byte 0
.text
.global _start

_start:
    call _printText1
    call _getText
    
    movq %rax, num2
    xorq %rax, %rax
    movb $0, (num1)

    call _printText1
    call _getText
    
    movq %rax, num3
    call _process
    call _finishCode

_printText1:            # texto inicial
    movq $1, %rax
    movq $1, %rdi
    movq $text1, %rsi
    movq $18, %rdx
    syscall 
    ret

_getText:               # obtiene el texto
    movq $0, %rax
    movq $0, %rdi
    movq $num1, %rsi
    movq $101, %rdx
    syscall 
    call _inputCheck
    call _AtoiStart

_AtoiStart:
    xorq %rbx, %rbx
    xorq %rax, %rax
    leaq num1(%rip), %rcx
    jmp _Atoi

_Atoi:
    movb (%rcx), %bl
    cmpb $0xA, %bl
    je _exitFunction

    subb $0x30, %bl
    imulq $10, %rax
    addq %rbx, %rax

    xorq %rbx, %rbx
    incq %rcx
    jmp _Atoi

_exitFunction:
    ret

_inputCheck:
    movq $num1, %rsi   # Direccion del buffer input
    xorq %rcx, %rcx    # Limpia contador
check_input:
    movzbq (%rsi, %rcx), %rax  # Carga el byte actual
    cmpb $0xA, %al
    je input_valid      # Llega al final del string
    cmpb $'0', %al
    jb _finishError    # Checkea que no tenga caracteres invalidos
    cmpb $'9', %al
    ja _finishError    # Checkea que no tenga caracteres invalidos
    incq %rcx             # Se mueve al siguiente byte
    jmp check_input
input_valid:
    ret

_process:
    movq num2(%rip), %rax
    subq num3(%rip), %rax
    call _startItoa

    call _clearBuffer

    movq num2(%rip), %rax
    addq num3(%rip), %rax
    call _startItoa
    ret

_clearBuffer:
    movq $number, %rsi    # Resetiando el numero de buffer
    movq $101, %rcx       # Set el contador del bucle al tamao del buffer
    xorq %rax, %rax       # Set el registro a cero
reset_loop:
    movb %al, (%rsi)      
    incq %rsi             # Mueve al siguiente byte en el buffer
    loop reset_loop       # Continua con el loop hasta que rcx sea cero
    ret

_startItoa:
    movq $number, %rsi      # carga la direccion de "number en rsi
    call _firstNeg

    cmpb $1, flag1
    je _printNeg

_continueItoa:
    movq $1, %rax
    movq $1, %rdi
    movq $number, %rsi
    movq $101, %rdx        # cambiar esto si se quiere un num mas grande
    syscall

    movq $1, %rax
    movq $1, %rdi
    movq $newl, %rsi
    movq $2, %rdx         # cambiar esto si se quiere un num mas grande
    syscall

    movb $0, flag1

    ret

_printNeg:
    movq $1, %rax
    movq $1, %rdi
    movq $negSign, %rsi
    movq $1, %rdx        # cambiar esto si se quiere un num mas grande
    syscall
    jmp _continueItoa

_firstNeg:

    testq %rax, %rax     # Prueba si el numero es negativo
    jns __to_string  # si es negativo salta a la seccion negativo
    negq %rax
    movb $1, flag1

__to_string:
    pushq %rax           # Guarda el valor de rax en la pila

    movq $1, %rdi
    movq $1, %rcx        # contador de digitos a 1

    movq $10, %rbx       # base para la division
get_divisor:
    xorq %rdx, %rdx     # limpia rdx para preparar la division
    divq %rbx           # divide rax por 10, resultado en rax y residuo en rdx

    cmpq $0, %rax       # comprueba si el cociente es cero
    je _after           # termina bucle si es 0
    imulq $10, %rcx     # multiplica contador por 10
    incq %rdi           # incrementa el contador
    jmp get_divisor     # vuelve al inicio del bucle

_after:
    popq %rax            # recupera el valor original de rax
    pushq %rdi           # guarda el contador de digitos en la pila

to_string:
    xorq %rdx, %rdx      # limpia rdx para preparar la division
    divq %rcx            # divide el valor original de rax por el contador de digitos

    addb $'0', %al       # Convierte digito a su representacion en ASCII
    movb %al, (%rsi)     # almacena digito a la posicion de memoria
    incq %rsi            # incrementa el puntero a la siguiente posicion de memoria

    pushq %rdx           # guarda el residuo de la division en la pila
    xorq %rdx, %rdx      # limpia rdx
    movq %rcx, %rax      # restaura rax
    movq $10, %rbx       # establece la base para la division siguiente
    divq %rbx            # divide el valor original de rax por 10
    movq %rax, %rcx      # actualiza el contador con el nuevo valor de rax

    popq %rax            # recupera el residuo de la pila

    cmpq $0, %rcx        # Comprueba que se han procesado todos los digitos
    jg to_string         # continua el bucle si aun no se procesan todos los digitos

    popq %rdx            # limpia residuo de la pila
    ret                   # retorna de la funcion

_finishError:             # finaliza codigo
    movq $1, %rax
    movq $1, %rdi
    movq $errorCode, %rsi
    movq $31, %rdx
    syscall 

_finishCode:              # finaliza codigo
    movq $60, %rax
    movq $0, %rdi
    syscall
