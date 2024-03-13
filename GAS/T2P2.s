.section .bss
    .lcomm number, 101   # Reserve 101 bytes for the number
    .lcomm num1, 101
    .lcomm num2, 101
    .lcomm num3, 101

.section .data
    text1:  .ascii "Ingrese un numero\n\0"  # String with newline
    newl:   .ascii " \n\0"                  # Newline and null terminator

.section .text
.globl _start

_start:
    #call _printText1
    #call _getText

    #mov %rax, num2(%rip)    # Store the input into num2
    #xor %rax, %rax           # Clear rax (num1)
    #movb $0, num1(%rip)      # Set the first byte of num1 to 0

    #call _printText1
    #call _getText

    #mov %rax, num3(%rip)

    #call _process
    mov $33333333, %rax 
    call _startItoa
    call _finishCode

_printText1:
    mov $1, %rax            # syscall number for sys_write
    mov $1, %rdi            # file descriptor 1 (stdout)
    lea text1(%rip), %rsi   # pointer to the string
    mov $18, %rdx           # number of bytes to write
    syscall
    ret

_getText:
    mov $0, %rax            # syscall number for sys_read
    mov $0, %rdi            # file descriptor 0 (stdin)
    lea num1(%rip), %rsi    # pointer to the buffer
    mov $101, %rdx          # number of bytes to read
    syscall
    call _AtoiStart
    ret

_AtoiStart:
    xor %rbx, %rbx
    xor %rax, %rax
    lea num1(%rip), %rcx
    jmp _Atoi

_Atoi:
    movb (%rcx), %bl         # Move byte at [rcx] into bl
    cmpb $0xA, %bl           # Check for newline character
    je _exitFunction

    sub $0x30, %rbx          # Convert ASCII to integer
    imul $10, %rax           # Multiply previous result by 10
    add %rbx, %rax           # Add new digit

    xor %rbx, %rbx           # Clear rbx
    inc %rcx                 # Move to next character
    jmp _Atoi

_exitFunction:
    ret

_process:
    movq num2(%rip), %rax    # Load num2 into rax
    subq num3(%rip), %rax       # Subtract num3 from rax
    call _startItoa


    #call _clearBuffer

    #movq number(%rip), %rax    # Reload num2 into rax
    #addq num3(%rip), %rax       # Add num3 to rax
    #call _startItoa

    ret
    

_clearBuffer:
    # Resetting the number buffer
    movq $number, %rsi    # Load the address of the number buffer into rsi
    movq $101, %rcx       # Set the loop counter to the size of the buffer
    xorq %rax, %rax       # Set al register to zero (null character)

reset_loop:
    movb %al, (%rsi)      # Store the value of al (zero) into the current byte of the buffer
    incq %rsi             # Move to the next byte in the buffer
    loop reset_loop       # Continue the loop until rcx becomes zero

    ret


_startItoa:
    # Load the address of the number buffer into rsi
    movq number(%rip), %rsi
    
    # Call the __to_string function
    call __to_string
    
    # Print the result
    
    movq $1, %rax          # syscall number for sys_write
    movq $1, %rdi          # file descriptor 1 (stdout)
    movq number(%rip), %rsi   # pointer to the number buffer
    movq $101, %rdx        # number of bytes to write
    syscall
    
    # Print newline character
    movq $1, %rax          # syscall number for sys_write
    movq $1, %rdi          # file descriptor 1 (stdout)
    movq newl(%rip), %rsi  # pointer to the newline character
    movq $2, %rdx          # number of bytes to write
    syscall
    
    ret

__to_string:
    pushq %rax             # Guarda el valor de rax en la pila
    
    movq $1, %rdi          # file descriptor 1 (stdout)
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

_finishCode:           # Finalizes code
    movq $60, %rax     # syscall number for sys_exit
    xorq %rdi, %rdi    # Exit code 0
    syscall
