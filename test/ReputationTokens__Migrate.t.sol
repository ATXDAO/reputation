// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__Migrate is ReputationTokensTest__Base {
    address user1;
    uint256 tokenId = 0;

    function setUp() public override {
        super.setUp();

        uint256 value = type(uint256).max;

        address distributor = vm.addr(1);
        user1 = vm.addr(2);

        vm.prank(MINTER);
        s_repTokens.mint(distributor, tokenId, value, "");

        vm.prank(distributor);
        s_repTokens.distribute(distributor, user1, tokenId, value, "");
    }

    ////////////////////////
    // Tests
    ////////////////////////

    function testMigrate(
        uint256 value,
        uint256 user2Id
    ) public onlyValidAddress(user2Id) {
        address user2 = vm.addr(user2Id);

        vm.prank(user1);
        s_repTokens.setApprovalForAll(TOKEN_MIGRATOR, true);

        vm.prank(TOKEN_MIGRATOR);
        s_repTokens.migrate(user1, user2, tokenId, value, "");
    }
}
