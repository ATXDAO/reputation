// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../src/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../src/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__Distribute is ReputationTokensTest__Base {
    // function setUp() public override {
    //     super.setUp();
    // }

    ////////////////////////
    // Tests
    ////////////////////////

    function testDistribute(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
        address user
    ) external {
        vm.assume(user != address(0));

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

        uint256[] memory priorDistributableBalances = new uint256[](
            tokensProperties.length
        );

        uint256[] memory priorTransferrableBalances = new uint256[](
            tokensProperties.length
        );

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            priorDistributableBalances[i] = s_repTokens.getDistributableBalance(
                DISTRIBUTOR,
                i
            );

            priorTransferrableBalances[i] = s_repTokens.getTransferrableBalance(
                DISTRIBUTOR,
                i
            );
        }

        distribute(distributeOperations);
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            assertEq(s_repTokens.balanceOf(DISTRIBUTOR, i), 0);
            assertEq(
                s_repTokens.balanceOf(user, i),
                tokensProperties[i].maxMintAmountPerTx
            );
            assertEq(
                s_repTokens.getDistributableBalance(DISTRIBUTOR, i),
                priorDistributableBalances[i] -
                    tokensProperties[i].maxMintAmountPerTx
            );
        }
    }

    function testSetDestinationWallet(
        address user,
        address destinationWallet
    ) external {
        vm.assume(user != destinationWallet);
        vm.assume(user != address(0));
        setDestinationWallet(user, destinationWallet);
        assertEq(s_repTokens.getDestinationWallet(user), destinationWallet);
    }

    // function testRedeem() external {
    //     batchCreateTokens(tokensProperties);
    //     ReputationTokensInternal.TokensOperations
    //         memory tokenOperations = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     ReputationTokensInternal.TokensOperations
    //         memory distributeOperations = createTokenOperationsSequential(
    //             USER,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(tokenOperations);
    //     distribute(DISTRIBUTOR, distributeOperations);
    //     vm.startPrank(USER);
    //     s_repTokens.safeTransferFrom(USER, BURNER, 1, DEFAULT_MINT_AMOUNT, "");
    //     vm.stopPrank();
    // }
    // // function testRevertIfRedeemIsTokenIsNotTradeable() external {
    // //     batchCreateTokens(tokensProperties);
    // //     ReputationTokensInternal.TokensOperations
    // //         memory mintOperations = createTokenOperationsSequential(
    // //             DISTRIBUTOR,
    // //             TOKEN_TYPES_TO_CREATE,
    // //             DEFAULT_MINT_AMOUNT
    // //         );
    // //     ReputationTokensInternal.TokensOperations
    // //         memory distributeOperations = createTokenOperationsSequential(
    // //             USER,
    // //             TOKEN_TYPES_TO_CREATE,
    // //             DEFAULT_MINT_AMOUNT
    // //         );
    // //     mint(mintOperations);
    // //     distribute(DISTRIBUTOR, distributeOperations);
    // //     vm.startPrank(USER);
    // //     vm.expectRevert(
    // //         IReputationTokensBaseInternal
    // //             .ReputationTokens__AttemptingToSendNonRedeemableTokens
    // //             .selector
    // //     );
    // //     s_repTokens.safeTransferFrom(USER, BURNER, 0, DEFAULT_MINT_AMOUNT, "");
    // //     vm.stopPrank();
    // // }
    // function testRevertIfRedeemIllegalyAsDistributor() external {
    //     batchCreateTokens(tokensProperties);
    //     ReputationTokensInternal.TokensOperations
    //         memory mintOperations = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(mintOperations);
    //     vm.startPrank(DISTRIBUTOR);
    //     vm.expectRevert(
    //         IReputationTokensBaseInternal
    //             .ReputationTokens__AttemptingToSendTokensFlaggedForDistribution
    //             .selector
    //     );
    //     s_repTokens.safeTransferFrom(
    //         DISTRIBUTOR,
    //         BURNER,
    //         1,
    //         DEFAULT_MINT_AMOUNT,
    //         ""
    //     );
    //     vm.stopPrank();
    // }
    // function testRevertIfRedeemIsNotBeingSentToABurner() external {
    //     batchCreateTokens(tokensProperties);
    //     ReputationTokensInternal.TokensOperations
    //         memory mintOperations = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     ReputationTokensInternal.TokensOperations
    //         memory distributeOperations = createTokenOperationsSequential(
    //             USER,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(mintOperations);
    //     distribute(DISTRIBUTOR, distributeOperations);
    //     vm.startPrank(USER);
    //     vm.expectRevert(
    //         IReputationTokensBaseInternal
    //             .ReputationTokens__AttemptingToSendRedeemableToNonBurner
    //             .selector
    //     );
    //     s_repTokens.safeTransferFrom(
    //         USER,
    //         DISTRIBUTOR,
    //         1,
    //         DEFAULT_MINT_AMOUNT,
    //         ""
    //     );
    //     vm.stopPrank();
    // }
    // function testMigrationOfTokens() external {
    //     batchCreateTokens(tokensProperties);
    //     ReputationTokensInternal.TokensOperations
    //         memory mintOperations = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     ReputationTokensInternal.TokensOperations
    //         memory distributeOperations = createTokenOperationsSequential(
    //             USER,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(mintOperations);
    //     distribute(DISTRIBUTOR, distributeOperations);
    //     vm.startPrank(USER);
    //     s_repTokens.setApprovalForAll(TOKEN_MIGRATOR, true);
    //     vm.stopPrank();
    //     vm.startPrank(TOKEN_MIGRATOR);
    //     s_repTokens.migrateOwnershipOfTokens(USER, USER2);
    //     vm.stopPrank();
    //     for (uint256 i = 0; i < tokensProperties.length; i++) {
    //         assertEq(s_repTokens.balanceOf(USER, i), 0);
    //         assertEq(s_repTokens.balanceOf(USER2, i), DEFAULT_MINT_AMOUNT);
    //     }
    // }
    // function testSetTokenURI(
    //     uint256 numOfTokens,
    //     string[] memory uris
    // ) external {
    //     vm.assume(numOfTokens < uris.length);
    //     vm.startPrank(TOKEN_URI_SETTER);
    //     for (uint256 i = 0; i < numOfTokens; i++) {
    //         s_repTokens.setTokenURI(i, uris[i]);
    //     }
    //     vm.stopPrank();
    //     for (uint256 i = 0; i < numOfTokens; i++) {
    //         assertEq(s_repTokens.uri(i), uris[i]);
    //     }
    // }
    // function testGetMaxMintPerTx() external {
    //     batchCreateTokens(tokensProperties);
    //     for (uint256 i = 0; i < tokensProperties.length; i++) {
    //         assertEq(s_repTokens.getMaxMintPerTx(i), DEFAULT_MINT_AMOUNT);
    //     }
    // }
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
