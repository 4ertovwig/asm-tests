BUILD_DIR= build
BUILD_OBJ_DIR= obj

BINUTILS= as ldd
$(foreach exec,$(BINUTILS),\
    $(if $(shell which $(exec)),,$(error "No binary $(exec), install binutils...")))

CRT_PATH= /usr/lib/x86_64-linux-gnu

ASM_FLAGS= --64 --gstabs+
# readelf -a $(BUILD_DIR)/$binary | grep interpreter
LDFLAGS= -m elf_x86_64 -dynamic-linker /lib64/ld-linux-x86-64.so.2

SOURCES= 	string_algo.s syscall.s stack.s perf_rdtsc.s client.s net_algo.s server.s libc_progname.s \
			test_rpn.s test_perf.s test_clone.s test_malloc.s test_mems.s test_random.s test_string.s test_chain.s
OBJECTS= $(SOURCES:.s=.o)
EXECUTABLES= client server
TESTS= test_malloc test_mems test_random test_string test_chain test_clone test_perf test_rpn

all: create_build_directory $(EXECUTABLES) $(TESTS)

create_build_directory:
	@mkdir -p ${BUILD_DIR}
	@mkdir -p ${BUILD_DIR}/${BUILD_OBJ_DIR}

# compile with glibc
client.o: client.s
	as $(ASM_FLAGS) $< string_algo.s random.s digits_algo.s syscall.s net_algo.s -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

server.o: server.s
	as $(ASM_FLAGS) $< string_algo.s syscall.s net_algo.s -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

libc_progname.o: libc_progname.s
	as $(ASM_FLAGS) $< syscall.s -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

test_clone.o: test_clone.s
	as $(ASM_FLAGS) $< syscall.s libc_progname.s concurrency.s string_algo.s -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

test_perf.o: test_perf.s
	as $(ASM_FLAGS) $< perf_rdtsc.s syscall.s net_algo.s string_algo.s digits_algo.s libc_progname.s \
		 -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

test_rpn.o: test_rpn.s
	as $(ASM_FLAGS) $< digits_algo.s syscall.s stack.s string_algo.s libc_progname.s -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

test_random.o: test_random.s
	as $(ASM_FLAGS) $< libc_progname.s digits_algo.s string_algo.s syscall.s random.s -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

test_%.o: test_%.s
	as $(ASM_FLAGS) $< syscall.s string_algo.s libc_progname.s digits_algo.s -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

%.o: %.s
	as $(ASM_FLAGS) $< -o ${BUILD_DIR}/${BUILD_OBJ_DIR}/$@

%: %.o
	ld $(LDFLAGS) -o ${BUILD_DIR}/$@ ${CRT_PATH}/crt1.o ${CRT_PATH}/crti.o \
		-lc ${BUILD_DIR}/${BUILD_OBJ_DIR}/$< ${CRT_PATH}/crtn.o

test:
# @killall server client
	@echo "START TESTS"
	@echo "==============================================="
	@echo "All auto tests:"
	@find ${BUILD_DIR} -name 'test_*' -type f -executable
	@$(foreach var,$(TESTS),./${BUILD_DIR}/$(var);)
	@echo "==============================================="
	@echo "START NETWORK TEST"
	@echo "Run server:"
	@./${BUILD_DIR}/server &
	@sleep 1
	@echo "Run client:"
	@./${BUILD_DIR}/client
	@echo "\n	END TESTS"
	@echo "==============================================="

clean:
	@rm -f ${BUILD_DIR}/${BUILD_OBJ_DIR}/*.o 2> /dev/null
	@find ${BUILD_DIR} -type f -delete
	@echo "Remove binary and object files"

.INTERMEDIATE: $(OBJECTS)
