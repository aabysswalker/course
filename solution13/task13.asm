%macro ADDITION 2
    mov eax, %1
    mov ebx, %2
    add eax, ebx
    mov [resulta], eax
%endmacro

%macro SUBTRACTION 2
    mov eax, %1
    mov ebx, %2
    sub eax, ebx
    mov [results], eax
%endmacro

%macro MULTIPLICATION 2
    mov eax, %1
    mov ebx, %2
    imul eax, ebx
    mov [resultm], eax
%endmacro

%macro DIVISION 2
    mov eax, %1
    mov ebx, %2
    xor edx, edx
    div ebx
    mov [resultd], eax
%endmacro

section .data
    d_add_str db "Addition: ", 0
    d_add_str_l equ $ - d_add_str
    d_sub_str db "Subtraction: ", 0
    d_sub_str_l equ $ - d_sub_str
    d_mul_str db "Addition: ", 0
    d_mul_str_l equ $ - d_mul_str
    d_div_str db "Division: ", 0  
    d_div_str_l equ $ - d_div_str
section .bss
    buffer_write resb 16
    buffer_read resb 16
    resulta resd 1
    results resd 1
    resultm resd 1
    resultd resd 1

section .text
    global _start

_start:

    ADDITION 123, 123    
    mov eax, 4
    mov ebx, 1
    mov ecx, d_add_str
    mov edx, d_add_str_l
    int 0x80
    mov eax, [resulta]
    call printf

    SUBTRACTION 123, 124    
    mov eax, 4
    mov ebx, 1
    mov ecx, d_sub_str
    mov edx, d_sub_str_l
    int 0x80
    mov eax, [results]
    call printf

    MULTIPLICATION 24, 24    
    mov eax, 4
    mov ebx, 1
    mov ecx, d_mul_str
    mov edx, d_mul_str_l
    int 0x80
    mov eax, [resultm]
    call printf

    DIVISION 128, 2    
    mov eax, 4
    mov ebx, 1
    mov ecx, d_div_str
    mov edx, d_div_str_l
    int 0x80
    mov eax, [resultd]
    call printf

    mov eax, 1
    mov ebx, 0
    int 0x80

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