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

    mov     $digits1, %rdi
    call    atoi_
    movq    $48394310, %rdx
    cmpq    %rax, %rdx
    je .L1.string_test_2
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed1, %rsi
    call    write_str_
    jmp .L1.string_test_stop

    .L1.string_test_2:
    mov     $digits2, %rdi
    mov     $4, %rsi
    call    atoin_
    movq    $1951, %rdx
    cmpq    %rax, %rdx
    je .L1.string_test_3
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed2, %rsi
    call    write_str_
    jmp .L1.string_test_stop

    .L1.string_test_3:
    mov     $string1, %rdi
    call    strlen_
    movq    $7, %rdx
    cmpq    %rax, %rdx
    je .L1.string_test_4
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed3, %rsi
    call    write_str_
    jmp .L1.string_test_stop

    .L1.string_test_4:
    lea     -32(%rbp), %r13

    mov     %r13, %rdi
    mov     $0, %rsi
    mov     $32, %rdx
    call    memset_

    movq    $-65265377, %rdi
    movq    %r13, %rsi
    call    itoa_

    mov     $STDOUT_FD_, %rdi
    movq    $itoa_str, %rsi
    call    write_str_

    mov     $STDOUT_FD_, %rdi
    movq    %r13, %rsi
    call    write_str_

    movq    $STDOUT_FD_, %rdi
    movb    $0x0A, -4(%rbp) # print '\n'
    leaq    -4(%rbp), %rsi
    mov     $1, %rdx
    call    write_

    // passed
    mov     $STDOUT_FD_, %rdi
    mov     $test_passed, %rsi
    call    write_str_

    .L1.string_test_stop:
    mov     $STDOUT_FD_, %rdi
    mov     $test_end, %rsi
    call    write_str_

    xor     %eax, %eax
    addq    $64, %rsp
    popq    %rbp
    ret

.data
.include "test_utils.s"
digits1:        .asciz "48394310"
digits2:        .asciz "195190443"
string1:        .asciz "test123"
itoa_str:       .asciz "itoa string: "
