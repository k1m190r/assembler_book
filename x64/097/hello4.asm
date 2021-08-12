;hello4

extern printf

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


; print_string with format and string
%macro prs 2
xor rax, rax
mov rdi, %1 ; fmt
mov rsi, %2 ; msg
call printf
%endmacro

section .data
msg  db "hello world", nil
msg_len equ $-msg-1 ; $ current addr - prev addr - nil
fmt db "String: %s", NLL
fmt_len equ $-fmt-1 

rad dq 357
pi dq 3.1416

section .bss

section .text

global main

main:
PROLO

prs fmt, msg

EPILO

; exit 0
mov rax, 60 ; exit
mov rdi, 0 ; exit code
syscall

nop

;main:

