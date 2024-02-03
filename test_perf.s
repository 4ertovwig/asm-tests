.bss
value: .space 8

.data
.include "test_utils.s"

.text
.globl main
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

    call perf_start_

    /////////////////////////////////////////////////

    leaq    -64(%rbp), %rdi
    mov     $0, %rsi
    mov     $24, %rdx
    call    memset_

    mov     $513141, %rdi
    lea     -32(%rbp), %rsi
    call    itoa_

    /////////////////////////////////////////////////

    mov     $123, %rbx
    mov     %rbx, value

    leaq    -32(%rbp), %rdi
    mov     $0, %rsi
    mov     $24, %rdx
    call    memset_

    mov     value, %rdi
    lea     -32(%rbp), %rsi
    call    itoa_

    /////////////////////////////////////////////////

    call perf_stop_

    mov     $STDOUT_FD_, %rdi
    mov     $test_passed, %rsi
    call    write_str_

    .L1.perf_test_stop:
    mov     $STDOUT_FD_, %rdi
    mov     $test_end, %rsi
    call    write_str_

    xor     %eax, %eax
    addq    $64, %rsp
    popq    %rbp
    retq
