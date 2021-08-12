;alive2

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

msg1  db "hello world", nil
msg2 db "Alive and kicking", nil

rad dq 357
pi dq 3.1416

fmt_str db "%s",NLL
fmt_flt db "%lf",NLL
fmt_int db "%d",NLL

section .bss

; #############################
; # CODE

section .text

global main

main:
PROLO

; write stdout msg len(msg)
prs fmt_str, msg1
prs fmt_str, msg2
pri fmt_int, rad
prf fmt_flt, pi

EPILO
EXIT0

;main:

