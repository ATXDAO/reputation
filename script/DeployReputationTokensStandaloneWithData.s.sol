// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "./DeployReputationTokensStandalone.s.sol";

contract DeployReputationTokensStandaloneWithData is Script {
    address OWNER_NOMINEE = 0xc4f6578c24c599F195c0758aD3D4861758d703A3;
    address ADMIN = 0xc4f6578c24c599F195c0758aD3D4861758d703A3;
    string constant BASE_URI =
        "ipfs://bafybeiaz55w6kf7ar2g5vzikfbft2qoexknstfouu524l7q3mliutns2u4/";

    function run() external returns (ReputationTokensStandalone) {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;

        vm.startBroadcast();
        ReputationTokensStandalone repTokens = new ReputationTokensStandalone(
            OWNER_NOMINEE,
            admins
        );
        vm.stopBroadcast();

        return repTokens;
    }
}
