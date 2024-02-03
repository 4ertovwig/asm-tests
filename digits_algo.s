.text
.globl digit_int2char_
.globl digit_char2int_
.globl is_digit_
.globl atoi_
.globl itoa_
.globl remainder_

// .extern .strreverse_
// .extern .strlen_

# char digit_int2char_(int in)
# return digit if input symbol was digit
# return 0 if input symbol not digit
digit_int2char_:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     %rdi, %rdx
    cmp     $1, %dl
    je .LI.case1
    cmpb    $2, %dl
    je .LI.case2
    cmpb    $3, %dl
    je .LI.case3
    cmpb    $4, %dl
    je .LI.case4
    cmpb    $5, %dl
    je .LI.case5
    cmpb    $6, %dl
    je .LI.case6
    cmpb    $7, %dl
    je .LI.case7
    cmpb    $8, %dl
    je .LI.case8
    cmpb    $9, %dl
    je .LI.case9

    mov     $0x30, %rax
    jmp .LI0.stop

    .LI.case1:
    movq    $0x31, %rax
    jmp .LI0.stop
    .LI.case2:
    movq    $0x32, %rax
    jmp .LI0.stop
    .LI.case3:
    movq    $0x33, %rax
    jmp .LI0.stop
    .LI.case4:
    movq    $0x34, %rax
    jmp .LI0.stop
    .LI.case5:
    movq    $0x35, %rax
    jmp .LI0.stop
    .LI.case6:
    movq    $0x36, %rax
    jmp .LI0.stop
    .LI.case7:
    movq    $0x37, %rax
    jmp .LI0.stop
    .LI.case8:
    movq    $0x38, %rax
    jmp .LI0.stop
    .LI.case9:
    movq    $0x39, %rax
    jmp .LI0.stop

    .LI0.stop:
    popq    %rbp
    retq

//////////////////////////////////////////////////////////////////////////////////
# int digit_char2int_(char in)
# return digit if input symbol was digit
# return 0 if input symbol not digit
digit_char2int_:
    pushq   %rbp
    movq    %rsp, %rbp

    mov %rdi, %rdx
    cmp $0x31, %dl
    je .LC.case1
    cmpb $0x32, %dl
    je .LC.case2
    cmpb $0x33, %dl
    je .LC.case3
    cmpb $0x34, %dl
    je .LC.case4
    cmpb $0x35, %dl
    je .LC.case5
    cmpb $0x36, %dl
    je .LC.case6
    cmpb $0x37, %dl
    je .LC.case7
    cmpb $0x38, %dl
    je .LC.case8
    cmpb $0x39, %dl
    je .LC.case9

    mov $0, %rax
    jmp .LC0.stop

    .LC.case1:
    movq $1, %rax
    jmp .LC0.stop
    .LC.case2:
    movq $2, %rax
    jmp .LC0.stop
    .LC.case3:
    movq $3, %rax
    jmp .LC0.stop
    .LC.case4:
    movq $4, %rax
    jmp .LC0.stop
    .LC.case5:
    movq $5, %rax
    jmp .LC0.stop
    .LC.case6:
    movq $6, %rax
    jmp .LC0.stop
    .LC.case7:
    movq $7, %rax
    jmp .LC0.stop
    .LC.case8:
    movq $8, %rax
    jmp .LC0.stop
    .LC.case9:
    movq $9, %rax
    jmp .LC0.stop

    .LC0.stop:
    popq    %rbp
    retq

//////////////////////////////////////////////////////////////////////////////////
# int is_digit(byte in)
# return 0 if not digit
# return 1 if digit
is_digit_:
    pushq   %rbp
    movq    %rsp, %rbp

    cmpb $0x30, %dil
    je .digit
    cmpb $0x31, %dil
    je .digit
    cmpb $0x32, %dil
    je .digit
    cmpb $0x33, %dil
    je .digit
    cmpb $0x34, %dil
    je .digit
    cmpb $0x35, %dil
    je .digit
    cmpb $0x36, %dil
    je .digit
    cmpb $0x37, %dil
    je .digit
    cmpb $0x38, %dil
    je .digit
    cmpb $0x39, %dil
    je .digit
    jmp .default

    .digit:
    mov $1, %rax
    jmp .L1.stop

    .default:
    mov $0, %rax
    .L1.stop:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
# long atoi(char* input_digits)
# input: "7314" -> return 7314
# return long integer value from input string
atoi_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp      /* 2 long vars */

    mov     %rdi, -16(%rbp)
    mov     -16(%rbp), %rdi  # string ptr
    call    strlen_
    
    push    $0
    pop     -8(%rbp)    # ret value
    mov     $1, %rcx    # temp value
    mov     %rax, %rdx  # iterator in input string
    dec     %rdx

    .L1.atoi_loop:
        test    %rdx, %rdx
        jl .L1.atoi_stop
        push    -16(%rbp)
        pop     %rsi
        movb    (%rdx, %rsi, 1), %r10b     # current symbol
        push    %rax                       # save registers before next call
        cmpb    $20, %r10b
        je .L1.atoi_stop
        push    %rdx
        xor     %r9, %r9
        mov     %r10b, %r9b
        push    %rcx
        push    %r10
        mov     %r9, %rdi
        call    is_digit_
        test    %rax, %rax
        je .L1.atoi_stop
        pop     %r10
        mov     %r10, %rdi
        call    digit_char2int_
        
        pop     %rcx
        imul    %rcx, %rax
        add     %rax, -8(%rbp)
        imul    $10, %rcx
        pop     %rdx
        pop     %rax

        dec     %rdx
        jmp .L1.atoi_loop
    .L1.atoi_stop:

    addq    $16, %rsp
    mov     -8(%rbp), %rax
    popq    %rbp
    ret

/////////////////////////////////////////////////////////////////////////////////////////
# long atoin(char* input_digits, size_t n)
# input: "731452",4 -> return 7313
# input: "731452",3 -> return 731
# return long integer value from input string
atoin_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp      /* 2 long vars */

    test    %rsi, %rsi
    je .L1.atoin_broken
    push    %rsi
    mov     %rdi, -16(%rbp)
    mov     -16(%rbp), %rdi  # string ptr
    call    strlen_
    pop     %r8
    
    push    $0
    pop     -8(%rbp)    # ret value
    mov     $1, %rcx    # temp value
    cmp     %r8, %rax
    jle     .L1.atoin_len_pass
    mov     %r8, %rdx   # iterator in input string if len > n
    jmp .L2
    .L1.atoin_len_pass:
    mov     %rax, %rdx  # iterator in input string if len <= n
    .L2:
    dec     %rdx

    .L1.atoin_loop:
        test    %rdx, %rdx
        jl .L1.atoin_stop
        test    %r8, %r8
        jl .L1.atoin_stop
        push    -16(%rbp)
        pop     %rsi
        movb    (%rdx, %rsi, 1), %r10b     # current symbol
        push    %rax                       # save registers before next call
        cmpb    $20, %r10b
        je .L1.atoi_stop
        push    %rdx
        xor     %r9, %r9
        mov     %r10b, %r9b
        push    %rcx
        push    %r10
        mov     %r9, %rdi
        call    is_digit_
        test    %rax, %rax
        je .L1.atoi_stop
        pop     %r10
        mov     %r10, %rdi
        call    digit_char2int_
        
        pop     %rcx
        imul    %rcx, %rax
        add     %rax, -8(%rbp)
        imul    $10, %rcx
        pop     %rdx
        pop     %rax

        dec     %rdx
        dec     %r8
        jmp .L1.atoin_loop
    .L1.atoin_stop:

    mov     -8(%rbp), %rax
    jmp     .L1.atoin_exit

    .L1.atoin_broken:
    xor     %rax, %rax

    .L1.atoin_exit:
    addq    $16, %rsp
    popq    %rbp
    ret

///////////////////////////////////////////////////////////////////////////////////
# void itoa(long input, char* dst)
# input: long integer -6242441
# destination "-6242441"
itoa_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $24, %rsp
    xor     %rcx, %rcx       # index
    mov     %rdi, -16(%rbp)  # temp value
    mov     %rsi, %rax       # destination
    mov     %rdi, -8(%rbp)

    cmpq    $0, -16(%rbp)
    jge .L1.invert_
    // negative to positive for input digit
    mov     -8(%rbp), %rsi
    neg     %rsi
    mov     %rsi, -8(%rbp)
    .L1.invert_:
    .L1.itoa_loop:

        push    %rax
        // n % 10
        xor     %rdx, %rdx
        mov     -8(%rbp), %rax
        mov     $10, %r8
        xor     %rdx, %rdx
        idiv    %r8    # rdx: n % 10

        push    %rcx
        movb    %dl, %dil
        call    digit_int2char_
        movb    %al, %dl

        pop     %rcx
        pop     %rax
        movb    %dl, (%rcx, %rax, 1)
        inc     %rcx

        push    %rax
        mov     -8(%rbp), %rax
        mov     $10, %r8
        xor     %rdx, %rdx
        idiv    %r8    # rax: n / 10
        mov     %rax, -8(%rbp)
        pop     %rax
        cmpq    $0, -8(%rbp)
        jle .L1.itoa_stop
        jmp .L1.itoa_loop

    .L1.itoa_stop:
    cmpq    $0, -16(%rbp)
    jge     .L1.no_minus
    movb    $0x2d, (%rcx, %rax, 1) # add '-' if input digit was negative
    inc     %rcx
    .L1.no_minus:
    movb    $0, (%rcx, %rax, 1)    # null-terminate

    lea     (%rax), %rdi
    call    strreverse_

    addq    $24, %rsp
    popq    %rbp
    xor     %rax, %rax
    retq

///////////////////////////////////////////////////////////////////////////////////
// remainder of the division
// int remainder(int dividend, int divider)
remainder_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp

    movl    %edi, %eax
    movl    %esi, -8(%rbp)
    cltd
    idivl   -8(%rbp)

    movl    %edx, %eax
    addq    $16, %rsp
    popq    %rbp
    retq
