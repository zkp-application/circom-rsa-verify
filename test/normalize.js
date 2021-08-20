//const path = require("path");
//
//const bigInt = require("big-integer");
//const Scalar = require("ffjavascript").Scalar;
//const tester = require("circom").tester;
//
//const { splitToArray } = require("./util.js");
//
//function print(circuit, w, s) {
//    console.log(s + ": " + w[circuit.getSignalIdx(s)]);
//}
//
//
//describe("normalize template test. a > modulus ? a - modulus : a", function () {
//
//    this.timeout(100000);
//
//    let circuit;
//    before(async () => {
//        circuit = await tester(path.join(__dirname, "circuits", "normalize.circom"));
//    });
//
//    it("normalize template test", async () => {
//        var testCases = [{
//            description: "One word. No need for sub",
//            input: {
//                a: splitToArray(bigInt("4"), 64, 8),
//                modulus: splitToArray(bigInt("5"), 64, 8),
//            },
//            output: { out: [4, 0, 0, 0, 0, 0, 0, 0] },
//        }, {
//            description: "Two word. Need for sub",
//            input: {
//                a: splitToArray(bigInt("45613215616541654654"), 64, 8),
//                modulus: splitToArray(bigInt("45613215616541654651"), 64, 8),
//            },
//            output: { out: [3, 0, 0, 0, 0, 0, 0, 0] },
//        }, {
//            description: "Three word. Need for sub",
//            input: {
//                a: splitToArray(bigInt("35165413564654612131346546516513054615640"), 64, 8),
//                modulus: splitToArray(bigInt("35165413564654612131346546516513054615636"), 64, 8),
//            },
//            output: { out: [4, 0, 0, 0, 0, 0, 0, 0] },
//        }, {
//            description: "Eight word. Need for sub",
//            input: {
//                a: splitToArray(bigInt("3516541356445124321613556156315611321654561563153615613213156315615615612316156123132123132165156465132165465465411651656546126513054615644"), 64, 8),
//                modulus: splitToArray(bigInt("3516541356445124321613556156311611321654561563153615613213156315615615612316156123132123132165156465132165465465411651656546126513054615640"), 64, 8),
//            },
//            output: { out: [0, 0, 4, '10967461361298178048', '9489550332887426220', '11036400390711386231', '16220791373695979585', '1872670541876'] },
//        }
//        ]
//
//        for (var i = 0; i < testCases.length; i++) {
//            const witness = await circuit.calculateWitness(testCases[i].input, true);
//            await circuit.assertOut(witness, testCases[i].output);
//        }
//    });
//});
