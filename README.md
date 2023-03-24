# Efficient algorithms for extension fields of large prime characteristic with applications to bilinear pairings and supensingular isogeny-based protocols

This library includes efficient implementations of the extension field arithmetic that underlies many cryptographic protocols, including pairing-based and supersingular isogeny-based schemes. 

For more information about the algorithms refer to the paper by P. Longa, "Efficient Algorithms for Large Prime Characteristic Fields and Their Application to Bilinear Pairings", CHES 2023.
The preprint is available [here](https://eprint.iacr.org/2022/367).

## Contents

The new implementations are applied to two settings:

* [`Pairings`](RELIC_pairings/): contains implementations for the BLS12-381 and BLS24-509 pairing-friendly curves, which are integrated to [RELIC](https://github.com/relic-toolkit/relic).
* [`Isogenies`](SIKE_primes/): contains implementations of the quadratic extension field multiplication and squaring for the SIKE primes, which are integrated to [SIDH Library](https://github.com/microsoft/PQCrypto-SIDH).

