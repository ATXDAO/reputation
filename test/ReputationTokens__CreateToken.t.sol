// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

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

        ReputationTokens.TokenProperties memory tokenProperties =
        ReputationTokens.TokenProperties(
            ReputationTokens.TokenType(tokenTypeId), maxMintAmountPerTx
        );

        uint256 tokenId = createToken(tokenProperties);

        ReputationTokens.TokenProperties memory createdTokenProperties =
            s_repTokens.getTokenProperties(tokenId);

        assertEq(uint8(createdTokenProperties.tokenType), tokenTypeId);

        assertEq(
            createdTokenProperties.maxMintAmountPerTx,
            tokenProperties.maxMintAmountPerTx
        );
    }

    function testBatchCreateTokens(uint256 numToCreate) public {
        vm.assume(numToCreate < 1000);

        ReputationTokens.TokenProperties[] memory tokensProperties =
            new ReputationTokens.TokenProperties[](numToCreate);

        for (uint256 i = 0; i < numToCreate; i++) {
            tokensProperties[i] = ReputationTokens.TokenProperties(
                ReputationTokens.TokenType.Default, 0
            );
        }
        batchCreateTokens(tokensProperties);

        assertEq(tokensProperties.length, s_repTokens.getNumOfTokenTypes());
    }
}
