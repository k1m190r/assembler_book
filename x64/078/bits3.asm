; bits3

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

NGLOB main
NEXTERN printb

;#####################################
; SECTIONS

section .data

    fmt db "%s", NLL

    %macro  NMSG 1-*
    %assign I 1
    %rep %0
        msg%[I] db %1, nil

        %assign I I+1
        %rotate 1
    %endrep
    %endmacro

    NMSG "No bits set:", \
         "Set #4:", "Set #7:", "Set #8:", "Set #61:", \
         "Clear #8:", "Test #61 show RDI:"

    bitflags dq 0

section .bss

section .text

; #############################
main:
PROLO

    PR1 fmt, msg1

    mov rdi, [bitflags]
    call printb

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

MAIN_EPILO_EXIT0
; main:




