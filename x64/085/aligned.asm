; aligned

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; numbers
fmt db "2 × π=%g", NLL
pi dq 3.14159265358979

section .bss


section .text

; ################################
func3:
PROLO
    movsd xmm0, [pi] ; π
    addsd xmm0, [pi] ; * π
EPILO

; ##############################
func2:
PROLO
    call func3
EPILO

; ###############################
func1:
PROLO
    call func2
EPILO

; #############################
global main
main:
PROLO

call func1

MAIN_EPILO_EXIT0
; main:

