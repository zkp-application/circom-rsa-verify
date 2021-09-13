const path = require("path");

const bigInt = require("big-integer");
const Scalar = require("ffjavascript").Scalar;
const tester = require("circom").tester;

const { splitToArray } = require("./util.js");


describe("Divisible. 64bits / 64chunks", function () {
    this.timeout(100000);

    let circuit;
    before(async () => {
        circuit = await tester(path.join(__dirname, "circuits", "div.circom"));
    });

    it("64bits/32words. Montgomery exponent", async () => {

        var modulus = bigInt("27333278531038650284292446400685983964543820405055158402397263907659995327446166369388984969315774410223081038389734916442552953312548988147687296936649645550823280957757266695625382122565413076484125874545818286099364801140117875853249691189224238587206753225612046406534868213180954324992542640955526040556053150097561640564120642863954208763490114707326811013163227280580130702236406906684353048490731840275232065153721031968704703853746667518350717957685569289022049487955447803273805415754478723962939325870164033644600353029240991739641247820015852898600430315191986948597672794286676575642204004244219381500407");
        var m_shift_2048 = modulus.shiftLeft(bigInt(2048));        
        var testCases = [{
            description: "calc powerMod",
            input: {
                // 1844674407370955161600
                a: splitToArray(modulus.multiply(modulus), 64, 64),
                b: splitToArray(modulus, 64, 64),
                remainder: splitToArray(bigInt(0), 64, 64),
            },
            output: { out: splitToArray(bigInt(0), 64, 64) },
        }];

        for (var i = 0; i < testCases.length; i++) {
           const witness = await circuit.calculateWitness(testCases[i].input, true);

           await circuit.assertOut(witness, testCases[i].output);
        }
    });
});

