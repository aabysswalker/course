section .data
    string db "He123lO%$#O, worl@#$ddDD!", 0
    string_length equ $ - string

section .bss
    result resb string_length + 1

section .text
    global _start

_start:
    mov esi, string
    mov ecx, string_length
; Additional task: in the condition, we need to apply uppercase BEFORE reversing, so we have to loop twice
_uppercase:
    mov al, [esi]
    cmp al, 97
    jl _skip
    cmp al, 122
    jg _skip
    sub al, 32
_skip:
    mov [esi], al
    inc esi
    loop _uppercase
    
; Reverse
    mov esi, string + string_length - 1
    mov edi, result
    mov ecx, string_length

_reverse:
    mov al, [esi]
    mov [edi], al
    dec esi
    inc edi
    loop _reverse
    mov byte [edi], 0

    mov eax, 1
    mov ebx, 0
    int 0x80