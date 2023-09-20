// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";

contract DeployReputationTokens is Script {
    function run(
        address[] memory admins,
        uint256 maxMintAmountPerTx,
        string memory baseUri
    ) external returns (ReputationTokensStandalone) {
        vm.startBroadcast();
        ReputationTokensStandalone repTokens = new ReputationTokensStandalone(
            admins,
            maxMintAmountPerTx,
            baseUri
        );
        vm.stopBroadcast();
        return repTokens;
    }
}
