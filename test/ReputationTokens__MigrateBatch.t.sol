// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__Migrate is ReputationTokensTest__Base {
    address user1;
    uint256 tokenId = 0;

    uint256[] tokenIds;
    uint256[] values;

    function setUp() public override {
        super.setUp();

        address distributor = vm.addr(1);
        user1 = vm.addr(2);

        for (uint256 i = 0; i < 1; i++) {
            tokenIds.push(i);
            values.push(i);
        }

        vm.prank(MINTER);
        s_repTokens.mintBatch(distributor, tokenIds, values, "");

        vm.prank(distributor);
        s_repTokens.distributeBatch(distributor, user1, tokenIds, values, "");
    }

    ////////////////////////
    // Tests
    ////////////////////////

    function testMigrateBatch(uint256 user2Id)
        public
        onlyValidAddress(user2Id)
    {
        address user2 = vm.addr(user2Id);

        vm.prank(user1);
        s_repTokens.setApprovalForAll(TOKEN_MIGRATOR, true);

        vm.prank(TOKEN_MIGRATOR);
        s_repTokens.migrateBatch(user1, user2, tokenIds, values, "");
    }
}
