.data
.include "test_utils.s"
# Empty string means end of list
string_list:    .asciz  "Yet", "another", "GNU", "assembler", "test", ""
compared_str:   .asciz  "Yet another GNU assembler test "

.text
.internal process_string_
# NOTE: return two regs
process_string_:

    movq    %rdi, %rsi              # Destination
    xor     %eax, %eax              # Length

    # copy one string in two buffers:
    # in buffer for print
    # in compared buffer
    .L1.process_string_loop:
    mov     (%rbx, %rax), %dl       # one symbol
    testb   %dl, %dl
    je      .L1.process_string_exit
    movb    %dl, (%rsi, %rax)       # copy one symbol to destination buffer
    incq    %rax
    movb    %dl, (%r13, %r12)       # copy one symbol to compared buffer
    incq    %r12
    jmp     .L1.process_string_loop

    .L1.process_string_exit:
    movb    $' ', (%rsi, %rax)      # Adding space
    incq    %rax
    movb    $' ', (%r13, %r12)      # Adding space
    incq    %r12
    retq

.global main
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp

    pushq   (%rsi)
    mov     $STDOUT_FD_, %rdi
    mov     $test_border, %rsi
    call    write_str_
    mov     $STDOUT_FD_, %rdi
    mov     $test_name, %rsi
    call    write_str_

    popq    %rdi
    call    progname_

    # Allocate output buffer
    movl    $1512, %edi
    call    malloc_
    test    %rax, %rax
    je .L1.chain_test_failed1
    movq    %rax, %r13

    mov     %r13, %rdi
    mov     $0, %rsi
    mov     $1512, %rdx
    call    memset_

    # Accumulated len
    xor     %r12, %r12

    # Loop for each string
    mov     $string_list, %rbx
        .L1.chain_test_print_loop:
        cmpb    $0, (%rbx)           # list end
        je      .L1.chain_test_passed1

        movl    $32, %edi
        call    malloc_
        test    %rax, %rax
        je .L1.chain_test_failed1
        movq    %rax, -16(%rbp)

        mov     -16(%rbp), %rdi
        mov     $0, %rsi
        mov     $32, %rdx
        call    memset_

        movq    %rax, %rdi
        call    process_string_  # %rsi is address, %rax is length
        addq    %rax, %rbx       # Advancing in the list

        mov     $STDOUT_FD_, %rdi
        leaq    (%rsi), %rsi
        call    write_str_

        movq    -16(%rbp), %rdi
        call    free_
        
        jmp     .L1.chain_test_print_loop

    .L1.chain_test_passed1:

    movq    $STDOUT_FD_, %rdi
    movb    $0x0A, -4(%rbp) # print '\n'
    leaq    -4(%rbp), %rsi
    mov     $1, %rdx
    call    write_

    mov     $STDOUT_FD_, %rdi
    movq    %r13, %rsi
    movq    %r12, %rdx
    call    write_

    movq    $STDOUT_FD_, %rdi
    movb    $0x0A, -4(%rbp) # print '\n'
    leaq    -4(%rbp), %rsi
    mov     $1, %rdx
    call    write_

    movq    $compared_str, %rdi
    movq    %r13, %rsi
    movq    %r12, %rdx
    call    memcmp_

    test    %rax, %rax
    je .L1.chain_test_passed2
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed2, %rsi
    call    write_str_

    movq    %r13, %rdi
    call    free_
    jmp .L1.chain_test_stop

    .L1.chain_test_passed2:
    mov     $STDOUT_FD_, %rdi
    mov     $test_passed, %rsi
    call    write_str_
    jmp .L1.chain_test_stop

    .L1.chain_test_failed1:
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed1, %rsi
    call    write_str_
    jmp .L1.chain_test_stop

    movq    %r13, %rdi
    call    free_

    .L1.chain_test_stop:
    mov     $STDOUT_FD_, %rdi
    mov     $test_end, %rsi
    call    write_str_

    xor     %eax, %eax
    addq    $16, %rsp
    movq    %rbp, %rsp
    popq    %rbp
    retq
