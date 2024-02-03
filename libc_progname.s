//                 top of memory (highest addresses)
// "bottom" of stack (stack grows down towards lower addresses)
// ┌───────────────────────────────────────────────────────────┐
// │                                                           │

//                          other stuff

// │                                                           │
// ├───────────────────────────────────────────────────────────┤
// │                        64-bit zero                        │
// ├───────────────────────────────────────────────────────────┤
// │ pointer to env var N (address of first char of env var N) │
// ├───────────────────────────────────────────────────────────┤
//                             ...
// ├───────────────────────────────────────────────────────────┤
// │ pointer to env var 3 (address of first char of env var 3) │
// ├───────────────────────────────────────────────────────────┤
// │ pointer to env var 2 (address of first char of env var 2) │
// ├───────────────────────────────────────────────────────────┤
// │ pointer to env var 1 (address of first char of env var 1) │
// ├───────────────────────────────────────────────────────────┤
// │                        64-bit zero                        │
// ├───────────────────────────────────────────────────────────┤
// │     pointer to arg N (address of first char of arg N)     │
// ├───────────────────────────────────────────────────────────┤
//                             ...
// ├───────────────────────────────────────────────────────────┤
// │     pointer to arg 3 (address of first char of arg 3)     │
// ├───────────────────────────────────────────────────────────┤
// │     pointer to arg 2 (address of first char of arg 2)     │
// ├───────────────────────────────────────────────────────────┤
// │     pointer to arg 1 (address of first char of arg 1)     │
// ├───────────────────────────────────────────────────────────┤
// │  pointer to program name / arg 0 (address of first char)  │
// ├───────────────────────────────────────────────────────────┤
// │            number of args (as a 64-bit integer)           │
// └───────────────────────────────────────────────────────────┘
//   "top" of stack (stack grows down towards lower addresses)

//--------------------------------------------------------------------------

//https://stackoverflow.com/questions/50260855/how-to-get-arguments-value-in-start-and-call-main-using-inline-assembly-in-c
// _start:
//         xorl   %ebp, %ebp       #  mark the deepest stack frame

//   # Current Linux doesn't pass an atexit function,
//   # so you could leave out this part of what the ABI doc says you should do
//   # You can't just keep the function pointer in a call-preserved register
//   # and call it manually, even if you know the program won't call exit
//   # directly, because atexit functions must be called in reverse order
//   # of registration; this one, if it exists, is meant to be called last.
//         testq  %rdx, %rdx       #  is there "a function pointer to
//         je     skip_atexit      #  register with atexit"?

//         movq   %rdx, %rdi       #  if so, do it
//         call   atexit

// skip_atexit:
//         movq   (%rsp), %rdi           #  load argc
//         leaq   8(%rsp), %rsi          #  calc argv (pointer to the array on the stack)
//         leaq   8(%rsp,%rdi,8), %rdx   #  calc envp (starts after the NULL terminator for argv[])
//         call   main

//         movl   %eax, %edi   # pass return value of main to exit
//         call   exit

//         hlt                 # should never get here

//--------------------------------------------------------------------------
https://dev.gentoo.org/~vapier/crt.txt

// crt0.o crt1.o etc...
//   Some systems use crt0.o, while some use crt1.o (and a few even use crt2.o
//   or higher).  Most likely due to a transitionary phase that some targets
//   went through.  The specific number is otherwise entirely arbitrary -- look
//   at the internal gcc port code to figure out what your target expects.  All
//   that matters is that whatever gcc has encoded, your C library better use
//   the same name.

//   This object is expected to contain the _start symbol which takes care of
//   bootstrapping the initial execution of the program.  What exactly that
//   entails is highly libc dependent and as such, the object is provided by
//   the C library and cannot be mixed with other ones.

//   On uClibc/glibc systems, this object initializes very early ABI requirements
//   (like the stack or frame pointer), setting up the argc/argv/env values, and
//   then passing pointers to the init/fini/main funcs to the internal libc main
//   which in turn does more general bootstrapping before finally calling the real
//   main function.

//   glibc ports call this file 'start.S' while uClibc ports call this crt0.S or
//   crt1.S (depending on what their gcc expects).

// crti.o
//   Defines the function prologs for the .init and .fini sections (with the _init
//   and _fini symbols respectively).  This way they can be called directly.  These
//   symbols also trigger the linker to generate DT_INIT/DT_FINI dynamic ELF tags.

//   These are to support the old style constructor/destructor system where all
//   .init/.fini sections get concatenated at link time.  Not to be confused with
//   newer prioritized constructor/destructor .init_array/.fini_array sections and
//   DT_INIT_ARRAY/DT_FINI_ARRAY ELF tags.

//   glibc ports used to call this 'initfini.c', but now use 'crti.S'.  uClibc
//   also uses 'crti.S'.

// crtn.o
//   Defines the function epilogs for the .init/.fini sections.  See crti.o.

//   glibc ports used to call this 'initfini.c', but now use 'crtn.S'.  uClibc
//   also uses 'crtn.S'.

.text
.global progname_
progname_:
    pushq    %rbp
    movq    %rsp, %rbp
    subq    $8, %rsp
    movq    %rdi, %rsi
    mov     $STDOUT_FD_, %rdi
    call    write_str_

    movq    $STDOUT_FD_, %rdi
    movb    $0x0A, -4(%rbp) # print '\n'
    leaq    -4(%rbp), %rsi
    mov     $1, %rdx
    call    write_

    addq    $8, %rsp
    popq    %rbp
    ret
