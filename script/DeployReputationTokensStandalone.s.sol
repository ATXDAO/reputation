// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";

contract DeployReputationTokensStandalone is Script {
    function run(
        address ownerNominee,
        address[] memory admins,
        string memory baseUri
    ) external returns (ReputationTokensStandalone) {
        vm.startBroadcast();
        ReputationTokensStandalone repTokens = new ReputationTokensStandalone(
            ownerNominee,
            admins,
            baseUri
        );
        vm.stopBroadcast();

        return repTokens;
    }
}
