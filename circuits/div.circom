pragma circom 2.0.0;

include "../circomlib/circuits/bitify.circom";

// constraint (a - remainder) % b = 0
template Divisible(w, n) {
    signal input a[n];
    // b == n / 2 * w bits
    signal input b[n];

    signal input remainder[n];

    signal out[n];
    // signal output divisible_res;
    
    var t[n + 1];
    t[0] = a[0];

    for (var i = 1; i < n; i++) {
        t[i] = a[i] + (t[i - 1] >> w);
    }

    // witness
    var lo_bit_var = (1 << w) - 1;
    // 0b1000000000000000000000000000000000000000000000000000000000000000
    var highest = 1 << (w - 1);

    for (var i = 0; i < n; i++) {
        t[i] = t[i] & lo_bit_var;
    }

    var t_b_rsh_c[n + 1];

    var c = n \ 2;
    // b << (w * c)
    for (var i = 0; i < n; i++) {
        if (i  < c) {
            t_b_rsh_c[i] = 0;
        } else {
            t_b_rsh_c[i] = b[i - c];
        }
    }
    t_b_rsh_c[n] = 0;

    var temp;
    // // rsh 1
    component normalizes[w * n];
    for (var i = 0; i < w * n; i++) {
        normalizes[i] = normalize(w, n);

        if (i == 0) {
            for (var j = 0; j < n; j++) {
                normalizes[i].a[j] <== a[j];
                normalizes[i].modulus[j] <== b[j];
            }
        } else {
            for (var j = 0; j < n; j++) {
                normalizes[i].a[j] <== normalizes[i - 1].out[j];
                normalizes[i].modulus[j] <== t_b_rsh_c[j];
            }
            // rsh 1
            for (var j = 0; j < n; j++) {
                if (t_b_rsh_c[j] != 0) {
                    t_b_rsh_c[j] = t_b_rsh_c[j] >> 1;
                }

                if ((t_b_rsh_c[j + 1] & 1) == 1) {
                    t_b_rsh_c[j] = t_b_rsh_c[j] ^ highest;
                }
            }
        }
    }

    for (var i = 0; i < n; i++) {
        normalizes[w * n - 1].out[i] === remainder[i];
    }
}


// a > modulus ? a - modulus : a;
template normalize(w, nb) {/*{{{*/
    signal input a[nb];
    signal input modulus[nb];

    signal output out[nb];
    signal output has_sub;

    var need_sub = 3;

    for (var i = nb - 1; i >= 0; i--) {
        if (need_sub == 3 && a[i] > modulus[i]) {
            need_sub = 1;
        }

        if (need_sub == 3 && a[i] < modulus[i]) {
            need_sub = 0;
        }
    }

    has_sub <-- need_sub;
    (has_sub) * (has_sub - 1) === 0;
    
    var borrow = 0;
    var temp = 0;

    var t[nb];
    // out = a
    for (var i = 0;i < nb; i++) {
        t[i] = a[i];
    }

    var carry_v = 1 << w;
    
    if (has_sub != 0) {
        for (var i = 0; i < nb; i++) {
            temp = a[i];

            if (temp < (modulus[i] + borrow)) {
                temp += (carry_v - borrow);
                borrow = 1;
            }else {
                temp = temp - borrow;
                borrow = 0;
            }

            t[i] = temp - modulus[i];
        }
    }

   for (var i = 0; i< nb; i++) {
        out[i] <-- t[i];
   }
}/*}}}*/

template div(w, n) {
    signal input a[2 * n];
    signal input b[n];


    signal output quotient[n];
    signal output remainder[n];

    component rshs[w * n];
    for (var i = 0; i < w * n; i++) {
        rshs[i] = rsh(w, 2 * n);

        if (i == 0) {
            for (var j = 0; j < 2 * n; j++) {
                if (j < n) {
                    rshs[i].a[j] <-- 0;
                } else {
                    rshs[i].a[j] <-- b[j - n];
                }
            }
        } else {
            for (var j = 0; j < 2 * n; j++) {
                rshs[i].a[j] <-- rshs[i - 1].out[j];
            }
        }
    }

    // init normalizes
    component normalizes[w * n];

    for (var i = 0; i < n * w; i++) {
        normalizes[i] = normalize(w, 2 * n) ;
    }
    
    // normalizes[0]
    for (var i = 0; i < 2 * n; i++) {
        normalizes[0].a[i] <== a[i];

        normalizes[0].modulus[i] <== rshs[0].out[i];
    }

    for (var i = 1; i < n * w; i++) {
        for (var j  = 0; j < 2 * n; j++) {
            normalizes[i].a[j] <-- normalizes[i - 1].out[j];
            normalizes[i].modulus[j] <-- rshs[i].out[j];
        }
    }

    for (var i = 0; i < n; i++) {
        remainder[i] <== normalizes[n * w - 1].out[i];
    }

    component bits2nums[n];
    for (var i = 0; i < n; i++) {
        bits2nums[i] = Bits2Num(w);

        var start_index = i * w;
        for (var j = 0; j < w; j++) {
            bits2nums[i].in[j] <== normalizes[start_index + w - 1 - j].has_sub;
        }

        quotient[n - i - 1] <== bits2nums[i].out;
    }
}

template rsh(w, n) {
    signal input a[n];
    
    signal output out[n];

    signal low_bits[n];
    for (var i = 0; i < n; i++) {
        low_bits[i] <-- a[i] & 1;

        low_bits[i] * (low_bits[i] - 1) === 0;
    }
    
    var highest = 1 << (w - 1);

    out[n - 1] <-- (a[n - 1] >> 1);

    out[n - 1] * 2 + low_bits[n - 1] === a[n - 1];

    for (var i = 0; i < n - 1; i++) {
        out[i] <== (a[i] - low_bits[i]) / 2 + highest * low_bits[i + 1];
    }
}

