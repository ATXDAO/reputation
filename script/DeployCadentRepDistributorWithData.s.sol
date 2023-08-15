// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {CadentRepDistributor} from "../src/CadentRepDistributor.sol";
import {DeployCadentRepDistributor} from "./DeployCadentRepDistributor.s.sol";

contract DeployCadentRepDistributorWithData is Script {
    address repTokens = 0xF0535B9d8E98144BB4233fEdd252220d0152311E;
    uint256 amountToDistributePerCadence = 1;
    uint256 cadence = 60;

    function run() external returns (CadentRepDistributor) {
        DeployCadentRepDistributor deployer = new DeployCadentRepDistributor();
        return deployer.run(repTokens, amountToDistributePerCadence, cadence);
    }
}
