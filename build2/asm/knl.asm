KNL_BA  equ 0x900
DISP_MD equ 0x007

section KNL vstart=KNL_BA
    mov ax, 0xb800
    mov es, ax

    mov byte [es:0x00], '2'
    mov byte [es:0x01], DISP_MD

    hlt
    jmp $
