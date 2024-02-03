.text

.global main
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp

    movq    $AF_INET_, %rdi
    movq    $SOCK_STREAM_, %rsi
    movq    $0, %rdx
    call    socket_
    push    %rax
    cmpl    $-1, %eax
    je .L1.bad_socket_call
    
    mov     $STDOUT_FD_, %rdi
    mov     $success_socket, %rsi
    call    write_str_
    
    lea     -16(%rbp), %rdi
    mov     $0, %rsi
    mov     $16, %rdx
    call    memset_

    lea     -16(%rbp), %r12
    movw    $AF_INET_, (%r12)
    movl    $16777343, 4(%r12)  # 127.0.0.1
    movl    $5555, %edi         # port 5555
    call    htons_
    movq    %rax, 2(%r12)

    pop     %rax
    movl    %eax, %edi
    pushq   %rax
    lea     (%r12), %rsi
    mov     $16, %rdx
    call    connect_
    test    %rax, %rax
    jne     .L1.bad_connect_call

    mov     $STDOUT_FD_, %rdi
    mov     $success_connect, %rsi
    call    write_str_

    movl    $1512, %edi
    call    malloc_
    test    %rax, %rax
    je .L1.allocation_error
    mov     %rax, -24(%rbp)

    mov     -24(%rbp), %rdi
    mov     $0x31, %esi
    mov     $1512, %edx
    call    memset_

    mov     -24(%rbp), %rdi
    mov     $1512, %rsi
    call    gen_random_str_numbers
    test     %rax, %rax
    je .L1.bad_generate

    popq    %rdi
    mov    -24(%rbp), %rsi
    movl    $1512, %edx
    xor     %rcx, %rcx
    pushq   %rdi
    call    send_all_

    mov     $STDOUT_FD_, %rdi
    mov     $send_end, %rsi
    call    write_str_

    mov     $STDOUT_FD_, %rdi
    mov     -24(%rbp), %rsi
    mov     $1512, %rdx
    call    write_zero_str_

    popq    %rax
    call    close_
    jmp .L1.client_exit

    .L1.bad_generate:
    popq    %rax
    mov     $STDOUT_FD_, %rdi
    mov     $bad_generate, %rsi
    call    write_str_
    mov     $EXIT_FAILURE_, %rdi
    call    exit_

    .L1.allocation_error:
    popq    %rax
    mov     $STDOUT_FD_, %rdi
    mov     $allocation_error, %rsi
    call    write_str_
    mov     $EXIT_FAILURE_, %rdi
    call    exit_

    .L1.bad_socket_call:
    pop     %rax
    mov     $STDOUT_FD_, %rdi
    mov     $bad_socket, %rsi
    call    write_str_
    mov     $EXIT_FAILURE_, %rdi
    call    exit_

    .L1.bad_connect_call:
    popq    %rax
    push    errno_
    mov     $STDOUT_FD_, %rdi
    mov     $bad_connect, %rsi
    call    write_str_

    pop     %rdi
    call    strerror_
    mov     %rax, %r12
    mov     %rax, %rdi
    call    strlen_

    mov     $STDOUT_FD_, %rdi
    mov     %r12, %rsi
    inc     %rax
    mov     %rax, %rdx
    call    write_
    mov     $EXIT_FAILURE_, %rdi
    call    exit_

    .L1.client_exit:
    addq    $32, %rsp
    popq    %rbp
    xor     %rax, %rax
    retq


.data
buf_len:            .long  64
bad_socket:         .asciz "CLIENT: socket creation failed\n"
success_socket:     .asciz "CLIENT: client socket successfully created\n"
bad_connect:        .asciz "CLIENT: connection with the server failed...\n"
success_connect:    .asciz "CLIENT: connection with the server was successfull...\n"
allocation_error:   .asciz "CLIENT: allocation error...\n"
bad_generate:       .asciz "CLIENT: bad generate...\n"
inet_addr:          .asciz "127.0.0.1"
send_end:           .asciz "========\nCLIENT: send data:\n"
data:               .asciz "CLIENT: send string %s:\n"
// hello_world:
//     .asciz "hello world!\n"
//     .set hello_world_length, .-hello_world
