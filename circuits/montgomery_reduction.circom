
// Montgomery modular multiplication. CIOS alg
// Souce paper from https://www.microsoft.com/en-us/research/wp-content/uploads/1998/06/97Acar.pdf
// (x * y) mod modulus
template Montgomery(w, nb) {
    signal input x[nb];
    signal input y[nb];
    signal input modulus[nb];

    signal input monty_prime[nb];

    signal output out[nb + 1];

    var temps[nb + 2];
    for (var i = 0; i < nb +2 ;i ++) {
        temps[i] = 0;
    }

    var temp = 0;
    var carry = 0;
    // 0b1111111111111111111111111111111111111111111111111111111111111111
    var lo_64_bit_var = 18446744073709551615;
    for (var i = 0; i< nb; i++) {
        for (var j = 0; j < nb; j++) {
            temp = temps[j] + x[j] * y[i] + carry;
            // t[j], carry = lo_bits, hi_bits
            temps[j] = temp & lo_64_bit_var;
            carry = temp >> 64;
        }

        temp = temps[nb] + carry;

        temps[nb] = temp & lo_64_bit_var;
        temps[nb + 1] = temp >> 64;

        var m = (temps[0] * monty_prime[0]) % (2 << 63);
        carry = loBitsNum(m);

        for (var k = 1; k < nb; k++) {
            temp = temps[k] + m * modulus[k] + carry;
            temps[k - 1] = temp & lo_64_bit_var;
            carry = temp >> 64;
        }

        temp = temps[nb] + carry;

        temps[nb - 1] = temp & lo_64_bit_var;
        temps[nb] = temp >> 64 + temps[nb + 1];
    }

    for (var i = 0; i < nb + 1; i++) {
        temps[i] --> out[i];
    }
}
