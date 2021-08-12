; func4

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

nextern c_area, c_circum, r_area, r_circum
nglob pi

;#####################################
; .data

section .data

pi dq 3.14159265358979
rad dq 10.0
side1 dq 4
side2 dq 5

fmt1 db "pi=%g rad=%g", NLL
fmt2 db "side1=%d  side2=%d", NLL

fmtf db "%s = %g", NLL
fmti db "%s = %d", NLL

ca db "c area", nil
cc db "c circum", nil
ra db "r area", nil
rc db "r circum", nil

section .bss


section .text

; #############################
global main
main:
PROLO

    PRF2 fmt1, [pi], [rad]

    ; c area
    movsd xmm0, qword[rad]
    call c_area ; → xmm0
    mov rsi, ca
    PRFX fmtf, 1

    ; c circum
    movsd xmm0, qword[rad]
    call c_circum ; → xmm0
    mov rsi, cc
    PRFX fmtf, 1

    PR2 fmt2, [side1], [side2]

    ; r area
    mov rdi, [side1]
    mov rsi, [side2]
    call r_area ; → rax
    PR2 fmti, ra, rax

    ; r circum
    mov rdi, [side1]
    mov rsi, [side2]
    call r_circum ; → rax
    PR2 fmti, rc, rax

MAIN_EPILO_EXIT0
; main:

