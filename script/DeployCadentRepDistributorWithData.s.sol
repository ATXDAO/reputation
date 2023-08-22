// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {CadentRepDistributor} from "../src/CadentRepDistributor.sol";
import {DeployCadentRepDistributor} from "./DeployCadentRepDistributor.s.sol";

contract DeployCadentRepDistributorWithData is Script {
    address repTokens = 0x65aD2263e658E75762253076E2EBFc9211E05D2F;
    uint256 amountToDistributePerCadence = 1;
    uint256 cadence = 60;

    function run() external returns (CadentRepDistributor) {
        DeployCadentRepDistributor deployer = new DeployCadentRepDistributor();
        return deployer.run(repTokens, amountToDistributePerCadence, cadence);
    }
}
