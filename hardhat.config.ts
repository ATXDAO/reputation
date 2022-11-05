import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import dotenv from 'dotenv';
import fs from 'fs';
import 'hardhat-deploy';
import { HardhatUserConfig } from 'hardhat/config';

dotenv.config();

if (fs.existsSync('typechain-types')) {
  require('./scripts/gas-price');
  require('./scripts/merkle-tree');
}

const {
  MAINNET_RPC_URL,
  GOERLI_RPC_URL,
  MUMBAI_RPC_URL,
  PRIVATE_KEY,
  ETHERSCAN_API_KEY,
} = process.env;
const privateKeys = PRIVATE_KEY ? [`0x${PRIVATE_KEY}`] : undefined;

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: 'contracts/',
    tests: 'contracts/test',
  },
  networks: {
    hardhat: {},
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: privateKeys,
      gasPrice: 65000000000,
    },
    mumbai: {
      url: MUMBAI_RPC_URL,
      accounts: privateKeys,
    },
    mainnet: {
      url: MAINNET_RPC_URL,
      accounts: privateKeys,
    },
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: ETHERSCAN_API_KEY,
  },
};

// eslint-disable-next-line import/no-default-export
export default config;
