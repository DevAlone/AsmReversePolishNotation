; под программу 30208
; под стек 623104
org 0x0; смещение для правильного вычисления адресов

ARITHMETICAL_STACK_SIZE equ 15

section .bss
   token_buffer resb 255
   token_buffer_length resd 1
   number_buffer resb 10
   arithmetical_stack resd ARITHMETICAL_STACK_SIZE
section .data
   err_message db "error", 0
   input_message db "enter token or ? for getting help: "
   empty_string db 0
   arithmetical_stack_length db 1
section .text
main:

    push dword input_message
    call print
    add esp, 4
    
    push dword token_buffer
    push dword 255
    call readLine
    add esp, 8
    mov [token_buffer_length], eax
    
    push dword token_buffer
    call println
    add esp, 4
    
    cmp [token_buffer], byte '?'
    je .case_help
    cmp [token_buffer], byte '+'
    je .case_add
    cmp [token_buffer], byte '-'
    je .case_sub
    cmp [token_buffer], byte '*'
    je .case_mult
    cmp [token_buffer], byte '/'
    je .case_div
    cmp [token_buffer], byte '%'
    je .case_remainder_of_div
    
    jmp .case_default
    
    
    .case_help:
        call printHelp
        jmp .break
    .case_add:
        
        jmp .break
    .case_sub:
        
        jmp .break
    .case_mult:
        
        jmp .break
    .case_div:
        
        jmp .break
    .case_remainder_of_div:
        
        jmp .break
    
    .case_default:
        ; парсим число
        push dword token_buffer
        push dword [token_buffer_length]
        push dword number_buffer
        call parseInt
        add esp, 12
        cmp eax, 0
        jnz .error
        ; пихаем в стек
        ;inc dword [arithmetical_stack_length]
        ;cmp [arithmetical_stack_length], dword ARITHMETICAL_STACK_SIZE
        ;jnl .error
        
        mov eax, [number_buffer]
        ;mov ebx, [arithmetical_stack_length]
        mov [arithmetical_stack], dword eax
        ; выводим содержимое стека
        
        mov ecx, ARITHMETICAL_STACK_SIZE
        .lp1:
            push dword [arithmetical_stack+ecx*3]
            call printInt
            add esp, 4
            
            mov al, 13
            mov ah, 0x0e
            mov bl, 0
            int 0x10
            mov al, 10
            mov ah, 0x0e
            mov bl, 0
            int 0x10
            
            loop .lp1
       
    .break:
    ;push dword var
    ;call readInt
    ;cmp eax, 0
    ;jnz .error
    ;add esp, 4
   
   ; push dword [var]
   ; call printInt
   ; add esp, 4


    push dword 100
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
section .data

help_message incbin "help_message.bin"
    db 0
section .text
printHelp:
    ;push ebp
    ;mov ebp, esp
    
    push dword help_message
    call println
    add esp, 4

    ;mov esp, ebp
    ;pop ebp
    ret
debug:
    pusha
    mov al, '&'
    mov ah, 0x0e
    mov bl, 0
    int 0x10
    ; jmp $
    popa
    ret