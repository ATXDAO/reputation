// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";
import {IReputationTokensEvents} from "../contracts/IReputationTokensEvents.sol";

contract ReputationTokens__SafeTransferFrom is ReputationTokensTest__Base {
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

    function testSafeTransferFrom(
        uint256 value,
        uint256 user2Id
    ) public onlyValidAddress(user2Id) {
        address user2 = vm.addr(user2Id);

        vm.prank(user1);
        s_repTokens.safeTransferFrom(user1, user2, tokenId, value, "");
    }

    function testSafeTransferFromToBurner(uint256 value) public {
        vm.prank(TOKEN_UPDATER);
        s_repTokens.updateToken(
            tokenId, IReputationTokensEvents.TokenType.Redeemable
        );

        uint256 priorBalance = s_repTokens.honestBalanceOf(user1, tokenId);

        vm.prank(user1);
        s_repTokens.safeTransferFrom(user1, user1, tokenId, value, "");

        assertEq(
            priorBalance - value, s_repTokens.honestBalanceOf(user1, tokenId)
        );
        assertEq(value, s_repTokens.burnedBalanceOf(user1, tokenId));
    }

    function testRevertSafeTransferFromSoulboundToken(uint256 value) public {
        vm.prank(TOKEN_UPDATER);
        s_repTokens.updateToken(
            tokenId, IReputationTokensEvents.TokenType.Soulbound
        );

        vm.expectRevert(
            IReputationTokensErrors
                .ReputationTokens__CannotTransferSoulboundToken
                .selector
        );

        vm.prank(user1);
        s_repTokens.safeTransferFrom(user1, user1, tokenId, value, "");
    }

    function testRevertSafeTransferFromInsufficientBalance(
        uint256 value,
        uint256 user2Id
    ) public onlyValidAddress(user2Id) {
        vm.assume(value > 0);
        address user2 = vm.addr(user2Id);
        vm.assume(user2 != user1);

        vm.prank(TOKEN_UPDATER);
        s_repTokens.updateToken(
            tokenId, IReputationTokensEvents.TokenType.Transferable
        );

        uint256 userBalance = s_repTokens.balanceOf(user1, tokenId);

        vm.startPrank(user1);
        s_repTokens.safeTransferFrom(user1, user2, tokenId, userBalance, "");

        uint256 userBalance2 = s_repTokens.balanceOf(user1, tokenId);

        console.log(userBalance2);

        vm.expectRevert(
            IReputationTokensErrors
                .ReputationTokens__InsufficientBalance
                .selector
        );

        s_repTokens.safeTransferFrom(user1, user2, tokenId, value, "");

        vm.stopPrank();
    }
}
