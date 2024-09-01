%macro PRINTM 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

section .data
    key_s db "Enter key: ", 0
    key_l equ $ - key_s 
    input_path db 'Enter encryption filepath: ', 0
    input_path_l equ $ - input_path
    output_path db 'Enter decryption filepath: ', 0
    output_path_l equ $ - output_path
    state db 'Success', 0x0A
    debug_err db 'File not defined', 0x0A
    debug_l equ $ - debug_err
    file_descriptor dd 0
    file_size db 0
    zero_buffer db 1024 dup(0)

section .bss
    key resb 2
    input_file resb 32
    output_file resb 32
    buffer_write resb 1
    input_buffer resb 1
    result_array resd 1
    result_array_size resd 1
    old_array_size resd 1

section .text
    global _start

_start:
    PRINTM key_s, key_l
    mov eax, 3
    mov ebx, 2
    mov ecx, key
    mov edx, 2
    int 0x80

    mov al, [key]
    sub al, '0'
    mov [key], al

    PRINTM input_path, input_path_l
    mov eax, 3
    mov ebx, 2
    mov ecx, input_file
    mov edx, 32
    int 0x80
    
    mov byte [input_file + eax - 1], 0

    PRINTM output_path, output_path_l
    mov eax, 3
    mov ebx, 2
    mov ecx, output_file
    mov edx, 32
    int 0x80
    mov byte [output_file + eax - 1], 0

    call read_file
    mov esi, input_buffer
    mov edi, input_buffer
    mov ecx, 256
    call crypt
    call write_file

    mov esi, input_buffer
    mov edi, buffer_write
    mov ecx, 256
    call crypt

exit:
    PRINTM state, 7
    mov eax, 1
    xor ebx, ebx
    int 0x80

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

crypt:
    mov edx, ecx
    shr edx, 2
    jz crypt_tail

crypt_unroll:
    lodsb
    xor al, [key]
    stosb
    lodsb
    xor al, [key]
    stosb
    lodsb
    xor al, [key]
    stosb
    lodsb
    xor al, [key]
    stosb
    dec edx
    jnz crypt_unroll

crypt_tail:
    and ecx, 3
    jz _done_crypt

crypt_tail_loop:
    lodsb
    xor al, [key]
    stosb
    loop crypt_tail_loop

_done_crypt:
    ret

read_file:
    mov eax, 5
    mov ebx, input_file
    mov ecx, 0
    int 0x80

    test eax, eax
    js open_error

    mov [file_descriptor], eax

    mov eax, 19
    mov ebx, [file_descriptor]
    xor ecx, ecx
    mov edx, 2
    int 0x80
    mov [file_size], eax

    mov eax, 19
    mov ebx, [file_descriptor]
    xor ecx, ecx
    xor edx, edx
    int 0x80

    mov eax, 3
    mov ebx, [file_descriptor]
    mov ecx, input_buffer
    mov edx, [file_size]
    int 0x80

    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80
    ret

write_file:
    mov eax, 5
    mov ebx, output_file
    mov ecx, 0101h
    mov edx, 0666h
    int 0x80
    test eax, eax
    js open_error

    mov [file_descriptor], eax

    mov eax, 4
    mov ebx, [file_descriptor]
    mov ecx, input_buffer
    mov edx, [file_size]
    int 0x80

    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80
    ret

open_error:
    PRINTM debug_err, debug_l
    mov eax, 1
    mov ebx, 1
    int 0x80

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

printf:
    test eax, eax
    jge _store_number
    mov byte [input_buffer], '-'
    neg eax
    mov esi, input_buffer
    inc esi
    jmp _convert_number

_store_number:
    mov esi, input_buffer

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
    mov ecx, input_buffer
    mov edx, esi
    sub edx, input_buffer
    int 0x80
    ret
