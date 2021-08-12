;memory

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; numbers
b1 db 123
w1 dw 12345
warr1 times 5 dw 0 ; 5 words with 0
d1 dd 12345
q1 dq 12345
txt1 db "abc", nil
q2 dq 3.141592654
txt2 db "cde", nil

; reserved memory
section .bss
bv1 resb 1
dv1 resd 1
wv1 resw 10
qv1 resq 3

section .text

global main
main:
PROLO

; ##################################
; START

lea rax, [b1] ; load address → rax
mov rax, b1 ; load address → rax
mov rax, [b1] ; load value from b1 → rax

mov [bv1], rax ; rax → [bv1]
lea rax, [bv1] ; bv1 addr → rax
lea rax, [w1] ; addr(w1) → rax
mov rax, [w1] ; value(w1) → rax
lea rax, [txt1] ; address(tx1) → rax
mov rax, txt1 ; address(tx1) → rax
mov rax, txt1+1 ; address(tx1)+1 → rax
lea rax, [txt1+1] ; address(tx1)+1 → rax
mov rax, [txt1] ; value(txt1) → rax
mov rax, [txt1+1] ; value(txt1+1) → rax


; END
; ################################

EPILO
EXIT0
;main:

