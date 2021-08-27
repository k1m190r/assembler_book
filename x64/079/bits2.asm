; bits1

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

NGLOB main

;#####################################
; SECTIONS

section .data

    fmt db "N: %ld: %s: %ld", NLL

    %macro  NMSG 1-*
    %assign I 1
    %rep %0
        msg%[I] db %1, nil

        %assign I I+1
        %rotate 1
    %endrep
    %endmacro

    NMSG "SHL 2 = OK * 4", "SHL 2 = BAD * 4", \
         "SAL 2 = OK * 4", "SAL 2 = OK  * 4", \
         "SHR 2 = OK / 4", "SHR 2 = BAD / 4", \
         "SAR 2 = OK / 4", "SAR 2 = OK  / 4"

    n1 dq 8
    n2 dq -8
    res dq 0

section .bss

section .text

; #############################
main:
PROLO

    %macro SHOPS 1-*
    %assign I 1
    %rep %0/2
        mov rax, [%2]
        %1  rax, 2
        mov [res], rax
        PR3 fmt, [%2], msg%[I], [res]

        %assign I I+1
        %rotate 2
    %endrep
    %endmacro 

    SHOPS   shl, n1, shl, n2, \
            sal, n1, sal, n2, \
            shr, n1, shr, n2, \
            sar, n1, sar, n2


MAIN_EPILO_EXIT0
; main:




