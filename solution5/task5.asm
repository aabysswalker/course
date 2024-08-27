section .data
    array dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,-1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -26, -27, -28, -29, -30, -31, -32
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
    mov esi, array
    mov ecx, array_length

    cmp edx, 1
    je _findmax
    cmp edx, 2
    jne exit

_findmin:
    mov ebx, [esi]
    cmp eax, ebx
    cmovg eax, ebx

    mov ebx, [esi + 4]
    cmp eax, ebx
    cmovg eax, ebx

    mov ebx, [esi + 8]
    cmp eax, ebx
    cmovg eax, ebx

    mov ebx, [esi + 12]
    cmp eax, ebx
    cmovg eax, ebx

    sub ecx, 4
    add esi, 16
    cmp ecx, 4
    jl _continue_min
    cmp ecx, 0
    je _findmin
    _continue_min:
        sub ecx, 1
        _loop_min:
            mov ebx, [esi]
            cmp eax, ebx
            cmovg eax, ebx

            add esi, 4
            sub ecx, 1
            cmp ecx, 0
            jge _loop_min
    jmp exit

_findmax:
    mov ebx, [esi]
    cmp eax, ebx
    cmovl eax, ebx

    mov ebx, [esi + 4]
    cmp eax, ebx
    cmovl eax, ebx

    mov ebx, [esi + 8]
    cmp eax, ebx
    cmovl eax, ebx

    mov ebx, [esi + 12]
    cmp eax, ebx
    cmovl eax, ebx

    sub ecx, 4
    add esi, 16
    cmp ecx, 4
    jl _continue_max
    cmp ecx, 0
    je _findmax
    _continue_max:
        sub ecx, 1
        _loop_max:
            mov ebx, [esi]
            cmp eax, ebx
            cmovl eax, ebx

            add esi, 4
            sub ecx, 1
            cmp ecx, 0
            jge _loop_max

exit:    
    mov [result], eax
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