include "../circomlib/circuits/bitify.circom"
include "./mul.circom"
include "./sub.circom"
// montrygomery production alg. Currently 
// w = 64
// nb is the length of the number input 
template mont_mul(w, nb) {
    signal input pre_compute_a[nb];
    signal input b[nb];
    signal input modulus[nb];

    signal input m0inv;

    signal output out [nb];

    component montPr = mont_cios(w, nb);

    for (var i = 0; i < nb; i++) {
        montPr.x[i] <== pre_compute_a[i];
        montPr.y[i] <== b[i];
        montPr.modulus[i] <== modulus[i];

        montPr.m0inv <== m0inv;
    }

    for (var i = 0; i < nb; i++) {
        montPr.out[i] ==> out[i];
    }
}

// Montgomery modular multiplication. CIOS alg
// Souce paper from https://www.microsoft.com/en-us/research/wp-content/uploads/1998/06/97Acar.pdf
// (x * y) mod modulus
template mont_cios(w, nb) {
    signal input x_raw[nb];

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
    var lo_64_bit_var = (1 << w) - 1;

     // TODO: add constraint for (m0inv * modulus[0]) % (1 << w) ≡ -1

    // Witness computation
    var C = 0;
    for (var i = 0; i < nb; i++) {
        C = 0;

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

        C = temp >> 64;

        temps[nb - 1] = temp & lo_64_bit_var;
        temps[nb] = C + temps[nb + 1];
    }

    // verify
    component normal = normalize(w, nb);
    normal.a_carry <-- temps[nb];
     
    for (var i = 0; i < nb; i++) {
        normal.a[i] <-- temps[i];
        normal.modulus[i] <-- modulus[i];
    }

    for (var i = 0; i < nb; i++) {
        out[i] <== normal.out[i];
    }
    
    // Verify that the remainder and quotient are w-bits, n-chunks.
    component prodDecomp[nb];
    for (var i = 0; i < nb; i++) {
        prodDecomp[i] = Num2Bits(w);
        prodDecomp[i].in <== normal.out[i];
    }

    // TODO: constraints (x_raw * y) - out divisible modulus
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

