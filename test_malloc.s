.data
.include "test_utils.s"
iterations: .quad 50

.text

// while(iterations--) {
//     ptr1 = malloc
//     ptr2 = malloc
//     ptr1 == ptr2 ? pass : failure
//     free(ptr2)
//     free(ptr2) }

.global main
main:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   (%rsi)
    mov     $STDOUT_FD_, %rdi
    mov     $test_border, %rsi
    call    write_str_
    mov     $STDOUT_FD_, %rdi
    mov     $test_name, %rsi
    call    write_str_

    popq    %rdi
    call    progname_

    movq    iterations, %rbx
    .L1.malloc_test_loop:
    test    %rbx, %rbx
    je .L1.malloc_test_passed
    dec     %rbx

    mov     $1512, %rdi
    call    malloc_
    test    %rax, %rax
    je .L1.malloc_test_error_1
    pushq   %rax

    mov     $1548288, %rdi
    call    malloc_
    test    %rax, %rax
    je .L1.malloc_test_error_2
    pushq   %rax

    popq    %rax
    popq    %rcx
    cmpq    %rcx, %rax
    pushq   %rcx
    pushq   %rax
    jne .L1.malloc_test_free
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed, %rsi
    call    write_str_
    jmp .L1.malloc_test_failed

    .L1.malloc_test_free:
    popq    %rdi
    call    free_
    popq    %rdi
    call    free_

    jmp .L1.malloc_test_loop

    .L1.malloc_test_error_1:
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed, %rsi
    call    write_str_
    jmp .L1.malloc_test_stop

    .L1.malloc_test_error_2:
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed, %rsi
    call    write_str_
    popq    %rdi
    callq   free_
    jmp .L1.malloc_test_stop
    
    .L1.malloc_test_failed:
    popq    %rdi
    call    free_
    popq    %rdi
    call    free_
    jmp .L1.malloc_test_stop

    .L1.malloc_test_passed:
    mov     $STDOUT_FD_, %rdi
    mov     $test_passed, %rsi
    call    write_str_

    .L1.malloc_test_stop:
    mov     $STDOUT_FD_, %rdi
    mov     $test_end, %rsi
    call    write_str_

    xor     %eax, %eax
    popq    %rbp
    ret
