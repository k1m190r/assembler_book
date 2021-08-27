; bits1

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

NEXTERN printb
NGLOB main

;#####################################
; SECTIONS

section .data

    fmt1 db "%s", NLL

    msgn1 db "N1", nil
    msgn2 db "N2", nil
    
    %macro  NMSG 1-*
    %assign I 1
    %rep %0
        msg%[I] db %1, nil

        %assign I I+1
        %rotate 1
    %endrep
    %endmacro

    NMSG     "XOR", "OR", "AND", "NOT N1",  \
        "SHL 2 Lb of N1", "SHR 2 Lb of N1", \
        "SAL 2 Lb of N1", "SAR 2 Lb of N1", \
        "ROL 2 Lb of N1", "ROL 2 Lb of N2", \
        "ROR 2 Lb of N1", "ROR 2 Lb of N2"

    n1 dq -72
    n2 dq 1064

section .bss

section .text

; #############################
main:
PROLO

    ;p n1
    PR1 fmt1, msgn1
    mov rdi, [n1]
    call printb

    ;p n2
    PR1 fmt1, msgn2
    mov rdi, [n2]
    call printb

    %macro BINOPS 1-*
    %assign I 1
    %rep %0
        PR1 fmt1, msg%[I]
        mov rax, [n1]
        %1 rax, [n2]
        mov rdi, rax
        call printb

        %assign I I+1
        %rotate 1
    %endrep
    %endmacro 

    BINOPS xor, or, and

    ; NOT
    PR1 fmt1, msg4
    mov rax, [n1]
    not rax
    mov rdi, rax
    call printb


    %macro SHOPS 1-*
    %assign I 5
    %rep %0
        PR1 fmt1, msg%[I]
        mov rax, [n1]
        %1  al, 2
        mov rdi, rax
        call printb

        %assign I I+1
        %rotate 1
    %endrep
    %endmacro 

    SHOPS shl, shr, sal, sar

    %macro ROOPS 1-*
    %assign I 9
    %rep %0
        PR1 fmt1, msg%[I]
        mov rax, [n1]
        %1  al, 2
        mov rdi, rax
        call printb

        %assign I I+1
        PR1 fmt1, msg%[I]
        mov rax, [n2]
        %1  al, 2
        mov rdi, rax
        call printb

        %assign I I+1
        %rotate 1
    %endrep
    %endmacro

    ROOPS rol, ror

MAIN_EPILO_EXIT0
; main:




