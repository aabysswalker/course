section .data
    key db 90
    encr db 'solution15/input', 0
    decr db 'solution15/output', 0
    mode db 'Mode? (e - encrypt, d - decrypt) ', 0
    mode_l equ $ - mode
    file_descriptor dd 0

section .bss
    buffer resb 256
    input resb 256
    buffer_write resb 256
    buffer_read resb 256

section .text
    global _start

_start:    
    mov eax, 4
    mov ebx, 1
    mov ecx, mode
    mov edx, mode_l
    int 0x80

    call scanf
    mov al, [buffer_write]
    cmp al, 'd'
    je exit 

    call read_file
    mov esi, buffer_read
    mov edi, buffer
    mov ecx, 256
    call encrypt
    call write_file


    mov esi, buffer
    mov edi, buffer_write
    mov ecx, 256
    call decrypt

exit:

    mov eax, 1
    xor ebx, ebx
    int 0x80

encrypt:
    encrypt_loop:
        lodsb
        test al, al
        jz _done_encryption
        xor al, [key]
        stosb
        loop encrypt_loop

    _done_encryption:
        ret

decrypt:
    decrypt_loop:
        lodsb
        test al, al
        jz _done_decryption
        xor al, [key]
        stosb
        loop decrypt_loop

    _done_decryption:
        ret

read_file:
    mov eax, 5
    mov ebx, encr
    mov ecx, 0
    int 0x80
    mov [file_descriptor], eax

    mov eax, 3
    mov ebx, [file_descriptor]
    mov ecx, buffer_read
    mov edx, 16
    int 0x80

    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80
    ret

write_file:
    mov eax, 5
    mov ebx, decr
    mov ecx, 0101h
    mov edx, 0666h
    int 0x80
    mov [file_descriptor], eax

    mov eax, 4
    mov ebx, [file_descriptor]
    mov ecx, buffer
    mov edx, 16
    int 0x80

    mov eax, 6
    mov ebx, [file_descriptor]
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