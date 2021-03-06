section .bss
    char_buff_10 resb 10; просто буфер для хранения промежуточных данных
section .data
	current_ch_color dd 1111b
section .text
; void setCharColor(int_32 color)
setCharColor: 
	push eax
	mov eax, [esp+2+4]
	mov [current_ch_color], eax
	pop eax
	ret
;void printChar(char_8* buff)
printChar:
    push ebp
    mov ebp, esp
    
    push eax
    push ebx
    push ecx
    
    mov al, [ebp+2+4]    
    ; если \t
    cmp al, 9
    je .proc_tab
    jmp .next
    .proc_tab:
    mov ecx, 4
    .tab_lp: ; выводим 4 пробела
        mov al, ' '
        mov ah, 0x0e
        mov bl, [current_ch_color]
        int 0x10
        loop .tab_lp
        
    .next:
    ; иначе выводим символ
    mov ah, 0x0e
    mov bl, [current_ch_color]
    int 0x10
    
    ; если \n добавляем \r
    cmp al, 10
    jne .end
    mov al, 13
    mov ah, 0x0e
    mov bl, [current_ch_color]
    int 0x10
    
    .end:
    
    pop ecx
    pop ebx
    pop eax
    
    mov esp, ebp
    pop ebp
    ret
; void print(char_8* buff)
print:
    ; сохраняем положение вершины стека, 
    ; чтоб было удобно получать аргументы
    push ebp
    mov ebp, esp
    ; сохраняем параметры, 
    ; чтоб не поломать ничего в чужом коде
    push ax
    push bx
    push esi
    
    mov esi, [ebp+2+4]; первый аргумент (ebp + адрес возврата)
    
    .lp:; посимвольно выводим
        mov al, [esi]    
        cmp al, 0
        ; если нулевой символ, выходим
        jz .end_lp
        ; если \t
        cmp al, 9
        je .proc_tab
        jmp .next
        .proc_tab:
        mov ecx, 4
        .tab_lp: ; выводим 4 пробела
            mov al, ' '
            mov ah, 0x0e
            mov bl, [current_ch_color]
            int 0x10
            loop .tab_lp
            
        .next:
        ; иначе выводим символ
        mov ah, 0x0e
        mov bl, [current_ch_color]
	int 0x10
        inc esi
        
        ; если \n добавляем \r
        cmp al, 10
        jne .lp
        mov al, 13
        mov ah, 0x0e
        mov bl, [current_ch_color]
        int 0x10
        
        jmp .lp
    .end_lp:
    ; делаем всё как было до вызова функции
    pop esi    
    pop bx
    pop ax

    mov esp, ebp
    pop ebp
    ; выходим
    ret
; void println(char_8* buff)
println:
    push dword [esp+2]
    call print
    add esp, 4
    ; добавляем возврат каретки и перенос строки
    mov al, 13; \r
    mov ah, 0x0e
    mov bl, [current_ch_color]
    int 0x10
    
    mov al, 10; \n
    mov ah, 0x0e
    mov bl, [current_ch_color]
    int 0x10

    ret
    
; void printInt(int value)
printInt:
    push ebp
    mov ebp, esp
    
    push ecx
    push esi
    push edi
    push eax
    push ebx
    
    xor ecx, ecx
    
    mov eax, [ebp+2+4]
    mov edi, char_buff_10 
    cmp eax, 0
    jnl .lp
        neg eax
        pusha
        mov al, '-'
        mov ah, 0x0e
        mov bl, [current_ch_color]
        int 0x10
        popa
;    mov eax, 1591
    .lp:
        mov edx, 0
        mov ebx, 10
        idiv ebx
        
        
        add dl, 48
        mov [edi], dl
        inc edi      
        inc ecx
        
        cmp eax, 0
        jz .endlp
        jmp .lp
    .endlp:
    
    .outlp:
        dec edi
        mov al, [edi]
        mov ah, 0x0e
        mov bl, [current_ch_color]
        int 0x10
        loop .outlp
     
    pop ebx
    pop eax
    pop edi
    pop esi
    pop ecx
    
    mov esp, ebp
    pop ebp
    ret

; тут баг с переходом на новую строку
; после перехода на новую строку backspace стирает содержимое массива, но не стирает с экрана
; int_32 readLine(char_8 *buff, int count)
readLine:
    push ebp
    mov ebp, esp

    push edi
    push ecx
        
    mov edi, [ebp+2+8]; буфер
    mov ecx, [ebp+2+4]; количество
    
    xor esi, esi

    .readlp:

        mov ah, 0
        int 0x16
        ; al, ah
        test al, al

        jnz .noerror
        ; handle error
        jmp .endlp
        .noerror:
        
        
        cmp al, 13;\r
        jz .endlp
        cmp al, 10;\n
        jz .endlp
        
        cmp al, 8;\b backspace
        jz .backspace_handler
        
        ; пишем в массив
        mov [edi+esi], al
        inc esi   
        jmp .print_char
        .backspace_handler:
        cmp esi, 0
        je .readlp
        
        dec esi
        ; выводим backspace
        mov al, 8
        mov ah, 0x0e
        mov bl, [current_ch_color]
        int 0x10
        ; пробельный символ
        mov al, ' '
        mov ah, 0x0e
        mov bl, [current_ch_color]
        int 0x10
        ; и потом ещё один backspace
        mov al, 8
        .print_char:
        ; выводим на экран
        mov ah, 0x0e
        mov bl, [current_ch_color]
        int 0x10
        loop .readlp
    .endlp:

    mov [edi+esi], byte 0

    mov al, 10    
    mov ah, 0x0e
    mov bl, [current_ch_color]
    int 0x10
    mov al, 13    
    mov ah, 0x0e
    mov bl, [current_ch_color]
    int 0x10

        
    mov eax, esi
    pop ecx
    pop edi
    
    mov esp, ebp
    pop ebp
    ret

; int_32 readInt(int_32* result)
; success code in eax
; result in first argument
readInt:
    push ebp
    mov ebp, esp
    
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov edi, [ebp+2+4]; адрес на который указывает аргумент

    push dword char_buff_10
    push dword 10
    call readLine
    add esp, 8
    
    mov ecx, eax
    xor esi, esi; итератор
    xor edx, edx; аккумулятор
    
    
    .lp:; перебираем строку с конца
        
        xor eax, eax; зануляем eax
        mov al, [char_buff_10+ecx-1]; считываем символ
        
        cmp ecx, 1; если нулевой символ, проверяем знак
        jnz .next
        cmp al, '-'
        jnz .next
        ; Обрабатываем минус
        neg edx; меняем знак
        jmp .endlp
        .next:

        ; проверяем соответствует ли он ascii коду цифры
        cmp al, '0'
        jl .error
        cmp al, '9'
        jg .error
        
        
        
        sub al, '0'
        ; вычисляем 10 в степени номер цифры
        push ecx
        mov ebx, 1
        mov ecx, esi; степень
        cmp ecx, 0
        jng .break_pow_lp
        .pow_lp:
            imul ebx, 10
            jo .error
            loop .pow_lp
        .break_pow_lp:
        pop ecx
        
        imul eax, ebx
        jo .error
        add edx, eax; добавляем очередную цифру
        jo .error
                
        inc esi
        loop .lp
        .endlp:
        
;    mov edx, 666
    mov [edi], edx; пишем по адресу на который указывает первый аргумент
    
    
    xor eax, eax; ошибки нет
    mov eax, 0
    jmp .noerror
    .error:
    mov eax, 1; ошибка есть
    .noerror:
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
        
    mov esp, ebp
    pop ebp    
    ret

; int_32 parseInt(char_8* buff, int size, int_32* result)
; success code in eax
; result in first argument
parseInt:
    push ebp
    mov ebp, esp
    
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov edi, [ebp+2+4]; result - адрес на который указывает аргумент
    mov ebx, [ebp+2+12]; buff
    ;mov ebx, [ebx]
    
    mov ecx, [ebp+2+8]; size
    xor esi, esi; итератор
    xor edx, edx; аккумулятор
    
    
    .lp:; перебираем строку с конца    
        xor eax, eax; зануляем eax
        mov al, [ebx+ecx-1]; считываем символ

        cmp ecx, 1; если нулевой символ, проверяем знак
        jnz .next
        cmp al, '-'
        jnz .next
        ; Обрабатываем минус
        neg edx; меняем знак
        jmp .endlp
        .next:
        
        ;pusha
;        mov ah, 0x0e
;        mov bl, 0
;        int 0x10
;        popa
        
        ; проверяем соответствует ли он ascii коду цифры
        cmp al, '0'
        jl .error
        cmp al, '9'
        jg .error
        
        
        
        sub al, '0'
        ; вычисляем 10 в степени номер цифры
        push ebx
        push ecx
        mov ebx, 1
        mov ecx, esi; степень
        cmp ecx, 0
        jng .break_pow_lp
        .pow_lp:
            imul ebx, 10
            jo .error
            loop .pow_lp
        .break_pow_lp:
        pop ecx
        
        imul eax, ebx
        jo .error
        add edx, eax; добавляем очередную цифру
        jo .error
        pop ebx
                
        inc esi
        loop .lp
        .endlp:
        
;    mov edx, 666
    mov [edi], edx; пишем по адресу на который указывает первый аргумент
    
    
    xor eax, eax; ошибки нет
    mov eax, 0
    jmp .noerror
    .error:
    mov eax, 1; ошибка есть
    .noerror:
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
        
    mov esp, ebp
    pop ebp    
    ret

;void printNewLine()
printNewLine:
    push eax
    push ebx
    
    mov al, 13
    mov ah, 0x0e
    mov bl, [current_ch_color]
    int 0x10
    mov al, 10
    mov ah, 0x0e
    mov bl, [current_ch_color]
    int 0x10

    pop ebx
    pop eax
    
    ret

;int_32 strlen(char_8* buff)
strlen:
    push ebp 
    mov ebp, esp
    
    push esi

    xor eax, eax
    mov esi, [ebp+2+4]
    .lp:
        cmp [esi+eax], byte 0
        jz .endlp        
        inc eax
        jmp .lp
    .endlp:

    pop esi
    
    mov esp, ebp
    pop ebp
    ret
