// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../src/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../src/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__UpdateTokenProperties is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////
    function testUpdateTokenProperties(
        TokensPropertiesStorage.TokenProperties memory _tokenProperties,
        TokensPropertiesStorage.TokenProperties memory newTokenProperties
    ) public {
        createToken(_tokenProperties);

        updateToken(0, newTokenProperties);

        TokensPropertiesStorage.TokenProperties
            memory tokenProperties = s_repTokens.getTokenProperties(0);

        assertEq(
            tokenProperties.maxMintAmountPerTx,
            newTokenProperties.maxMintAmountPerTx
        );
        assertEq(tokenProperties.isSoulbound, newTokenProperties.isSoulbound);
        assertEq(tokenProperties.isRedeemable, newTokenProperties.isRedeemable);
    }

    function testRevertUpdateIfNonExistentToken(
        TokensPropertiesStorage.TokenProperties memory _tokenProperties,
        TokensPropertiesStorage.TokenProperties memory newTokenProperties
    ) public {
        createToken(_tokenProperties);

        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__CannotUpdateNonexistentTokenType
                .selector
        );
        updateToken(1, newTokenProperties);
    }

    function testUpdateTokens(
        TokensPropertiesStorage.TokenProperties[] memory _tokensProperties
    ) public {
        batchCreateTokens(_tokensProperties);
        uint256[] memory ids = new uint256[](_tokensProperties.length);
        for (uint256 i = 0; i < _tokensProperties.length; i++) {
            ids[i] = i;
        }
        batchUpdateTokensProperties(ids, _tokensProperties);
        for (uint256 i = 0; i < _tokensProperties.length; i++) {
            assertEq(
                s_repTokens.getTokenProperties(i).isSoulbound,
                _tokensProperties[i].isSoulbound
            );
            assertEq(
                s_repTokens.getTokenProperties(i).isRedeemable,
                _tokensProperties[i].isRedeemable
            );
            assertEq(
                s_repTokens.getTokenProperties(i).maxMintAmountPerTx,
                _tokensProperties[i].maxMintAmountPerTx
            );
        }
    }
}
