; func2

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; numbers
rad dq 10.0
fmt db "A=R^2 × π=%2$g^2 × π=%1$g", NLL

section .bss


section .text

; ################################
area:
section .data
.pi dq 3.141592654 ; local to area

section .text
PROLO
    movsd xmm0, [rad] ; R
    mulsd xmm0, [rad] ; * R
    mulsd xmm0, [.pi] ; * π
EPILO
;ret

; ##############################
circum:
section .data
    .pi dq 3.14 ; local to circum

section .text
PROLO
    movsd xmm0, [rad] ; R
    addsd xmm0, [rad] ; + R
    mulsd xmm0, [.pi] ; * π
EPILO
;ret

; ###############################
circle:
section .data
.fmt_area db "Area=%g", NLL
.fmt_circ db "Circum=%g", NLL

section .text
PROLO

call area
PRFX .fmt_area, 1
call circum
PRFX .fmt_circ, 1

EPILO
;ret

; #############################
global main
main:
PROLO

call circle

MAIN_EPILO_EXIT0
;main:

