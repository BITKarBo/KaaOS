bits 16

; Käyttöjärjestelmän ydin alkaa tästä
org 0x8000

%define ENDL 0x0D, 0x0A

start:



    ; Lopeta
    cli          ; Poista keskeytykset käytöstä
    hlt          ; Pysäytä prosessori


puts:
    push si
    push ax

.loop:
    lodsb 
    or al, al
    jz .done

    mov ah, 0x0e ;video interrupti biossille 
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop ax
    pop si
    ret



times 510-($-$$) db 0 ; Täytä käyttöjärjestelmän ytimen koko 510 tavulla
dw 0xAA55 ; Boot-sektorin lopetusmerkki
