const RsaVerify = artifacts.require("../contracts/sign.sol");

contract("SolRsaVerify-openssl", (accounts) => {
    let v

    beforeEach(async () => {
        v = await RsaVerify.new();
    });

    
})