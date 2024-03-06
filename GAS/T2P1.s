.section .data
    text1: .string "Ingrese la palabra a cambiar\n"
    text2: .string "Error: Ingrese elementos validos\n"

.section .bss
    textoC: .space 101

.section .text
.global main

main:
    call printText1
    call getText
    call compareTexts

printText1:
    mov $1, %rax
    mov $1, %rdi
    mov $text1, %rsi
    mov $29, %rdx
    syscall
    ret

getText:
    mov $0, %rax
    mov $0, %rdi
    mov $textoC, %rsi
    mov $101, %rdx
    syscall
    ret

compareTexts:
    movb (%rsi), %al
    cmpb $0xA, %al
    je printFinalText
    cmpb $' ', %al
    je addSpace
    cmpb $'A', %al
    jb finishCodeError
    cmpb $'Z', %al
    ja compareTextsLower
    jmp toLowerCase

compareTextsLower:
    cmpb $'a', %al
    jb finishCodeError
    cmpb $'z', %al
    ja finishCodeError
    jmp toUpperCase

addSpace:
    movb (%rsi), %al
    inc %rsi
    jmp compareTexts
		

toUpperCase:
    movb (%rsi), %al
    cmpb $0xA, %al
    je printFinalText
    subb $32, %al
    movb %al, (%rsi)
    inc %rsi
    jmp compareTexts

toLowerCase:
    movb (%rsi), %al
    cmpb $0xA, %al
    je printFinalText
    addb $32, %al
    movb %al, (%rsi)
    inc %rsi
    jmp compareTexts

printFinalText:
    mov $1, %rax
    mov $1, %rdi
    mov $textoC, %rsi
    mov $101, %rdx
    syscall
    call finishCode

finishCodeError:
    mov $1, %rax
    mov $1, %rdi
    mov $text2, %rsi
    mov $33, %rdx
    syscall
    call finishCode

finishCode:
    mov $60, %rax
    xor %rdi, %rdi
    syscall
