KNL_BA  equ 0x900
DISP_MD equ 0x07

section KNL vstart=KNL_BA
kmain:
    xor ax, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, ax
    mov ss, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax

    xor bx, bx      ; VGA offset
    xor cx, cx      ; CH = row, CL = col
    xor dx, dx      ; counter

    xor ah, ah
    mov al, '>'
    call putchar

%if 0
    mov word es:[60h * 4], read_disk
    mov word es:[60h * 4 + 2], read_disk >> 4

    mov word es:[61h * 4], write_disk
    mov word es:[61h * 4 + 2], seg write_disk >> 4
%endif

.wait_key:
    xor ax, ax
    int 0x16        ; AH=scancode, AL=ascii

    call putchar

    cmp ah, 1ch
    jmp .end_key

    inc dx

    cmp dx, 0xfe
    je .end_key

    jmp .wait_key
.end_key:
    mov byte [0x7eff], 0

    push si
        cmp byte [si], 'h'
        jne .key_not_eq

        cmp byte [si+1], 'i'
        jne .key_not_eq

        xor ah, ah
        mov al, 'H'
        call putchar

        mov al, 'e'
        call putchar

        .key_not_eq:
    pop si
            mov ah, 1ch
            call putchar

            jmp .wait_key

; Disk IO
%if 0
read_disk:
    push ax
    push bx
    push cx
    push dx
    push esi

    mov esi, eax
    mov di,  cx

    mov dx,  0x1f2
    mov al,  cl
    out dx,  al
    mov eax, esi
    pop esi

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

    pop dx
    pop cx
    pop bx
    pop ax

    iret

write_disk:
    push ax
    push bx
    push cx
    push dx
    push esi

    mov esi, eax
    mov di, cx

    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi
    pop esi
    mov dx, 0x1f3
    out dx, al

    mov cl, 8
    shr eax, cl
    mov dx, 0x1f4
    out dx, al

    shr eax, cl
    mov dx, 0x1f5
    out dx, al

    shr eax, cl
    and al, 0fh
    or al, 0xe0
    mov dx, 0x1f6
    out dx, al
    mov dx, 0x1f7
    mov al, 30h
    out dx, al

    .not_ready:
        nop
        in al, dx
        and al, 88h
        cmp al, 08h
        jnz .not_ready

    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax

    mov dx, 0x1f0

    .go_on:
        mov ax, [bx]
        out dx, ax
        add bx, 2
        loop .go_on

    pop dx
    pop cx
    pop bx
    pop ax

    iret
%endif

; ==================================================
; putchar
; AH = scancode
; AL = ascii
; ==================================================
putchar:
    cmp ah, 0x1C        ; Enter
    je .is_enter

    cmp ah, 0x0E        ; Backspace
    je .is_bksp

    ; -------- normal char --------
    mov [gs:bx], al
    mov byte [gs:bx+1], DISP_MD
    add bx, 2

    inc cl
    cmp cl, 80
    jne .done

    ; wrap line
    xor cl, cl
    inc ch
    cmp ch, 25
    jne .done

    ; scroll later
    xor ch, ch
    jmp .done

; ==================================================
; Enter
; ==================================================
.is_enter:
    xor cl, cl
    inc ch

    ; Calculate cell index
    mov al, 80
    xor ah, ah
    mul ch
    add al, cl
    adc ah, 0

    shl ax, 1       ; -> VGA offset
    mov bx, ax

    call update_cursor
    jmp .done

; ==================================================
; Backspace
; ==================================================
.is_bksp:
    cmp bx, 0
    je .done

    sub bx, 2
    dec cl

    mov byte [gs:bx], ' '
    mov byte [gs:bx+1], DISP_MD

    call update_cursor
    jmp .done

.done:
    call update_cursor
    ret

; ==================================================
; Update VGA cursor
; BX = offset
; ==================================================
update_cursor:
    push ax
    push dx

    mov ax, bx
    shr ax, 1           ; offset -> cell index

    ; Low byte
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al

    mov dx, 0x3D5
    mov al, ah
    out dx, al

    ; High byte
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al

    mov dx, 0x3D5
    mov al, ah
    out dx, al

    pop dx
    pop ax
    ret

