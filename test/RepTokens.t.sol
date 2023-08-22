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

    address[] public t;

    function setUp() public {
        t = [accounts[0]];
        deployer = new DeployRepTokens();
        s_repTokens = deployer.run(t, MAX_MINT_PER_TX);
    }

    function testAccountZeroHasAdminRole() external {
        bool hasRole = s_repTokens.hasRole(s_repTokens.DEFAULT_ADMIN_ROLE(), accounts[0]);
        assertEq(hasRole, true);
    }

    function testMaxMintPerTxEqualsValuePassedInDuringDeployment() external {
        assertEq(s_repTokens.maxMintAmountPerTx(), MAX_MINT_PER_TX);
    }
}
