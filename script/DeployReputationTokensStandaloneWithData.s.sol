// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "./DeployReputationTokensStandalone.s.sol";

contract DeployReputationTokensStandaloneWithData is Script {
    address OWNER_NOMINEE;
    address ADMIN;
    uint256 constant MAX_MINT_PER_TX = 100;
    string constant BASE_URI =
        "ipfs://bafybeiaz55w6kf7ar2g5vzikfbft2qoexknstfouu524l7q3mliutns2u4/";

    function run() external returns (ReputationTokensStandalone) {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;

        vm.startBroadcast();
        ReputationTokensStandalone repTokens = new ReputationTokensStandalone(
            OWNER_NOMINEE,
            admins,
            MAX_MINT_PER_TX,
            BASE_URI
        );
        vm.stopBroadcast();

        return repTokens;
    }
}
