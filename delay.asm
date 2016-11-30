; void sleep(int ms)
; ждёт ms миллисекунд
; параметры передаются через стек  
sleep: 
    push ebp
    mov ebp, esp
    
    push eax
    push ecx
    push edx

    mov eax, [ebp+2+4]; в мС
    imul eax, 1000; переводим в мкС
    mov ecx, eax
    
    mov ah, 0x86; ждать N микросекунд
    mov dx, cx; low word
    shr ecx, 16; high word
    int 0x15
   
    pop edx
    pop ecx
    pop eax
    
    mov esp, ebp
    pop ebp
    ret
