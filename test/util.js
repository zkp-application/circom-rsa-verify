const bigInt = require("big-integer");
const chai = require("chai");
const snarkjs = require("snarkjs");

const assert = chai.assert;

function splitToArray(x, w, n) {
    let t = bigInt(x);
    w = bigInt(w);
    n = bigInt(n);
    var words = new Array(w);
    for (let i = 0; i < n; ++i) {
        // words[`${name}[${i}]`] = `${t.mod(bigInt(2).pow(w))}`;
        words[i] = `${t.mod(bigInt(2).pow(w))}`;
        t = t.divide(bigInt(2).pow(w));
    }
    if (!t.isZero()) {
        throw `Number ${x} does not fit in ${w * n} bits`;
    }

    let end_index = n - 1;
    for (let i = n - 1; i >= 0; i--) {
        if (words[i] == '0') {
            continue;
        }

        words[end_index] = words[i];
        if (end_index != i) {
            words[i] = '0'; 
        }
        
        end_index--;
    }

    return words;
}



const extractExpr = (f) => {
    const src = f.toString();
    const re = /.*=> *\((.*)\)/;
    return src.match(re)[1];
};

module.exports = {
    extractExpr,
    splitToArray,
};
