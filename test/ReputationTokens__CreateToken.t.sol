// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from
    "../contracts/ReputationTokensStandalone.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokensInternal} from
    "../contracts/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__CreateToken is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////
    function testCreateToken(
        uint256 tokenTypeId,
        uint256 maxMintAmountPerTx
    ) public {
        tokenTypeId = bound(tokenTypeId, 0, 2);

        ReputationTokensInternal.TokenProperties memory tokenProperties =
        ReputationTokensInternal.TokenProperties(
            ReputationTokensInternal.TokenType(tokenTypeId), maxMintAmountPerTx
        );

        uint256 tokenId = createToken(tokenProperties);

        ReputationTokensInternal.TokenProperties memory createdTokenProperties =
            s_repTokens.getTokenProperties(tokenId);

        assertEq(uint8(createdTokenProperties.tokenType), tokenTypeId);

        assertEq(
            createdTokenProperties.maxMintAmountPerTx,
            tokenProperties.maxMintAmountPerTx
        );
    }

    function testBatchCreateTokens(uint256 numToCreate) public {
        vm.assume(numToCreate < 1000);

        ReputationTokensInternal.TokenProperties[] memory tokensProperties =
            new ReputationTokensInternal.TokenProperties[](numToCreate);

        for (uint256 i = 0; i < numToCreate; i++) {
            tokensProperties[i] = ReputationTokensInternal.TokenProperties(
                ReputationTokensInternal.TokenType.Default, 0
            );
        }
        batchCreateTokens(tokensProperties);

        assertEq(tokensProperties.length, s_repTokens.getNumOfTokenTypes());
    }
}
