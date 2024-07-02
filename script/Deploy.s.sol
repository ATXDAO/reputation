//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/ReputationTokens.sol";
import "./DeployHelpers.s.sol";

import "./DeployReputationTokens.s.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    address ownerNominee;
    address[] admins;

    function run() external {
        DeployReputationTokens deployer = new DeployReputationTokens();

        string[] memory uris;
        ReputationTokensBase.TokenType[] memory tokenTypes;

        deployer.run(ownerNominee, admins, admins, tokenTypes, uris);

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function test() public {}
}
