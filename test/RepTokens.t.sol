// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RepTokens} from "../src/RepTokens.sol";
import {DeployRepTokens} from "../script/DeployRepTokens.s.sol";

contract RepTokensTest is Test {
    address[] public accounts =
        [makeAddr("ADMIN"), makeAddr("MINTER"), makeAddr("DISTRIBUTOR"), makeAddr("TOKEN_MIGRATOR"), makeAddr("USER")];
    uint256 constant MAX_MINT_PER_TX = 100;

    RepTokens s_repTokens;

    DeployRepTokens deployer;

    address[] public admins;

    function setUp() public {
        admins = [accounts[0]];
        deployer = new DeployRepTokens();
        s_repTokens = deployer.run(admins, MAX_MINT_PER_TX);
    }
}
