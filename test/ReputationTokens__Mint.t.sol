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

    function testMint(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    ) public {
        batchCreateTokens(tokensProperties);
        ReputationTokensInternal.TokensOperations
            memory operations = createTokenOperationsSequential(
                DISTRIBUTOR,
                tokensProperties
            );

        mint(operations);

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            assertEq(
                s_repTokens.balanceOf(DISTRIBUTOR, i),
                tokensProperties[i].maxMintAmountPerTx
            );
            assertEq(
                s_repTokens.getDistributableBalance(DISTRIBUTOR, i),
                tokensProperties[i].maxMintAmountPerTx
            );
            assertEq(s_repTokens.getTransferrableBalance(DISTRIBUTOR, i), 0);
        }
    }

    function testRevertIfMintingTooManyTokens(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    ) external {
        vm.assume(tokensProperties.length > 0);

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            vm.assume(
                tokensProperties[i].maxMintAmountPerTx != type(uint256).max
            );
        }

        batchCreateTokens(tokensProperties);

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            tokensProperties[i].maxMintAmountPerTx += 1;
        }

        ReputationTokensInternal.TokensOperations
            memory operations = createTokenOperationsSequential(
                DISTRIBUTOR,
                tokensProperties
            );

        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__MintAmountExceedsLimit
                .selector
        );
        mint(operations);
    }

    function testRevertIfMintingToNonDistributor(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    ) external {
        batchCreateTokens(tokensProperties);

        ReputationTokensInternal.TokensOperations
            memory operations = createTokenOperationsSequential(
                USER,
                tokensProperties
            );
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__CanOnlyMintToDistributor
                .selector
        );
        mint(operations);
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
    ) public {
        vm.startPrank(TOKEN_CREATOR);
        s_repTokens.createToken(tokenProperties);
        vm.stopPrank();
    }

    function batchUpdateTokensProperties(
        uint256[] memory ids,
        TokensPropertiesStorage.TokenProperties[] memory _tokensProperties
    ) public {
        vm.startPrank(TOKEN_UPDATER);
        s_repTokens.batchUpdateTokensProperties(ids, _tokensProperties);
        vm.stopPrank();
    }

    function updateToken(
        uint256 id,
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) public {
        vm.startPrank(TOKEN_UPDATER);
        s_repTokens.updateTokenProperties(id, tokenProperties);
        vm.stopPrank();
    }
}
