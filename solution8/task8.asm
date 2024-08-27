section .data
    array dd 4,-2,1,3,-8,9,0,-5
    array_length equ ($ - array) / 4
    temp dd 0
    uns_str db "Unsorted array", 0x0A
    uns_str_len equ $ - uns_str
    sor_str db "Sorted array", 0x0A
    sor_str_len equ $ - sor_str

section .bss
    buffer_write resb 16
    buffer_read resb 16

section .text
    global _start

_start:

    mov eax, 4
    mov ebx, 1
    mov ecx, uns_str
    mov edx, uns_str_len
    int 0x80
    
    call print_array

    call sort_array

    mov eax, 4
    mov ebx, 1
    mov ecx, sor_str
    mov edx, sor_str_len
    int 0x80

    call print_array

    mov eax, 1
    mov ebx, 0
    int 0x80

sort_array:
    mov esi, array
    mov ecx, array_length
    dec ecx

    _outer_loop:
        mov edx, ecx
        mov ebx, esi

    _inner_loop:
        mov eax, [ebx]
        mov edi, [ebx + 4]

        cmp eax, edi
        jl _skip_swap

        mov [temp], eax
        mov eax, edi
        mov edi, [temp]
        mov [ebx], eax
        mov [ebx + 4], edi

    _skip_swap:
        add ebx, 4
        dec edx
        jnz _inner_loop

        dec ecx
        jnz _outer_loop

        ret

print_array:
    mov esi, array
    mov ecx, array_length
    
    _print_loop:
        test ecx, ecx
        jz _leave
        
        mov eax, [esi]
        
        ; Save state
        push ecx
        push esi
        call printf
        pop esi
        pop ecx

        add esi, 4
        dec ecx
        jmp _print_loop

        _leave:
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