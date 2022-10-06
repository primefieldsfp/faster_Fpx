# Integration to the SIKE software in the SIDH library, version 3.4
# Paper "Efficient Algorithms for Large Prime Characteristic Fields and Their Application to Bilinear Pairings"

This library includes new efficient implementations of the quadratic extension field arithmetic that underlies the SIKE protocol. 
The original SIDH library version 3.4 is available here: https://github.com/microsoft/PQCrypto-SIDH

WARNING: the SIDH and SIKE protocols have been recently shown to be insecure [1].
The software provided here is mainly intended for evaluating the speed performance and memory usage of the proposed method for different prime bitlengths.

## Contents

Our new implementations and modifications are available here:

* [`asm p377 folder`](SIKE_primes/src/P377/AMD64/): contains the assembly implementations of the quadratic extension field multiplication and squaring for p377
(file fp_x64_asm.S).
* [`asm p434 folder`](SIKE_primes/src/P434/AMD64/): contains the assembly implementations of the quadratic extension field multiplication and squaring for p434
(file fp_x64_asm.S).
* [`asm p503 folder`](SIKE_primes/src/P503/AMD64/): contains the assembly implementations of the quadratic extension field multiplication and squaring for p503
(file fp_x64_asm.S).
* [`asm p610 folder`](SIKE_primes/src/P610/AMD64/): contains the assembly implementations of the quadratic extension field multiplication and squaring for p610
(file fp_x64_asm.S).
* [`fpx folder`](SIKE_primes/src/): contains the modifications to the C implementations of the quadratic extension field multiplication and squaring
(file fpx.c).


## Instructions for Linux

IMPORTANT NOTE: the software requires a processor with support for MULX and ADX instructions (Intel Broadwell microarchitecture and later).

Compilation is done by executing the following for each prime pXXX in [p377, p434, p503, p610]:

```sh
$ cd SIKE_primes
$ make tests_pXXX 
```

Once compilation is complete, testing and benchmarking can be run by executing 

```sh
$ ./arith_tests-p377
$ ./arith_tests-p434
$ ./arith_tests-p503
$ ./arith_tests-p610
```

for the field operations, and

```sh
$ ./sike377/test_SIKE
$ ./sike434/test_SIKE
$ ./sike503/test_SIKE
$ ./sike610/test_SIKE
```

for the full protocol.

## References

[1] Wouter Castryck and Thomas Decru. An efficient key recovery attack on SIDH.
Cryptology ePrint Archive, Report 2022/975, 2022.
