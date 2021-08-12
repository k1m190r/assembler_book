;alive

nil equ 0
nl equ 10

%define NLL nl,nil

%macro PROLO 0
push rbp
mov rbp, rsp
%endmacro

%macro EPILO 0
mov rsp, rbp
pop rbp
%endmacro

section .data
msg  db "hello world", NLL
msg_len equ $-msg-1 ; $ current addr - prev addr - nil
msg2 db "Alive and kicking", NLL
msg2_len equ $-msg2-1
rad dq 357
pi dq 3.1416

section .bss

section .text

global main

main:
PROLO

; write stdout msg len(msg)
mov rax, 1 ; write
mov rdi, 1 ; stdout
mov rsi, msg
mov rdx, msg_len
syscall

mov rax, 1
mov rdi, 1
mov rsi, msg2
mov rdx, msg2_len
syscall

EPILO

; exit 0
mov rax, 60 ; exit
mov rdi, 0 ; exit code
syscall

nop

;main:

