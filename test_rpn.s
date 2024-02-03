/*
 * Base implementation of Reverse Polish notation.
 * With simple calculating the result of input string.
 * Algorithm cannot process input string with spaces and numbers greater than 10
 */

.data
.include "test_utils.s"
// Tested input string 
fml: .asciz "(((1-2)+(3+2*3-7))*4)/2+((2*6/4-4)+9)"   # result 10
#fml: .asciz "((1-2)+(3+2*3-7))*2"
#fml: .asciz "(1-2)+(3+2*3-7)*2"
#fml: .asciz "1+(3+2*1-7)*2"
#fml: .asciz "1+(3+2*3-7)"
#fml: .asciz "(3+2*1-7)+1"
#fml: .asciz "(3+2*1-7)"
#fml: .asciz "3+2*1-7"
#fml: .asciz "(3+2-1+7)"
#fml: .asciz "3+2-1+7"
#fml: .asciz "(4/2)"
#fml: .asciz "(3+2)"
#fml: .asciz "3+2"
    .set fml_length, .-fml
input_fml:
    .asciz "Input formula: "
    .set input_fml_length, .-input_fml
infix_buff:
    .asciz "Infix buffer:  "
    .set infix_buff_length, .-infix_buff
input_error: 
    .asciz "Error string is empty\n"
    .set input_error_length, .-input_error
invalid_symbol:
    .asciz "Invalid symbol in string\n"
    .set invalid_symbol_length, .-invalid_symbol
result:
    .asciz "Result: "
    .set result_length, .-result
end:
    .asciz "\n"
    .set end_length, .-end

// pointer to stack start
stack: .quad 0


.text

// just for debug
trace_infix_buffer:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    %rdi, %rcx
    push    %rcx
    movq    $STDOUT_FD_, %rdi
    movq    $infix_buff, %rsi
    movq    $infix_buff_length, %rdx
    call    write_
    pop     %rcx
    xor     %r8, %r8
    .L1.trace_infix_buffer_loop:
        cmp     %r8, %r12
        je .L1.trace_infix_buffer_loop_exit

        movq    $STDOUT_FD_, %rdi
        lea     (%r8, %rcx, 1), %rsi
        movq    $1, %rdx
        push    %r8
        push    %rcx
        call    write_
        pop     %rcx
        pop     %r8

        inc     %r8
        jmp .L1.trace_infix_buffer_loop

    .L1.trace_infix_buffer_loop_exit:
        movq    $STDOUT_FD_, %rdi
        movq    $end, %rsi
        movq    $end_length, %rdx
        call    write_

    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////

// void process_closing_bracket(void* infix_buffer)
process_closing_bracket:
    pushq   %rbp
    movq    %rsp, %rbp

    .L1.closing_bracket_loop:
        push    %rdi
        mov     $stack, %rdi
        call    stack_get_size
        //cmp $0, %rax
        test    %rax, %rax
        je .L1.closing_bracket_stack_empty

        mov     $stack, %rdi
        call    stack_pop
        pop     %rcx                # infix buffer
        cmpb    $0x28, %al
        je .L1.closing_bracket_loop_exit
        movb    %al, (%r12, %rcx, 1)
        inc     %r12
        jmp .L1.closing_bracket_loop

    .L1.closing_bracket_stack_empty:
        pop     %rdi
        jmp .L1.closing_bracket_loop_exit
    
    .L1.closing_bracket_loop_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////

// void process_operation(char symbol, void* infix_buffer)
// return 0 if input value unavaliable or return 1
process_operation:
    pushq   %rbp
    movq    %rsp, %rbp

    test    %r12, %r12
    jle .L1.input_error

    xor     %r13, %r13
    movb    %dil, %r13b    # input symbol
    mov     %rsi, %r14      # infix buffer
    # rdi -> rdi
    call    get_priority
    cmp     $-1, %rax
    je .L1.invalid_operation
    mov     %rax, %r15      # input priority

    .L1.operation_loop:
        mov     $stack, %rdi
        call    stack_get_size
        test    %rax, %rax
        je .L1.stack_empty
        mov     $stack, %rdi
        call    stack_get_last
        mov     %rax, %rdi
        call    get_priority
        // compare priority of operations
        cmp     %rax, %r15
        jle .L1.lower_operation

            // push input operation in stack
            mov     $stack, %rdi
            mov     %r13, %rsi
            call    stack_push
            jmp .L1.operation_loop_exit

        .L1.lower_operation:
            mov     $stack, %rdi
            call    stack_pop
            movb    %al, (%r12, %r14, 1)
            inc     %r12
            
            mov     $stack, %rdi
            call    stack_get_size
            test    %rax, %rax
            je .L1.stack_empty
        jmp .L1.operation_loop

    .L1.invalid_operation:
        mov     $STDOUT_FD_, %rdi
        mov     $invalid_symbol, %rsi
        mov     $invalid_symbol_length, %rdx
        call    write_
        popq    %rbp
        mov     $0, %rax
        retq

    .L1.stack_empty:
        mov     $stack, %rdi
        mov     %r13, %rsi
        call    stack_push

    .L1.operation_loop_exit:
    mov     $1, %rax
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////

// main logic
update_states:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     %rdi, %rax      # input symbol
    mov     %rsi, %rdx      # infix buffer
    push    %rdx

    // if '('
    cmpb    $0x28, %al
    je .L1.push_stack

    // if digit
    mov     %rax, %rdi
    push    %rax
    call    is_digit_
    cmp     $1, %rax
    pop     %rax
    je .L1.store_digit

    // if '+'
    cmpb    $0x2b, %al
    je .L1.process_operation

    // if '-'
    cmpb    $0x2d, %al
    je .L1.process_operation

    // if '*'
    cmpb    $0x2a, %al
    je .L1.process_operation

    // if '/'
    cmpb    $0x2f, %al
    je .L1.process_operation

    // if ')'
    cmpb    $0x29, %al
    je .L1.process_closing_bracket

    // if '0'
    cmpb    $0, %al
    je .L1.process_null_terminate
    
    .L1.process_null_terminate:
        .L1.null_terminate:
            push    %rax
            mov     $stack, %rdi
            call    stack_get_size
            test    %rax, %rax
            je .L1.update_exit_null_terminate
            pop     %rax
            
            mov     $stack, %rdi
            call    stack_pop
            pop     %rdx
            mov     %rax, (%r12, %rdx, 1)
            push    %rdx

            inc     %r12
            jmp .L1.null_terminate

    .L1.process_closing_bracket:
        pop     %rdx
        mov     %rdx, %rdi
        call    process_closing_bracket
        jmp .L1.update_exit

    .L1.process_operation:
        mov     %rax, %rdi
        pop     %rdx
        mov     %rdx, %rsi
        call    process_operation
        test    %rax, %rax
        je .L1.process_operation_error
        jmp .L1.update_exit

    .L1.store_digit:
        pop     %rdx
        movb    %al, (%r12, %rdx, 1)
        inc     %r12
        jmp .L1.update_exit

    .L1.push_stack:
        mov     $stack, %rdi
        mov     %rax, %rsi
        call    stack_push
        pop     %rdx
        #inc %r12
        jmp .L1.update_exit

    .L1.process_operation_error:
    .L1.update_exit_null_terminate:
        pop     %rdx
        pop     %rdx
        mov     $0, %rax
        popq    %rbp
        retq

    .L1.update_exit:
    mov     $1, %rax
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////

// |----------|-----------|
// |operation | priority  |
// |----------|-----------|
// |    (     |     0     |
// |    )     |     1     |
// |   +-     |     2     |
// |   */     |     3     |
// |----------|-----------|
get_priority:
    pushq   %rbp
    movq    %rsp, %rbp

    cmpb    $0x28, %dil     # '('
    je .L1.case1
    cmpb    $0x29, %dil     # ')'
    je .L1.case2
    cmpb    $0x2b, %dil     # '+'
    je .L1.case3
    cmpb    $0x2d, %dil     # '-'
    je .L1.case3
    cmpb    $0x2a, %dil     # '*'
    je .L1.case4
    cmpb    $0x2f, %dil     # '/'
    je .L1.case4

    mov     $-1, %rax
    jmp .L1.priority_exit

    .L1.case1:
    mov     $0, %rax
    jmp .L1.priority_exit
    .L1.case2:
    mov     $1, %rax
    jmp .L1.priority_exit
    .L1.case3:
    mov     $2, %rax
    jmp .L1.priority_exit
    .L1.case4:
    mov     $3, %rax
    jmp .L1.priority_exit

    .L1.priority_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////

calculate_operation:
    pushq   %rbp
    movq    %rsp, %rbp

    push    %rdi
    mov     $stack, %rdi
    call    stack_pop
    push    %rax
    // if stack empty than stop calculation
    mov     $stack, %rdi
    call    stack_get_size
    test    %rax, %rax
    je .L1.calculate_stop

    mov     $stack, %rdi
    call    stack_pop
    mov     %rax, %rdx  # right operand
    pop     %rcx        # left operand
    pop     %rdi        # operation

    cmpb    $0x2b, %dil     # '+'
    je .L1.calculate_add
    cmpb    $0x2d, %dil     # '-'
    je .L1.calculate_sub
    cmpb    $0x2a, %dil     # '*'
    je .L1.calculate_mult
    cmpb    $0x2f, %dil     # '/'
    je .L1.calculate_div

    // undefined operation
    jmp .L1.calculate_operation_exit

    .L1.calculate_stop:
        pop     %rcx
        pop     %rdi
        jmp .L1.calculate_operation_exit

    .L1.calculate_add:
        addq    %rcx, %rdx
        mov     %rdx, %rcx
        jmp .L1.calculate_operation_exit

    .L1.calculate_sub:
        subq    %rcx, %rdx
        mov     %rdx, %rcx
        jmp .L1.calculate_operation_exit

    .L1.calculate_mult:
        imulq   %rcx, %rdx
        mov     %rdx, %rcx
        jmp .L1.calculate_operation_exit

    .L1.calculate_div:
        mov     %rdx, %rax
        xor     %rdx, %rdx
        div     %rcx
        mov     %rax, %rcx
        jmp .L1.calculate_operation_exit

    .L1.calculate_operation_exit:
    mov     $stack, %rdi
    mov     %rcx, %rsi
    call    stack_push
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////

// calculate result from all infix buffer
calculate:
    pushq   %rbp
    movq    %rsp, %rbp
    mov     %rdi, %rdx      # pointer to infix buffer
    xor     %rcx, %rcx
    push    %rcx
    push    %rdx

    .L1.calculate_loop:
        pop     %rdx
        pop     %rcx
        cmpb    $0, (%rcx, %rdx, 1)
        je .L1.calculate_loop_stop
        movb    (%rcx, %rdx, 1), %dil
        push    %rcx
        push    %rdx
        call    is_digit_
        test    %rax, %rax
        je .L1.calculate_operation

        //put a number on the stack
        pop     %rdx
        pop     %rcx
        mov     (%rcx, %rdx, 1), %rdi
        inc     %rcx
        push    %rcx
        push    %rdx
        call    digit_char2int_

        mov     $stack, %rdi
        mov     %rax, %rsi
        call    stack_push
        jmp .L1.calculate_loop
        
        //calculate operation with 2 high stack values
        .L1.calculate_operation:
            pop     %rdx
            pop     %rcx
            mov     (%rcx, %rdx, 1), %rdi
            inc     %rcx
            push    %rcx
            push    %rdx
            call    calculate_operation

        jmp .L1.calculate_loop

    .L1.calculate_loop_clean_stack:
        pop     %rdx
        pop     %rcx

    .L1.calculate_loop_stop:
    mov     $stack, %rdi
    call    stack_pop
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////

.globl main
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp
    // 8 byte for result string buffer
    // 8 byte for pointer from malloc
    // allocate store for stack
    // 63 elements maximum

    pushq   (%rsi)
    mov     $STDOUT_FD_, %rdi
    mov     $test_border, %rsi
    call    write_str_
    mov     $STDOUT_FD_, %rdi
    mov     $test_name, %rsi
    call    write_str_

    popq    %rdi
    call    progname_

    movq    $STDOUT_FD_, %rdi
    movq    $input_fml, %rsi
    movq    $input_fml_length, %rdx
    call    write_

    movq    $STDOUT_FD_, %rdi
    movq    $fml, %rsi
    movq    $fml_length, %rdx
    call    write_

    movq    $STDOUT_FD_, %rdi
    movq    $end, %rsi
    movq    $end_length, %rdx
    call    write_

    mov     $512, %rdi
    call    malloc_
    test    %rax, %rax
    je .L1.main_exit

    // 512 bytes for infix buffer
    mov     %rax, stack
    mov     $stack, %rdi
    mov     $0, %rsi
    mov     $512, %rdx
    call    memset_

    mov     $stack, %rdi
    call    stack_init

    mov     $512, %rdi
    call    malloc_
    test    %rax, %rax
    je .L1.main_exit

    //output infix string in preallocated buffer
    movq    %rax, -16(%rbp) 
    mov     -16(%rbp), %rdi
    mov     $0, %rsi
    mov     $512, %rdx
    call    memset_

    mov     $4, %rdi
    call    malloc_
    //output infix string in preallocated buffer
    movq    %rax, -8(%rbp) 
    mov     -8(%rbp), %rdi
    mov     $0, %rsi
    mov     $4, %rdx
    call    memset_

    mov     $fml, %rbx      # inut string
    mov     $0, %r12        # position in infix buffer
    .L1.read_symbol:
        mov     (%rbx), %rdi        # input symbol
        mov     -16(%rbp), %rsi      # buffer with infix string
        call    update_states
        test    %rax, %rax
        je .L1.rpn_exit

        inc     %rbx
        jmp .L1.read_symbol

    .L1.rpn_exit:
    mov     $stack, %rdi
    call    stack_get_size
    test    %rax, %rax
    je .L1.main_stack_empty

    .L1.main_stack_empty:
    mov     -16(%rbp), %rdi
    call    trace_infix_buffer

    mov     -16(%rbp), %rdi
    call    calculate

    // print result
    push    %rax
    mov     $STDOUT_FD_, %rdi
    mov     $result, %rsi
    mov     $result_length, %rdx
    call    write_

    pop     %rax
    push    %rax
    mov     %rax, %rdi
    mov     -8(%rbp), %rsi
    call    itoa_

    mov     -8(%rbp), %rdi
    call    strlen_
    
    mov     $STDOUT_FD_, %rdi
    mov     -8(%rbp), %rsi
    mov     %rax, %rdx
    call    write_

    mov     $STDOUT_FD_, %rdi
    mov     $end, %rsi
    mov     $end_length, %rdx
    call    write_

    pop     %rax
    cmp     $10, %rax
    je .L1.rpn_test_passed
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed, %rsi
    call    write_str_
    jmp .L1.main_exit

    .L1.rpn_test_passed:
    mov     $STDOUT_FD_, %rdi
    mov     $test_passed, %rsi
    call    write_str_

    jmp .L1.main_exit

    .L1.input_error:
        mov     $STDOUT_FD_, %rdi
        mov     $input_error, %rsi
        mov     $input_error_length, %rdx
        call    write_

        mov     $STDOUT_FD_, %rdi
        mov     $test_failed1, %rsi
        call    write_str_

    .L1.main_exit:
    movq    $stack, %rdi
    call    free_
    movq    -16(%rbp), %rdi
    call    free_
    movq    -8(%rbp), %rdi
    call    free_

    .L1.rpn_test_stop:
    mov     $STDOUT_FD_, %rdi
    mov     $test_end, %rsi
    call    write_str_

    addq    $32, %rsp
    popq    %rbp
    xor     %rax, %rax
    retq
