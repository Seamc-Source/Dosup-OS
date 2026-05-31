KNL_BA  equ 0x900
DISP_MD equ 0x007

section KNL vstart=KNL_BA
kmain:
    mov ax, 0xb800
    mov es, ax

    mov byte [es:0x00], '>'
    mov byte [es:0x01], DISP_MD
.waiting:
    xor ah, ah
    int 16h

    cmp al, 0x1c
    je .is_enter

    cmp al, 0x0e
    je .is_bksp

    mov ah, 0eh
    int 10h
.is_enter:
    mov ah, 0eh
    mov al, 0dh
    int 10h

    mov al, 0ah
    int 10h

    jmp .waiting
.is_bksp:
    mov ah, 3
    xor bh, bh
    int 10h

    cmp dl, 0
    jmp .waiting

    dec dl
    push dx

    mov ah, 2
    int 10h

    mov al, ' '
    mov ah, 0eh
    int 10h

    pop dx
    mov ah, 02h
    int 10h
