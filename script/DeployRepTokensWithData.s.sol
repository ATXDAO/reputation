// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {RepTokens} from "../src/RepTokens.sol";
import {DeployRepTokens} from "./DeployRepTokens.s.sol";

contract DeployRepTokensWithData is Script {
    address ADMIN = 0xc4f6578c24c599F195c0758aD3D4861758d703A3;

    function run() external returns (RepTokens) {
        DeployRepTokens deployer = new DeployRepTokens();
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;

        return deployer.run(admins, 20);
    }
}
