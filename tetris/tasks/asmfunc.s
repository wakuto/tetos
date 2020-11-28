section .text

draw_pixel:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edx

    mov ecx, [ebp + 8]  ; x
    mov edx, [ebp +12]  ; y
    mov ebx, [ebp +16]  ; color

    int 0x82

    pop edx
    pop ecx
    pop ebx

    mov esp, ebp
    pop ebp
    ret

draw_char:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx

    mov ecx, [ebp + 8]  ; x
    mov edx, [ebp +12]  ; y
    mov ebx, [ebp +16]  ; color
    mov eax, [ebp +20]  ; ch

    int 0x81

    pop edx
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
    ret

