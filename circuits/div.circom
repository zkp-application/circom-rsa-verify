include "./sub.circom"

template divisible(w, n) {
    signal input a[n];
    // b == n / 2 * w bits
    signal input b[n];

    // signal output divisible_res;
    
    var t[n];
    t[0] = a[0];

    for (var i = 1; i < n; i++) {
        t[i] = a[i] + (t[i - 1] >> w);
    }


    var lo_bit_var = (1 << w) - 1;
    // 0b1000000000000000000000000000000000000000000000000000000000000000
    var highest = 1 << (w - 1);

    for (var i = 0; i < n; i++) {
        t[i] = t[i] & lo_bit_var;
    }

    var t_b_lsh_c[n];

    var c = n / 2;
    for (var i = 0; i < c; i++) {
            t_b_lsh_c[i] = 0;
    }
    // b << (w * c)
    for (var i = c; i < n; i++) {
        t_b_lsh_c[i] = b[c - i];
    }

    // rsh 1
    for (var i = 0; i < n - 1; i++) {
        t_b_lsh_c[i] = t_b_lsh_c[i] >> 1;
        if ((t_b_lsh_c[i + 1] & 1) == 1) {
            t_b_lsh_c[i] = t_b_lsh_c[i] ^ highest;
        }
    }

    t_b_lsh_c[n - 1] =  t_b_lsh_c[n - 1] >> 1;

    var normalizes[w * n];
    component normalizes = normalize(w, n);
    for (var i = 0; i < w * n; i++) {
        normalizes[i] = normalize(w, n);
    }

    for (var i = 0; i < n; i++) {
        normalizes[0].a[i] <== a[i];
        normalizes[0].modulus[i] <== t_b_lsh_c[i];
        normalizes.a_carry <== 0;
    }

    for (var i = 1; i < n; i++) {
        // rsh 1
        for (var i = 0; i < n - 1; i++) {
            t_b_lsh_c[i] = t_b_lsh_c[i] >> 1;
            if ((t_b_lsh_c[i + 1] & 1) == 1) {
                t_b_lsh_c[i] = t_b_lsh_c[i] ^ highest;
            }
        }

        t_b_lsh_c[n - 1] =  t_b_lsh_c[n - 1] >> 1;
        
        for (j = 0; j < n; j++) {
             normalizes[i].a[j] <== normalizes[i - 1].out[j];
             normalizes[i].modulus[j] <== t_b_lsh_c[j];
             normalizes.a_carry <== 0;
        }
    }

    for (var i = 0; i < n; i++) {
        normalizes.out[i] === 0;
    }
}
