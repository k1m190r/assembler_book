;memory

; nl nil nll PROLO EPILO EXIT0 PRS PRI PRF
%include "../inc/common.inc"

;#####################################
; SECTIONS

section .data

; numbers
num1 dq 128
num2 dq 19
neg_num dq -12

; fmt
fmt db "n1=%ld n2=%ld", NLL
fmti db "%s%ld", NLL
sumi db "n1+n2=", nil
difi db "n1-n2=", nil
inci db "inc(n1)=", nil
deci db "dec(n1)=", nil
sali db "shl(n1,2)=n1×4=", nil
sari db "shr(n1,2)=n1÷4=", nil
sariex db "shr(n1,2)=n1÷4 "
    db "sign extension=", nil
multi db "n1*n2=", nil
divi db "n1//n2=", nil
remi db "rem(n1//n2)=", nil

section .bss
resi resq 1
modulo resq 1

section .text

global main
main:
PROLO

; ##################################
; START

PRI2 fmt, num1, num2

%macro BINOP 2 ; operation, string
    mov rax, [num1]
    %1 rax, [num2]
    mov [resi], rax
    PRSI fmti, %2, resi
%endmacro

%macro UNOP 2 ; op str
    mov rax, [num1]
    %1 rax
    mov [resi], rax
    PRSI fmti, %2, resi
%endmacro

%macro SHOP 3 ; op num str
    mov rax, [%2]
    %1 rax, 2
    mov [resi], rax
    PRSI fmti, %3, resi
%endmacro

%macro IOP 2 ; op str
    mov rax, [num1]
    %1 qword[num2]
    mov [resi], rax
    mov [modulo], rdx
    PRSI fmti, %2, resi
    PRSI fmti, remi, modulo
%endmacro

BINOP add, sumi
BINOP sub, difi

UNOP inc, inci
UNOP dec, deci

SHOP sal, num1, sali
SHOP sar, num1, sari
SHOP sar, neg_num, sariex

IOP imul, multi
IOP idiv, divi

; END
; ################################

EPILO
EXIT0
;main:

