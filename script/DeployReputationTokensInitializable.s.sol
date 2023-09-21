// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ReputationTokensInitializable} from "../src/ReputationTokensInitializable.sol";

contract DeployReputationTokensInitializable is Script {
    function run() external returns (ReputationTokensInitializable) {
        vm.startBroadcast();
        ReputationTokensInitializable repTokens = new ReputationTokensInitializable();
        vm.stopBroadcast();
        return repTokens;
    }
}
