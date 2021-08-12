;jump

;###########################################
; CONST & MACRO

nil equ 0
nl equ 10

%define NLL nl,nil

%macro PROLO 0
push rbp
mov rbp, rsp
%endmacro

%macro EPILO 0
mov rsp, rbp
pop rbp
%endmacro

%macro EXIT0 0
mov rax, 60 ; exit
mov rdi, 0 ; exit code
syscall
%endmacro

; ######################
; PRINTF MACROS

extern printf

; print_string format 1xstring
%macro prs 2
xor rax, rax
mov rdi, %1 ; fmt
mov rsi, %2 ; msg
call printf
%endmacro

; print_int format 1xint
%macro pri 2
xor rax, rax
mov rdi, %1 ; fmt
mov rsi, [%2] ; int
call printf
%endmacro

; print_float format 1xfloat
%macro prf 2
mov rax, 1
mov rdi, %1 ; fmt
movq xmm0, [%2] ; float
call printf
%endmacro


;#####################################
; SECTIONS

section .data

; numbers
n1 dq 42
n2 dq 43

; fmt strings
ge db ">=", nil
lt db "<", nil
fmt db "n1 %s n2", NLL

section .bss

; #############################
; # CODE

section .text

global main

main:
PROLO

; load numbers
mov rax, [n1]
mov rbx, [n2]

; rax > rbx
cmp rax, rbx
jge greater

; less than
prs fmt, lt
jmp exit

; greater or equal
greater:
prs fmt, ge

exit:
EPILO
EXIT0

;main:

