;jumploop

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; number
num dq 5

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
xor rbx, rbx
xor rax, rax

jloop:
    add rax, rbx
    inc rbx

    cmp rbx, [num]
    jle jloop

mov rdx, rax ; printf 2nd arg
PRI fmt, num

EPILO
EXIT0
;main:

