KNL_BA  equ 0x900
DISP_MD equ 0x07

section KNL vstart=KNL_BA
kmain:
    mov ax, 0xb800
    mov gs, ax

    xor bx, bx      ; VGA offset
    xor cx, cx      ; CH = row, CL = col

.wait_key:
    xor ax, ax
    int 0x16        ; AH=scancode, AL=ascii

    call putchar
    jmp .wait_key

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
    mov al, 80
    mul cl
    add ax, cx
    shl ax, 1
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

