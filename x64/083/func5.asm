; func5

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

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
fmt1 db "string: %s%s%s%s%s%s%s%s%s%s", NLL

pi dq 3.14
fmt2 db "π=%g", NLL

section .bss


section .text


; #############################
global main
main:
PROLO

mov rdi, fmt1 ; 1
mov rsi, A ; 2
mov rdx, B ; 3 
mov rcx, C ; 4
mov r8, D ; 5
mov r9, E ; 6

NPUSH F, G, H, I, J

xor rax, rax
call printf

; 16byte align
and rsp, 0xfffffffffffffff0
PRF1 fmt2, [pi]


MAIN_EPILO_EXIT0
; main:

