// Starting with the Intel Pentium processor, most Intel CPUs support out-of-order execution of the code.
// The purpose is to optimize the penalties due to the different instruction latencies. Unfortunately this
// feature does not guarantee that the temporal sequence of the single compiled C instructions will respect
// the sequence of the instruction themselves as written in the source C file. When we call the RDTSC instruction,
// we pretend that that instruction will be executed exactly at the beginning and at the end of code being measured
// (i.e., we don’t want to measure compiled code executed outside of the RDTSC calls or executed in between the 
// calls themselves). 
// The solution is to call a serializing instruction before calling the RDTSC one. A serializing instruction is an
// instruction that forces the CPU to complete every preceding instruction of the C code before continuing the
// program execution. By doing so we guarantee that only the code that is under measurement will be executed in 
// between the RDTSC calls and that no part of that code will be executed outside the calls. 
// The complete list of available serializing instructions on IA64 and IA32 can be found in the Intel® 64 and IA-32
// Architectures Software Developer’s Manual Volume 3A [4]. Reading this manual, we find that “CPUID can be executed
// at any privilege level to serialize instruction execution with no effect on program flow, except that the
// EAX, EBX, ECX and EDX registers are modified”. Accordingly, the natural choice to avoid out of order execution
// would be to call CPUID just before both RTDSC calls; this method works but there is a lot of variance (in terms of clock cycles)
// that is intrinsically associated with the CPUID instruction execution itself. This means that to guarantee serialization of
// instructions, we lose in terms of measurement resolution when using CPUID. A quantitative analysis about this is 
// presented in Section 3.1.2. An important consideration that we have to make is that the CPUID instruction overwrites
// EAX, EBX, ECX, and EDX registers. So we have to add EBX and ECX to the list of clobbered registers mentioned in Register Overwriting above.
// If we are using an IA64 rather than an IA32 platform, in the list of clobbered registers we have
// to replace "%eax", "%ebx", "%ecx", "%edx" with "%rax", "%rbx", "%rcx", "%rdx".
// In fact, in the Intel® 64 and IA-32 Architectures Software Developer’s Manual Volume 2A ([3]), it states that “On Intel 64 processors,
// CPUID clears the high 32 bits of the RAX/RBX/RCX/RDX registers in all modes”

//https://www.intel.com/content/dam/www/public/us/en/documents/white-papers/ia-32-ia-64-benchmark-code-execution-paper.pdf

.bss
perf_count: .space 8

.data
perf_error: 
    .asciz "RDTSC is too small\n"
    .set perf_error_len, .-perf_error
perf_result:
    .asciz "RDTSC ticks: \n"
    .set perf_result_len, .-perf_result

.text

.globl perf_start_
.globl perf_stop_

/////////////////////////////////////////////////////////////////////////////////////////
// void perf_start()
// get cpu ticks in begin
perf_start_:
    pushq   %rbp
    movq    %rsp, %rbp

    // get current timestamp 
    rdtsc
    cmp     $0x0fff, %rax
    jl .L1.perf_start_nop
    addq    %rax, perf_count
    jmp .L1.perf_start_exit

    .L1.perf_start_nop:
    movq    $1, %rax
    movq    $STDOUT_FD_, %rdi
    movq    $perf_error, %rsi
    movq    $perf_error_len, %rdx
    call    write_
    .L1.perf_start_exit:
    popq    %rbp
    retq

/////////////////////////////////////////////////////////////////////////////////////////
// void perf_stop()
// get cpu ticks in end and trace it
perf_stop_:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $32, %rsp

    // compute elapsed ticks
    rdtsc
    cmp     $0x0fff, %rax
    jl .L1.perf_stop_nop
    subq    perf_count, %rax
    movq    %rax, perf_count

    // trace result
    movq    $1, %rax
    movq    $STDOUT_FD_, %rdi
    movq    $perf_result, %rsi
    movq    $perf_result_len, %rdx
    call    write_

    leaq    -32(%rbp), %rdi
    mov     $0, %rsi
    mov     $24, %rdx
    call    memset_

    mov     perf_count, %rdi
    leaq    -32(%rbp), %rsi
    call    itoa_

    leaq    -32(%rbp), %rdi
    call    strlen_

    movq    %rax, %rdx
    movq    $STDOUT_FD_, %rdi
    lea     -32(%rbp), %rsi
    call    write_

    movq    $STDOUT_FD_, %rdi
    movb    $0x0A, -4(%rbp) # print '\n'
    leaq    -4(%rbp), %rsi
    mov     $1, %rdx
    call    write_

    jmp .L1.perf_stop_ret

    .L1.perf_stop_nop:
    movq    $1, %rax
    movq    $STDOUT_FD_, %rdi
    movq    $perf_error, %rsi
    movq    $perf_error_len, %rdx
    call    write_

    .L1.perf_stop_ret:
    addq    $32, %rsp
    popq    %rbp
    retq
