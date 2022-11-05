import { FixedDeployFunction } from '../types';
import { dynamicGetGasPrice } from '../util/gas-now';

const contractName = 'REP';

const deployFunc: FixedDeployFunction = async ({
  network,
  ethers,
  deployments,
}) => {
  if (network.name === 'mainnet') {
    ethers.providers.BaseProvider.prototype.getGasPrice =
      dynamicGetGasPrice('fast');
  }

  const signer = await ethers.provider.getSigner();
  const from = await signer.getAddress();
  const deployGasPrice = await ethers.provider.getGasPrice();
  if (!deployGasPrice) {
    throw new Error('deploy gas price undefined!');
  }
  console.log(`deploying:  ${contractName}`);
  console.log(`  network:  ${network.name}`);
  console.log(` deployer:  ${from}`);
  console.log(
    ` gasPrice:  ${ethers.utils.formatUnits(deployGasPrice, 'gwei')} gwei\n`
  );
  const contract = await deployments.deploy(contractName, {
    args: ['0xA0E4307b80966af146C89E911bD78FbD909fA87C', 1000],
    libraries: {},
    from,
    log: true,
    autoMine: true,
  });
  console.log('deploy tx: ', contract.receipt?.transactionHash);
  console.log('  address: ', contract.address);
};

deployFunc.id = contractName;

export default deployFunc;
