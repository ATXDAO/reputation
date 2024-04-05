// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from
    "../contracts/ReputationTokensStandalone.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokensInternal} from
    "../contracts/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__UpdateTokenProperties is
    ReputationTokensTest__Base
{
    ////////////////////////
    // Tests
    ////////////////////////
    function testUpdateTokenProperties(
        uint256 tokenTypeId,
        uint256 maxMintAmountPerTx
    ) public {
        tokenTypeId = bound(tokenTypeId, 0, 2);

        createDefaultToken();

        ReputationTokensInternal.TokenProperties memory newTokenProperties =
        ReputationTokensInternal.TokenProperties(
            ReputationTokensInternal.TokenType(tokenTypeId), maxMintAmountPerTx
        );

        updateToken(0, newTokenProperties);

        ReputationTokensInternal.TokenProperties memory tokenProperties =
            s_repTokens.getTokenProperties(0);

        assertEq(
            tokenProperties.maxMintAmountPerTx,
            newTokenProperties.maxMintAmountPerTx
        );
    }

    function testRevertUpdateIfNonExistentToken() public {
        ReputationTokensInternal.TokenProperties memory newTokenProperties =
        ReputationTokensInternal.TokenProperties(
            ReputationTokensInternal.TokenType(0), 0
        );

        vm.expectRevert(
            IReputationTokensErrors
                .ReputationTokens__CannotUpdateNonexistentTokenType
                .selector
        );
        updateToken(0, newTokenProperties);
    }

    function testUpdateTokens(uint256 numToUpdate) public {
        vm.assume(numToUpdate < 1000);

        ReputationTokensInternal.TokenProperties[] memory tokensProperties =
            new ReputationTokensInternal.TokenProperties[](numToUpdate);

        for (uint256 i = 0; i < numToUpdate; i++) {
            tokensProperties[i] = ReputationTokensInternal.TokenProperties(
                ReputationTokensInternal.TokenType(0), 0
            );
        }

        batchCreateTokens(tokensProperties);

        uint256[] memory ids = new uint256[](tokensProperties.length);
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            ids[i] = i;
        }

        batchUpdateTokensProperties(ids, tokensProperties);
    }
}
