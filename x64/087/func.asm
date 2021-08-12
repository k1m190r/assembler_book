; func

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; numbers
rad dq 10.0
pi dq 3.14
fmt db "A=R^2 × π=%2$g^2 × π=%1$g", NLL

section .bss


section .text

global main
main:
PROLO

; ##################################
; START

call area

movsd xmm1, [rad]
PRFX fmt, 2

EPILO
EXIT0
;main:

; ################################
area:
PROLO
    movsd xmm0, [rad] ; R
    mulsd xmm0, [rad] ; * R
    mulsd xmm0, [pi] ; * π

EPILO
; leave
ret



