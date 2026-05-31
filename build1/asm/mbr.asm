KNL_BA equ 0x7e00 ; Base Address
KNL_SS equ      2 ; Start Sector
KNL_UL equ      1 ; Used Length

section mbr vstart=0x7c00
mmain:
    xor ax, ax
    mov cs, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, ax

    mov ax, 0xb800
    mov gs, ax

    mov byte [gs:0x00], 'R'
    mov byte [gs:0x01], 0x07
    mov byte [gs:0x02], 'D'
    mov byte [gs:0x03], 0x07

    ; rd disk
    mov esi, KNL_SS
    mov di,  KNL_BA
    mov cx,  KNL_UL
    mov esi, eax
    mov di,  cx

    mov dx, 0x1f2
    mov al, cl
    out dx, al

    ; 7-10 bits
    mov dx, 0x1f3
    out dx, al

    ; 15-8 bits
    mov cl,  8
    shr eax, cl
    mov dx,  0x1f4
    out dx,  al

    ; 23-16 bit
    shr eax, cl
    mov dx,  0x1f5
    out dx,  al

    ; Go to LBA Mode
    shr eax, cl
    and al,  0x0f
    or  al,  0xe0

    mov dx, 0x1f6
    out dx, al

    ; Write Read Command form 0x1f7
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    .not_ready:
        nop
        in  al, dx
        and al, 88h
        cmp al, 8
        jnz .not_ready

    ; Read Data
    mov ax, di
    mov dx, 0xff
    mul dx
    mov cx, ax
    mov dx, 0x1f0

    .go_on:
        in ax, dx
        mov [bx], ax
        add bx, 2
        loop .go_on

    jmp 0x0000:KNL_BA

times 510-($-$$) db 0
dw 0xaa55
