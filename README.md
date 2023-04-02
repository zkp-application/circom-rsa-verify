# circom-rsa-verify

This repository contains an implementation of a Zero Knowledge Proof for RSA signature verify for the [Circom](https://docs.circom.io) language.
Currently supported pkcs1v15 + sha256 and exponent is 65537. The Montgomery Exponentiation algorithm and Montgomery CIOS product is used to calculate large numbers  [Modular exponentiation](https://en.wikipedia.org/wiki/Modular_exponentiation)

# Getting started

Running circuits test cases

```sh
git submodule update --init --recursive; npm i; npm test
```

## Circuits Benchmark

RSA verify: pkcs1v15/sha256/2048 bits key

* Env: Mac mini (M1, 2020). 8 cores. 8 threads

Circuit infomation

* Curve: bn-128
* Wires: 103
* Constraints: 65
* Public Inputs: 102
* Memory consumption: 120M+
* Time consumption: 40ms

## Ref

1. [Montgomery modular multiplication](https://en.wikipedia.org/wiki/Montgomery_modular_multiplication)

2. [Arithmetic of Finite Fields](https://www.researchgate.net/publication/319538235_Arithmetic_of_Finite_Fields)
