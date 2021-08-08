

template mont_mul(w, nb) {
    signal input a[nb];
    signal input b[nb];
    signal input modulus[nb];

    signal input m0inv;

    signal output out [nb];

    component montPr = mont_pr_cios(w, nb);



}

// Montgomery modular multiplication. CIOS alg
// Souce paper from https://www.microsoft.com/en-us/research/wp-content/uploads/1998/06/97Acar.pdf
// (x * y) mod modulus
template mont_pr_cios(w, nb) {
    signal input x[nb];
    signal input y[nb];
    signal input modulus[nb];

    signal input m0inv;

    signal output out[nb];

    var temps[nb + 2];
    for (var i = 0; i < nb +2 ;i ++) {
        temps[i] = 0;
    }

    var temp = 0;
    // 0b1111111111111111111111111111111111111111111111111111111111111111
    var lo_64_bit_var = 18446744073709551615;
    for (var i = 0; i < nb; i++) {
        var C = 0;
        for (var j = 0; j < nb; j++) {
            temp = x[j] * y[i] + temps[j] + C;
            C = temp >> 64;
            temps[j] = temp & lo_64_bit_var;
        }

        temp = temps[nb] + C;

        temps[nb + 1] = temp >> 64;
        temps[nb] = temp & lo_64_bit_var;

        C = 0;

        var q = (temps[0] * m0inv) % (1 << 64);
        var temp = q * modulus[0] + temps[0];

        C = temp >> 64;

        for (var j = 1; j < nb; j++) {
            temp = q * modulus[j] + temps[j] + C;

            C = temp >> 64;
            temps[j - 1] = temp & lo_64_bit_var;
        }

        temp = temps[nb] + C;

        temps[nb - 1] = temp & lo_64_bit_var;
        temps[nb] = C + temps[nb + 1];
    }

    component normal = normalize(w, nb);
    for (var i = 0; i< nb; i++) {
        normal.a[i] <-- temps[i];
        normal.modulus[i] <-- modulus[i];
    }


    for (var i = 0; i < nb; i++) {
        out[i] <-- normal.out[i];
    }
}

// a > modulus ? a - modulus : a;
// 
template normalize(w, nb) {
    signal input a[nb];
    signal input modulus[nb];

    signal output out[nb];

    // check a greater than modulus
    var needSub = 2;
    for (var i = nb - 1; i >= 0; i--) {
        if(a[i] > modulus[i] && needSub == 2) {
            needSub = 1;
        }

        if (a[i] < modulus[i] && needSub == 2) {
            needSub = 0;
        }
    }

    var borrow = 0;
    var temp = 0;

    var t[nb];

    if (needSub == 0) {
        // out = a
        for (var i = 0;i < nb; i++) {
            out[i] <-- a[i];
        }
    } else {
         // out =  a - m;

        for (var i = 0; i< nb; i++) {
            temp = a[i];

            if(borrow == 1) {
                temp--;
            }

            if (((temp == 0) && (modulus[i] > 0 || borrow == 1)) || temp < modulus[i]) {
                borrow = 1;
                temp += 1 << (w + 1);
            } else {
                borrow = 0;
            }

            t[i]  = (temp - modulus[i]) & 18446744073709551615;
        }

        var last = nb - 1;
        var sign = 0;

        for (var i = nb - 1; i >= 0; i--) {
            if (t[i] != 0 || sign != 0) {
                t[last] = t[i];
                last --;
                if (last != i) {
                    t[i] = 0;
                }

                sign = 1;
            }
        }

        for (var i = 0; i< nb; i++) {
            out[i] <-- t[i];
        }
   }
}

// return a - b
function sub(a, b, nb, w) {
    var borrow = 0;
    var temp = 0;
    var out[nb];

    for (var i = 0; i< nb; i++) {
        temp = a[i];
        if (borrow == 1) {
            temp--;
        }
        
        if (((temp == 0) && (b[i] > 0 || borrow == 1)) || temp < b[i]) {
            borrow = 1;
            temp += 1 << (w + 1);
        }

        out[i] = temp - b[i];
    }

    return out;
}
