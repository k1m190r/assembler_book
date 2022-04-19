; macro

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

NGLOB main
NEXTERN printb

%define double_it(r) sal r, 1; single line

%macro PR 2
    section .data
        %%arg1 db %1, 0
        %%fmt db "%s %ld", NLL

    section .text
        mov rdi, %%fmt
        mov rsi, %%arg1
        mov rdx, [%2]
        xor rax, rax
        call printf
%endmacro

;#####################################
; SECTIONS

section .data
    num dq 15

section .bss

section .text

; #############################
main:
PROLO

    PR "Num:", num
    mov rax, [num]
    double_it(rax)
    mov [num], rax
    PR "Num*2:", num

MAIN_EPILO_EXIT0
; main:




