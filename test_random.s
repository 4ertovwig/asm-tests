.text

.global main
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $64, %rsp

    pushq   (%rsi)
    mov     $STDOUT_FD_, %rdi
    mov     $test_border, %rsi
    call    write_str_
    mov     $STDOUT_FD_, %rdi
    mov     $test_name, %rsi
    call    write_str_

    popq    %rdi
    call    progname_

    movb    $0x32, -48(%rbp)
    movb    $0x32, -47(%rbp)
    movb    $0x38, -46(%rbp)
    movb    $0x0A, -45(%rbp)

    lea     -16(%rbp), %rdi
    call    rand_long
    test    %eax, %eax
    je .L1.bad_gen

    lea     val_32(%rip), %rdi
    movl    -16(%rbp), %esi
    xor     %eax, %eax
    call    printf

    lea     -16(%rbp), %rdi
    call    rand_short
    test    %eax, %eax
    je .L1.bad_gen

    lea     val_16(%rip), %rdi
    xor     %rsi, %rsi
    movw    -16(%rbp), %si
    xor     %eax, %eax
    call    printf

    lea     -32(%rbp), %rdi
    call    rand_quad
    test    %eax, %eax
    je .L1.bad_gen

    lea     val_64(%rip), %rdi
    xor     %rsi, %rsi
    movq    -32(%rbp), %rsi
    xor     %eax, %eax
    call    printf

    movq    $1512, %rdi
    callq    malloc_
    mov     %rax, -48(%rbp)

    test    %rax, %rax
    je .L1.bad_gen

    movq    %rax, %rdi
    mov     $0, %rsi
    mov     $1512, %rdx
    call    memset_

    mov     -48(%rbp), %rdi
    mov     $1512, %rsi
    #call    gen_random_str
    call    gen_random_str_numbers

    test    %rax, %rax
    je .L1.bad_gen_str

    lea     rand_str(%rip), %rdi
    xor     %rsi, %rsi
    movq    -48(%rbp), %rsi
    xor     %eax, %eax
    call    printf

    mov     $STDOUT_FD_, %rdi
    mov     $trace, %rsi
    call    write_str_

    mov      $STDOUT_FD_, %rdi
    movq    -48(%rbp), %rsi
    mov     $1512, %rdx
    call    write_zero_str_

    movq    $STDOUT_FD_, %rdi
    movb    $0x0A, -4(%rbp) # print '\n'
    leaq    -4(%rbp), %rsi
    mov     $1, %rdx
    call    write_

    mov     -48(%rbp), %rdi
    call    free_

    ////////////////////////////////////////
    call    gen_random_number
    lea     val_round(%rip), %rdi
    lea     (%rax), %rsi
    xor     %eax, %eax
    call    printf

    ////////////////////////////////////////
    mov     $STDOUT_FD_, %rdi
    mov     $test_passed, %rsi
    call    write_str_
    jmp .L1.random_test_stop

    .L1.bad_gen_str:
    mov     -48(%rbp), %rdi
    call    free_

    .L1.bad_gen:
    lea     badgen(%rip), %rdi
    xor     %eax, %eax
    call    printf

    mov     $STDOUT_FD_, %rdi
    mov     $test_failed, %rsi
    call    write_str_

    .L1.random_test_stop:
    mov     $STDOUT_FD_, %rdi
    mov     $test_end, %rsi
    call    write_str_

    addq    $64, %rsp
    xor     %eax, %eax
    popq    %rbp
    ret

.data
.include "test_utils.s"
trace:      .asciz "========================\n"
buf:        .asciz "buf: %s\n"
badgen:     .asciz "bad generation\n"
val_16:     .asciz "val short: %hu\n"
val_32:     .asciz "val int: %d\n"
val_64:     .asciz "val quad: %llu\n"
rand_str:   .asciz "random string:\n%s\n"
val_round:  .asciz "\nround value: %c\n"
