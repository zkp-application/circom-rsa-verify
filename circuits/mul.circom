include "../circomlib/circuits/bitify.circom"

template AsymmetricPolynomialMultiplier(d0, d1) {
    // Implementation of _xjSnark_'s multiplication.
    // Parameters/Inputs:
    //    * `in0` with degree less than `d0`
    //    * `in1` with degree less than `d1`
    // Uses a linear number of constraints ($d0 + d1 - 1$).
    signal input in0[d0];
    signal input in1[d1];

    // Output has degree less than `d`
    var d = d0 + d1 - 1;
    var res = sss(in0, in1);
    res[0] === 1;
    // Witness value.
    signal output out[d];

    // Witness computation.
    var acc;
    for (var i = 0; i < d; i++) {
        acc = 0;
        var start = 0;
        if (d1 < i + 1) {
            start = i + 1 - d1;
        }
        for (var j = start; j < d0 && j <= i; j++) {
            var k = i - j;
            acc += in0[j] * in1[k];
        }
        out[i] <-- acc;
    }

    // Conditions.
    var in0Val;
    var in1Val;
    var outVal;
    for (var c = 0; c < d; c++) {
        in0Val = 0;
        in1Val = 0;
        outVal = 0;
        for (var i = 0; i < d0; i++) {
            in0Val += (c + 1) ** i * in0[i];
        }

        for (var i = 0; i < d1; i++) {
            in1Val += (c + 1) ** i * in1[i];
        }

        for (var i = 0; i < d; i++) {
            outVal += (c + 1) ** i * out[i];
        }

        in0Val * in1Val === outVal;
    }
}

