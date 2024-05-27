// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";
import {IReputationTokensEvents} from "../contracts/IReputationTokensEvents.sol";

contract ReputationTokens__Distribute is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////
    function testDistribute(
        uint256 fromId,
        uint256 toId,
        uint256 tokenId,
        uint256 value
    ) public onlyValidAddress(fromId) onlyValidAddress(toId) {
        address from = vm.addr(fromId);
        address to = vm.addr(toId);

        vm.prank(MINTER);
        s_repTokens.mint(from, tokenId, value, "");

        vm.expectEmit();
        // emit IReputationTokensEvents.Distribute(from, to, tokenId, value);

        uint256 distributeBalancePrior = s_repTokens.distributableBalanceOf(
            from,
            tokenId
        );

        vm.prank(from);
        s_repTokens.distribute(from, to, tokenId, value, "");

        assertEq(
            distributeBalancePrior - value,
            s_repTokens.distributableBalanceOf(from, tokenId)
        );

        assertEq(value, s_repTokens.balanceOf(to, tokenId));
        assertEq(value, s_repTokens.honestBalanceOf(to, tokenId));
    }

    function testDistributeBatch(
        uint256 fromId,
        uint256 toId,
        uint256[] memory tokenIds,
        uint32[] memory values32
    ) public onlyValidAddress(fromId) onlyValidAddress(toId) {
        vm.assume(tokenIds.length > 0);
        vm.assume(values32.length > 0);

        uint256[] memory values = new uint256[](values32.length);

        for (uint256 i = 0; i < values.length; i++) {
            values[i] = values32[i];
        }

        (
            uint256[] memory cauterizedIds,
            uint256[] memory cauterizedValues
        ) = cauterizeLength(tokenIds, values);

        address from = vm.addr(fromId);
        address to = vm.addr(toId);

        vm.prank(MINTER);
        s_repTokens.mintBatch(from, cauterizedIds, cauterizedValues, "");

        vm.prank(from);
        s_repTokens.distributeBatch(
            from,
            to,
            cauterizedIds,
            cauterizedValues,
            ""
        );
    }
}
