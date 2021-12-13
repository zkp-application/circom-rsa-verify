const path = require("path");

const bigInt = require("big-integer");
const Scalar = require("ffjavascript").Scalar;
const wasm_tester = require("circom_tester").wasm;

const { splitToArray } = require("./util.js");


describe("Rsh bignumber", function () {
    this.timeout(100000);

    let circuit;
    before(async () => {
        circuit = await wasm_tester(path.join(__dirname, "circuits", "rsh.circom"));
    });

    it("64bits/64words. bignumber left shift", async () => {

        const x = bigInt("27166015521685750287064830171899789431519297967327068200526003963687696216659347317736779094212876326032375924944649760206771585778103092909024744594654706678288864890801000499430246054971129440518072676833029702477408973737931913964693831642228421821166326489172152903376352031367604507095742732994611253344812562891520292463788291973539285729019102238815435155266782647328690908245946607690372534644849495733662205697837732960032720813567898672483741410294744324300408404611458008868294953357660121510817012895745326996024006347446775298357303082471522757091056219893320485806442481065207020262668955919408138704593").shiftLeft(32 * 64);

        const result = x;
        var testCases = [{
            description: "Right shift 1",
            input: {
                // 1844674407370955161600
                a: splitToArray(x, 64, 64),
            },
            output: { out: splitToArray(result.shiftRight(1), 64, 64)},
        }];


        for (var i = 0; i < testCases.length; i++) {
            const witness = await circuit.calculateWitness(testCases[i].input, true);

            await circuit.assertOut(witness, testCases[i].output);
        }
    });
});
