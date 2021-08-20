//const path = require("path");
//
//const bigInt = require("big-integer");
//const Scalar = require("ffjavascript").Scalar;
//const tester = require("circom").tester;
//
//const { splitToArray } = require("./util.js");
//
//
//describe("montgomery reduction 64bits/4words", function () {
//    this.timeout(100000);
//
//    let circuit;
//    before(async () => {
//        circuit = await tester(path.join(__dirname, "circuits", "montgomery_64_4.circom"));
//    });
//
//    it("64bits/4words. and mod = 52435875175126190479447740508185965837690552500527637822603658699938581184513", async () => {
//
//        const modulus = splitToArray(bigInt("52435875175126190479447740508185965837690552500527637822603658699938581184513"), 64, 4);
//        const m0inv = "18446744069414584319";
//
//
//        var testCases = [{
//            description: "one word",
//            input: {
//                x: splitToArray(bigInt("1844674407370955161600"), 64, 4),
//                y: splitToArray(bigInt("100"), 64, 4),
//                // 52435875175126190479447740508185965837690552500527637822603658699938581184513
//                modulus: modulus,
//                m0inv: "18446744069414584319",
//            },
//            output: { out: [0, 0, 10000, 0] },
//        }, {
//            description: "two words",
//            input: {
//                x: splitToArray(bigInt("184467440737095516161561654"), 64, 4),
//                y: splitToArray(bigInt("184467440737095516161561654"), 64, 4),
//                // 52435875175126190479447740508185965837690552500527637822603658699938581184513
//                modulus: modulus,
//                m0inv: m0inv,
//            },
//            output: { out: [2438763215716, 31233080000000, 100000000000000, 0] },
//        }, {
//            description: "Four words",
//            input: {
//                x: ['9366702579560100036', '3153357315881433552', '1550162754830709279', '3363521531482743643'],
//                y: splitToArray(bigInt("12389174593798789739243342131821798678432796312321"), 64, 4),
//                // 52435875175126190479447740508185965837690552500527637822603658699938581184513
//                modulus: modulus,
//                m0inv: m0inv,
//            },
//            output: { out: ['11877590625878374308', '91176932193565308', '14825753355501141940', '4643043795916575606'] },
//        }
//        ]
//
//
//        for (var i = 0; i < testCases.length; i++) {
//            const witness = await circuit.calculateWitness(testCases[i].input, true);
//            await circuit.assertOut(witness, testCases[i].output);
//        }
//    });
//});
