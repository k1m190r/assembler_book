;betterloop

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; number
num dq 6

; fmt string
fmt db "sum from 0 to %ld is %ld", NLL

section .bss

; #############################
; # CODE

section .text

global main
main:
PROLO

; init counter
mov rcx, [num]
xor rax, rax

bloop:
    add rax, rcx
loop bloop ; loop while decr(rcx) until rcx = 0

mov rdx, rax ; printf 2nd arg
PRI fmt, num

EPILO
EXIT0
;main:

