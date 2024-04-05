//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/ReputationTokensStandalone.sol";
import "./DeployHelpers.s.sol";

contract DeployReputationTokensStandalone is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    function run(
        address ownerNominee,
        address[] memory admins
    ) external returns (ReputationTokensStandalone) {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);
        ReputationTokensStandalone repTokens =
            new ReputationTokensStandalone(ownerNominee, admins);
        console.logString(
            string.concat(
                "ReputationTokensStandalone deployed at: ",
                vm.toString(address(repTokens))
            )
        );
        vm.stopBroadcast();

        return repTokens;
    }

    function test() public {}
}
