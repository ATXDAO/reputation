require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_KEY_GOERLI}`,
      accounts: [process.env.PRIVATE_KEY],
      gasPrice: 65000000000
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_KEY_MUMBAI}`,
      accounts: [process.env.PRIVATE_KEY],
      },
  },
  etherscan: {
    apiKey: `${process.env.POLYGONSCAN_KEY}`
    // apiKey: `${process.env.ETHERSCAN_KEY}`
  }
};
