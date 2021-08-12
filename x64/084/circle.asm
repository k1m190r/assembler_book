; circle

%include "../inc/common.inc"

nextern pi
nglob c_area, c_circum

section .data
section .bss
section .text

c_area:
PROLO
    mulsd xmm0, xmm0 ; r²
    movsd xmm1, qword[pi] ; π
    mulsd xmm0, xmm1 ; r² × π
EPILO

c_circum:
PROLO
    addsd xmm0, xmm0 ; r+r=d
    movsd xmm1, qword[pi] ; π
    mulsd xmm0, xmm1 ; d × π
EPILO