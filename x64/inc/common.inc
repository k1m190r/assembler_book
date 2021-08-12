; ################################
; n × {extern global push}

%macro NEXTERN 1-*
%rep %0 
    extern %1
%rotate 1
%endrep
%endmacro

%macro NGLOB 1-*
%rep %0 
    global %1
%rotate 1
%endrep
%endmacro

%macro NPUSH 1-*
%rep %0
    push %1
%rotate 1
%endrep
%endmacro

;###########################################
; Constants, Essential macros

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
    ret
%endmacro

%macro MAIN_EPILO_EXIT0 0
    mov rsp, rbp
    pop rbp
    mov rax, 60 ; exit
    xor rdi, rdi ; exit code 0
    syscall
%endmacro

; ######################
; PRINTF

extern printf

; ############################
; Prints

; print non floats fmt v1
%macro PR1 2
    mov rdi, %1 ; fmt
    mov rsi, %2 ; var1
    xor rax, rax
    call printf
%endmacro

; print non floats fmt v1 v2
%macro PR2 3
    mov rdi, %1 ; fmt
    mov rsi, %2 ; var1
    mov rdx, %3 ; var2
    xor rax, rax
    call printf
%endmacro


; #################################
; Floats

; expecting xmm0..%2 with value(s)
%macro PRFX 2
    mov rdi, %1 ; fmt
    mov rax, %2 ; %2 floats
    call printf
%endmacro

; print_float format 1 x float
%macro PRF1 2
    movsd xmm0, %2
    PRFX %1, 1
%endmacro

; print_float format 2 x floats
; expecting xmm0,1 with value
%macro PRF2 3
    movsd xmm0, %2 ; float 1
    movsd xmm1, %3 ; float 2
    PRFX %1, 2
%endmacro

