PROGRAM_SIZE equ 5; константа, определяющая размер программы (плохая идея, но пока так)
DATA_SEG equ 0x60; сегмент данных, куда загружаем наш код
STACK_SEG equ 0x7E0; сегмент для стека

use16
org 0x7c00
section .text
start:

    mov   ax, DATA_SEG         ; сегмент куда пишем
    mov   es, ax
    mov bx, 0; адрес куда пишем
    mov   ch, 0; дорожка 0
    mov   cl, 2   ; начиная с сектора 2(нумерация с одного)
    mov   dl, 0x80; номер диска
    mov   dh, 0; номер головки(нумерация с нуля)
    mov   ah, 2; номер функции
    mov   al, PROGRAM_SIZE;считать n секторов
    int   0x13
    
    jnc .no_error
    ; если что-то пошло не так
    mov al, '!'
    mov ah, 0x0E; номер функции BIOS
    mov bh, 0; страница видеопамяти
    int 0x10; выводим символ
    jmp $
    .no_error:
    ; настраиваем сегменты
    
    mov ax, DATA_SEG; сегмент данных
    mov ds, ax
    mov es, ax
    mov ax, STACK_SEG
    mov ss, ax; не забываем про сегмент стека
    
    
    jmp DATA_SEG:0; прыгаем на только что загруженный код
finish:
    times 0x1FE-finish+start db 0
    db 0x55, 0xAA; сигнатура загрузочного сектора
