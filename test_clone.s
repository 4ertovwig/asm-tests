.data
.include "test_utils.s"

.text
.globl main

worker_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp

    movq    $1, glval

    addq    $32, %rsp
    popq    %rbp
    xor     %rax, %rax
    retq

main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp
    movb    $1, SKIPPED # Skip this test

    pushq   (%rsi)
    mov     $STDOUT_FD_, %rdi
    mov     $test_border, %rsi
    call    write_str_
    mov     $STDOUT_FD_, %rdi
    mov     $test_name, %rsi
    call    write_str_

    popq    %rdi
    call    progname_

    cmpb    $0, SKIPPED
    je .L1.clone_test_not_skipped
    mov     $STDOUT_FD_, %rdi
    mov     $test_skipped, %rsi
    call    write_str_
    jmp .L1.clone_test_stop

    .L1.clone_test_not_skipped:
    movq    $3, glval

    movl    $worker_, %edi
    call    thread_start_

    cmp    $-1, %rax
    jne    .L1.test_clone_sucess

    mov     $STDOUT_FD_, %rdi
    mov     $bad_info, %rsi
    call    write_str_
    jmp     .L1.clone_test_failed

    .L1.test_clone_sucess:
    // lea     msg(%rip), %rdi
    // xor     %eax, %eax
    // call    printf

    // sleep on 2 seconds
    mov     $2, %rdi
    call    sleep_

    lea     value(%rip), %rdi
    movq    glval, %rsi 
    xor     %eax, %eax
    call    printf

    mov     $STDOUT_FD_, %rdi
    mov     $test_passed, %rsi
    call    write_str_
    jmp .L1.clone_test_stop

    .L1.clone_test_failed:
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed, %rsi
    call    write_str_

    .L1.clone_test_stop:
    mov     $STDOUT_FD_, %rdi
    mov     $test_end, %rsi
    call    write_str_

    addq    $32, %rsp
    popq    %rbp
    xor     %rax, %rax
    retq

.data
bad_info:
    .asciz "Bad clone\n"
    .set bad_info_length, .-bad_info
msg:
    .asciz "hello, thread!\n"
value:
    .asciz "glval: %d\n"

glval: .space 8
