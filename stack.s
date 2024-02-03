.text
.globl stack_init
.globl stack_push
.globl stack_pop
.globl stack_print
.globl stack_get_last

/*
    Stack in memory:
       len      1       2           63
    |-------|-------|-------|...|-------|
     8 bytes    8       8           8
*/

// void stack_init(void* stack)
// stack initialization - len 0
stack_init:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    $0, (%rdi)
    popq    %rbp
    retq

////////////////////////////////////////////////////////////
// void stack_push(void* stack, long value)
// push value to current stack
stack_push:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rdi, %rax
    movq    %rdi, %rdx

    cmpq    $0, (%rdx)
    je .L1.stack_add_first
    add     $8, %rax

    mov     (%rdi), %rcx
    imul    $8, %rcx
    mov     %rsi, (%rcx, %rax, 1) 
    addq    $1, (%rdx)
    jmp .L1.push_exit

    .L1.stack_add_first:
        movq    %rsi, 8(%rax)
        addq    $1, (%rdx)
    .L1.push_exit:
    popq    %rbp
    retq

////////////////////////////////////////////////////////////
// long stack_pop(void* stack)
// delete last element from current stack
// return previous last element in current stack
// WARNING: function call exit(FAILURE) if stack is empty
stack_pop:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     %rdi, %rax
    mov     (%rdi), %rcx
    test    %rcx, %rcx
    je .L1.stack_pop_exit_failure
    add     $8, %rax
    dec     %rcx
    imul    $8, %rcx
    mov     (%rcx, %rax, 1), %rax
    subq    $1, (%rdi)
    jmp .L1.stack_pop_exit_success

    .L1.stack_pop_exit_failure:
        mov     $STDOUT_FD_, %rdi
        mov     $print_empty_stack, %rsi
        mov     $print_empty_stack_length, %rdx
        call    write_

        mov     $EXIT_FAILURE_, %rdi
        call    exit_
    .L1.stack_pop_exit_success:
    popq    %rbp
    retq

////////////////////////////////////////////////////////////
// void stack_trace(void* stack)
// print all values in current stack
// Warning: this function trace
stack_trace:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     %rdi, %rax
    mov     %rdi, %rdx

    cmpq    $0, (%rdx)
    je .L1.print_exit
    mov     (%rdx), %rcx
    add     $8, %rax
    
    .L1.print_loop:
        test    %rcx, %rcx
        je .L1.print_delimiter
        push    %rcx

        // convert int to char
        movb    (%rax), %dil
        push    %rax
        call    digit_int2char_

        // print
        mov     $STDOUT_FD_, %rdi
        mov     %rax, %rsi
        mov     $1, %rdx
        call    write_
        mov     $STDOUT_FD_, %rdi
        mov     $end_s, %rsi
        mov     $end_length, %rdx
        call    write_

        pop     %rax
        pop     %rcx
        add     $8, %rax
        dec     %rcx
        jmp .L1.print_loop

    .L1.print_delimiter:
        mov     $STDOUT_FD_, %rdi
        mov     $print_end, %rsi
        mov     $print_end_length, %rdx
        call    write_
    .L1.print_exit:
    popq    %rbp
    retq

////////////////////////////////////////////////////////////
// long stack_get_last(void* stack)
// return last value in current stack
// WARNING: function call exit(FAILURE) if stack is empty
stack_get_last:
    pushq   %rbp
    movq    %rsp, %rbp
    
    mov     %rdi, %rax
    mov     (%rdi), %rcx
    test    %rcx, %rcx
    je .L1.stack_get_last_exit_failure
    add     $8, %rax
    dec     %rcx
    imul    $8, %rcx
    mov     (%rcx, %rax, 1), %rdx
    mov     %rdx, %rax
    jmp .L1.stack_get_last_exit_success

    .L1.stack_get_last_exit_failure:
        mov     $STDOUT_FD_, %rdi
        mov     $print_empty_stack, %rsi
        mov     $print_empty_stack_length, %rdx
        call    write_
        mov     $EXIT_FAILURE_, %rdi
        call    exit_

    .L1.stack_get_last_exit_success:
    popq    %rbp
    retq

////////////////////////////////////////////////////////////
// long stack_get_size(void* stack)
// return stack size in elements
stack_get_size:
    pushq   %rbp
    movq    %rsp, %rbp
    mov     (%rdi), %rax
    popq    %rbp
    retq


.section .rodata
trace_value:
    .asciz "Value: "
    .set trace_value_length, .-trace_value
print_start:
    .asciz "====start=stack====\n"
    .set print_start_length, .-print_start
print_end:
    .asciz "=====end=stack=====\n"
    .set print_end_length, .-print_end
print_empty_stack:
    .asciz "stack is empty\n"
    .set print_empty_stack_length, .-print_empty_stack
end_s:
    .asciz "\n"
    .set end_length, .-end_s
