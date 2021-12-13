pragma circom 2.0.0;

include "../../circuits/rsa_verify.circom";

component main = RsaVerifyPkcs1v15(64, 32, 4);
