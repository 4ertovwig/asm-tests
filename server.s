.text

error_handler:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     %rdi, %rsi
    mov     $STDOUT_FD_, %rdi
    call    write_str_
    mov     $EXIT_FAILURE_, %rdi
    call    exit_

    xor     %rax, %rax
    popq    %rbp
    retq

.global main
main:
    // endbr64
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $64, %rsp

    movq    $AF_INET_, %rdi
    movq    $SOCK_STREAM_, %rsi
    movq    $0, %rdx
    call    socket_
    pushq   %rax
    cmpl    $-1, %eax
    je .L1.bad_socket_call

    mov     $STDOUT_FD_, %rdi
    mov     $success_socket, %rsi
    call    write_str_

    pop     %rdi
    push    %rdi
    mov     $SOL_SOCKET_, %rsi
    xor     %rdx, %rdx
    mov     $SO_REUSEADDR_, %rdx
    or      $SO_REUSEPORT_, %rdx
    mov     $1, %rcx
    mov     %rcx, -20(%rbp)
    lea     -20(%rbp), %rcx
    mov     $4, %r8
    call    setsockopt_
    cmp     $-1, %rax
    je .L1.bad_setsockopt_call

    lea     -16(%rbp), %rdi
    mov     $0, %rsi
    mov     $16, %rdx
    call    memset_

    lea     -16(%rbp), %r12
    movw    $AF_INET_, (%r12)
    movl    $INADDR_ANY_, 4(%r12)
    movl    $5555, %edi # port 5555
    call    htons_
    movq    %rax, 2(%r12)

    pop     %rdi
    push    %rdi
    lea     -16(%rbp), %rsi
    mov     $16, %rdx
    call    bind_
    cmp     $-1, %rax
    je .L1.bad_bind

    pop     %rdi
    push    %rdi
    mov     $3, %rsi
    call    listen_
    cmp     $-1, %rax
    je .L1.bad_listen

    pop     %rdi
    push    %rdi
    lea     -16(%rbp), %rsi
    movl    $16, -20(%rbp)
    lea     -20(%rbp), %rdx
    call    accept_
    cmp     $-1, %rax
    je .L1.bad_accept
    mov     %rax, %r12

    mov     $1512000, %rdi
    call    malloc_
    test    %rax, %rax
    je .L1.allocation_error
    mov     %rax, -64(%rbp)

    mov     -64(%rbp), %rdi
    mov     $0, %rsi
    mov     $32, %rdx
    call    memset_

    //recv data
    mov     %r12, %rdi
    mov     -64(%rbp), %rsi
    mov     $1512000, %rdx
    xor     %rcx, %rcx
    call    recv_all_
    cmp     $-1, %rax
    je .L1.bad_recv

    pushq %rax
    lea     recv_len(%rip), %rdi
    mov     %rax, %rsi
    xor     %rax, %rax
    call    printf
    popq %rax

    // lea     success_recv(%rip), %rdi
    // mov     -64(%rbp), %rsi
    // xor     %eax, %eax
    // call    printf

    mov     $STDOUT_FD_, %rdi
    mov     -64(%rbp), %rsi
    mov     %rax, %rdx
    call    write_

    jmp .L1.server_exit

    .L1.allocation_error:
    popq    %rax
    mov     $allocation_error, %rdi
    call    error_handler

    .L1.bad_socket_call:
    popq    %rax
    mov     $bad_socket, %rdi
    call    error_handler

    .L1.bad_setsockopt_call:
    popq    %rax
    mov     $bad_setsockopt, %rdi
    call    error_handler

    .L1.bad_bind:
    popq    %rax
    mov     $bad_bind, %rdi
    call    error_handler

    .L1.bad_listen:
    popq    %rax
    mov     $bad_listen, %rdi
    call    error_handler

    .L1.bad_accept:
    popq    %rax
    mov     $bad_accept, %rdi
    call    error_handler

    .L1.bad_recv:
    popq    %rax
    mov     $bad_recv, %rdi
    call    error_handler

    .L1.server_exit:
    popq    %rax
    mov     %rax, %rdi
    call    close_
    addq    $64, %rsp
    popq    %rbp
    xor     %eax, %eax
    retq

.data
buf_len:            .long 64
bad_socket:         .asciz "SERVER: socket creation failed\n"
success_socket:     .asciz "SERVER: server socket successfully created\n"
bad_setsockopt:     .asciz "SERVER: setsockopt failed\n"
bad_bind:           .asciz "SERVER: bind error\n"
bad_listen:         .asciz "SERVER: listen error\n"
bad_accept:         .asciz "SERVER: accept error\n"
bad_recv:           .asciz "SERVER: receive data error\n"
allocation_error:   .asciz "SERVER: allocation error...\n"
success_recv:       .asciz "SERVER: receive data: %s\n"
recv_len:           .asciz "\nSERVER: receive length: %d\n"
