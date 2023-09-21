// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensInitializable} from "../src/ReputationTokensInitializable.sol";
import {DeployReputationTokensInitializable} from "../script/DeployReputationTokensInitializable.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {ReputationTokensStorage} from "../src/ReputationTokensStorage.sol";

contract RepTokensInitializableTest is Test {
    ////////////////////////
    // State Variables
    ////////////////////////
    address ADMIN = makeAddr("ADMIN");

    uint256 constant MAX_MINT_PER_TX = 100;

    ReputationTokensInitializable s_repTokens;

    ////////////////////////
    // Functions
    ////////////////////////

    function setUp() public {
        DeployReputationTokensInitializable deployer = new DeployReputationTokensInitializable();
        s_repTokens = deployer.run();
    }

    function testInitialize() public {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;
        s_repTokens.initialize(ADMIN, admins, MAX_MINT_PER_TX, "");
        assertEq(MAX_MINT_PER_TX, s_repTokens.getMaxMintPerTx());
    }
}