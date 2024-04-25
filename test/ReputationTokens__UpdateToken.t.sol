// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {IReputationTokensEvents} from "../contracts/IReputationTokensEvents.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";
import {IReputationTokensTypes} from "../contracts/IReputationTokensTypes.sol";

contract ReputationTokens__UpdateToken is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    function testUpdateTokenType(uint256 id, uint256 tokenTypeId) public {
        tokenTypeId = bound(tokenTypeId, 0, getNumTokenTypesMaxBound());
        IReputationTokensTypes.TokenType tokenType =
            IReputationTokensTypes.TokenType(tokenTypeId);

        vm.expectEmit();
        emit IReputationTokensEvents.Update(id, tokenType);

        vm.prank(TOKEN_UPDATER);
        s_repTokens.updateToken(id, tokenType);

        assertEq(tokenTypeId, uint8(s_repTokens.getTokenType(id)));
    }

    function testUpdateTokenBatch(uint256[] memory tokenTypeIds) public {
        IReputationTokensTypes.TokenType[] memory tokenTypes =
            new IReputationTokensTypes.TokenType[](tokenTypeIds.length);

        uint256[] memory uniqueIds = new uint256[](tokenTypeIds.length);

        for (uint256 i = 0; i < tokenTypeIds.length; i++) {
            tokenTypeIds[i] =
                bound(tokenTypeIds[i], 0, getNumTokenTypesMaxBound());
            tokenTypes[i] = IReputationTokensTypes.TokenType(tokenTypeIds[i]);
            uniqueIds[i] = i;
        }

        vm.expectEmit();
        emit IReputationTokensEvents.UpdateBatch(uniqueIds, tokenTypes);

        vm.prank(TOKEN_UPDATER);
        s_repTokens.updateTokenBatch(uniqueIds, tokenTypes);

        for (uint256 i = 0; i < tokenTypeIds.length; i++) {
            assertEq(
                tokenTypeIds[i], uint8(s_repTokens.getTokenType(uniqueIds[i]))
            );
        }
    }
}
