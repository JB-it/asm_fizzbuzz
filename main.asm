section .data
    test_msg: db "Hello, World!",0xA,0x0
    fizz: db "Fizz",0x0
    buzz: db "Buzz",0x0
    fizzbuzz: db "FizzBuzz",0x0
    newline: db 0xA
    
    write: equ 0x1
    stdout: equ 1
    sys_exit: equ 60

    numbers: db "0123456789"

    counter: dq 0

    loop_variable: dq 1
    max_variable: dq 100

section .text
    global _start

_start:
    mov rsi, test_msg
    call _printf

    mov rsi, newline  
    call _print_char

_number_loop:
    mov r14, [loop_variable]

    mov r15b, 0 ; Flag to check if something was printed

_check_fizz:
    mov rax, r14
    mov rdx, 0
    mov rbx, 3
    div rbx

    cmp rdx, 0
    jne _check_buzz

    mov rsi, fizz
    call _printf
    mov r15b, 1

_check_buzz:
    mov rax, r14
    mov rdx, 0
    mov rbx, 5
    div rbx

    cmp rdx, 0
    jne _loop_end

    mov rsi, buzz
    call _printf
    mov r15b, 1

_loop_end:

    cmp r15b, 1
    je _increment_and_loop_reset


    mov rsi, r14
    call _print_big_num

_increment_and_loop_reset:
    mov rsi, newline
    call _print_char

    inc r14
    mov [loop_variable], r14

    mov r14, [loop_variable]
    cmp r14, [max_variable]
    jle _number_loop

    mov rsi, newline
    call _print_char

    call _exit


_print_big_num:         ; Prints any number in rsi in decimal
    mov r10, rsi
    mov rbx, 1000000
    mov r13b, 0 ; Flag to check if we have printed the first digit
_print_big_num_loop:
    mov rax, r10
    mov rdx, 0
    div rbx ; Divide by current divisor. Divisor is divided by 10 for every iteration in the loop
    ;https://stackoverflow.com/questions/8021772/assembly-language-how-to-do-modulo

    ; MOD 10
    mov r12, rbx
    mov rbx, 10
    mov rdx, 0
    div rbx

    cmp r13b, 1 ; If the flag is set, that means we already printed a number. SKips the check for 0
    je _print_big_num_loop_print

    cmp rdx, 0 ; Checks if the remainder is 0. If so, skip the print part
    je _print_big_num_loop_reset

_print_big_num_loop_print:
    mov r13b, 1
    mov rsi, rdx ; Print the content of RDX (the remainder)
    call _print_num

_print_big_num_loop_reset:
    ; Divide divisor by 10
    mov rax, r12
    mov rdx, 0
    mov rbx, 10
    div rbx
    mov rbx, rax
    cmp rbx, 0 ; If the divisor is 0, we have printed all the digits
    jne _print_big_num_loop ; Jump back to the loop otherwise
    
    mov rsi, r10 ; Restores the RSI register
    ret


_print_num:
    add rsi, numbers 
    call _print_char
    ret

_print_char:            ; Prints the character in rsi
    mov rax, write      ; syscall number for sys_write
    mov rdi, stdout     ; file descriptor 1 is stdout
    mov rdx, 1          ; Prints one single character
    syscall
    ret

_printf:
    mov r8b, [rsi]
    cmp r8b, 0x0
    je _printf_end
    call _print_char
    inc rsi
    jmp _printf
_printf_end:
    ret

_exit:
    mov rax, sys_exit   ; syscall number for sys_exit
    mov rdi, 0          ; exit code 0
    syscall

    ; 35565 / 10000 = 3
    ; 3 % 10 = 3
    ; 35565 / 1000 = 35
    ; 35 % 10 = 5
    ; 35565 / 100 = 355
    ; 355 % 10 = 5
    ; 35565 / 10 = 3556
    ; 3556 % 10 = 6
    ; 35565 / 1 = 35565
    ; 35565 % 10 = 5