const bigInt = require("big-integer");


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
