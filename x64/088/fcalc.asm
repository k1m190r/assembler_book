; fcalc

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; numbers
num1 dq 9.0
num2 dq 73.0
fmt db "n₁=%g n₂=%g", NLL

fmtflt db "%s %f", NLL

f_sum db "n₁ + n₂=%g", NLL
f_dif db "n₁ - n₂=%g", NLL
f_mul db "n₁ × n₂=%g", NLL
f_div db "n₁ ÷ n₂=%g", NLL
f_sqrt1 db "√n₁=%g", NLL
f_sqrt2 db "√n₂=%g", NLL

section .bss


section .text

global main
main:
; Comment Prologue to segfault due to stack aligment

; PROLO

; ##################################
; START


PRF2 fmt, num1, num2

%macro BOP 2 ; binary operator
    movsd xmm0, [num1]
    %1    xmm0, [num2]
    PRFX %2, 1
%endmacro

BOP addsd, f_sum
BOP subsd, f_dif
BOP mulsd, f_mul
BOP divsd, f_div

sqrtsd xmm0, [num1]
PRFX f_sqrt1, 1

sqrtsd xmm0, [num2]
PRFX f_sqrt2, 1

; END
; ################################

EPILO
EXIT0
;main:

