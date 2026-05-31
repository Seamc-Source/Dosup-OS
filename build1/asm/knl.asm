section knl vstart=0x7e00
kmain:
    xor ax, ax
    mov cs, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, ax

    mov ax, 0xb800
    mov gs, ax

    mov byte [gs:0x00], 'O'
    mov byte [gs:0x01], 0x07
    mov byte [gs:0x02], 'K'
    mov byte [gs:0x03], 0x07
