// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";
import {IReputationTokensEvents} from "../contracts/IReputationTokensEvents.sol";

contract ReputationTokens__Mint is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////
    function testMint(
        uint256 toId,
        uint256 tokenId,
        uint256 mintAmount
    ) public onlyValidAddress(toId) {
        address to = vm.addr(toId);

        vm.expectEmit();
        emit IReputationTokensEvents.Mint(MINTER, to, tokenId, mintAmount);

        vm.prank(MINTER);
        s_repTokens.mint(to, tokenId, mintAmount, "");

        assertEq(s_repTokens.balanceOf(to, tokenId), mintAmount);
        assertEq(s_repTokens.distributableBalanceOf(to, tokenId), mintAmount);
        assertEq(
            s_repTokens.honestBalanceOf(to, tokenId),
            s_repTokens.balanceOf(to, tokenId) - mintAmount
        );
    }

    function testMintBatch(
        uint256 toId,
        uint256[] memory ids,
        uint32[] memory values32
    ) public onlyValidAddress(toId) {
        uint256[] memory values = new uint256[](values32.length);

        for (uint256 i = 0; i < values.length; i++) {
            values[i] = values32[i];
        }

        (uint256[] memory cauterizedIds, uint256[] memory cauterizedValues) =
            cauterizeLength(ids, values);

        address to = vm.addr(toId);

        vm.expectEmit();
        emit IReputationTokensEvents.MintBatch(
            MINTER, to, cauterizedIds, cauterizedValues
        );

        vm.prank(MINTER);
        s_repTokens.mintBatch(to, cauterizedIds, cauterizedValues, "");
    }
}
