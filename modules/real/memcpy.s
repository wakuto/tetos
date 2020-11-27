memcpy:     ; void memcpy(src, dest, size);
    push bp
    mov bp, sp

    push cx
    push si
    push di

    cld     ; clear direction flag
    mov di, [bp + 4]    ; src
    mov si, [bp + 6]    ; dest
    mov cx, [bp + 8]    ; size

    rep movsb

    pop di
    pop si
    pop cx

    mov sp, bp
    pop bp

    ret
