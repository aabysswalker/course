section .data
    valid_operators db '+', '-', '/', '*'
    input_str db "Enter two operands: ", 0x0A
    input_str_l equ $ - input_str
    op_input_str db "Enter operator (+, -, *, /): ", 0
    op_input_str_l equ $ - op_input_str
    zero_str db "Dividing by zero is not allowed ", 0
    zero_str_l equ $ - zero_str
    op_debug_str db "Invalid operator", 0x0A
    op_debug_str_l equ $ - op_debug_str
    continue_str db "Continue? (y) ", 0
    continue_str_l equ $ - continue_str
    wrong_int db "Invalid number ", 0x0A
    wrong_int_l equ $ - wrong_int
    first dd 0
    second dd 0

section .bss
    buffer_write resb 16
    buffer_read resb 16
    operator resb 1
    continue resb 1

section .text
    global _start

_start:
_main_loop:
    mov eax, 4
    mov ebx, 1
    mov ecx, input_str
    mov edx, input_str_l
    int 0x80

    call scanf
    mov [first], eax

    call scanf
    mov [second], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, op_input_str
    mov edx, op_input_str_l
    int 0x80

    mov eax, 3
    mov ebx, 2
    mov ecx, operator  
    mov edx, 2
    int 0x80

    cmp byte [operator], '+'
    je addition
    cmp byte [operator], '-'
    je subtraction
    cmp byte [operator], '*'
    je multiplication
    cmp byte [operator], '/'
    je division

    mov eax, 4
    mov ebx, 1
    mov ecx, op_debug_str
    mov edx, op_debug_str_l
    int 0x80
    jmp _main_loop

exit:
    call printf

    mov eax, 4
    mov ebx, 1
    mov ecx, continue_str
    mov edx, continue_str_l
    int 0x80

    mov eax, 3
    mov ebx, 2
    mov ecx, continue  
    mov edx, 2
    int 0x80

    cmp byte [continue], 'y'
    je _main_loop

    mov eax, 1
    mov ebx, 0
    int 0x80

subtraction:
    mov eax, [first]
    sub eax, [second]

    jmp exit

multiplication:
    mov eax, [first]
    imul eax, [second]

    jmp exit

addition:
    mov eax, [first]
    add eax, [second]

    jmp exit

division:
    mov eax, [first]
    xor edx, edx
    mov ebx, [second]
    cmp ebx, 0
    jne _divide

    mov eax, 4
    mov ebx, 1
    mov ecx, zero_str
    mov edx, zero_str_l
    int 0x80
    xor eax, eax
    jmp exit

    _divide:
        div ebx 
        jmp exit

printf:
    test eax, eax
    jge _store_number
    mov byte [buffer_read], '-'
    neg eax
    mov esi, buffer_read
    inc esi
    jmp _convert_number

    _store_number:
        mov esi, buffer_read

    _convert_number:
        xor ecx, ecx
        mov ebx, 10

    _convert_loop:
        xor edx, edx
        div ebx
        add dl, '0'
        push dx
        inc ecx
        test eax, eax
        jnz _convert_loop

    _print_digits:
        test ecx, ecx
        jz _done_printing
        pop dx
        mov [esi], dl
        inc esi
        dec ecx
        jmp _print_digits

    _done_printing:
        mov byte [esi], 0x0A
        inc esi

        mov eax, 4
        mov ebx, 1
        mov ecx, buffer_read
        mov edx, esi
        sub edx, buffer_read
        int 0x80
        ret

scanf:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer_write
    mov edx, 16
    int 0x80

    xor eax, eax
    xor edi, edi
    mov esi, buffer_write

    mov dl, [esi]
    test dl, dl
    jz _convert_char
    cmp dl, '-'
    jne _convert_char
    inc esi
    mov edi, -1

    _convert_char:
        movzx edx, byte [esi]
        cmp edx, 0x0A
        je _done
        cmp edx, 57
        jg _invalid_number
        cmp edx, 48
        jl _invalid_number
        imul eax, 10
        sub edx, '0'
        add eax, edx
        inc esi
        jmp _convert_char

    _done:
        test edi, edi
        jnz _negate
        xor esi, esi
        ret

    _negate:
        neg eax
        ret

    _invalid_number:
        mov eax, 4
        mov ebx, 1
        mov ecx, wrong_int
        mov edx, wrong_int_l
        int 0x80
        ; ??
        jmp _main_loop