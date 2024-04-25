// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {IReputationTokensEvents} from "../contracts/IReputationTokensEvents.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__UpdateToken is ReputationTokensTest__Base {
    uint256 numOfTokenTypes = 3;

    ////////////////////////
    // Tests
    ////////////////////////

    function testUpdateTokenType(uint256 id, uint256 tokenTypeId) public {
        tokenTypeId = bound(tokenTypeId, 0, numOfTokenTypes - 1);
        IReputationTokensEvents.TokenType tokenType =
            IReputationTokensEvents.TokenType(tokenTypeId);

        vm.expectEmit();
        emit IReputationTokensEvents.Update(id, tokenType);

        vm.prank(TOKEN_UPDATER);
        s_repTokens.updateToken(id, tokenType);

        assertEq(tokenTypeId, uint8(s_repTokens.getTokenType(id)));
    }

    function testUpdateTokenBatch(uint256[] memory tokenTypeIds) public {
        IReputationTokensEvents.TokenType[] memory tokenTypes =
            new IReputationTokensEvents.TokenType[](tokenTypeIds.length);

        uint256[] memory uniqueIds = new uint256[](tokenTypeIds.length);

        for (uint256 i = 0; i < tokenTypeIds.length; i++) {
            tokenTypeIds[i] = bound(tokenTypeIds[i], 0, numOfTokenTypes - 1);
            tokenTypes[i] = IReputationTokensEvents.TokenType(tokenTypeIds[i]);
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
