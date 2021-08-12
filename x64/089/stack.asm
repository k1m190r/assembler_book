;stack

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; numbers
str1 db "ABCDE", nil
str1_len equ $-str1-1
fmt1 db "original str: %s", NLL
fmt2 db "reversed str: %s", NLL
num1 db 0x00, 0x00, 0x20, 0x41


section .bss


section .text

global main
main:
PROLO

; ##################################
; START

PRS fmt1, str1

; push str on stack
xor rax, rax
mov rbx, str1
mov rcx, str1_len
xor r12, r12

push_loop:
    mov al, byte[rbx+r12]
    push rax
    inc r12
loop push_loop

; pop str from stack
; this reverses str

mov rbx, str1
mov rcx, str1_len
xor r12, r12

pop_loop:
    pop rax
    mov byte[rbx+r12], al
    inc r12
loop pop_loop

PRS fmt2, str1

; END
; ################################

EPILO
EXIT0
;main:

