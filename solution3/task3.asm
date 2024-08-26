section .bss
    result resd 1
    buffer_write resb 16
    buffer_read resb 16
section .data
    fnum dd 0
    snum dd 0
    tnum dd 0
    minmax dd 0
    high_str db "Highest number: ", 0
    high_str_len equ $ - high_str
    low_str db "Lowest number: ", 0
    low_str_len equ $ - low_str
    f_str db "First number: ", 0
    f_str_len equ $ - f_str
    s_str db "Second number: ", 0
    s_str_len equ $ - s_str
    t_str db "Third number: ", 0
    t_str_len equ $ - t_str
    minmax_str db "Max - 1, Min - 2: ", 0
    minmax_str_len equ $ - minmax_str

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, f_str
    mov edx, f_str_len
    int 0x80
    call scanf
    mov [fnum], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, s_str
    mov edx, s_str_len
    int 0x80
    call scanf
    mov [snum], eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, t_str
    mov edx, t_str_len
    int 0x80
    call scanf
    mov [tnum], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, minmax_str
    mov edx, minmax_str_len
    int 0x80
    call scanf
    cmp eax, 1
    je max
    cmp eax, 2
    jne exit


min:
    mov eax, [snum]
    mov edx, [fnum]
    cmp eax, edx
    cmovg eax, edx

    mov edx, [tnum]
    cmp eax, edx
    cmovg eax, edx

    mov [result], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, low_str
    mov edx, low_str_len
    int 0x80

    jmp exit
max:
    mov eax, [snum]
    mov edx, [fnum]
    cmp eax, edx
    cmovl eax, edx

    mov edx, [tnum]
    cmp eax, edx
    cmovl eax, edx

    mov [result], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, high_str
    mov edx, high_str_len
    int 0x80

exit:
    mov eax, [result]
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