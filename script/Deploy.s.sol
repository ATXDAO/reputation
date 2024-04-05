//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/ReputationTokensStandalone.sol";
import "./DeployHelpers.s.sol";

import "./DeployReputationTokensStandalone.s.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    address ownerNominee;
    address[] admins;

    function run() external {
        DeployReputationTokensStandalone deployer =
            new DeployReputationTokensStandalone();
        deployer.run(ownerNominee, admins);

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function test() public {}
}
