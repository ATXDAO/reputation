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

    function testSafeTransferFromAsUser(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
        address user,
        address recipient
    ) external {
        vm.assume(user != address(0));
        vm.assume(recipient != address(0));

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

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            if (!tokensProperties[i].isSoulbound) {
                vm.prank(user);
                s_repTokens.safeTransferFrom(
                    user,
                    recipient,
                    i,
                    tokensProperties[i].maxMintAmountPerTx,
                    ""
                );
            }
        }
    }

    function testRevertSafeTransferFromAsDistrubtor(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
        address user,
        address recipient
    ) external {
        vm.assume(user != address(0));
        vm.assume(recipient != address(0));

        uint256 divisbleAmount = 2;
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            vm.assume(
                tokensProperties[i].maxMintAmountPerTx % divisbleAmount == 0
            );
        }

        batchCreateTokens(tokensProperties);
        ReputationTokensInternal.TokensOperations
            memory tokenOperations = createTokenOperationsSequential(
                DISTRIBUTOR,
                tokensProperties
            );
        mint(tokenOperations);

        ReputationTokensInternal.TokensOperations
            memory distributeOperations = createTokenOperationsSequentialHalf(
                DISTRIBUTOR,
                tokensProperties,
                divisbleAmount
            );

        uint256[] memory originalDistributableBalances = new uint256[](
            distributeOperations.operations.length
        );

        for (uint256 i = 0; i < distributeOperations.operations.length; i++) {
            originalDistributableBalances[i] = s_repTokens
                .getDistributableBalance(DISTRIBUTOR, i);
        }

        distribute(distributeOperations);

        for (uint256 i = 0; i < distributeOperations.operations.length; i++) {
            assertEq(
                s_repTokens.getDistributableBalance(DISTRIBUTOR, i),
                originalDistributableBalances[i] -
                    distributeOperations.operations[i].amount
            );
        }

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            if (!tokensProperties[i].isSoulbound) {
                uint256 originalTransferrableAmount = s_repTokens
                    .getTransferrableBalance(DISTRIBUTOR, i);

                vm.prank(DISTRIBUTOR);
                s_repTokens.safeTransferFrom(
                    DISTRIBUTOR,
                    recipient,
                    i,
                    distributeOperations.operations[i].amount,
                    ""
                );

                assertEq(
                    s_repTokens.getTransferrableBalance(DISTRIBUTOR, i),
                    originalTransferrableAmount -
                        distributeOperations.operations[i].amount
                );
            }
        }
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
