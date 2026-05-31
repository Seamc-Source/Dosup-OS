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

    xor bx, bx

    mov byte [gs:bx], '1'
    inc bx
    mov byte [gs:bx], DISP_MD
    inc bx

    mov eax, KNL_SS
    mov bx,  KNL_BA
    mov cx,  KNL_UL

    mov esi, eax
    mov di,  cx

    mov dx,  0x1f2
    mov al,  cl
    out dx,  al
    mov eax, esi

    mov dx, 0x1f3
    out dx, al

    mov cl,  8
    shr eax, cl
    mov dx,  0x1f4
    out dx,  al

    shr eax, cl
    mov dx,  0x1f5
    out dx,  al

    shr eax, cl
    and al,  0fh
    or  al,  0xe0
    mov dx,  1f6h
    out dx,  al

    mov dx, 1f7h
    mov al, 20h
    out dx, al

    .not_ready:
        nop
        in  al, dx
        and al, 88h
        cmp al, 8
        jnz .not_ready

    mov ax, di
    mov dx, 256
    mul dx

    mov cx, ax
    mov dx, 1f0h

    .go_on:
        in  ax, dx
        mov [bx], ax
        add bx, 2
        loop .go_on
        ret

    jmp 0x0000:KNL_BA

times 510 - ($ - $$) db 0
dw 0xaa55
