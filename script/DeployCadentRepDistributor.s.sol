// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {CadentRepDistributor} from "../src/CadentRepDistributor.sol";

contract DeployCadentRepDistributor is Script {
    function run(
        address repTokens,
        uint256 amountDistributedPerCadence,
        uint256 cadence
    ) external returns (CadentRepDistributor) {
        vm.startBroadcast();
        CadentRepDistributor cadentRepDistributor = new CadentRepDistributor(
            address(repTokens),
            amountDistributedPerCadence,
            cadence
        );
        vm.stopBroadcast();
        return cadentRepDistributor;
    }
}
