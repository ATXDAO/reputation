// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require('hardhat')

async function deployPaymaster(addr) {
  const contractName = "SingleRecipientPaymaster";
  const Contract = await ethers.getContractFactory(contractName);
  const contract = await Contract.deploy(addr);
  
  console.log(`${contractName} is being deployed...`);
  console.log(`Transaction hash: ${contract.deployTransaction.hash}`);

  let tx = await contract.deployed();
  
  console.log(`Gas Price: ${ethers.utils.formatUnits(contract.deployTransaction.gasPrice.toNumber(), 'gwei')} gwei`)
  console.log(`Gas Limit: ${contract.deployTransaction.gasLimit.toNumber()}`)
  
  console.log(`Deployed ${contractName} to: ${contract.address}`);
}

async function main() {

  // await deployPaymaster("0x4eB337e0FC01b8ed0Db67a37b5CAB4B8AA5F29f0");
  // return;

  const contractName = "RepTokens";
  const Contract = await ethers.getContractFactory(contractName);
  const contract = await Contract.deploy(["0xc689c800a7121b186208ea3b182fAb2671B337E7"], 50);
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  //MAKE SURE TO DEPLOY WITH ATX SPECIFIC PRIVATE KEY
  console.log(`${contractName} is being deployed...`);
  console.log(`Transaction hash: ${contract.deployTransaction.hash}`);

  let tx = await contract.deployed();
  
  console.log(`Gas Price: ${ethers.utils.formatUnits(contract.deployTransaction.gasPrice.toNumber(), 'gwei')} gwei`)
  console.log(`Gas Limit: ${contract.deployTransaction.gasLimit.toNumber()}`)
  
  console.log(`Deployed contract to: ${contract.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
