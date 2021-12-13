pragma circom 2.0.0;

include "../circomlib/circuits/bitify.circom";


template Sub(w, n1, n2) {
    signal input x[n1];
    signal input y[n2];

    signal output out[n1];

    // assert n1 >= n2

    // Witness computation
    var borrow = 0;
    var temp = 0;
    var carry_v = 1 << w;

    var t[n1];
    // out = a
    for (var i = 0;i < n1; i++) {
        t[i] = x[i];
    }

    
    for (var i = 0; i < n1; i++) {
        if (i < n2) {
            temp = y[i];
        } else {
            temp = 0;
        }

        if (x[i] < (temp + borrow)) {
            t[i] = x[i] - temp - borrow + carry_v;
            borrow = 1;
        } else {
            t[i] = x[i] - temp - borrow;
            borrow = 0;
        }
    }

    for (var i = 0; i < n1; i++) {
        out[i] <== t[i];
    }

    // Constraints conditions
    // TODO: x + y === out
}
