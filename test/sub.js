// const path = require("path");

const bigInt = require("big-integer");
const Scalar = require("ffjavascript").Scalar;
const tester = require("circom").tester;

const { splitToArray } = require("./util.js");


describe("big int sub test", function () {
    this.timeout(100000);

    let circuit;
    before(async () => {
        circuit = await tester(path.join(__dirname, "circuits", "sub.circom"));
    });

    it("64bits/1words. Polynomial Multiplier", async () => {

        const x = bigInt("1");

        const y = bigInt("1");

        const result = x.multiply(y);
        var testCases = [{
            description: "calc powerMod",
            input: {
                // 1844674407370955161600
                x: splitToArray(x, 64, 32),
                y: splitToArray(y, 64, 32),

            },
            output: { out: splitToArray(x.subtract(y), 64, 1) },
        }];


        for (var i = 0; i < testCases.length; i++) {
            const witness = await circuit.calculateWitness(testCases[i].input, true);

            await circuit.assertOut(witness, testCases[i].output);
        }
    });
});

