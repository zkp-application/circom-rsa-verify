const path = require("path");

const bigInt = require("big-integer");
const Scalar = require("ffjavascript").Scalar;
const tester = require("circom").tester;

function print(circuit, w, s) {
    console.log(s + ": " + w[circuit.getSignalIdx(s)]);
}

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
    for (let i = n-1;i >=0;i--) {
        if(words[i] == '0') {
            continue;
        }

        words[end_index] = words[i];
        words[i] = '0';
        end_index--;
    }

    return words;
}

describe("big_int test", function () {

    this.timeout(100000);

    let circuit;
    before( async() => {
        circuit = await tester(path.join(__dirname, "circuits", "montgomery_reduction.circom"));
    });

    it("Should check variuos ege cases", async () => {
        const input = {
            x: splitToArray(bigInt("12356113212455744564564234654654654468464321564"), 64, 8),
            y: splitToArray(bigInt("12356113212455744564564234654654654468464321564"), 64, 8),
            // 52656145834278439889366339653259878764854242728404374413724460883
            modulus: splitToArray(bigInt("52435875175126190479447740508185965837690552500527637822603658699938581184513"), 64, 8),
            monty_prime:  splitToArray("18446744069414584319", 64, 8),
        }

        console.log(input);

        const witness = await circuit.calculateWitness (input, true);

        
        console.log({out: splitToArray(8, 64, 8)});

        await circuit.assertOut(witness, {out: splitToArray(8, 64, 8)});
    });
});

