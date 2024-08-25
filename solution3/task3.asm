section .bss
    result resd 1
section .data
    fnum dd -21234
    snum dd -11234
    tnum dd -31234

section .text
    global _start

_start:
    mov eax, [snum]
    mov edx, [fnum]
    cmp eax, edx
    cmovl eax, edx

    mov edx, [tnum]
    cmp eax, edx
    cmovl eax, edx

    mov [result], eax

    mov eax, 1
    mov ebx, 0
    int 0x80