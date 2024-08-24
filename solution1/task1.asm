section .bss
    res resd 1
section .data
    fnum dd -1123492
    snum dd 2534232
    tnum dd -3123442

section .text
    global _start   

_start:
    mov eax, [fnum]
    add eax, [snum]
    add eax, [tnum]
    mov [res], eax
    mov eax, 1
    mov ebx, 0
    int 0x80  