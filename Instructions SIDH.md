# Integration to the SIKE software in the SIDH library, version 3.4
# Paper "Efficient Algorithms for Large Prime Characteristic Fields and Their Application to Bilinear Pairings and Supersingular Isogeny-Based Protocols"

This library includes new efficient implementations of quadratic extension field arithmetic that speed up the SIKE protocol. 
The original SIDH library version 3.4 is available here: https://github.com/microsoft/PQCrypto-SIDH


## Contents

Our new implementations and modifications are available here:

* [`asm p377 folder`](SIDH_isogenies/src/P377/AMD64/): contains the assembly implementations of the quadratic extension field multiplication and squaring for p377
(file fp_x64_asm.S).
* [`asm p434 folder`](SIDH_isogenies/src/P434/AMD64/): contains the assembly implementations of the quadratic extension field multiplication and squaring for p434
(file fp_x64_asm.S).
* [`asm p503 folder`](SIDH_isogenies/src/P503/AMD64/): contains the assembly implementations of the quadratic extension field multiplication and squaring for p503
(file fp_x64_asm.S).
* [`asm p610 folder`](SIDH_isogenies/src/P610/AMD64/): contains the assembly implementations of the quadratic extension field multiplication and squaring for p610
(file fp_x64_asm.S).
* [`fpx folder`](SIDH_isogenies/src/): contains the modifications to the C implementations of the quadratic extension field multiplication and squaring
(file fpx.c).


## Instructions for Linux

IMPORTANT NOTE: the software requires a processor with support for MULX and ADX instructions (Intel Broadwell microarchitecture and later).

Compilation is done by executing the following for each prime pXXX in [p377, p434, p503, p610]:

```sh
$ cd SIDH_isogenies
$ make tests_pXXX 
```

Once compilation is complete, testing can be run by executing 

```sh
$ ./sike377/test_SIKE
$ ./sike434/test_SIKE
$ ./sike503/test_SIKE
$ ./sike610/test_SIKE
```
