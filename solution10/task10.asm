section .data
    msg db 'Hello, World!', 0
    msg_len equ $ - msg
    shift db 3
    encrypted_msg db 256 dup(0)
    decrypted_msg db 256 dup(0)
    encrypted_label db 'Encrypted: ', 0
    encrypted_label_l equ $ - encrypted_label
    decrypted_label db 'Decrypted: ', 0
    decrypted_label_l equ $ - decrypted_label
    newline db 0xA

section .text
    global _start

section .extra
    extra_msg db 'Segment data', 0
    extra_msg_len equ $ - extra_msg

_start:
    mov esi, extra_msg
    mov edi, encrypted_msg
    mov ecx, extra_msg_len
    mov al, [shift]
    call encrypt

    mov esi, encrypted_msg
    mov edi, decrypted_msg
    mov ecx, extra_msg_len
    mov al, [shift]
    call decrypt

    call print_encrypted
    call print_decrypted

    mov eax, 1
    xor ebx, ebx
    int 0x80

encrypt:
    pushad
    _encrypt_loop:
        lodsb
        cmp al, 0
        je _end_encrypt
        add al, [shift]
        stosb
        dec ecx
        cmp ecx, 0
        jg _encrypt_loop
    _end_encrypt:
        popad
        ret

decrypt:
    pushad
    _decrypt_loop:
        lodsb
        cmp al, 0
        je _end_decrypt
        sub al, [shift]
        stosb
        dec ecx
        cmp ecx, 0
        jg _decrypt_loop
    _end_decrypt:
        popad
        ret

print_encrypted:
    mov eax, 4
    mov ebx, 1
    mov ecx, encrypted_label
    mov edx, encrypted_label_l
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, encrypted_msg
    mov edx, extra_msg_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

print_decrypted:
    mov eax, 4
    mov ebx, 1
    mov ecx, decrypted_label
    mov edx, decrypted_label_l
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, decrypted_msg
    mov edx, extra_msg_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret