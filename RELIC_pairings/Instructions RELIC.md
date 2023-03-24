## Implementation of the BLS12-381 and BLS24-509 pairing-friendly curves using the RELIC library (v0.5.0 and v0.6.0)

This library includes two efficient implementations of the extension field arithmetic that underlies the optimal ate pairings over BLS12-381 and BLS24-509.
These implementations are integrated to the [RELIC library](https://github.com/relic-toolkit/relic).


## Contents

The new implementations and modifications are available here (for BLS12-381):

* [`asm folder`](RELIC_pairings/relic-bls12-381/src/low/x64-asm-382/): contains the assembly implementations for extension field multiplication
(file relic_fpx_mul_low_asm.s) and squaring (file relic_fpx_sqr_low_asm.s).
* [`fp2 folder`](RELIC_pairings/relic-bls12-381/src/low/easy/): contains modifications to the C implementations of the GF(p^2) multiplication
(file relic_fpx_mul_low.c) and squaring (relic_fpx_sqr_low.c).
* [`fpx folder`](RELIC_pairings/relic-bls12-381/src/fpx/): contains modifications to the C implementations of the GF(p^6) multiplication
(relic_fp6_mul.c) and GF(p^12) multiplication (relic_fp12_mul.c).

And here (for BLS24-509):

* [`asm folder`](RELIC_pairings/relic-bls24-509/src/low/x64-asm-8l/): contains the assembly implementations for extension field multiplication
(file relic_fpx_mul_low_asm.s) and squaring (file relic_fpx_sqr_low_asm.s).
* [`fp2 folder`](RELIC_pairings/relic-bls24-509/src/low/easy/): contains modifications to the C implementations of the GF(p^2) multiplication
(file relic_fpx_mul_low.c) and squaring (relic_fpx_sqr_low.c).
* [`fpx folder`](RELIC_pairings/relic-bls24-509/src/fpx/): contains modifications to the C implementations of the GF(p^4) multiplication
(relic_fp4_mul.c) and the GF(p^8) multiplication (relic_fp8_mul.c).


## Instructions for Linux

IMPORTANT NOTE: the software requires a processor with support for MULX and ADX instructions (Intel Broadwell microarchitecture and later).

Compilation for BLS12-381 is done by executing:

```sh
$ cd RELIC_pairings
$ mkdir relic-target
$ cd relic-target
$ ../relic-bls12-381/preset/x64-pbc-bls12-381.sh ../relic-bls12-381/        [Make sure the .sh file has permission as executable]
$ make
```

Compilation for BLS24-509 is done by executing:

```sh
$ cd RELIC_pairings
$ mkdir relic-target
$ cd relic-target
$ ../relic-bls24-509/preset/x64-pbc-bls24-509.sh ../relic-bls24-509/        [Make sure the .sh file has permission as executable]
$ make
```

Once compilation is complete for one of the implementations, testing can be run by executing 

```sh
$ ./bin/test_fpx
$ ./bin/test_pp
```

Similarly, benchmarking can be run by executing 

```sh
$ ./bin/bench_fpx
$ ./bin/bench_pp
```

## License

All the new code is released under MIT license.
The RELIC library is under Apache-2.0 or LGPL-2.1 license.