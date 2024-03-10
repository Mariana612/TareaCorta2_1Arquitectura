section .bss
	number resb 20
	
section .text
global _start

_start:
	mov rax, 432  ; 432/100=4, 32 => 3, 2
	mov rsi, number
	call __to_string
	
	mov rax, 1
	mov rdi, 1
	mov rsi, number
	mov rdx, 3
	syscall
	
	mov rax, 60
	mov rdi, 0
	syscall
	
__to_string:
	push rax
	
	mov rdi, 1
	mov rcx, 1
	mov rbx, 10
	get_divisor:
		xor rdx, rdx
		div rbx  ; rax = 4
		
		cmp rax, 0 ; false
		je _after
		imul rcx, 10  ; 100
		inc rdi
		jmp get_divisor
		
		
	_after:
		pop rax
		push rdi
		
	to_string:
		xor rdx, rdx
		div rcx ; RDX = 32, RAX = 4
		
		add al, "0" ;52 = "4"
		mov [rsi], al
		inc rsi
		
		push rdx
		xor rdx, rdx
		mov rax, rcx
		mov rbx, 10
		div rbx
		mov rcx, rax
		
		pop rax
		
		cmp rcx, 0
		jg to_string
		
	pop rdx
	ret
