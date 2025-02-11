; Just a simple project to learn assembly.  Prints the occurences of each letter
; in a string
global _start

section .data
	message: db "Input your message: "

section .bss
	dictionary: resq 256 ;; allocate an array of 256 64-bit integers

section .text
	print:
		; rsi = string ptr
		; rdx = length
		mov rax, 1 ; system call for write
		mov rdi, 1 ; file handle 1 is stdout
		syscall ; invoke operating system to do the write
		ret
		
	itoa: ; input: rax
		mov rbp, rsp ; save stack ptr since push inc's it

		mov r10, 10 ; 10 is always used for division, might as well use r10
		xor rbx, rbx ; i = 0
		itoa_loop:
			add rbx, 8 ; i++, each push to stack is 8 bytes in x86_64
			xor rdx, rdx ; clear rdx so that the double width rdx:rax isn't used
			
			div r10 ; rdx = rax % 10, rax /= 10
			add rdx, '0' ; shift to ascii 0
			push rdx ; push to stack

			cmp rax, 0 ; loop again if the result isn't 0
			jne itoa_loop
		; end of itoa_loop

		mov rsi, rsp ; set input string ptr to rsp 
		mov rdx, rbx ; set read length to rbx
		call print

		mov rsp, rbp ; restore stack ptr
		ret

	format_char: ; input: rax, prints like this: '[c]': [count]
		mov rbp, rsp

		push ' '
		push ':'
		push '"'
		push rax
		push '"'
		push 10 ; newline
		mov rsi, rsp
		mov rdx, 48
		
		call print

		mov rsp, rbp
		ret


	_start:
		mov rsi, message ; address of string to output
		mov rdx, 20 ; number of bytes
		call print

		push 0 ; just add an emply value to the stack

		input_loop: 
			mov rax, 0 ; system call for read
			mov rdi, 0 ; file handle 0 is stdin
			mov rsi, rsp ; address to input
			mov rdx, 1 ; read 2 bytes (input and newline)
			syscall
			
			mov r13, [rsp]

			cmp r13, 10
			je exit_input_loop

			mov rax, 8
			mul r13

			mov rdi, dictionary
			add rdi, rax

			inc qword [rdi]

			jmp input_loop
		exit_input_loop:

		xor r13, r13 ; i = 0, increments of 1
		xor r14, r14 ; j = 0, increments of 8
		mov r12, dictionary
		result_loop:
			mov r8, [r12 + r14] ; dictionary value
			cmp r8, 0 ; note: I had previously used r11 but syscalls messed with
			; it
			je skip_print ; skip if none counted
			
			mov rax, r13
			call format_char
			
			mov rax, r8
			call itoa

			skip_print:
				inc r13 ; i++
				add r14, 8 ; j += 8
				cmp r13, 256
				jl result_loop

		; add newline at the end
		push 10
		mov rsi, rsp
		mov rdx, 1
		call print

		; Exit
		mov rax, 60 ; system call for exit
		xor rdi, rdi ; exit code 0
		syscall