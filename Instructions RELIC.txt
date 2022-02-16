# Integration to the BLS12-381 pairing software in the RELIC library, version 0.5.0
# Paper "Efficient Algorithms for Large Prime Characteristic Fields and Their Application to Bilinear Pairings and Supersingular Isogeny-Based Protocols"

This library includes new efficient implementations of extension field arithmetic that speed up the optimal ate pairing over BLS12-381. 
The original RELIC library version 0.5.0 is available here: https://github.com/relic-toolkit/relic


## Contents

Our new implementations and modifications are available here:

* [`asm folder`](RELIC_pairings/relic/src/low/x64-asm-382/): contains the assembly implementations for extension field multiplication
(file relic_fpx_mul_low_asm.s) and squaring (file relic_fpx_sqr_low_asm.s).
* [`fp2 folder`](RELIC_pairings/relic/src/low/easy/): contains modifications to the C implementations of the GF(p^2) multiplication
(file relic_fpx_mul_low.c) and squaring (relic_fpx_sqr_low.c).
* [`fpx folder`](RELIC_pairings/relic/src/fpx/): contains modifications to the C implementations of the GF(p^6) multiplication
(relic_fp6_mul.c) and GF(p^12) multiplication (relic_fp12_mul.c).


## Instructions for Linux

IMPORTANT NOTE: the software requires a processor with support for MULX and ADX instructions (Intel Broadwell microarchitecture and later).

Compilation is done by executing:

```sh
$ cd RELIC_pairings
$ mkdir relic-target
$ cd relic-target
$ ../relic/preset/x64-pbc-bls12-381.sh ../relic/
$ make
```

Once compilation is complete, testing can be run by executing 

```sh
$ ./bin/test_fpx
$ ./bin/test_pp
```

Similarly, benchmarking can be run by executing 

```sh
$ ./bin/bench_fpx
$ ./bin/bench_pp
```

Relevant results to observe correspond to fp2_mul, fp2_sqr, fp6_mul, fp12_mul, pp_map_oatep_k12 (full optimal ate pairing) and
pp_map_sim_oatep_k12 (2 pairings computed simultaneously).
