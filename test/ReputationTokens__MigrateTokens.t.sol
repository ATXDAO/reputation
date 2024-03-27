// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../src/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../src/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__MigrateTokens is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    function testMigrationOfTokens(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
        address user,
        address user2
    ) external {
        vm.assume(user != address(0));
        vm.assume(user2 != address(0));

        batchCreateTokens(tokensProperties);
        ReputationTokensInternal.TokensOperations
            memory tokenOperations = createTokenOperationsSequential(
                DISTRIBUTOR,
                tokensProperties
            );
        mint(tokenOperations);
        ReputationTokensInternal.TokensOperations
            memory distributeOperations = createTokenOperationsSequential(
                user,
                tokensProperties
            );
        distribute(distributeOperations);
        vm.startPrank(user);
        s_repTokens.setApprovalForAll(TOKEN_MIGRATOR, true);
        vm.stopPrank();
        vm.startPrank(TOKEN_MIGRATOR);
        s_repTokens.migrateOwnershipOfTokens(user, user2);
        vm.stopPrank();
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            assertEq(s_repTokens.balanceOf(user, i), 0);
            assertEq(
                s_repTokens.balanceOf(user2, i),
                tokensProperties[i].maxMintAmountPerTx
            );
        }
    }

    function testSetTokenURI(
        uint256 numOfTokens,
        string[] memory uris
    ) external {
        vm.assume(numOfTokens < uris.length);
        vm.startPrank(TOKEN_URI_SETTER);
        for (uint256 i = 0; i < numOfTokens; i++) {
            s_repTokens.setTokenURI(i, uris[i]);
        }
        vm.stopPrank();
        for (uint256 i = 0; i < numOfTokens; i++) {
            assertEq(s_repTokens.uri(i), uris[i]);
        }
    }

    function testGetMaxMintPerTx(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    ) external {
        batchCreateTokens(tokensProperties);
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            assertEq(
                s_repTokens.getMaxMintPerTx(i),
                tokensProperties[i].maxMintAmountPerTx
            );
        }
    }
}
