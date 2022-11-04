const { ethers } = require('ethers');
const { abi } = require("./abi");
require('dotenv').config()

async function main() {
    const provider = new ethers.providers.JsonRpcProvider(`https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_KEY_GOERLI}`);
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY);
    const account = signer.connect(provider);
    
    const contractAddress = "";

    const contract = new ethers.Contract(
        contractAddress,
        abi,
        account
    );

    console.log("minting...");
    let mTx = await contract.mint(10);
    await mTx.wait();
    console.log("minted.");


    // let tx = await contract.transfer("", 1);
    // await tx.wait();

    let bo = await contract.balanceOf("");

    console.log(bo.toString());
    // let ts = await contract.totalSupply();
    // console.log(ts.toString());

    // mintToOwnerVerbose(contract);
    // setBaseURIVerbose(contract);
}

main();
