; под программу 30208
; под стек 623104
org 0x0; смещение для правильного вычисления адресов

ARITHMETICAL_STACK_SIZE equ 15

section .bss
   token_buffer resb 255; буфер для временного хранения токенов
   token_buffer_length resd 1; длина токена
   number_buffer resb 10
   arithmetical_stack resd ARITHMETICAL_STACK_SIZE; собсно стек для хранения значений
section .data
   err_message db "error", 0
   input_message db "enter token or ? for getting help: "
   empty_string db 0
   arithmetical_stack_top dd 0; 
section .text
main:
    mov [arithmetical_stack_top], dword 0

    .loop:
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
    cmp [token_buffer], byte 'p'
    je .case_print_stack
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
    .case_print_stack:
        call printArithmeticalStack
        jmp .break
    .case_add:
        ;берём число из стека
        mov ecx, [arithmetical_stack_top]
        mov eax, [arithmetical_stack+ecx*4]
        dec ecx
        mov [arithmetical_stack_top], ecx
        ; и ещё одно
        mov ebx, [arithmetical_stack+ecx*4]
        dec ecx
        mov [arithmetical_stack_top], ecx
        ; вычисляем
        add eax, ebx
        ; кладём результат на вершину стека
        inc dword [arithmetical_stack_top]
        mov ecx, [arithmetical_stack_top]
        mov [arithmetical_stack+ecx*4], eax
        
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
        ; если не спарсилось, то выдаём ошибку
        cmp eax, 0
        jnz .error
        ; пихаем в стек
        inc dword [arithmetical_stack_top]; увеличиваем указатель на вершину стека
        cmp [arithmetical_stack_top], dword ARITHMETICAL_STACK_SIZE; сравниваем с максимальным размером
        jnl .error; если больше или равно, ошибка
        
        mov eax, [number_buffer]
        mov ebx, [arithmetical_stack_top]
        mov [arithmetical_stack+ebx*4], dword eax; кладём число на вершину стека
        ; выводим содержимое стека
        call printArithmeticalStack
       
    .break:


    ;push dword 100
    ;call sleep
    ;add esp, 4
    
    jmp .loop
    .error:
        push dword err_message
        call println
        add esp, 4
        ; ждём нажатия клавиши
        mov ah, 0
        int 0x16
        jmp main
        
%include "io.asm"
%include "delay.asm"
section .data
; включаем содержимое файла с информацией о помощи
help_message incbin "help_message.bin"
db 0; и символ конца строки
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
section .data
    stack_size_message db "stack size is ", 0
section .text
printArithmeticalStack:
    push dword stack_size_message 
    call print
    add esp, 4
    
    mov ecx, [arithmetical_stack_top]
    push dword ecx
    call printInt
    add esp, 4
    
    call printNewLine
    
    mov ecx, ARITHMETICAL_STACK_SIZE
    .lp1:
        push dword [arithmetical_stack+ecx*4-4]
        call printInt
        add esp, 4
        
        ;pusha
        mov al, 13
        mov ah, 0x0e
        mov bl, 0
        int 0x10
        mov al, 10
        mov ah, 0x0e
        mov bl, 0
        int 0x10
        ;popa
        loop .lp1
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