import path = require("path");
import { expect, assert } from 'chai';
const circom_tester = require('circom_tester');
const wasm_tester = circom_tester.wasm;

// TODO: Factor this out into some common code among all the tests
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

function bigint_to_array(n: number, k: number, x: bigint) {
    let mod: bigint = 1n;
    for (var idx = 0; idx < n; idx++) {
        mod = mod * 2n;
    }

    let ret: bigint[] = [];
    var x_temp: bigint = x;
    for (var idx = 0; idx < k; idx++) {
        ret.push(x_temp % mod);
        x_temp = x_temp / mod;
    }
    return ret;
}


describe("Power mod n = 64, k = 32, ", function () {
    this.timeout(1000 * 1000);

    // runs circom compilation
    let circuit: any;
    before(async function () {
        circuit = await wasm_tester(path.join(__dirname, "circuits", "pow_mod_64_32.circom"));
    });

    // a, e, m, (a ** e) % m
    let test_cases: Array<[bigint, bigint, bigint, bigint]> = [];
    let a = BigInt("27166015521685750287064830171899789431519297967327068200526003963687696216659347317736779094212876326032375924944649760206771585778103092909024744594654706678288864890801000499430246054971129440518072676833029702477408973737931913964693831642228421821166326489172152903376352031367604507095742732994611253344812562891520292463788291973539285729019102238815435155266782647328690908245946607690372534644849495733662205697837732960032720813567898672483741410294744324300408404611458008868294953357660121510817012895745326996024006347446775298357303082471522757091056219893320485806442481065207020262668955919408138704593");
    let e = BigInt(65537);
    let m = BigInt("27333278531038650284292446400685983964543820405055158402397263907659995327446166369388984969315774410223081038389734916442552953312548988147687296936649645550823280957757266695625382122565413076484125874545818286099364801140117875853249691189224238587206753225612046406534868213180954324992542640955526040556053150097561640564120642863954208763490114707326811013163227280580130702236406906684353048490731840275232065153721031968704703853746667518350717957685569289022049487955447803273805415754478723962939325870164033644600353029240991739641247820015852898600430315191986948597672794286676575642204004244219381500407");
    let result = (a ** e) % m;

    test_cases.push([a, e, m, result]);

    let test_bigsubmodp_32 = function (x: [bigint, bigint, bigint, bigint]) {
        const [a, b, p, result] = x;

        let a_array: bigint[] = bigint_to_array(64, 32, a);
        let b_array: bigint[] = bigint_to_array(64, 32, b);
        let p_array: bigint[] = bigint_to_array(64, 32, p);
        let result_array: bigint[] = bigint_to_array(64, 32, result);

        it('Testing a: ' + a + ' b: ' + b + ' p: ' + p, async function () {
            let witness = await circuit.calculateWitness({
                "base": a_array,
                "exp": b_array,
                "modulus": p_array
            });

            for (var i = 0; i < 32; i++) {
                expect(witness[i + 1]).to.equal(result_array[i]);
            }

            await circuit.checkConstraints(witness);
        });
    }

    test_cases.forEach(test_bigsubmodp_32);
});