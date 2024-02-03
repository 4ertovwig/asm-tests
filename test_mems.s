.text

.global main
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

    // addr:
    // -10, -9...........-1
    // [7,2,3,4,8,2,1,5,6,9]
    movb    $0x37, -10(%rbp)
    movb    $0x32, -9(%rbp)
    movb    $0x33, -8(%rbp)
    movb    $0x34, -7(%rbp)
    movb    $0x38, -6(%rbp)
    movb    $0x32, -5(%rbp)
    movb    $0x31, -4(%rbp)
    movb    $0x35, -3(%rbp)
    movb    $0x36, -2(%rbp)
    movb    $0x39, -1(%rbp)

    lea     before_memmove_half1(%rip), %rdi
    movb    -10(%rbp), %sil
    movb    -9(%rbp), %dl
    movb    -8(%rbp), %cl
    movb    -7(%rbp), %r8b
    movb    -6(%rbp), %r9b
    xor     %eax, %eax
    call    printf

    lea     before_memmove_half2(%rip), %rdi
    movb    -5(%rbp), %sil
    movb    -4(%rbp), %dl
    movb    -3(%rbp), %cl
    movb    -2(%rbp), %r8b
    movb    -1(%rbp), %r9b
    xor     %eax, %eax
    call    printf

    // addr:
    // -10 -9 -8 -7 -6 -5 -4 -3 -2 -1
    // -------------------------------
    // [ 7, 2, 3, 4, 8, 2, 1, 5, 6, 9]
    //  |______________|
    //          |
    //          |----|
    //               |
    //        _______|_______
    // [ 7, 2,|7, 2, 3, 4, 8| 5, 6, 9]
    lea     -8(%rbp), %rdi
    lea     -10(%rbp), %rsi
    mov     $5, %rdx
    call    memmove_

    lea     after_memmove_half1(%rip), %rdi
    movb    -10(%rbp), %sil
    movb    -9(%rbp), %dl
    movb    -8(%rbp), %cl
    movb    -7(%rbp), %r8b
    movb    -6(%rbp), %r9b
    xor     %eax, %eax
    call    printf

    lea     after_memmove_half2(%rip), %rdi
    movb    -5(%rbp), %sil
    movb    -4(%rbp), %dl
    movb    -3(%rbp), %cl
    movb    -2(%rbp), %r8b
    movb    -1(%rbp), %r9b
    xor     %eax, %eax
    call    printf

    cmpb    $0x37, -8(%rbp)
    jne .L1.mems_test_failed
    mov     $STDOUT_FD_, %rdi
    mov     $test_passed1, %rsi
    call    write_str_

    leaq    -8(%rbp), %rdi
    leaq    -10(%rbp), %rsi
    mov     $2, %rdx
    call    memcmp_

    test    %rax, %rax
    jne .L1.mems_test_failed
    mov     $STDOUT_FD_, %rdi
    mov     $test_passed2, %rsi
    call    write_str_

    mov     $12, %rdi
    call    malloc_
    mov     %rax, %rbx  # Note: need check nullptr, but lazy

    lea     (%rax), %rdi
    movq    $0, %rsi
    movq    $12, %rdx
    call    memset_

    // movq    $-860254, %rsi
    // pushq   %rsi
    // lea     itoa_string(%rip), %rdi
    // xor     %rax, %rax
    // call    printf # <--- crash here
    // popq    %rdi

    movq    $-860254, %rdi
    lea     (%rax), %rsi
    call    itoa_

    lea     after_itoa(%rip), %rdi
    movb    (%rbx), %sil
    movb    1(%rbx), %dl
    movb    2(%rbx), %cl
    movb    3(%rbx), %r8b
    movb    4(%rbx), %r9b
    xor     %rax, %rax
    call    printf

    cmpb    $0x32, 4(%rbx)
    jne .L1.mems_test_failed
    mov     $STDOUT_FD_, %rdi
    mov     $test_passed3, %rsi
    call    write_str_

    // addr:
    // -48, -47...........-41
    // [1,2,3,4,5,6,7,8]
    movb    $0x31, -48(%rbp)
    movb    $0x32, -47(%rbp)
    movb    $0x33, -46(%rbp)
    movb    $0x34, -45(%rbp)
    movb    $0x35, -44(%rbp)
    movb    $0x36, -43(%rbp)
    movb    $0x37, -42(%rbp)
    movb    $0x38, -41(%rbp)

    lea     before_memset(%rip), %rdi
    movb    -48(%rbp), %sil
    movb    -47(%rbp), %dl
    movb    -46(%rbp), %cl
    movb    -45(%rbp), %r8b
    movb    -44(%rbp), %r9b
    xor     %eax, %eax
    call    printf

    leaq    -48(%rbp), %rdi
    movq    $0x32, %rsi
    movq    $5, %rdx
    call    memset_

    lea     after_memset(%rip), %rdi
    movb    -48(%rbp), %sil
    movb    -47(%rbp), %dl
    movb    -46(%rbp), %cl
    movb    -45(%rbp), %r8b
    movb    -44(%rbp), %r9b
    xor     %eax, %eax
    call    printf

    cmpb    $0x32, -44(%rbp)
    jne .L1.mems_test_failed

    mov     $STDOUT_FD_, %rdi
    mov     $test_passed4, %rsi
    call    write_str_
    jmp .L1.mems_test_stop

    .L1.mems_test_failed:
    mov     $STDOUT_FD_, %rdi
    mov     $test_failed, %rsi
    call    write_str_
    jmp .L1.mems_test_stop

    .L1.mems_test_stop:
    mov     $STDOUT_FD_, %rdi
    mov     $test_end, %rsi
    call    write_str_

    xor     %eax, %eax
    addq    $64, %rsp
    popq    %rbp
    ret

.data
.include "test_utils.s"

itoa_string:            .asciz "Itoa string: \n"
after_itoa:             .asciz "After itoa: %c, %c, %c, %c, %c\n"
before_memset:          .asciz "Before memset: %c, %c, %c, %c, %c\n"
after_memset:           .asciz "After memset:  %c, %c, %c, %c, %c\n"
before_memmove_half1:   .asciz "Before memmove: %c, %c, %c, %c, %c, "
before_memmove_half2:   .asciz "%c, %c, %c, %c, %c\n"
after_memmove_half1:    .asciz "After memmove:  %c, %c, %c, %c, %c, "
after_memmove_half2:    .asciz "%c, %c, %c, %c, %c\n"
