.text

.globl htonl_
.globl htons_
.globl ntohl_
.globl ntohs_

/////////////////////////////////////////////////////////////////////////////////////////
// unsigned int htonl(unsigned int)
htonl_:
    pushq   %rbp
    movq    %rsp, %rbp
    xor     %eax, %eax

    movl    %edi, %ecx
    andl    $0xff, %ecx
    shll    $24, %ecx
    movl    %ecx, %eax
    movl    %edi, %ecx
    andl    $0xff00, %ecx
    shll    $8, %ecx
    orl     %ecx, %eax
    movl    %edi, %ecx
    andl    $0xff0000, %ecx
    shrl    $8, %ecx
    orl     %ecx, %eax
    movl    %edi, %ecx
    andl    $0xff000000, %ecx
    shrl    $24, %ecx
    orl     %ecx, %eax

    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// unsigned short htons(unsigned short)
// 'smart' implementation:
//    ror    $0x8,%di
//    movzwl %di,%eax
//    retq
htons_:
    pushq   %rbp
    movq    %rsp, %rbp
    xor     %eax, %eax

    movw    %di, %cx
    andw    $0xff, %cx
    shlw    $8, %cx
    movw    %cx, %ax
    movw    %di, %cx
    andw    $0xff00, %cx
    shrw    $8, %cx
    orw     %cx, %ax

    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// unsigned int ntohl(unsigned int)
ntohl_:
    pushq   %rbp
    movq    %rsp, %rbp
    call    htonl_

    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// unsigned short ntohs(unsigned short)
ntohs_:
    pushq   %rbp
    movq    %rsp, %rbp
    call    htons_

    popq    %rbp
    retq
