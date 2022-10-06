####  Makefile for compilation on Unix-like operative systems  ####

OPT=-O3     # Optimization option by default

CC=clang
ifeq "$(CC)" "gcc"
    COMPILER=gcc
else ifeq "$(CC)" "clang"
    COMPILER=clang
endif

ARCHITECTURE=_AMD64_
USE_OPT_LEVEL=_FAST_
MULX=-D _MULX_
ADX=-D _ADX_

AR=ar rcs
RANLIB=ranlib
ADDITIONAL_SETTINGS=-march=native

CFLAGS=$(OPT) -std=gnu11 $(ADDITIONAL_SETTINGS) -D $(ARCHITECTURE) -D __NIX__ -D $(USE_OPT_LEVEL) $(MULX) $(ADX)
LDFLAGS=-lm

EXTRA_OBJECTS_377=objs377/fp_x64.o objs377/fp_x64_asm.o
EXTRA_OBJECTS_434=objs434/fp_x64.o objs434/fp_x64_asm.o
EXTRA_OBJECTS_503=objs503/fp_x64.o objs503/fp_x64_asm.o
EXTRA_OBJECTS_610=objs610/fp_x64.o objs610/fp_x64_asm.o
OBJECTS_377=objs377/P377.o $(EXTRA_OBJECTS_377) objs/random.o objs/fips202.o
OBJECTS_434=objs434/P434.o $(EXTRA_OBJECTS_434) objs/random.o objs/fips202.o
OBJECTS_503=objs503/P503.o $(EXTRA_OBJECTS_503) objs/random.o objs/fips202.o
OBJECTS_610=objs610/P610.o $(EXTRA_OBJECTS_610) objs/random.o objs/fips202.o

all: lib377 lib434 lib503 lib610 tests_p377 tests_p434 tests_p503 tests_p610

objs377/%.o: src/P377/%.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

objs434/%.o: src/P434/%.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

objs503/%.o: src/P503/%.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

objs610/%.o: src/P610/%.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@
	
objs377/fp_x64.o: src/P377/AMD64/fp_x64.c
	$(CC) -c $(CFLAGS) src/P377/AMD64/fp_x64.c -o objs377/fp_x64.o

objs377/fp_x64_asm.o: src/P377/AMD64/fp_x64_asm.S
	$(CC) -c $(CFLAGS) src/P377/AMD64/fp_x64_asm.S -o objs377/fp_x64_asm.o
			
objs434/fp_x64.o: src/P434/AMD64/fp_x64.c
	$(CC) -c $(CFLAGS) src/P434/AMD64/fp_x64.c -o objs434/fp_x64.o

objs434/fp_x64_asm.o: src/P434/AMD64/fp_x64_asm.S
	$(CC) -c $(CFLAGS) src/P434/AMD64/fp_x64_asm.S -o objs434/fp_x64_asm.o

objs503/fp_x64.o: src/P503/AMD64/fp_x64.c
	$(CC) -c $(CFLAGS) src/P503/AMD64/fp_x64.c -o objs503/fp_x64.o

objs503/fp_x64_asm.o: src/P503/AMD64/fp_x64_asm.S
	$(CC) -c $(CFLAGS) src/P503/AMD64/fp_x64_asm.S -o objs503/fp_x64_asm.o

objs610/fp_x64.o: src/P610/AMD64/fp_x64.c
	$(CC) -c $(CFLAGS) src/P610/AMD64/fp_x64.c -o objs610/fp_x64.o

objs610/fp_x64_asm.o: src/P610/AMD64/fp_x64_asm.S
	$(CC) -c $(CFLAGS) src/P610/AMD64/fp_x64_asm.S -o objs610/fp_x64_asm.o

objs/random.o: src/random/random.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) src/random/random.c -o objs/random.o

objs/fips202.o: src/sha3/fips202.c
	$(CC) -c $(CFLAGS) src/sha3/fips202.c -o objs/fips202.o

lib377: $(OBJECTS_377)
	rm -rf lib377 sike377
	mkdir lib377 sike377
	$(AR) lib377/libsidh.a $^
	$(RANLIB) lib377/libsidh.a

lib434: $(OBJECTS_434)
	rm -rf lib434 sike434
	mkdir lib434 sike434
	$(AR) lib434/libsidh.a $^
	$(RANLIB) lib434/libsidh.a

lib503: $(OBJECTS_503)
	rm -rf lib503 sike503
	mkdir lib503 sike503
	$(AR) lib503/libsidh.a $^
	$(RANLIB) lib503/libsidh.a

lib610: $(OBJECTS_610)
	rm -rf lib610 sike610
	mkdir lib610 sike610
	$(AR) lib610/libsidh.a $^
	$(RANLIB) lib610/libsidh.a

tests_p377: lib377
	$(CC) $(CFLAGS) -L./lib377 tests/arith_tests-p377.c tests/test_extras.c -lsidh $(LDFLAGS) -o arith_tests-p377 $(ARM_SETTING)
	$(CC) $(CFLAGS) -L./lib377 tests/test_SIKEp377.c tests/test_extras.c -lsidh $(LDFLAGS) -o sike377/test_SIKE $(ARM_SETTING)
tests_p434: lib434
	$(CC) $(CFLAGS) -L./lib434 tests/arith_tests-p434.c tests/test_extras.c -lsidh $(LDFLAGS) -o arith_tests-p434 $(ARM_SETTING)
	$(CC) $(CFLAGS) -L./lib434 tests/test_SIKEp434.c tests/test_extras.c -lsidh $(LDFLAGS) -o sike434/test_SIKE $(ARM_SETTING)
tests_p503: lib503
	$(CC) $(CFLAGS) -L./lib503 tests/arith_tests-p503.c tests/test_extras.c -lsidh $(LDFLAGS) -o arith_tests-p503 $(ARM_SETTING)
	$(CC) $(CFLAGS) -L./lib503 tests/test_SIKEp503.c tests/test_extras.c -lsidh $(LDFLAGS) -o sike503/test_SIKE $(ARM_SETTING)
tests_p610: lib610
	$(CC) $(CFLAGS) -L./lib610 tests/arith_tests-p610.c tests/test_extras.c -lsidh $(LDFLAGS) -o arith_tests-p610 $(ARM_SETTING)
	$(CC) $(CFLAGS) -L./lib610 tests/test_SIKEp610.c tests/test_extras.c -lsidh $(LDFLAGS) -o sike610/test_SIKE $(ARM_SETTING)

check: tests_p377 tests_p434 tests_p503 tests_p610

.PHONY: clean

clean:
	rm -rf *.req objs377* objs434* objs503* objs610* objs lib377* lib434* lib503* lib610* sike377* sike434* sike503* sike610* arith_tests-*

