// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";
import {IReputationTokensEvents} from "../contracts/IReputationTokensEvents.sol";

contract ReputationTokens__SafeTransferFrom is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    // function testSafeTransferFrom() public {
    //     uint256 distributorId = 1;
    //     uint256 user1Id = 2;
    //     uint256 tokenId = 0;
    //     uint256 value = 2;
    //     uint256 user2Id = 2;

    //     address distributor = vm.addr(distributorId);
    //     address user1 = vm.addr(user1Id);
    //     address user2 = vm.addr(user2Id);

    //     vm.prank(TOKEN_UPDATER);
    //     s_repTokens.updateToken(
    //         tokenId, IReputationTokensEvents.TokenType.Transferable
    //     );

    //     vm.prank(MINTER);
    //     s_repTokens.mint(distributor, tokenId, 3, "");

    //     vm.prank(distributor);
    //     s_repTokens.distribute(distributor, user1, tokenId, 3, "");

    //     console.log(value);
    //     uint256 priorBalanceUser1 = s_repTokens.balanceOf(user1, tokenId);
    //     console.log(priorBalanceUser1);
    //     uint256 diff = priorBalanceUser1 - value;
    //     console.log(diff);
    //     vm.prank(user1);
    //     s_repTokens.safeTransferFrom(user1, user2, tokenId, value, "");

    //     uint256 user1BalanceOf = s_repTokens.balanceOf(user1, tokenId);
    //     uint256 user2BalanceOf = s_repTokens.balanceOf(user2, tokenId);

    //     uint256 userDiff = user2BalanceOf - user1BalanceOf;

    //     assertEq(value, user2BalanceOf - userDiff);
    //     assertEq(userDiff, user1BalanceOf - value);

    //     uint256 postBalanceUser1 = s_repTokens.balanceOf(user1, tokenId);
    //     console.log(postBalanceUser1);

    //     console.log(postBalanceUser1 - diff);

    //     // assertEq(postBalanceUser1, postBalanceUser1 - diff);
    // }

    function testSafeTransferFrom(
        uint256 distributorId,
        uint256 user1Id,
        uint256 tokenId,
        uint256 value,
        uint256 user2Id
    )
        public
        onlyValidAddress(distributorId)
        onlyValidAddress(user1Id)
        onlyValidAddress(user2Id)
    {
        address distributor = vm.addr(distributorId);
        address user1 = vm.addr(user1Id);
        address user2 = vm.addr(user2Id);

        vm.prank(TOKEN_UPDATER);
        s_repTokens.updateToken(
            tokenId, IReputationTokensEvents.TokenType.Transferable
        );

        vm.prank(MINTER);
        s_repTokens.mint(distributor, tokenId, value, "");

        vm.prank(distributor);
        s_repTokens.distribute(distributor, user1, tokenId, value, "");

        vm.prank(user1);
        s_repTokens.safeTransferFrom(user1, user2, tokenId, value, "");

        uint256 user1BalanceOf = s_repTokens.balanceOf(user1, tokenId);
        uint256 user2BalanceOf = s_repTokens.balanceOf(user2, tokenId);

        uint256 userDiff = user2BalanceOf - user1BalanceOf;

        assertEq(value, user2BalanceOf);
        assertEq(value, user1BalanceOf + userDiff);
    }

    // function testDistributeBatch(
    //     uint256 fromId,
    //     uint256 toId,
    //     uint256[] memory tokenIds,
    //     uint32[] memory values32
    // ) public onlyValidAddress(fromId) onlyValidAddress(toId) {
    //     vm.assume(tokenIds.length > 0);
    //     vm.assume(values32.length > 0);

    //     uint256[] memory values = new uint256[](values32.length);

    //     for (uint256 i = 0; i < values.length; i++) {
    //         values[i] = values32[i];
    //     }

    //     (uint256[] memory cauterizedIds, uint256[] memory cauterizedValues) =
    //         cauterizeLength(tokenIds, values);

    //     address from = vm.addr(fromId);
    //     address to = vm.addr(toId);

    //     vm.prank(MINTER);
    //     s_repTokens.mintBatch(from, cauterizedIds, cauterizedValues, "");

    //     vm.prank(from);
    //     s_repTokens.distributeBatch(
    //         from, to, cauterizedIds, cauterizedValues, ""
    //     );
    // }
}
