section .data
    array dd 123123,1,-2,2,-1543,123,12,-2314,123,1234213,-4123,1234
    array_length equ ($ - array) / 4
    minmax_str db "Max - 1, Min - 2: ", 0
    minmax_str_len equ $ - minmax_str

section .bss
    result resd 1
    buffer_write resb 16
    buffer_read resb 16

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, minmax_str
    mov edx, minmax_str_len
    int 0x80
    call scanf
    mov edx, eax
    mov eax, [array]
    mov esi, array + 4
    mov ecx, array_length - 1

    cmp edx, 1
    je _findmax
    cmp edx, 2
    jne exit

_findmin:
    cmp eax, [esi]
    cmovg eax, [esi]
    add esi, 4
    loop _findmin
    jmp exit
_findmax:
    cmp eax, [esi]
    cmovl eax, [esi]
    add esi, 4
    loop _findmax

exit:    
    mov [result], eax
    call printf

    mov esi, array
    mov ecx, array_length - 1

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