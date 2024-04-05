// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../contracts/ReputationTokensStandalone.sol";
import {IReputationTokensBaseInternal} from "../contracts/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../contracts/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../contracts/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__CreateToken is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    function testCreateToken(
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) public {}

    // uint256 tokenId = createToken(tokenProperties);
    // assertEq(s_repTokens.getNumOfTokenTypes(), 1);
    // TokensPropertiesStorage.TokenProperties
    //     memory createdTokenProperties = s_repTokens.getTokenProperties(
    //         tokenId
    //     );
    // assertEq(
    //     createdTokenProperties.maxMintAmountPerTx,
    //     tokenProperties.maxMintAmountPerTx
    // );
    // assertEq(
    //     uint8(createdTokenProperties.transferType),
    //     uint8(tokenProperties.transferType)
    // );
    // assertEq(
    //     createdTokenProperties.isSoulbound,
    //     tokenProperties.isSoulbound
    // );
    // assertEq(
    //     createdTokenProperties.isRedeemable,
    //     tokenProperties.isRedeemable
    // );

    function testBatchCreateTokens()
        public
    // TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    {
        // batchCreateTokens(tokensProperties);
        // assertEq(tokensProperties.length, s_repTokens.getNumOfTokenTypes());
        // for (uint256 i = 0; i < tokensProperties.length; i++) {
        //     TokensPropertiesStorage.TokenProperties
        //         memory createdTokenProperties = s_repTokens.getTokenProperties(
        //             i
        //         );
        //     assertEq(
        //         createdTokenProperties.maxMintAmountPerTx,
        //         tokensProperties[i].maxMintAmountPerTx
        //     );
        //     // assertEq(
        //     //     uint8(createdTokenProperties.transferType),
        //     //     uint8(tokensProperties[i].transferType)
        //     // );
        //     // assertEq(
        //     //     createdTokenProperties.isSoulbound,
        //     //     tokensProperties[i].isSoulbound
        //     // );
        //     // assertEq(
        //     //     createdTokenProperties.isRedeemable,
        //     //     tokensProperties[i].isRedeemable
        //     // );
        // }
    }
}
