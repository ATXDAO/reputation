const { ethers }  = require("ethers");
require("dotenv").config();
const { abi } = require("./abi.js");

async function main() {
    const providerURL = process.env.URL_MUMBAI;
    const provider = ethers.providers.getDefaultProvider(providerURL);
    const contractAddress = "0xc58d4F1F78F71931A21488F7EEC1dFF30eF2E3b1";

    const adminWallet = new ethers.Wallet(process.env.adminKey, provider);
    const distributorWallet = new ethers.Wallet(process.env.distributorKey, provider);
    // const burnerWallet = new ethers.Wallet(process.env.burnerKey, provider);

    // const contract = new ethers.Contract(contractAddress, abi, adminWallet);
    // await setupDistribsAndBurners(contract, ["0xCe1716BA43A9926A772c5d701bcF5DB4d5B717B6"], ["0x9486038cc385997a62FB8f1f8a22a55186e241E8"]);
    
    const contract = new ethers.Contract(contractAddress, abi, distributorWallet);
    console.log("distrubutiing...");
    await contract.distribute("0x2D40964D0C19c960a894B7C6893290Ba268eD8A8", 400, []);
    console.log("distrubuted!");
}

async function setupDistribsAndBurners(contract, distribs, burners) {
    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();

    for (let i = 0; i < distribs.length; i++) {
        console.log("starting tx...");
        let tx = await contract.grantRole(DISTRIBUTOR_ROLE, distribs[i]);
        tx.wait();
        console.log("finished tx!");
    }

    for (let i = 0; i < burners.length; i++) {
        console.log("starting tx...");
        let tx = await contract.grantRole(BURNER_ROLE, burners[i]);
        tx.wait();
        console.log("finished tx!");
    }
}


main();