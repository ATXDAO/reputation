const { ethers }  = require("ethers");
require("dotenv").config();
const { abi } = require("./abi.js");

async function main() {
    const providerURL = process.env.URL_MUMBAI;
    const provider = ethers.providers.getDefaultProvider(providerURL);

    const adminPublicKey = "0xf1dd420F930a5CbC5363D24dC1a8cdC560b786E6";
    const adminWallet = new ethers.Wallet(process.env.adminKey, provider);

    const distributorPublicKey = "0xCe1716BA43A9926A772c5d701bcF5DB4d5B717B6";
    const distributorWallet = new ethers.Wallet(process.env.distributorKey, provider);

    const minterPublicKey = "0xE4D3081957cc1126e97B71FbDc0044edb2A1387A";
    const minterWallet = new ethers.Wallet(process.env.minterKey, provider);
    
    const burnerPublicKey = "0x9486038cc385997a62FB8f1f8a22a55186e241E8";
    // const burnerWallet = new ethers.Wallet(process.env.burnerKey, provider);

    const contractAddress = "0x89124e02C3926dA65B106C425a1A2Cd29FeBCC4e";

    // const adminContract = new ethers.Contract(contractAddress, abi, adminWallet);
    // await setupDistribsAndBurnersAndMinters(
    //     adminContract,
    //     [distributorPublicKey],
    //     [burnerPublicKey], 
    //     [minterPublicKey]
    //     );
    
    const minterContract = new ethers.Contract(contractAddress, abi, minterWallet);
    await mint(minterContract, distributorPublicKey, 350);

    // const distributorContract = new ethers.Contract(contractAddress, abi, distributorWallet);
    // console.log("distrubutiing...");
    // await distributorContract.transferFromDistributor("0xCe1716BA43A9926A772c5d701bcF5DB4d5B717B6", "0x2D40964D0C19c960a894B7C6893290Ba268eD8A8", 170, []);
    // console.log("distrubuted!");
}

async function mint(contract, to, amount) {
    console.log("minting...");
    await contract.mint(to, amount, []);
    console.log("minted!");
}

async function grantMinterRole(contract, address) {
    let MINTER_ROLE = await contract.MINTER_ROLE();
    console.log("starting tx...");
    let tx = await contract.grantRole(MINTER_ROLE, address);
    await tx.wait();
    console.log("finished tx!");
}

async function grantBurnerRole(contract, address) {
    let BURNER_ROLE = await contract.BURNER_ROLE();
    console.log("starting tx...");
    let tx = await contract.grantRole(BURNER_ROLE, address);
    await tx.wait();
    console.log("finished tx!");
}

async function grantDistributorRole(contract, address) {
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    console.log("starting tx...");
    let tx = await contract.grantRole(DISTRIBUTOR_ROLE, address);
    await tx.wait();
    console.log("finished tx!");
}

async function setupDistribsAndBurnersAndMinters(contract, distribs, burners, minters) {

    for (let i = 0; i < distribs.length; i++) {
        await grantDistributorRole(contract, distribs[i]);
    }

    for (let i = 0; i < burners.length; i++) {
        await grantBurnerRole(contract, burners[i]);
    }

    for (let i = 0; i < minters.length; i++) {
        await grantMinterRole(contract, minters[i]);
    }
}


main();