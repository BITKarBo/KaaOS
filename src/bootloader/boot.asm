org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

;
; FAT12 Headerit
;
jmp short start
nop

bdb_oem:                    db 'MSWIN4.1'   ; 8 bittiä
bdb_bytes_per_sector:       dw 512
bdb_sector_per_cluster:     db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880         ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type   db 0F0h
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

ebr_drive_number:           db 0
                            db 0

ebr_signature:              db 29h
ebr_volume_id:              db 69h, 42h, 05h, 55h
ebr_volume_label:           db 'KarBo Kaaos'
ebr_system_id:              db 'FAT12   '


start:
    jmp main



main: 
    
    mov ax, 0x07C0 ; Segmenttirekisteri
    add ax, 288 ; Offset
    mov ss, ax
    mov sp, 4096 ; Stack pointer
 
    ; Lataa käyttöjärjestelmän ydin muistiin
    mov ax, 0x0200 ; Lukualue (käyttöjärjestelmän ydin alkaa 0x0200)
    mov bx, 0x8000 ; Kohdealue muistissa
    mov cx, 0x0100 ; Sektorien määrä (esim. 256 sektoria)
    mov dl, 0x80 ; Levynumero
    mov dh, 0 ; Pään numero
    mov ch, 0 ; Rata numero
    mov cl, 2 ; Sektorin numero
    int 0x13 ; Kutsu BIOS-interruptia levyn lukuun


    ; Siirry käyttöjärjestelmän ytimeen
    jmp 0x8000:0000

floppy_error:
    mov si, msg_read_fail
    call puts
    jmp wait_key_and_reboot


wait_key_and_reboot:
    mov ah, 0
    int 16h
    jmp 0FFFFh:0
    hlt

.halt:
    cli
    hlt


;   Disk routines
;   Converts an LBA address to a CHS address
;   Parameters :
;       ax: LBA address
;   Returns :
;       - cx [bits 0-5]: sector number
;       - cx [bits 6-15]: cylinder
;       - dh: head
;

lba_to_chs:

    push ax
    push dx

    xor dx, dx                              ; dx = 0
    div word [bdb_sectors_per_track]        ; ax = LBA / SectorsPerTrack
                                            ; dx = LBA % SectorsPerTrack

    inc dx                                  ; dx = (LBA % SectorsPerTrack + 1) = secotrs
    mov cx, dx                              ; cx = sector

    xor dx, dx                              ; dx = 0
    div word [bdb_heads]                    ; ax = (LBA / SectorsPerTrack) / Heads = Cylinder
                                            ; dx = (LBA % SectorsPerTrack) % Heads = head

    mov dh, dl
    mov ch, al
    shl ah, 6
    or cl, ah

    pop ax
    mov dl, al
    pop ax
    ret

disk_read:

    push ax
    push bx
    push cx
    push dx
    push di


    push cx
    call lba_to_chs
    pop ax

    mov ah, 02h
    mov di, 3

.retry:
    pusha
    stc
    int 13h
    jnc .done

    ; luku feilas
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    jmp floppy_error

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    ret

disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa
    ret

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


msg_read_fail: db 'Read Failed!', ENDL, 0




times 510-($-$$) db 0 ; Täytä bootloaderin koko 510 tavulla
dw 0xAA55 ; Boot-sektorin lopetusmerkki