/* Very simple syscall wrappers as libc */

.include "memory_algo.s"
.include "errors.s"

.set PROT_READ_,		0x1
.set PROT_WRITE_,	    0x2
.set MAP_PRIVATE_,	    0x2
.set MAP_ANONYMOUS_,    0x20
.set MAP_GROWSDOWN_,	0x00100     /* memory allocation for new thread stack */
.set MAP_FAILED_,       0xffffffffffffffff    /* bad mmap result ((void*)-1) */

.set EXIT_SUCCESS_,     0x0
.set EXIT_FAILURE_,     0x1

.set STDIN_FD_,         0x0
.set STDOUT_FD_,        0x1
.set STDERR_FD_,        0x2

.set AF_INET_,          0x2
.set SOCK_STREAM_,      0x1
.set SOCK_CLOEXEC_,     02000000
.set SOCK_NONBLOCK_,    00004000
.set INADDR_ANY_,       0

.set MSG_CONFIRM_,      0x800
.set MSG_DONTROUTE_,    0x04
.set MSG_DONTWAIT_,     0x40
.set MSG_EOR_,          0x80
.set MSG_MORE_,         0x8000
.set MSG_NOSIGNAL_,     0x4000
.set MSG_OOB_,          0x01

.set SOL_SOCKET_,	    1
.set SO_REUSEADDR_,	    2
.set SO_REUSEPORT_,	    15

.globl malloc_
.globl free_
.globl socket_
.globl connect_
.globl setsockopt_
.globl bind_
.globl listen_
.globl accept_
.globl sendto_
.globl send_
.globl send_all_
.globl recvfrom_
.globl recv_
.globl recv_all_
.globl write_
.globl write_str_
.globl write_zero_str_
.globl exit_

.extern strlen_

.text

/*
 * In Unix syscall return error as integer value -4096...-1
 * From this value we get errno code
*/

// x86-64 Linux System Call convention
// https://stackoverflow.com/questions/2535989/what-are-the-calling-conventions-for-unix-linux-system-calls-and-user-space-f
// for user-space functions call convention:
// %rdi, %rsi, %rdx, %rcx, %r8 and %r9 are the registers in order used to pass integer/pointer (i.e. INTEGER class) parameters to any libc function from assembly.
// for syscall convention:
// The kernel interface uses %rdi, %rsi, %rdx, %r10, %r8 and %r9.

// Return value by syscall:
// https://stackoverflow.com/questions/38751614/what-are-the-return-values-of-system-calls-in-assembly
// -1 to -4095 means error, anything else means success

/////////////////////////////////////////////////////////////////////////////////////////
// void* malloc(size_t size)
// allocated memory with current size
// return ptr to allocated memory if success, or NULL if error was occured
// global variable errno used for errors detections
// NOTE: actually allocated size is size + 8 bytes:
// |   store size  |                                                |
// |<---8 bytes--->|<-----------------size bytes------------------->|
//             return ptr
// first 8 bytes used for store actually allocated size
malloc_:
    pushq   %rbp
    movq    %rsp, %rbp

    addq    $8, %rdi
    pushq   %rdi
    movq    %rdi, %rdx            # store size

    movl    $PROT_READ_, %ecx
    orl     $PROT_WRITE_, %ecx      # PROT flags
    movl    $MAP_PRIVATE_, %r9d
    orl     $MAP_ANONYMOUS_, %r9d   # MAP flags

    movl    $9, %eax              # system call 9 sys_mmap
    movq    $0, %rdi              # start address
    movq    %rdx, %rsi            # size

    movl    %ecx, %edx            # page flags
    movl    %r9d, %r10d           # mem flags
    movl    $-1, %r8d             # file descriptor
    movl    $0, %r9d              # offset
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.malloc_success
    mov     %rax, %rdi
    call    set_errno_
    popq    %rdi
    mov     $0, %rax
    jmp .L1.malloc_exit
    
    .L1.malloc_success:
    popq    %rdi
    movq    %rdi, (%rax)
    addq    $8, %rax
    .L1.malloc_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// void free(void* src)
// free memory for current address
// global variable errno used for errors detections
free_:
    pushq   %rbp
    movq    %rsp, %rbp

    testq   %rdi, %rdi
    je .L1.free_exit

    # read prev 8 byte from input pointer
    subq    $8, %rdi
    movq    (%rdi), %rdx

    mov     $11, %rax           # system call 11 sys_munmap
    movq    %rdx, %rsi          # size
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    je .L1.free_exit
    mov     %rax, %rdi
    call    set_errno_
    .L1.free_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// int socket(int domain, int type, int protocol)
// WARNING: incomplete error handling
socket_:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $41, %rax
    movl    $0, %r10d
    movl    $0, %r8d
    movl    $0, %r9d
    syscall

    mov     %rax, %rcx
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.socket_exit
    // TODO: add logic for non-blocking mode
    mov     $EINVAL_, %rcx
    neg     %rcx
    cmp     %rax, %rcx
    je .L1.socket_error
    mov     $EPROTONOSUPPORT_, %rcx
    neg     %rcx
    cmp     %rax, %rcx
    je .L1.socket_error

    .L1.socket_error:
    mov     %rax, %rdi
    call    set_errno_
    movl     $-1, %eax

    .L1.socket_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// int bind(int sockfd, struct sockaddr *my_addr, socklen_t addrlen)
bind_:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     $49, %rax
    xor     %r10, %r10
    xor     %r8, %r8
    xor     %r9, %r9
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.bind_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax

    .L1.bind_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// int listen(int s, int backlog)
listen_:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     $50, %rax
    xor     %rdx, %rdx
    xor     %r10, %r10
    xor     %r8, %r8
    xor     %r9, %r9
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.listen_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax

    .L1.listen_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
 //int accept(int s, struct sockaddr *addr, socklen_t *addrlen)
accept_:
    pushq   %rbp
    movq    %rsp, %rbp

    mov     $43, %rax
    xor     %r10, %r10
    xor     %r8, %r8
    xor     %r9, %r9
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.listen_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax

    .L1.accept_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// int setsockopt(int fd, int level, int optname, const void *optval, socklen_t optlen)
// WARNING: incomplete error handling
setsockopt_:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $54, %rax
    movq    %rcx, %r10
    xorq    %r9, %r9
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.setsockopt_exit
    //TODO: add handler for ENOPROTOOPT
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax

    .L1.setsockopt_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// int connect(int fd, const struct sockaddr *addr, socklen_t len)
connect_:
    pushq   %rbp
    movq    %rsp, %rbp

    //%rdi, %rsi, %rdx, %r10, %r8 and %r9.   
    movq    $42, %rax
    movl    $0, %r10d
    movl    $0, %r8d
    movl    $0, %r9d
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.connect_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax

    .L1.connect_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// ssize_t write(int fd, const void *buf, size_t count)
write_:
    pushq   %rbp
    movq    %rsp, %rbp

    # write(fd, buf, count)
    movq    $1, %rax
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.write_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax

    .L1.write_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// simple wrapper for write_ for null-terminated string
// ssize_t write_str(int fd, const void *buf)
write_str_:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %rdi
    movq    %rsi, %rdi
    pushq   %rsi
    callq   strlen_

    # write(fd, buf, count)
    popq    %rsi
    popq    %rdi
    inc     %rax
    movq    %rax, %rdx
    movq    $1, %rax
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.write_msg_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax

    .L1.write_msg_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// simple wrapper for write_ for '\0' contained string
// ssize_t write_zero_str_(int fd, const void *buf, size_t n)
write_zero_str_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp

    mov     %rdx, -8(%rbp)      # size
    // pushq   %rdi                # fd
    // pushq   %rsi                # source
    mov     %rdi, -24(%rbp)     #fd
    mov     %rsi, -32(%rbp)     #source

    //allocate temp buffer
    mov     %rdx, %rdi
    call    malloc_

    test    %rax, %rax
    je .L1.write_zero_str_bad_state
    mov     %rax, -16(%rbp)     # dst

    mov     %rax, %rdi
    mov     $0, %rsi
    mov     -8(%rbp), %rdx
    call    memset_

    //popq    %rcx                #source
    mov     -32(%rbp), %rcx
    mov     -16(%rbp), %rdx     #dst
    xorq    %rsi, %rsi
    mov     -8(%rbp), %rsi      #index

    //xor     %ebx, %ebx

    .L1.write_zero_str_copy_loop:
        cmpq    $0, %rsi
        je .L1.write_zero_str_stop
        // xor     %eax, %eax
        // movb    (%rcx), %al
        // cmpb    $0, %al 
        cmpb    $0, (%rcx)
        je  .L1.write_zero_str_copy_space
        movb    (%rcx), %al
        movb    %al, (%rdx)
        jmp .L1.write_zero_str_it
        .L1.write_zero_str_copy_space:
        //inc     %rbx
        movb    $' ', (%rdx)
        .L1.write_zero_str_it:
        inc     %rdx
        inc     %rcx
        dec     %rsi
        jmp .L1.write_zero_str_copy_loop

    .L1.write_zero_str_stop:
    //popq    %rdi  # fd
    mov     -24(%rbp), %rdi 
    //pushq   %rdi
    mov     -16(%rbp), %rsi
    call    write_str_
    mov     %rax, -24(%rbp)

    //TODO
    //popq    %rdi  # fd
    // mov     $0x0A, %rsi
    // call    write_str_

    //free temp buffer
    mov     -16(%rbp), %rdi
    call    free_
    jmp .L1.write_zero_str_exit

    .L1.write_zero_str_bad_state:
    // popq    %rdi
    // popq    %rdi
    mov     $-1, %rax
    .L1.write_zero_str_exit:
    addq    $32, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// ssize_t sendto(int fd, const void *buf, size_t len, int flags, const struct sockaddr *addr, socklen_t alen)
sendto_:
    pushq   %rbp
    movq    %rsp, %rbp
    movq    %rcx, %r10
    movq    $44, %rax
    syscall

    cmp     $-1, %rax
    jne .L1.sendto_exit
    movq    %rax, %rdi
    call    set_errno_
    movq    $-1, %rax

    .L1.sendto_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// ssize_t send(int fd, const void *buf, size_t len, int flags)
send_:
    pushq   %rbp
    movq    %rsp, %rbp

    xorq    %r8, %r8
    xorq    %r9, %r9
    call    sendto_
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// Wrapper for send all data
// int send_all(int fd, const void *buf, size_t len, int flags)
// ret -1 if failed, len - if success
// TODO: may be return len?
// pseudo-code:
//  while (length > 0)
//  {
//      send(socket, buf, length);
//      buf += i;
//      length -= i;
//  }
send_all_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $48, %rsp

    movl    %edi, -8(%rbp)
    movq    %rsi, -16(%rbp)
    movl    %edx, -24(%rbp)
    movl    %ecx, -32(%rbp)
    movl    $0, -40(%rbp)

    .L1.send_loop:
        movl    -8(%rbp), %edi
        movq    -16(%rbp), %rsi
        movl    -24(%rbp), %edx
        movl    -32(%rbp), %ecx
        call    send_
        cmp     $1, %rax
        jl .L1.send_all_failed
        add     %rax, -16(%rbp)
        sub     %rax, -24(%rbp)
        add     %rax, -40(%rbp)
        cmpl    $0, -24(%rbp)
        jg .L1.send_loop

    mov     -40(%rbp), %rax
    jmp .L1.send_all_exit

    .L1.send_all_failed:
    mov     $-1, %rax

    .L1.send_all_exit:
    addq    $48, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// ssize_t recvfrom(int fd, void *restrict buf, size_t len, int flags, struct sockaddr *restrict addr, socklen_t *restrict alen)
recvfrom_:
    pushq   %rbp
    movq    %rsp, %rbp
    mov     %rcx, %r10
    mov     $45, %rax
    syscall

    cmp     $-1, %rax
    jg .L1.recvfrom_exit
    mov     %rax, %rdi
    call    set_errno_
    movq    $-1, %rax

    .L1.recvfrom_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// ssize_t recv(int fd, void *buf, size_t len, int flags)
recv_:
    pushq   %rbp
    movq    %rsp, %rbp
    xor     %r8, %r8
    xor     %r9, %r9
    call    recvfrom_

    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// Wrapper for recv all input data
// int recv_all_(int fd, void *buf, size_t len, int flags)
// ret -1 if failed, len - if success
recv_all_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $48, %rsp
    
    movl    %edi, -8(%rbp)
    movq    %rsi, -16(%rbp)
    movl    %edx, -24(%rbp)
    movl    %ecx, -32(%rbp)
    movl    $0, -40(%rbp)

    .L1.recv_loop:
        movl    -8(%rbp), %edi
        movq    -16(%rbp), %rsi
        movl    -24(%rbp), %edx
        movl    -32(%rbp), %ecx
        call    recv_

        cmp     $0, %rax
        jl .L1.recv_all_failed
        test    %rax, %rax
        je .L1.recv_close
        add     %rax, -16(%rbp)
        sub     %rax, -24(%rbp)
        add     %rax, -40(%rbp)

        mov     -24(%rbp), %rdx

        cmpl    $0, -24(%rbp)
        jg .L1.recv_loop
    
    .L1.recv_close:
    mov     -40(%rbp), %rax
    jmp .L1.recv_all_exit

    .L1.recv_all_failed:
    movq    $-1, %rax

    .L1.recv_all_exit:
    addq    $48, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// int close(int fd)
close_:
    pushq   %rbp
    movq    %rsp, %rbp
    mov     $3, %rax
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.close_exit
    mov     %rax, %rdi
    call    set_errno_
    .L1.close_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// void exit(int exit_code)
// causes normal program termination to occur
exit_:
    pushq   %rbp
    movq    %rsp, %rbp
    mov     $60, %rax
    syscall
    popq    %rbp
    retq
