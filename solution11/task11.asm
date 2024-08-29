%macro PUSH_S 1
    sub edi, 4
    mov [edi], %1
%endmacro

%macro POP_S 0
    add edi, 4
%endmacro

%macro TOP_S 1
    mov %1, [edi]
%endmacro


section .data
    input db "21+1+3-1", 0x0A
    input_l equ $ - input
    stack times 256 dd 0
    debug db "Syntax Error", 0x0A
    debug_l equ $ - debug

section .bss
    buffer_write resb 16
    buffer_read resb 16

section .text
    global _start

_start:
    lea edi, [stack + 256 * 4]    

    call parse
    POP_S
    TOP_S eax

    call printf

    mov eax, 1
    mov ebx, 0
    int 0x80

parse:
    mov eax, 0
    PUSH_S eax
    mov eax, '+'
    PUSH_S eax
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    mov ecx, input_l
    mov esi, input

    _loop:

        mov bl, [esi]
        add esi, 1
        dec ecx
        jz _exit

        cmp bl, 0
        je _exit
        cmp bl, 0x0A
        je _exit
        cmp bl, '+'
        je _process_operation
        cmp bl, '-'
        je _process_operation

        cmp bl, 48
        jl _err
        cmp bl, 57
        jg _err

        sub bl, '0'
        imul edx, 10
        add edx, ebx
        jmp _loop

    _process_operation:
        TOP_S bh
        POP_S
        TOP_S eax
        POP_S

        cmp bh, 43
        je _add
        sub eax, edx

        _continue:
        PUSH_S eax
        PUSH_S bl
        xor edx, edx
        xor ebx, ebx
        jmp _loop

    _add:
        add eax, edx
        jmp _continue

    _exit:
        cmp edx, 0
        jne _process_operation

        TOP_S bh
        cmp bh, '+'
        je _err
        cmp bh, '-'
        je _err

        ret
    
    _err:
        mov eax, 4
        mov ebx, 1
        mov ecx, debug
        mov edx, debug_l
        int 0x80
        
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