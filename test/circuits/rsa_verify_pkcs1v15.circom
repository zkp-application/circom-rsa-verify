pragma circom 2.0.0;

include "../../circuits/rsa_verify.circom";

component main{public [exp, sign, modulus, hashed]} = RsaVerifyPkcs1v15(64, 32, 17, 4);
