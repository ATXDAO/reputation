// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");

async function deploy(contractName, ...params) {
  const Contract = await ethers.getContractFactory(contractName);
  const contract = await Contract.deploy(...params);

  console.log(`${contractName} is being deployed...`);
  console.log(`Transaction hash: ${contract.deployTransaction.hash}`);

  let tx = await contract.deployed();

  console.log(
    `Gas Price: ${ethers.utils.formatUnits(
      contract.deployTransaction.gasPrice.toNumber(),
      "gwei"
    )} gwei`
  );
  console.log(`Gas Limit: ${contract.deployTransaction.gasLimit.toNumber()}`);

  console.log(`Deployed ${contractName} to: ${contract.address}`);
}

async function deployPaymaster(addr) {
  const contractName = "SingleRecipientPaymaster";
  const Contract = await ethers.getContractFactory(contractName);
  const contract = await Contract.deploy(addr);

  console.log(`${contractName} is being deployed...`);
  console.log(`Transaction hash: ${contract.deployTransaction.hash}`);

  let tx = await contract.deployed();

  console.log(
    `Gas Price: ${ethers.utils.formatUnits(
      contract.deployTransaction.gasPrice.toNumber(),
      "gwei"
    )} gwei`
  );
  console.log(`Gas Limit: ${contract.deployTransaction.gasLimit.toNumber()}`);

  console.log(`Deployed ${contractName} to: ${contract.address}`);
  return contract;
}

async function main() {
  let rep = await deploy(
    "RepTokens",
    ["0xc4f6578c24c599F195c0758aD3D4861758d703A3"],
    200
  );

  // await deploy("SingleRecipientPaymaster", rep.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
