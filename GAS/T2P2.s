.section .bss
    .lcomm number, 101   # Reserva 101 bytes para el numero
    .lcomm num1, 101
    .lcomm num2, 101
    .lcomm num3, 101

.section .data
    text1:  .ascii "Ingrese un numero\n\0"  # String con nueva linea
    newl:   .ascii " \n\0"                  # Nueva linea y null terminator

.section .text
.globl _start

_start:
    #call _printText1
    #call _getText

    #mov %rax, num2(%rip)    # Guarda el dato ingresado en num2
    #xor %rax, %rax           # Limpia el rax (num1)
    #movb $0, num1(%rip)      # Coloca el primer byte de num1 a 0

    #call _printText1
    #call _getText

    #mov %rax, num3(%rip)

    #call _process
    mov $33333333, %rax 
    call _startItoa
    call _finishCode

_printText1:
    mov $1, %rax            # syscall numero a sys_write
    mov $1, %rdi            # Descriptor de archivo 1 (stdout)
    lea text1(%rip), %rsi   # puntero a string
    mov $18, %rdx           # numero de bytes a escribir
    syscall
    ret

_getText:
    mov $0, %rax            # syscall numero a sys_read
    mov $0, %rdi            # Descriptor de archivo 0 (stdin)
    lea num1(%rip), %rsi    # puntero a buffer
    mov $101, %rdx          # numero de bytes a leer
    syscall
    call _AtoiStart
    ret

_AtoiStart:
    xor %rbx, %rbx
    xor %rax, %rax
    lea num1(%rip), %rcx
    jmp _Atoi

_Atoi:
    movb (%rcx), %bl         # Mover byte de [rcx] a bl
    cmpb $0xA, %bl           # Revisar caracter de nueva linea
    je _exitFunction

    sub $0x30, %rbx          # Convertir ASCII a integer
    imul $10, %rax           # Multiplicar resultados por 10
    add %rbx, %rax           # Agregar nuevo digito

    xor %rbx, %rbx           # LImpiar rbx
    inc %rcx                 # Mover a siguiente caracter
    jmp _Atoi

_exitFunction:
    ret

_process:
    movq num2(%rip), %rax    # Cargar num2 a rax
    subq num3(%rip), %rax       # Quitar num3 de rax
    call _startItoa


    #call _clearBuffer

    #movq number(%rip), %rax    # Recargar num2 a rax
    #addq num3(%rip), %rax       # Agregar num3 a rax
    #call _startItoa

    ret
    

_clearBuffer:
    # Resetear el numero de buffer
    movq $number, %rsi    # Cargar la direccion del buffer de numero a rsi
    movq $101, %rcx       # Colocar el ciclo de contador al mismo tamano del buffer
    xorq %rax, %rax       # Colocar todos los registros en cero (null character)

reset_loop:
    movb %al, (%rsi)      # Guardar el valor de  al (zero) al buffer actual del byte
    incq %rsi             # Mover al sigueinte byte del buffer
    loop reset_loop       # Continuar el ciclo hasta que rcx se convierta a 0

    ret


_startItoa:
    # Cargar la direccion del buffer de numero a rsi
    movq number(%rip), %rsi
    
    # Call the __to_string function
    call __to_string
    
    # Print the result
    movq $1, %rax          # syscall numero a sys_write
    movq $1, %rdi          # descriptor de archivo 1 (stdout)
    movq number(%rip), %rsi   # puntero al buffer de numero
    movq $101, %rdx        # numero de bytes a escribir
    syscall
    
    # Print newline character
    movq $1, %rax          # syscall numero a sys_write
    movq $1, %rdi          # descriptor de archivo 1 (stdout)
    movq newl(%rip), %rsi  # puntero al caracter de nueva linea
    movq $2, %rdx          # numero de bytes a escribir
    syscall
    
    ret

__to_string:
    pushq %rax             # Guarda el valor de rax en la pila
    
    movq $1, %rdi          # descriptor de archivo 1 (stdout)
    movq $1, %rcx          # contador de digitos a 1
    movq $10, %rbx         # base para la division
get_divisor:
    xorq %rdx, %rdx       # limpia rdx para preparar la division
    divq %rbx             # divide rax por 10, resultado en rax y residuo en rdx
    
    cmpq $0, %rax         # comprueba si el cociente es cero
    je _after             # termina bucle si es 0
    imulq $10, %rcx       # multiplica contador por 10
    incq %rdi             # incrementa el contador
    jmp get_divisor       # vuelve al inicio del bucle
    
    
_after:
    popq %rax              # recupera el valor original de rax
    pushq %rdi             # guarda el contador de digitos en la pila
    
to_string:
    xorq %rdx, %rdx        # limpia rdx para preparar la division
    divq %rcx              # divide el valor original de rax por el contador de digitos
    
    addb $'0', %al         # Convierte digito a su representacion en ASCII
    movb %al, (%rsi)       # almacena digito a la posicion de memoria
    incq %rsi              # incrementa el puntero a la siguiente posicion de memoria
    
    pushq %rdx             # guarda el residuo de la division en la pila
    xorq %rdx, %rdx        # limpia rdx
    movq %rcx, %rax        # restaura rax
    movq $10, %rbx         # establece la base para la division siguiente
    divq %rbx              # divide el valor original de rax por 10
    movq %rax, %rcx        # actualiza el contador con el nuevo valor de rax
    
    popq %rax              # recupera el residuo de la pila
    
    cmpq $0, %rcx          # Comprueba que se han procesado todos los digitos
    jg to_string            # continua el bucle si aun no se procesan todos los digitos
    
    popq %rdx              # limpia residuo de la pila
    ret                     # retorna de la funcion

_finishCode:           # Finalizar codigo
    movq $60, %rax     # syscall numero a sys_exit
    xorq %rdi, %rdi    # Salir del codigo 0
    syscall
