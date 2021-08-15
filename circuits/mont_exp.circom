include "./montgomery.circom"
// r = 2 ^ (n * w). n is the modulus word count
// p_a = a * r mod modulus
// p_A = r mod modulus
// output A = (a ^ e) mod(p)
template mont_exp(w, nb) {
    signal input p_a[nb];
    signal input p_A[nb];

    signal input exp;
    signal input m0inv;
    signal input modulus[nb];


    signal output out[nb];

    exp === 65537;
    
    component muls[19];
    for (var i = 0; i< 19; i++) {
        muls[i] = mont_cios(w, nb);

        muls[i].m0inv <-- m0inv;

        for (var j = 0; j < nb; j++) {
            muls[i].modulus[j] <-- modulus[j];
        }

        if (i == 0) {
            for (var j = 0; j < nb; j++) {
                muls[i].x[j] <-- p_A[j];
                muls[i].y[j] <-- p_A[j];
            }
        } else if (i == 1 || i == 18) {
            for (var j = 0; j < nb; j++) {
                muls[i].x[j] <-- muls[i - 1].out[j];
                muls[i].y[j] <-- p_a[j];
            }
        } else {
            for (var j = 0; j < nb; j++) {
                muls[i].x[j] <-- muls[i - 1].out[j];
                muls[i].y[j] <-- muls[i - 1].out[j];
            } 
        }
    }

    // A <- MontPr(p_A, 1);
    component result_mul = mont_cios(w, nb);

    result_mul.m0inv <-- m0inv;

    for (var j = 0; j < nb; j++) {
        result_mul.modulus[j] <-- modulus[j];
        result_mul.x[j] <-- muls[18].out[j];

        if (j == 0) {
            result_mul.y[j] <-- 1;
        }else {
            result_mul.y[j] <-- 0;
        }
    }


    for (var i = 0; i< nb; i++) {
        out[i] <-- result_mul.out[i];
    }
}
