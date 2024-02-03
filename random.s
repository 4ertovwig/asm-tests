.globl rand_short
.globl rand_long
.globl rand_quad
.globl gen_random_str
.globl gen_random_number
.globl gen_random_str_numbers

.text

///////////////////////////////////////////////////////////////////////////////////
// Note: Carry flag set if rdrand was successfull
# bool rand_short(short* output)
# input: pointer to short value
# return value:
# 0: if the hardware does not return any random value
# 1: if the hardware returns a 16/32/64 random value
# see: int _rdrand16_step(unsigned short *random_val)
rand_short:
    pushq   %rbp
    movq    %rsp, %rbp
    
    rdrand  %ax
    jnc .L1.gen16_failed
    movq    $0, (%rdi)
    movw    %ax, (%rdi)
    mov     $1, %rax
    jmp .L1.gen16_exit

    .L1.gen16_failed:
    xor     %eax, %eax
    .L1.gen16_exit:
    popq    %rbp
    retq

///////////////////////////////////////////////////////////////////////////////////
# bool rand_long(int* output)
# input: pointer to int value
# return value:
# 0: if the hardware does not return any random value
# 1: if the hardware returns a 16/32/64 random value
# see: int _rdrand32_step(unsigned int *random_val)
rand_long:
    pushq   %rbp
    movq    %rsp, %rbp
    
    rdrand  %eax
    jnc .L1.gen32_failed
    movq    $0, (%rdi)
    movl    %eax, (%rdi)
    mov     $1, %rax
    jmp .L1.gen32_exit

    .L1.gen32_failed:
    xor     %eax, %eax
    .L1.gen32_exit:
    popq    %rbp
    retq

///////////////////////////////////////////////////////////////////////////////////
# bool rand_quad(int64* output)
# input: pointer to short value
# return value:
# 0: if the hardware does not return any random value
# 1: if the hardware returns a 16/32/64 random value
# see: int _rdrand64_step(unsigned __int64 *random_val
rand_quad:
    pushq   %rbp
    movq    %rsp, %rbp
    
    rdrand  %rax
    jnc .L1.gen64_failed
    movq    %rax, (%rdi)
    mov     $1, %rax
    jmp .L1.gen64_exit

    .L1.gen64_failed:
    xor     %eax, %eax
    .L1.gen64_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// Generate buffer with random VALUES with fixed length 
# bool gen_random_str(char* buf, size_t len)
# 1: if random geneate was succcess
# 0: if failed
gen_random_str:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp

    movq    %rdi, -8(%rbp)
    movq    %rsi, -16(%rbp)
    .L1.gen_loop:
        mov     -8(%rbp), %rdi
        call    rand_short
        test    %rax, %rax
        je  .L1.gen_random_str_failed
        incq    -8(%rbp)
        decq    -16(%rbp)
        mov     -16(%rbp), %rdx
        test    %rdx, %rdx
        jne .L1.gen_loop

    mov     $1, %rax
    jmp .L1.gen_random_str_exit

    .L1.gen_random_str_failed:
    xor     %eax, %eax

    .L1.gen_random_str_exit:
    addq    $16, %rsp
    mov     %rbp, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// Generate random number for print
// value: 0x31..0x39
# int gen_random_number(int* val)
# -1: if failed
# 0x31..0x39 - if success
gen_random_number:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp

    lea     -8(%rbp), %rdi
    call    rand_short
    test    %rax, %rax
    je .L1.bad_gen_random_number

    mov     -8(%rbp), %rdi
    mov     $9, %rsi
    call    remainder_
    add     $0x31, %rax
    movzb   %al, %rax
    mov     %rax, -8(%rbp)

    jmp .L1.gen_random_number_exit

    .L1.bad_gen_random_number:
    mov     $-1, %rax

    .L1.gen_random_number_exit:
    addq    $16, %rsp
    mov     %rbp, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// Fill fixed-size buffer with generated random NUMBERS
// NOTE: function used rbx!!!
// NOTE: function with BUG
# bool gen_random_str_numbers(char* buf, size_t len)
# 1: if random geneate was succcess
# 0: if failed
gen_random_str_numbers:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
    //mov     %rdi, -8(%rbp)      # source
    movq    %rdi, %rbx      # source
    movq    %rsi, -16(%rbp)     # len
    .L1.gen_random_str_numbers_loop:
        //mov     -8(%rbp), %rdi
        mov     %rbx, %rdi
        call    gen_random_number
        cmp     $-1, %rax
        je  .L1.gen_random_str_numbers_failed

        //!!!!!
        // lea     -8(%rbp), %rcx
        // movq    %rax, (%rcx)
        movq    %rax, (%rbx)

        //incq    -8(%rbp)
        incq    %rbx

        decq    -16(%rbp)
        mov     -16(%rbp), %rdx

        test    %rdx, %rdx
        jne .L1.gen_random_str_numbers_loop

    mov     $1, %rax
    //decq    -8(%rbp)
    decq    %rbx
    //mov     -8(%rbp), %rcx
    // lea     -8(%rbp), %rcx
    // movb    $' ', %cl    # null-terminate
    movb    $' ', (%rbx)    # null-terminate
    jmp .L1.gen_random_str_numbers_exit

    .L1.gen_random_str_numbers_failed:
    xor     %eax, %eax

    .L1.gen_random_str_numbers_exit:
    addq    $16, %rsp
    mov     %rbp, %rsp
    popq    %rbp
    retq
