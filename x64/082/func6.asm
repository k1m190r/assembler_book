; func6

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

NGLOB main

;#####################################
; SECTIONS

section .data

    ; n x db
    %macro NBD 1-*
    %rep %0
        %defstr s %1
        %1 db s, nil
        %rotate 1
    %endrep
    %endmacro

    NBD A, B, C, D, E, F, G, H, I, J

    fmt db "string: %s", NLL

section .bss
    flist resb 11 ; reserve 11 bytes

section .text

; #############################
main:
PROLO

    %macro MOV2 1-*
    %rep %0 / 2
        mov %1, %2
        %rotate 2
    %endrep
    %endmacro

    MOV2 rdi, flist, rsi, A, rdx, B, rcx, C, r8, D, r9, E
    NPUSH J, I, H, G, F ; 7 .. 11 in reserve 
    call lfunc 

    PR1 fmt, flist

MAIN_EPILO_EXIT0
; main:


; #############################################
lfunc:
PROLO
    xor rax, rax

    %macro MOV_REG 1-*
    %assign I 0 
    %rep    %0
        mov al, byte[%1]
        mov [rdi+I], al
        %assign I I+1
        %rotate 1
    %endrep
    %endmacro

    MOV_REG rsi, rdx, rcx, r8, r9 ; 0..4

    push rbx ; collee saved

    xor rbx, rbx

    %macro MOV_STK 1
    %assign I 0
    %rep %1
        mov rax, qword[rbp+16+I*8] ; call: push rip, PROLO: push rbp = 16 
        mov bl, byte[rax]
        mov [rdi+5+I], bl ; 5 already moved from registers

        %assign I I+1
        %rotate 1
    %endrep
    %endmacro

    MOV_STK 5 ; 5..9

    ; zero byte
    xor rbx, rbx
    mov [rdi+10], bl

    pop rbx ; callee saved

EPILO
; lfunc:



