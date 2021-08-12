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

b1 db 123
w1 dw 12345
d1 dd 1234567890
q1 dq 1234567890123456789
q2 dq 123456
q3 dq 3.1416

section .bss

; #############################
; # CODE

section .text

global main

main:
PROLO

; manipulations
mov rax, -1 ; all 1s
mov al, byte[b1] ; set lover byte
xor rax, rax ; clear rax
mov al, byte[b1] ; set lower byte

mov rax, -1
mov ax, word[w1]
xor rax, rax
mov ax, word[w1]

mov rax, -1
mov eax, dword[b1]

mov rax, -1
mov rax, qword[q1]
mov qword[q2], rax
mov rax, 123456

movq xmm0, [q3]

; write stdout msg len(msg)
prs fmt_str, msg1
prs fmt_str, msg2
pri fmt_int, rad
prf fmt_flt, pi

EPILO
EXIT0

;main:

