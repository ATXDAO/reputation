//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/ReputationTokens.sol";
import "./DeployHelpers.s.sol";

contract DeployReputationTokens is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    function run(
        address ownerNominee,
        address[] memory admins,
        address[] memory tokenUpdaters,
        ReputationTokens.TokenType[] memory tokenTypes,
        string[] memory uris
    ) external returns (ReputationTokens) {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);
        ReputationTokens repTokens = new ReputationTokens(
            ownerNominee,
            admins,
            tokenUpdaters,
            tokenTypes,
            uris
        );
        console.logString(
            string.concat(
                "ReputationTokens deployed at: ",
                vm.toString(address(repTokens))
            )
        );
        vm.stopBroadcast();

        return repTokens;
    }

    function test() public {}
}
