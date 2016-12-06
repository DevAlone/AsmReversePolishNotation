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
   unrecognized_token db 9,"unrecognized token", 0
   err_message db "error", 0
   input_message db "enter token or ? for getting help: ", 0
   stack_top_message db "stack top is ", 0
   empty_string db 0
   arithmetical_stack_top dd 0; 
section .text

; макросы для работы со стеком:

; аргумент указывает, куда класть значение(любой регистр общего назначения кроме edi)
%macro POP_A_STACK 1
    
    ;push esi
    cmp [arithmetical_stack_top], dword 0
    jl .error
    
    push edi
    mov edi, [arithmetical_stack_top]; берём вершину стека
    mov edi, [arithmetical_stack+edi*4]; значение с вершины в  нужное место
    mov %1, edi
    dec dword [arithmetical_stack_top]; уменьшаем значение вершины
    pop edi
%endmacro
%macro PUSH_A_STACK 1
    push eax
    push ebx
    ; пихаем в стек
    inc dword [arithmetical_stack_top]; увеличиваем указатель на вершину стека
    cmp [arithmetical_stack_top], dword ARITHMETICAL_STACK_SIZE; сравниваем с максимальным размером
    jnl .error; если больше или равно, ошибка
    
    mov eax, %1
    mov ebx, [arithmetical_stack_top]
    mov [arithmetical_stack+ebx*4], dword eax; кладём число на вершину стека
    pop ebx
    pop eax
%endmacro

; собсно код
main:
    mov [arithmetical_stack_top], dword -1

    .loop:
    push dword input_message
    call print
    add esp, 4
    
    push dword token_buffer
    push dword 255
    call readLine
    add esp, 8
    mov [token_buffer_length], eax
    
    
    
    
    ;push dword token_buffer
    ;call println
    ;add esp, 4
    
    cmp [token_buffer], byte '?'
    je .case_help
    cmp [token_buffer], byte 'h'
    je .case_help
    cmp [token_buffer], byte 'p'
    je .case_print_stack
    cmp [token_buffer], byte 'r'
    je .case_restart
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
    cmp [token_buffer], byte '&'
    je .case_bit_and
    cmp [token_buffer], byte '|'
    je .case_bit_or
    cmp [token_buffer], byte '^'
    je .case_bit_xor
    
    jmp .case_default
    
    
    .case_help:
        call printHelp
        jmp .break
    .case_print_stack:
        call printArithmeticalStack
        jmp .break
    .case_restart:
        jmp main
    .case_add:
        cmp [token_buffer_length], dword 1
        jne .case_default
    
            ; берём два числа из стека
        POP_A_STACK eax
        POP_A_STACK ebx
        ; складываем
        add eax, ebx
        ; кладём обратно в стек
        PUSH_A_STACK eax
        jmp .break
    .case_sub:   
        ; если это отрицательное число
        cmp [token_buffer_length], dword 1
        jne .case_default
             
        POP_A_STACK eax
        POP_A_STACK ebx
        sub ebx, eax
        PUSH_A_STACK ebx
        jmp .break
    .case_mult: ; умножение
        ; если токен **
        cmp [token_buffer+1], byte '*'
        je .case_pow
        
        POP_A_STACK eax
        POP_A_STACK ebx
        imul eax, ebx
        PUSH_A_STACK eax        
        jmp .break
    .case_pow: ; возведение в степень
        
        jmp .break
    .case_div:
;        POP_A_STACK eax
;        POP_A_STACK ebx
;        idiv ebx, eax
;        PUSH_A_STACK ebx        
        jmp .break
    .case_remainder_of_div:

        jmp .break
    .case_bit_and: ; побитовое и
        jmp .break
    .case_bit_or: ; побитовое или
        jmp .break
    .case_bit_xor: ; побитовое исключающее или
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
        jnz .unrecognized
        ; пихаем в стек
        PUSH_A_STACK [number_buffer]
        ; выводим содержимое стека
        call printArithmeticalStack
       
    .break:


    ;push dword 100
    ;call sleep
    ;add esp, 4
    
    push dword stack_size_message 
    call print
    add esp, 4    
    mov ecx, [arithmetical_stack_top]
    inc ecx
    push dword ecx
    call printInt
    add esp, 4
    call printNewLine
    
    cmp [arithmetical_stack_top], dword 0
    jl .stack_empty
    push dword stack_top_message
    call print
    add esp, 4
    push edi
    mov edi, [arithmetical_stack_top]; берём вершину стека
    mov edi, [arithmetical_stack+edi*4]; значение с вершины в  нужное место
    push dword edi
    call printInt
    add esp, 4
    pop edi
    call printNewLine
    .stack_empty:
    
    jmp .loop
    .unrecognized:
        push dword unrecognized_token
        call println
        add esp, 4
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

SYMBOLS_PER_LINE equ 80
LINES_PER_PAGE equ 24
section .text
printHelp:
    ;push ebp
    ;mov ebp, esp
    push eax
    push ecx
    
    .lp:        
        xor ecx, ecx
        xor ebx, ebx; счётчик переносов строки
        xor edx, edx; счётчик символов в строке
        ;pusha
        .print_loop:
            ;mov ah, 0
            ;int 0x16
            xor eax, eax
            mov al, [help_message+ecx]
            
            cmp al, 0
            je .endlp
            
            push dword ax
            call printChar
            add esp, 4
            
            
            cmp al, 9; табуляция = 4 символа
            je .case_tab
            cmp al, 10; перенос строки
            je .case_new_line
            cmp al, 13; возврат каретки
            je .case_carriage_ret
            
            jmp .case_default
            .case_tab:
                add edx, 4
                jmp .break
            .case_new_line:
                inc ebx
                jmp .break
            .case_carriage_ret:
                xor edx, edx
                jmp .break
            .case_default:
                inc edx
            .break:
            
            cmp edx, SYMBOLS_PER_LINE
            jl .next
            inc ebx; увеличиваем счётчик строк
            sub edx, SYMBOLS_PER_LINE
            .next:
            
            inc ecx
            ;cmp ecx, 10
            ;je .endlp
            
            cmp ebx, LINES_PER_PAGE
            jnl .endlp
            
            jmp .print_loop
        .endlp:
        popa
        
        ;mov ah, 0
        int 0x16
        
    jmp .lp    
    
    pop ecx
    pop eax
    ret
section .data
    stack_size_message db "stack size is ", 0
section .text
printArithmeticalStack:
    push eax
    push ebx
    push ecx
    
    push dword stack_size_message 
    call print
    add esp, 4
    
    mov ecx, [arithmetical_stack_top]
    inc ecx
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
    
    pop ecx
    pop ebx    
    pop eax
    
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