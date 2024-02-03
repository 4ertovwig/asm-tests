.globl strlen_
.globl strreverse_
#.globl strcpy_ 
.text

# void strcpy(char* dst, char* src)
# Warning: function is not check the length of destination buffer
strcpy_:
    pushq   %rbp
    movq    %rsp, %rbp
    mov     %rdi, %rdx # destination
    mov     %rsi, %rcx # source
    .L1.copy:
        cmpb    $0, (%rcx)
        je .L1.stop_copy
        movb    (%rcx), %r10b
        mov     %r10b, (%rdx)
        add     $1, %rcx
        add     $1, %rdx
        jmp .L1.copy
    .L1.stop_copy:
    mov     %rbp, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
# size_t strlen(char* string)
# Warning: in return value '\0' is not taken into account.
# For .asciz "123" function return 3
strlen_:
    pushq   %rbp
    movq    %rsp, %rbp
    xor     %rax, %rax
    .L1.strlen:
        cmpb    $0, (%rdi)
        je .L1.stop_len
        add     $1, %rdi
        inc     %rax
        jmp .L1.strlen
    .L1.stop_len:
    mov     %rbp, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
# void strreverse(char* string)
# reverse input string
strreverse_:
    pushq   %rbp
    movq    %rsp, %rbp
    push    %rdi
    call    strlen_                 /* rax  - len, input string - rdi */
    pop     %rdi
    mov     %rax, %rcx
    dec     %rcx                    # size
    lea     (%rcx, %rdi, 1), %rdx   # stop
    lea     (%rdi), %rcx            # start
    .L1.reverse:
        cmp     %rcx, %rdx
        jl .L1.stop_rev

        # swap chars
        movb    (%rcx), %al
        movb    (%rdx), %r8b
        movb    %r8b, (%rcx)
        movb    %al, (%rdx)

        add     $1, %rcx
        sub     $1, %rdx

        jmp .L1.reverse
    .L1.stop_rev:
    mov     %rbp, %rsp
    popq    %rbp
    retq
