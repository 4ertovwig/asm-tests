.text

.globl memset_
.globl memcpy_
.globl memmove_
.globl memcmp_

// NOTE:
// Depending on the hardware implementation, string moves with the direction flag (DF) cleared to 0
// (up) may be faster than string moves with DF set to 1 (down). DF = 1 is only needed for certain cases
// of overlapping REP MOVS, such as when the source and the destination overlap
// https://www.amd.com/system/files/TechDocs/24594.pdf

// Note that only rep movs and rep stos are fast. repe/ne cmps and scas on current CPUs only loop 1 element at a time.
// https://stackoverflow.com/a/33905887/5880581

/////////////////////////////////////////////////////////////////////////////////////////
// void* memset(void* dest, int ch, size_t n)
memset_:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     %rdi, %r8
    mov     %rsi, %rax
    cld
    mov     %rdx, %rcx
    rep stosb

    lea     (%r8), %rax
    mov     %rbp, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// void* memcpy(void* __restrict dst, const void* __restrict src, size_t n)
memcpy_:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     %rdi, %r8
    cld
    mov     %rdx, %rcx
    rep movsb

    lea     (%r8), %rax
    mov     %rbp, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// void* memmove(void* dst, const void* src, size_t n)
// 1) case 1:
// |----------------|
// src           src + n
//        |-----------------|
//       dst             dst + n
// 2) case 2:
//           |----------------|
//          src           src + n
// |-----------------|
// dst             dst + n
//
// if (dst > src)
//     set zf
//     rep movsb
// else if (dst < src)
//     call memmcpy
//
// char* memmove(char* dst, char* src, size_t n)
// {
// if (0 == n) return;
// if (dst == src) return;
// if (dst > src)
// {
//     char* s = (src + n - 1);
//     char* d = (dst + n - 1);
//     for (;n != 0 ; --n)
//     {
//         *d = *s;
//         s--;
//         d--;
//     }
// }
// else
// {
//     char* s = src;
//     char* d = dst;
//     for (;n != 0 ; --n)
//     {
//         *d = *s;
//         s++;
//         d++;
//     }
// }
// return dst;
// }

memmove_:
    pushq   %rbp
    movq    %rsp, %rbp

    test    %rdx, %rdx
    je .L1.memmove_exit

    cmp     %rdi, %rsi
    je .L1.memmove_exit

    cmp     %rsi, %rdi
    jl .L1.memmove_dst_lower
    // case 1
    addq    %rdx, %rsi
    dec     %rsi
    addq    %rdx, %rdi
    dec     %rdi
    std
    movq    %rdx, %rcx
    rep movsb
    jmp .L1.memmove_exit

    .L1.memmove_dst_lower:
    // case 2:
    cld
    movq    %rdx, %rcx
    rep movsb

    .L1.memmove_exit:
    xor %rdi, %rax
    mov     %rbp, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// bool memcmp(const void* lhs, const void* rhs, size_t n)
// ret 0 if strings equal, 1 - if not
// NOTE: return value is different from libc memcmp
memcmp_:
    pushq   %rbp
    movq    %rsp, %rbp

    cmp     %rdi, %rsi
    je .L1.memcmp_equal

    cld
    mov     %rdx, %rcx
    repe cmpsb
    jne .L1.memcmp_f    # zf=0

    xor     %eax, %eax
    jmp .L1.memcmp_stop

    .L1.memcmp_f:
    movq    $1, %rax
    jmp .L1.memcmp_stop 

    .L1.memcmp_equal:
    xor     %eax, %eax

    .L1.memcmp_stop:
    movq    %rbp, %rsp
    popq    %rbp
    retq
