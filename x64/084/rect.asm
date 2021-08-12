; circle

%include "../inc/common.inc"

nglob r_area, r_circum

section .data
section .bss
section .text

r_area:
PROLO
    mov rax, rsi ; x2
    imul rax, rdi ; x1 × x2 → rax
EPILO

r_circum:
PROLO
    mov rax, rsi ; x2
    add rax, rdi ; x1 + x2 → rax
    add rax, rax ; 2 × rax
EPILO
