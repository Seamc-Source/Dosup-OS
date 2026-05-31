KNL_BA  equ 0x900
KNL_SS  equ 0x002
KNL_UL  equ 0x001
DISP_MD equ 0x007

section mbr vstart=0x7c00
    xor ax, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, ax
    mov ss, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax

    mov ax, 0600h
    mov bx, 0700h
    xor cx, cx
    mov dx, 184fh

    int 10h

    xor bx, bx

    mov byte [gs:bx], '1'
    inc bx
    mov byte [gs:bx], DISP_MD
    inc bx

    mov ah, 02h
    mov al, KNL_UL
    mov bx, KNL_BA
    xor ch, ch
    mov cl, KNL_SS
    xor dh, dh
    mov dl, 80h

    int 13h
    jc  .disk_error

    jmp 0x0000:KNL_BA

.disk_error:
    mov byte [gs:bx], 'e'
    inc bx
    mov byte [gs:bx], DISP_MD
    inc bx

    hlt
    jmp $

times 510 - ($ - $$) db 0
dw 0xaa55
