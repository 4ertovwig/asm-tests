.internal stack_alloc_
.internal clone_
.globl thread_start_

.set CLONE_VM_,         0x00000100
.set CLONE_FS_,         0x00000200
.set CLONE_FILES_,      0x00000400
.set CLONE_SIGHAND_,    0x00000800
.set CLONE_PARENT_,     0x00008000
.set CLONE_THREAD_,     0x00010000
.set CLONE_IO_,         0x80000000


.data
STACK_SIZE:            .long  4194304   # 4MB stack

.text

/////////////////////////////////////////////////////////////
// allocation new stack for spawned thread
// ret: pointer to stack frame, null on failure
stack_alloc_:
    pushq   %rbp
    movq    %rsp, %rbp

    movl    $PROT_READ_, %ecx
    orl     $PROT_WRITE_, %ecx      # PROT flags
    movl    $MAP_PRIVATE_, %r9d
    orl     $MAP_ANONYMOUS_, %r9d
    orl     $MAP_GROWSDOWN_, %r9d  # MAP flags


    movl    $9, %eax              # system call 9 sys_mmap
    movq    $0, %rdi              # start address
    movq    STACK_SIZE, %rsi      # size
    movl    %ecx, %edx            # page flags
    movl    %r9d, %r10d           # mem flags
    movl    $-1, %r8d             # file descriptor
    movl    $0, %r9d              # offset
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.allocstack_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $0, %rax

    .L1.allocstack_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// int clone(int (*fn)(void *), void *stack, int flags, pid_t *parent_tid, void *tls, pid_t *child_tid)
// ret -1 on falilrue; on success - the thread ID of the child process is returned in the caller's thread of execution
clone_:
    pushq   %rbp
    movq    %rsp, %rbp

    //NOTE: this clone function has another declaration
    movq    %rcx, %r10
    movq    $56, %rax
    syscall

    // rax >= -4095ULL
    cmp     $0xfffffffffffff000, %rax
    jbe .L1.clone_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax
    .L1.clone_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// create thread
// ret -1 on failure, on success - new thread ID
thread_start_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
    mov     %rdi, -8(%rbp)

    callq   stack_alloc_

    test    %rax, %rax
    jne     .L1.stack_alloc_good
    movq    $-1, %rax
    jmp     .L1.thread_start_exit

    .L1.stack_alloc_good:
    movq    -8(%rbp), %rdi
    movq    %rax, %rsi
    addq    STACK_SIZE, %rsi # pointer to stack + stack_size

    movl    $CLONE_VM_, %edx
    orl     $CLONE_FS_, %edx
    orl     $CLONE_FILES_, %edx
    orl     $CLONE_SIGHAND_, %edx
    orl     $CLONE_PARENT_, %edx
    orl     $CLONE_THREAD_, %edx
    orl     $CLONE_IO_, %edx    # CLONE flags
    callq   clone_

    .L1.thread_start_exit:
    addq    $16, %rsp
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// int sleep(int seconds)
sleep_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
    movq    %rdi, -16(%rbp)
    movq    $0, -8(%rbp)
    leaq    -32(%rbp), %rsi
    leaq    -16(%rbp), %rdi
    movq    %rdx, %rsi
    movl    $35, %eax
    syscall

    cmp     $0xfffffffffffff000, %rax
    jbe .L1.sleep_exit
    mov     %rax, %rdi
    call    set_errno_
    mov     $-1, %rax

    .L1.sleep_exit:
    addq    $16, %rsp
    popq    %rbp
    retq
