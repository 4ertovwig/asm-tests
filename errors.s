.section .bss
errno_: .long 0

.section .rodata

# Some errno base codes
ENOINFO_:           .asciz "No error information\n"
EPERM_:             .asciz "Operation not permitted\n"
ENOENT_:            .asciz "No such file or directory\n"
ESRCH_:             .asciz "No such process\n"
EINTR_:             .asciz "Interrupted system call\n"
EIO_:               .asciz "I/O error\n"
ENXIO_:             .asciz "No such device or address\n"
E2BIG_:             .asciz "Argument list too long\n"
ENOEXEC_:           .asciz "Exec format error\n"
EBADF_:             .asciz "Bad file descriptor\n"
ECHILD_:            .asciz "No child process\n"
EAGAIN_:            .asciz "Resource temporarily unavailable\n"
ENOMEM_:            .asciz "Out of memory\n"
EACCES_:            .asciz "Permission denied\n"
EFAULT_:            .asciz "Bad address\n"
ENOTBLK_:           .asciz "Block device required\n"
EBUSY_:             .asciz "Resource busy\n"
EEXIST_:            .asciz "File exists\n"
EXDEV_:             .asciz "Cross-device link\n"
ENODEV_:            .asciz "No such device\n"
ENOTDIR_:           .asciz "Not a directory\n"
EISDIR_:            .asciz "Is a directory\n"
EINVAL_:            .asciz "Invalid argument\n"
ENFILE_:            .asciz "File table overflow\n"
EMFILE_:            .asciz "Too many open files\n"
ENOTTY_:            .asciz "File table overflow\n"
ETXTBSY_:           .asciz "Text file busy\n"
EFBIG_:             .asciz "File too large\n"
ENOSPC_:            .asciz "No space left on device\n"
ESPIPE_:            .asciz "Invalid seek\n"
EROFS_:             .asciz "Read-only file system\n"
EMLINK_:            .asciz "Too many links\n"
EPIPE_:             .asciz "Broken pipe\n"
EDOM_:              .asciz "Numerical argument out of domain\n"
ERANGE_:            .asciz "Math result not representable\n"
EADDRNOTAVAIL_:     .asciz "Address not available\n"
EPROTONOSUPPORT_:   .asciz "Protocol not supported\n"
EAFNOSUPPORT_:      .asciz "Address family not supported by protocol\n"
EALREADY_:          .asciz "Operation already in progress\n"
ECONNREFUSED_:      .asciz "Connection refused\n"
EINPROGRESS_:       .asciz "Operation in progress\n"
EISCONN_:           .asciz "Socket is connected\n"
ENOTCONN_:          .asciz "Socket not connected\n"
ENETUNREACH_:       .asciz "Network unreachable\n"
ENOTSOCK_:          .asciz "Not a socket\n"
EPROTOTYPE_:        .asciz "Protocol wrong type for socket\n"
ETIMEDOUT_:         .asciz "Operation timed out\n"
ESOCKTNOSUPPORT_:   .asciz "Socket type not supported\n"
EDQUOT_:            .asciz "Quota exceeded\n"
ENETDOWN_:          .asciz "Network is down\n"
ECONNABORTED_:      .asciz "Connection aborted\n"
ENOPROTOOPT_:       .asciz "Protocol not available\n"
ENAMETOOLONG_:      .asciz "Filename too long\n"
ELOOP_:             .asciz "Symbolic link loop\n"
ENOTSUP_: 	        .asciz "Operation not supported\n"
EADDRINUSE_:        .asciz "Address already in use\n"
EPROTO_:            .asciz "Protocol error\n"
EBADMSG_:           .asciz "Bad message\n"

EUNHANDLE_:         .asciz "Errno has not description\n"

// E(EILSEQ,       "Illegal byte sequence")

// E(ENOTTY,       "Not a tty")
// E(EPERM,        "Operation not permitted")
// E(ENOENT,       "No such file or directory")
// E(ESRCH,        "No such process")

// E(EOVERFLOW,    "Value too large for data type")

// E(EXDEV,        "Cross-device link")
// E(ENOTEMPTY,    "Directory not empty")

// E(ECONNRESET,   "Connection reset by peer")
// E(ETIMEDOUT,    "Operation timed out")
// E(EHOSTDOWN,    "Host is down")
// E(EHOSTUNREACH, "Host is unreachable")

// E(ENXIO,        "No such device or address")
// E(ENOTBLK,      "Block device required")
// E(ENODEV,       "No such device")
// E(ENOEXEC,      "Exec format error")

// E(E2BIG,        "Argument list too long")
// E(ENFILE,       "Too many open files in system")
// E(EBADF,        "Bad file descriptor")
// E(ECHILD,       "No child process")
// E(EFBIG,        "File too large")
// E(EMLINK,       "Too many links")
// E(ENOLCK,       "No locks available")

// E(EDEADLK,      "Resource deadlock would occur")
// E(ENOTRECOVERABLE, "State not recoverable")
// E(EOWNERDEAD,   "Previous owner died")
// E(ECANCELED,    "Operation canceled")
// E(ENOSYS,       "Function not implemented")
// E(ENOMSG,       "No message of desired type")
// E(EIDRM,        "Identifier removed")
// E(ENOSTR,       "Device not a stream")
// E(ENODATA,      "No data available")
// E(ETIME,        "Device timeout")
// E(ENOSR,        "Out of streams resources")
// E(ENOLINK,      "Link has been severed")
// E(EBADFD,       "File descriptor in bad state")
// E(EDESTADDRREQ, "Destination address required")
// E(EMSGSIZE,     "Message too large")
// E(EPFNOSUPPORT, "Protocol family not supported")
// E(ENETRESET,    "Connection reset by network")
// E(ENOBUFS,      "No buffer space available")
// E(ESHUTDOWN,    "Cannot send after socket shutdown")
// E(ESTALE,       "Stale file handle")
// E(EREMOTEIO,    "Remote I/O error")
// E(ENOMEDIUM,    "No medium found")
// E(EMEDIUMTYPE,  "Wrong medium type")
// E(EMULTIHOP,    "Multihop attempted")

.text
.globl set_errno_

/////////////////////////////////////////////////////////////////////////////////////////
# void set_errno_(int rax_from_syscall)
# set errno according to base errno table
set_errno_:
    pushq   %rbp
    movq    %rsp, %rbp

    neg     %edi
    movl    %edi, errno_

    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
# char* strerror(int errno)
# return string to human-readable errors
strerror_:
    pushq   %rbp
    movq    %rsp, %rbp

    test %rdi, %rdi
    je .L1.ENOINFO
    cmp $1, %rdi
    je .L1.EPERM
    cmp $2, %rdi
    je .L1.ENOENT
    cmp $3, %rdi
    je .L1.ESRCH
    cmp $4, %rdi
    je .L1.EINTR
    cmp $5, %rdi
    je .L1.EIO
    cmp $6, %rdi
    je .L1.ENXIO
    cmp $7, %rdi
    je .L1.E2BIG
    cmp $8, %rdi
    je .L1.ENOEXEC
    cmp $9, %rdi
    je .L1.EBADF
    cmp $10, %rdi
    je .L1.ECHILD
    cmp $11, %rdi
    je .L1.EAGAIN
    cmp $12, %rdi
    je .L1.ENOMEM
    cmp $13, %rdi
    je .L1.EACCES
    cmp $14, %rdi
    je .L1.EFAULT
    cmp $15, %rdi
    je .L1.ENOTBLK
    cmp $16, %rdi
    je .L1.EBUSY
    cmp $17, %rdi
    je .L1.EEXIST
    cmp $18, %rdi
    je .L1.EXDEV
    cmp $19, %rdi
    je .L1.ENODEV
    cmp $20, %rdi
    je .L1.ENOTDIR
    cmp $21, %rdi
    je .L1.EISDIR
    cmp $22, %rdi
    je .L1.EINVAL
    cmp $23, %rdi
    je .L1.ENFILE
    cmp $24, %rdi
    je .L1.EMFILE
    cmp $25, %rdi
    je .L1.ENOTTY
    cmp $26, %rdi
    je .L1.ETXTBSY
    cmp $27, %rdi
    je .L1.EFBIG
    cmp $28, %rdi
    je .L1.ENOSPC
    cmp $29, %rdi
    je .L1.ESPIPE
    cmp $30, %rdi
    je .L1.EROFS
    cmp $31, %rdi
    je .L1.EMLINK
    cmp $32, %rdi
    je .L1.EPIPE
    cmp $33, %rdi
    je .L1.EDOM
    cmp $34, %rdi
    je .L1.ERANGE
    cmp $36, %rdi
    je .L1.ENAMETOOLONG
    cmp $40, %rdi
    je .L1.ELOOP
    cmp $71, %rdi
    je .L1.EPROTO
    cmp $74, %rdi
    je .L1.EBADMSG
    cmp $93, %rdi
    je .L1.EPROTONOSUPPORT
    cmp $99, %rdi
    je .L1.EADDRNOTAVAIL
    cmp $97, %rdi
    je .L1.EAFNOSUPPORT
    cmp $111, %rdi
    je .L1.ECONNREFUSED
    cmp $114, %rdi
    je .L1.EALREADY
    cmp $115, %rdi
    je .L1.EINPROGRESS
    cmp $106, %rdi
    je .L1.EISCONN
    cmp $107, %rdi
    je .L1.ENOTCONN
    cmp $101, %rdi
    je .L1.ENETUNREACH
    cmp $110, %rdi
    je .L1.ETIMEDOUT
    cmp $88, %rdi
    je .L1.ENOTSOCK
    cmp $91, %rdi
    je .L1.EPROTOTYPE
    cmp $92, %rdi
    je .L1.ENOPROTOOPT
    cmp $94, %rdi
    je .L1.ESOCKTNOSUPPORT
    cmp $95, %rdi
    je .L1.ENOTSUP
    cmp $98, %rdi
    je .L1.EADDRINUSE
    cmp $122, %rdi
    je .L1.EDQUOT
    cmp $100, %rdi
    je .L1.ENETDOWN
    cmp $103, %rdi
    je .L1.ECONNABORTED

    mov $EUNHANDLE_, %rax
    jmp .L1.strerror_exit

    .L1.ENOINFO:
    mov $ENOINFO_, %rax
    jmp .L1.strerror_exit
    .L1.EPERM:
    mov $EPERM_, %rax
    jmp .L1.strerror_exit
    .L1.ENOENT:
    mov $ENOENT_, %rax
    jmp .L1.strerror_exit
    .L1.ESRCH:
    mov $ESRCH_, %rax
    jmp .L1.strerror_exit
    .L1.EINTR:
    mov $EINTR_, %rax
    jmp .L1.strerror_exit
    .L1.EIO:
    mov $EIO_, %rax
    jmp .L1.strerror_exit
    .L1.ENXIO:
    mov $ENXIO_, %rax
    jmp .L1.strerror_exit
    .L1.E2BIG:
    mov $E2BIG_, %rax
    jmp .L1.strerror_exit
    .L1.ENOEXEC:
    mov $ENOEXEC_, %rax
    jmp .L1.strerror_exit
    .L1.EBADF:
    mov $EBADF_, %rax
    jmp .L1.strerror_exit
    .L1.ECHILD:
    mov $ECHILD_, %rax
    jmp .L1.strerror_exit
    .L1.EAGAIN:
    mov $EAGAIN_, %rax
    jmp .L1.strerror_exit
    .L1.ENOMEM:
    mov $ENOMEM_, %rax
    jmp .L1.strerror_exit
    .L1.EACCES:
    mov $EACCES_, %rax
    jmp .L1.strerror_exit
    .L1.EFAULT:
    mov $EFAULT_, %rax
    jmp .L1.strerror_exit
    .L1.ENOTBLK:
    mov $ENOTBLK_, %rax
    jmp .L1.strerror_exit
    .L1.EBUSY:
    mov $EBUSY_, %rax
    jmp .L1.strerror_exit
    .L1.EEXIST:
    mov $EEXIST_, %rax
    jmp .L1.strerror_exit
    .L1.EXDEV:
    mov $EXDEV_, %rax
    jmp .L1.strerror_exit
    .L1.ENODEV:
    mov $ENODEV_, %rax
    jmp .L1.strerror_exit
    .L1.ENOTDIR:
    mov $ENOTDIR_, %rax
    jmp .L1.strerror_exit
    .L1.EISDIR:
    mov $EISDIR_, %rax
    jmp .L1.strerror_exit
    .L1.EINVAL:
    mov $EINVAL_, %rax
    jmp .L1.strerror_exit
    .L1.ENFILE:
    mov $ENFILE_, %rax
    jmp .L1.strerror_exit
    .L1.EMFILE:
    mov $EMFILE_, %rax
    jmp .L1.strerror_exit
    .L1.ENOTTY:
    mov $ENOTTY_, %rax
    jmp .L1.strerror_exit
    .L1.ETXTBSY:
    mov $ETXTBSY_, %rax
    jmp .L1.strerror_exit
    .L1.EFBIG:
    mov $EFBIG_, %rax
    jmp .L1.strerror_exit
    .L1.ENOSPC:
    mov $ENOSPC_, %rax
    jmp .L1.strerror_exit
    .L1.ESPIPE:
    mov $ESPIPE_, %rax
    jmp .L1.strerror_exit
    .L1.EROFS:
    mov $EROFS_, %rax
    jmp .L1.strerror_exit
    .L1.EMLINK:
    mov $EMLINK_, %rax
    jmp .L1.strerror_exit
    .L1.EPIPE:
    mov $EPIPE_, %rax
    jmp .L1.strerror_exit
    .L1.EDOM:
    mov $EDOM_, %rax
    jmp .L1.strerror_exit
    .L1.ERANGE:
    mov $ERANGE_, %rax
    jmp .L1.strerror_exit
    .L1.ENAMETOOLONG:
    mov $ENAMETOOLONG_, %rax
    jmp .L1.strerror_exit
    .L1.ELOOP:
    mov $ELOOP_, %rax
    jmp .L1.strerror_exit
    .L1.EPROTO:
    mov $EPROTO_, %rax
    jmp .L1.strerror_exit
    .L1.EBADMSG:
    mov $EBADMSG_, %rax
    jmp .L1.strerror_exit
    .L1.EPROTONOSUPPORT:
    mov $EPROTONOSUPPORT_, %rax
    jmp .L1.strerror_exit
    .L1.EADDRNOTAVAIL:
    mov $EADDRNOTAVAIL_, %rax
    jmp .L1.strerror_exit
    .L1.EAFNOSUPPORT:
    mov $EAFNOSUPPORT_, %rax
    jmp .L1.strerror_exit
    .L1.ECONNREFUSED:
    mov $ECONNREFUSED_, %rax
    jmp .L1.strerror_exit
    .L1.EALREADY:
    mov $EALREADY_, %rax
    jmp .L1.strerror_exit
    .L1.EINPROGRESS:
    mov $EINPROGRESS_, %rax
    jmp .L1.strerror_exit
    .L1.EISCONN:
    mov $EISCONN_, %rax
    jmp .L1.strerror_exit
    .L1.ENOTCONN:
    mov $ENOTCONN_, %rax
    jmp .L1.strerror_exit
    .L1.ENETUNREACH:
    mov $ENETUNREACH_, %rax
    jmp .L1.strerror_exit
    .L1.ENOTSOCK:
    mov $ENOTSOCK_, %rax
    jmp .L1.strerror_exit
    .L1.EPROTOTYPE:
    mov $EPROTOTYPE_, %rax
    jmp .L1.strerror_exit
    .L1.ETIMEDOUT:
    mov $ETIMEDOUT_, %rax
    jmp .L1.strerror_exit
    .L1.ESOCKTNOSUPPORT:
    mov $ESOCKTNOSUPPORT_, %rax
    jmp .L1.strerror_exit
    .L1.EDQUOT:
    mov $EDQUOT_, %rax
    jmp .L1.strerror_exit
    .L1.ENETDOWN:
    mov $ENETDOWN_, %rax
    jmp .L1.strerror_exit
    .L1.ECONNABORTED:
    mov $ECONNABORTED_, %rax
    jmp .L1.strerror_exit
    .L1.ENOPROTOOPT:
    mov $ENOPROTOOPT_, %rax
    jmp .L1.strerror_exit
    .L1.ENOTSUP:
    mov $ENOTSUP_, %rax
    jmp .L1.strerror_exit
    .L1.EADDRINUSE:
    mov $EADDRINUSE_, %rax
    jmp .L1.strerror_exit

    .L1.strerror_exit:
    popq    %rbp
    retq
