section .data
    array dd 1,2,3,4,4,3,2,1
    array_length equ 8

section .bss
    result resd 1

section .text
    global _start

_start:
    mov eax, [array]
    mov esi, array + 4
    mov ecx, array_length
_findmax:
    cmp eax, [esi]
    cmovl eax, [esi]
    add esi, 4
    loop _findmax

    mov [result], eax

    mov eax, 1
    mov ebx, 0
    int 0x80
