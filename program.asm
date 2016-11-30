; под программу 30208
; под стек 623104
org 0x0; смещение для правильного вычисления адресов


section .data
   test_str db  " hello, asm", 0
   err_message db "error", 0
   input_message db "enter token(number, arithmetic operation or ? for getting help)"
   var dd 1

section .text
main:
;mov [var], dword 999
    push dword var
    call readInt
    cmp eax, 0
    jnz .error
    add esp, 4
   
    push dword [var]
    call printInt
    add esp, 4


    push dword 1000
    call sleep
    add esp, 4
    
    jmp main
    .error:
        push dword err_message
        call println
        add esp, 4
        jmp $

%include "io.asm"
%include "delay.asm"

debug:
    pusha
    mov al, '&'
    mov ah, 0x0e
    mov bl, 0
    int 0x10
    ; jmp $
    popa
    ret