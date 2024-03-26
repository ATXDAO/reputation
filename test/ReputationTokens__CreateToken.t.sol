// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../src/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../src/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__CreateToken is ReputationTokensTest__Base {
    // function setUp() public override {
    //     super.setUp();
    // }
    ////////////////////////
    // Tests
    ////////////////////////
    function testCreateToken(
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) public {
        uint256 tokenId = createToken(tokenProperties);

        assertEq(s_repTokens.getNumOfTokenTypes(), 1);

        TokensPropertiesStorage.TokenProperties
            memory createdTokenProperties = s_repTokens.getTokenProperties(
                tokenId
            );

        assertEq(
            createdTokenProperties.maxMintAmountPerTx,
            tokenProperties.maxMintAmountPerTx
        );
        assertEq(
            createdTokenProperties.isSoulbound,
            tokenProperties.isSoulbound
        );
        assertEq(
            createdTokenProperties.isRedeemable,
            tokenProperties.isRedeemable
        );
    }

    function testBatchCreateTokens(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    ) public {
        batchCreateTokens(tokensProperties);

        assertEq(tokensProperties.length, s_repTokens.getNumOfTokenTypes());

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            TokensPropertiesStorage.TokenProperties
                memory createdTokenProperties = s_repTokens.getTokenProperties(
                    i
                );

            assertEq(
                createdTokenProperties.maxMintAmountPerTx,
                tokensProperties[i].maxMintAmountPerTx
            );
            assertEq(
                createdTokenProperties.isSoulbound,
                tokensProperties[i].isSoulbound
            );
            assertEq(
                createdTokenProperties.isRedeemable,
                tokensProperties[i].isRedeemable
            );
        }
    }

    // // ////////////////////////
    // // // Helper Functions
    // // ///////////////////////
    function batchCreateTokens(
        TokensPropertiesStorage.TokenProperties[] memory tokenProperties
    ) public {
        vm.startPrank(TOKEN_CREATOR);
        s_repTokens.batchCreateTokens(tokenProperties);
        vm.stopPrank();
    }

    function createToken(
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) public returns (uint256) {
        vm.startPrank(TOKEN_CREATOR);
        uint256 tokenId = s_repTokens.createToken(tokenProperties);
        vm.stopPrank();
        return tokenId;
    }
}
