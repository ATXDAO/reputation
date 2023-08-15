// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {CadentRepDistributor} from "../src/CadentRepDistributor.sol";
import {DeployCadentRepDistributor} from "./DeployCadentRepDistributor.s.sol";

contract DeployCadentRepDistributorWithData is Script {
    address repTokens = 0x57AA5fd0914A46b8A426cC33DB842D1BB1aeADa2;
    uint256 amountToDistributePerCadence = 1;
    uint256 cadence = 60;

    function run() external returns (CadentRepDistributor) {
        DeployCadentRepDistributor deployer = new DeployCadentRepDistributor();
        return deployer.run(repTokens, amountToDistributePerCadence, cadence);
    }
}
