;hello

nil equ 0
nl equ 10

section .data
msg  db "hello world",nl,nil
; nl db 0xa ; new line

section .bss

section .text

global main

main:

; write stdout msg len(msg)
mov rax, 1 ; write
mov rdi, 1 ; stdout
mov rsi, msg
mov rdx, 12 ; len(msg)
syscall

; exit 0
mov rax, 60 ; exit
mov rdi, 0 ; exit code
syscall

nop

;main:

