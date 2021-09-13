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

    var t_b_lsh_c[n + 1];

    var c = n \ 2;
    // b << (w * c)
    for (var i = 0; i < n; i++) {
        if (i  < c) {
            t_b_lsh_c[i] = 0;
        } else {
            t_b_lsh_c[i] = b[i - c];
        }
    }
    t_b_lsh_c[n] = 0;

    var temp;
    // // rsh 1
    component normalizes[w * n];
    for (var i = 0; i < w * n; i++) {
        normalizes[i] = normalize(w, n);
        normalizes[i].a_carry <== 0;

        if (i == 0) {
            for (var j = 0; j < n; j++) {
                normalizes[i].a[j] <== a[j];
                normalizes[i].modulus[j] <-- b[j];
            }
        } else {
            for (var j = 0; j < n; j++) {
                normalizes[i].a[j] <-- normalizes[i - 1].out[j];
                normalizes[i].modulus[j] <-- t_b_lsh_c[j];
            }
            // rsh 1
            for (var j = 0; j < n; j++) {
                if (t_b_lsh_c[j] != 0) {
                    t_b_lsh_c[j] = t_b_lsh_c[j] >> 1;
                }

                if ((t_b_lsh_c[j + 1] & 1) == 1) {
                    t_b_lsh_c[j] = t_b_lsh_c[j] ^ highest;
                }
            }
        }
    }

    for (var i = 0; i < n; i++) {
        normalizes[w * n - 1].out[i] === remainder[i];
    }
}



// a > modulus ? a - modulus : a;
template normalize(w, nb) {
    signal input a[nb];
    signal input modulus[nb];
    signal input a_carry;


    signal output out[nb];
    signal output has_sub;

    // check a greater than modulus
    var needSub = 2;
    if (a_carry == 1) {
        needSub = 1;
    }else {
        for (var i = nb - 1; i >= 0; i--) {
            if(a[i] > modulus[i] && needSub == 2) {
                needSub = 1;
            }

            if (a[i] < modulus[i] && needSub == 2) {
                needSub = 0;
            }
        }
    }

    has_sub <== 1;

    var borrow = 0;
    var temp = 0;

    var t[nb];
    // out = a
    for (var i = 0;i < nb; i++) {
        t[i] = a[i];
    }

    var carry_v = 1 << w;
    
    if (needSub != 0) {
        for (var i = 0; i < nb; i++) {
            temp = a[i];
            if (i == nb - 1 && a_carry == 1) {
                temp += carry_v;
            }

            if (temp < (modulus[i] + borrow)) {
                temp += (carry_v - borrow);
                borrow = 1;
            }else {
                temp = temp - borrow;
                borrow = 0
            }

            t[i] = temp - modulus[i];
        }
    }

   for (var i = 0; i< nb; i++) {
        out[i] <== t[i];
   }


//   // TODO: conditions
//   if (has_sub == 1) {
//       // out + modulus = a
//   }else {
//       // out == a
//   }
}

