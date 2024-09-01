%macro MALLOC 1
    mov	eax, 45
    xor	ebx, ebx
    int	0x80

    mov edx, %1 
    mov [result_array_size], edx
    mov edx, edx
    mov ebx, 4
    imul ebx, edx

    add eax, ebx
    mov	ebx, eax
    mov	eax, 45
    int	0x80
        
    cmp	eax, 0
    jl	exit

    mov	edi, eax
    sub	edi, 4

    mov [result_array], edi

    mov	ecx, 1
    xor	eax, eax
    std
    rep	stosd
    cld
%endmacro

%macro REALLOC 0
    mov esi, [result_array]
    mov	eax, 45
    xor	ebx, ebx
    int	0x80

    mov edx, [result_array_size]
    inc edx
    mov [result_array_size], edx
    
    mov edx, edx
    mov ebx, 4
    imul ebx, edx

    add eax, ebx
    mov	ebx, eax
    mov	eax, 45
    int	0x80
        
    cmp	eax, 0
    jl	exit

    mov	edi, eax
    sub	edi, 4

    mov [result_array], edi

    mov	ecx, [result_array_size]

    mov ecx, [result_array_size]
    
    call fill
%endmacro

%macro DEALLOC 0
    mov esi, [result_array]
    mov eax, 45
    xor ebx, ebx
    int 0x80

    mov edx, [result_array_size]
    dec edx
    mov [result_array_size], edx

    mov edx, edx
    mov ebx, 4
    imul ebx, edx

    add eax, ebx
    mov ebx, eax
    mov eax, 45
    int 0x80

    cmp eax, 0
    jl exit

    mov edi, eax
    sub edi, 4

    mov [result_array], edi

    mov ecx, [result_array_size]

    call fill

%endmacro

%macro FREE 0
    mov ecx, [result_array_size]
    call free_memory
        
    mov eax, 1
    mov [result_array_size], eax
    mov esi, [result_array]
    mov eax, 0
    mov [esi], eax
    mov [result_array], edi
%endmacro

free_memory:
    cmp ecx, 1
    je _lfm
    push ecx
    DEALLOC
    pop ecx
    dec ecx
    jnz free_memory
    _lfm:
        ret

fill:
    .loop:
        mov eax, [esi]
        add esi, 4
        mov [edi], eax
        add edi, 4
        loop .loop
    ret


%macro PRINTM 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

section	.data
    array1 dd 1,2,3,4
    array1_length equ ($ - array1) / 4
    array2 dd 3,4,5
    array2_length equ ($ - array2) / 4
    newline db 0x0A
    common_str db "Common elements: ", 0
    common_l equ $ - common_str
    common_f_str db "First array difference: ", 0
    common_f_str_l equ $ - common_f_str
    common_s_str db "Second array difference: ", 0
    common_s_str_l equ $ - common_s_str
    offset dd 0


section .bss
    buffer_write    resb 16
    buffer_read     resb 16
    result_array    resd 1
    result_array_size resd 1
    old_array_size resd 1


section	.text
   global _start 
_start:
    MALLOC 1
    PRINTM common_str, common_l
    call find_common
    FREE
    PRINTM common_f_str, common_f_str_l
    call find_not_common
    FREE
    PRINTM common_s_str, common_s_str_l
    call find_not_common2
exit:
    mov	eax, 1
    xor	ebx, ebx
    int	80h

find_not_common:
    mov esi, array1
    mov ecx, array1_length
    mov edx, 0
    mov [offset], edx

    _loop_not_common:
        test ecx, ecx
        jz _leave_not_common

        mov eax, [esi]

        push ecx
        push esi
        mov esi, array2
        mov ecx, array2_length
        call check_not_common
        pop esi
        pop ecx

        add esi, 4
        dec ecx
        jmp _loop_not_common

    _leave_not_common:
        mov eax, [result_array_size]
        cmp eax, 1
        je _lnc
        DEALLOC
        call print_array
        _lnc:
            PRINTM newline, 1
            ret

    check_not_common:
        mov edx, ecx
        mov ecx, 0

        _check_loop:
            cmp edx, 0
            jz _not_found

            cmp eax, [esi]
            je _found

            add esi, 4
            dec edx
            jmp _check_loop

        _not_found:
            push eax
            mov esi, [result_array]
            mov edx, [offset]
            mov [esi + edx], eax
            add edx, 4
            mov [offset], edx
            REALLOC
            pop eax
            ret

        _found:
            ret

find_not_common2:
    mov esi, array2
    mov ecx, array2_length
    mov edx, 0
    mov [offset], edx

    _loop_not_common2:
        test ecx, ecx
        jz _leave_not_common2

        mov eax, [esi]

        push ecx
        push esi
        mov esi, array1
        mov ecx, array1_length
        call check_not_common2
        pop esi
        pop ecx

        add esi, 4
        dec ecx
        jmp _loop_not_common2

    _leave_not_common2:
        mov eax, [result_array_size]
        cmp eax, 1
        je _lnc2
        DEALLOC
        call print_array
        _lnc2:
            PRINTM newline, 1
            ret

        check_not_common2:
            mov edx, ecx
            mov ecx, 0

        _check_loop2:
            cmp edx, 0
            jz _not_found2

            cmp eax, [esi]
            je _found2

            add esi, 4
            dec edx
            jmp _check_loop2

        _not_found2:
            push eax
            mov esi, [result_array]
            mov edx, [offset]
            mov [esi + edx], eax
            add edx, 4
            mov [offset], edx
            REALLOC
            pop eax
            ret

        _found2:
            ret

find_common:
    mov esi, array1
    mov ecx, array1_length
    mov edx, 0

    _loop_common:
        test ecx, ecx
        jz _leave_common
        
        mov eax, [esi]
    
        push ecx
        push esi
        mov esi, array2
        mov ecx, array2_length
        call iterate_common
        pop esi
        pop ecx

        add esi, 4
        dec ecx
        jmp _loop_common

        _leave_common:
            mov eax, [result_array_size]
            cmp eax, 1
            je _lc
            DEALLOC
            call print_array
                _lc:
                PRINTM newline, 1
                ret

    iterate_common:
        _iterate_common_loop:
            test ecx, ecx
            jz _leave_i_common
            
            cmp eax, [esi]
            jne _continue
            push esi
            mov esi, [result_array]
            mov edx, [offset]
            mov [esi + edx], eax
            add edx, 4
            mov [offset], edx
            REALLOC
            pop esi
            ret
            _continue:

            add esi, 4
            dec ecx
            jmp _iterate_common_loop

            _leave_i_common:
                ret


print_array:
    mov esi, [result_array]
    mov ecx, [result_array_size]
    
    _print_loop:
        test ecx, ecx
        jz _leave
        
        mov eax, [esi]
        
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
        mov byte [esi], ' '
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