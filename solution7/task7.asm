section .bss
    buffer_write resb 16
    buffer_read resb 16
    number resd 1
    loop_result resd 1
    recursion_result resd 1

section .data
    debug_str db "Input must be a positive integer", 0x0A
    debug_str_len equ $ - debug_str
    recursion_str db "Factorial: ", 0
    recursion_str_len equ $ - recursion_str
    loop_str db "Loop: ", 0
    loop_str_len equ $ - loop_str
section .text
    global _start

_start:
    call scanf
    mov [number], eax
    cmp eax, 0
    jle _wrong_input
    

    call recursion
    mov [recursion_result], eax
    mov eax, 4
    mov ebx, 1
    mov ecx, recursion_str
    mov edx, recursion_str_len
    int 0x80      
    mov eax, [recursion_result]
    call printf


    call loop
    mov eax, 4
    mov ebx, 1
    mov ecx, loop_str
    mov edx, loop_str_len
    int 0x80
    mov eax, [loop_result]
    call printf


    exit:
        mov eax, 1
        xor ebx, ebx
        int 0x80

    _wrong_input:
        mov eax, 4
        mov ebx, 1
        mov ecx, debug_str
        mov edx, debug_str_len
        int 0x80  
        jmp exit
    
recursion:
    cmp eax, 1
    jne _base
    ret
_base:
    push eax
    dec eax
    call recursion
    pop ebx
    mul ebx
    ret


loop:
    mov ecx, [number]
    mov eax, 1
    mov edx, ecx

    _factorial_loop:
    ; Multiply 2 elements in 1 iteration
        cmp ecx, 2
        jbe _last_digit
        imul eax, edx
        dec edx
        imul eax, edx
        dec edx
        sub ecx, 2
        jnz _factorial_loop

    _last_digit:
        imul eax, edx
        mov [loop_result], eax
        ret

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
            pop dx
            mov [esi], dl
            inc esi
            loop _print_digits

        mov byte [esi], 0x0A
        inc esi

        mov eax, 4
        mov ebx, 1
        mov ecx, buffer_read
        mov edx, 16
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
        imul eax, 10
        sub edx, '0'
        add eax, edx
        inc esi
        inc ecx
        jmp _convert_char

    _done:
        test edi, edi
        jnz _negate
        xor esi, esi
        ret

    _negate:
        neg eax    
        ret