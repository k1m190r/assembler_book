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

    %macro BTS_BTR 1-*
    %assign I 1
    %rep %0/2
        PR1 fmt, msg%[I]
        bt%[%1]  qword[bitflags], %2
        mov rdi, [bitflags]
        call printb

        %assign I I+1
        %rotate 2
    %endrep
    %endmacro 

    BTS_BTR r, 0, s, 4, s, 7, s, 8, s, 61, r, 8

    ; test 61, will set CF
    PR1 fmt, msg7
    
    xor rdi, rdi
    mov rax, 61
    xor rdi, rdi
    bt [bitflags], rax ; test bit
    setc dil ; set dil(=low rdi) to 1 if CF is set
    call printb

MAIN_EPILO_EXIT0
; main:




