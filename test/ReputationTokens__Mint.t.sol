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
    // function setUp() public override {
    //     super.setUp();
    // }

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

    // function testDistribute() external {
    //     batchCreateTokens(tokensProperties);
    //     uint256 numOfTokens = TOKEN_TYPES_TO_CREATE;
    //     address user = makeAddr("USER");
    //     ReputationTokensInternal.TokensOperations
    //         memory tokenOperations = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             numOfTokens,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(tokenOperations);
    //     ReputationTokensInternal.TokensOperations
    //         memory distributeOperations = createTokenOperationsSequential(
    //             user,
    //             numOfTokens,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     vm.startPrank(DISTRIBUTOR);
    //     s_repTokens.distribute(DISTRIBUTOR, distributeOperations, "");
    //     vm.stopPrank();
    //     for (uint256 i = 0; i < numOfTokens; i++) {
    //         assertEq(s_repTokens.balanceOf(DISTRIBUTOR, i), 0);
    //         assertEq(s_repTokens.balanceOf(user, i), DEFAULT_MINT_AMOUNT);
    //         assertEq(s_repTokens.getDistributableBalance(DISTRIBUTOR, i), 0);
    //         assertEq(s_repTokens.getTransferrableBalance(DISTRIBUTOR, i), 0);
    //     }
    // }
    // function testDistributeBatch() external {
    //     batchCreateTokens(tokensProperties);
    //     ReputationTokensInternal.TokensOperations
    //         memory mintOps = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(mintOps);
    //     address[] memory users = generateUsers(5);
    //     ReputationTokensInternal.TokensOperations[]
    //         memory batchOps = new ReputationTokensInternal.TokensOperations[](
    //             users.length
    //         );
    //     for (uint256 i = 0; i < batchOps.length; i++) {
    //         ReputationTokensInternal.TokensOperations
    //             memory distributeOps = createTokenOperationsSequential(
    //                 users[i],
    //                 TOKEN_TYPES_TO_CREATE,
    //                 DEFAULT_MINT_AMOUNT / users.length
    //             );
    //         batchOps[i] = distributeOps;
    //     }
    //     vm.startPrank(DISTRIBUTOR);
    //     s_repTokens.distributeBatch(DISTRIBUTOR, batchOps, "");
    //     vm.stopPrank();
    //     for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
    //         assertEq(s_repTokens.balanceOf(DISTRIBUTOR, i), 0);
    //         for (uint256 j = 0; j < batchOps.length; j++) {
    //             assertEq(
    //                 s_repTokens.balanceOf(batchOps[j].to, i),
    //                 DEFAULT_MINT_AMOUNT / users.length
    //             );
    //         }
    //     }
    // }
    // function testSetDestinationWalletAndDistribute() external {
    //     batchCreateTokens(tokensProperties);
    //     uint256 numOfTokens = 1;
    //     ReputationTokensInternal.TokensOperations
    //         memory tokenOperations = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             numOfTokens,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(tokenOperations);
    //     setDestinationWallet(USER, DESTINATION_WALLET);
    //     ReputationTokensInternal.TokensOperations
    //         memory distributeOperations = createTokenOperationsSequential(
    //             USER,
    //             numOfTokens,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     distribute(DISTRIBUTOR, distributeOperations);
    //     for (uint256 i = 0; i < numOfTokens; i++) {
    //         assertEq(
    //             s_repTokens.balanceOf(
    //                 s_repTokens.getDestinationWallet(USER),
    //                 i
    //             ),
    //             DEFAULT_MINT_AMOUNT
    //         );
    //         assertEq(
    //             s_repTokens.balanceOf(DESTINATION_WALLET, i),
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     }
    // }
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
