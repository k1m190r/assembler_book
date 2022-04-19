;hello

section .data
msg  db "hello world",0

section .bss

section .text

global main

main:

; write stdout msg len(msg)
mov rax, 1 ; write
mov rdi, 1 ; stdout
mov rsi, msg
mov rdx, 12 ; len(msg)
db 0x0F, 0x05
;syscall

; exit 0
mov rax, 60 ; exit
mov rdi, 0 ; exit code
syscall

nop

;main:

