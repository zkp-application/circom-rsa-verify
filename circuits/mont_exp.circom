include "./montgomery.circom"
// r = 2 ^ (n * w). n is the modulus word count
// p_a = a * r mod modulus
// p_A = r mod modulus
// output A = (a ^ e) mod(p)
template mont_exp(w, nb) {
    signal input p_a[nb];
    signal input p_A[nb];
    signal input exp;
    signal input p[nb];

    signal input m0ninv;

    signal output out[nb];

    // 0b10000000000000001
    exp === 65537;

    var e_bits = 17;

    component montPrs[19];

    for (var i = 0; i < e_bits + 2 ; i++) {
        montPrs[i] = mont_cios(w, nb);
        montPrs[i].m0inv <== m0ninv;

        for (var j = 0; j < nb; j++) {
            montPrs[i].modulus[j] <== p[j];
        }
    }

    var mont_index = 0;
    for (var i = 0; i < e_bits; i++) {
        if (i == 0) {
            for (var j = 0; j < nb; j++) {
                montPrs[mont_index].x[j] <== p_A[j];
                montPrs[mont_index].y[j] <== p_A[j];
            }
        } else {
            for (var j = 0; j < nb; j++) {
                montPrs[mont_index - 1].out[j] ==> montPrs[mont_index].x[j];
                montPrs[mont_index - 1].out[j] ==> montPrs[mont_index].y[j];
            }
        }

        mont_index ++;

        if (i == 0 || i == (e_bits - 1)) {
            for (var j = 0; j < nb; j++) {
                montPrs[mont_index - 1].out[j] ==> montPrs[mont_index].x[j];
                montPrs[mont_index].y[j] <== p_a[j];
            }

            mont_index ++;
        }
    }

    component resultMontPr = mont_cios(w, nb);

    resultMontPr.m0inv <== m0ninv;

    for (var i = 0; i < nb; i++) {
        resultMontPr.modulus[i] <== p[i];
        montPrs[mont_index - 1].out[i] ==> resultMontPr.x[i];
        var t = 0;
        if (i == 0) {
            t = 1;
        }

        resultMontPr.y[i] <== t;
    }

    for (var i = 0; i < nb; i ++) {
        resultMontPr.out[i] ==> out[i];
    }
}
