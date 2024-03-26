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

    // function testUpdateToken(
    //     TokensPropertiesStorage.TokenProperties memory _tokenProperties
    // ) public {
    //     batchCreateTokens(tokensProperties);
    //     updateToken(0, _tokenProperties);
    //     assertEq(
    //         s_repTokens.getTokenProperties(0).isSoulbound,
    //         _tokenProperties.isSoulbound
    //     );
    //     assertEq(
    //         s_repTokens.getTokenProperties(0).isRedeemable,
    //         _tokenProperties.isRedeemable
    //     );
    //     assertEq(
    //         s_repTokens.getTokenProperties(0).maxMintAmountPerTx,
    //         _tokenProperties.maxMintAmountPerTx
    //     );
    // }
    // function testUpdateToken() external {
    //     TokensPropertiesStorage.TokenProperties
    //         memory _tokenProperties = TokensPropertiesStorage.TokenProperties(
    //             true,
    //             false,
    //             1000
    //         );
    //     testUpdateToken(_tokenProperties);
    // }
    // function testRevertIfUpdatingNonexistentToken() external {
    //     TokensPropertiesStorage.TokenProperties
    //         memory _tokenProperties = TokensPropertiesStorage.TokenProperties(
    //             true,
    //             false,
    //             1000
    //         );
    //     vm.expectRevert(
    //         IReputationTokensBaseInternal
    //             .ReputationTokens__AttemptingToUpdateNonexistentToken
    //             .selector
    //     );
    //     updateToken(0, _tokenProperties);
    // }
    // function testMint(
    //     address minter,
    //     address distributor,
    //     TokenTypesStorage.TokenType[] memory types
    // ) public {
    //     vm.assume(minter != 0x0000000000000000000000000000000000000000);
    //     vm.assume(distributor != 0x0000000000000000000000000000000000000000);
    //     vm.assume(types.length > 0);
    //     for (uint256 i = 0; i < types.length; i++) {
    //         vm.assume(types[i].maxMintAmountPerTx > 0);
    //     }
    //     batchCreateTokenTypes(types);
    //     setUpRole(s_repTokens.DISTRIBUTOR_ROLE(), distributor);
    //     ReputationTokensInternal.TokenOperation[]
    //         memory tokenOperations = createTokenOperationsSequential(
    //             types.length,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(minter, distributor, tokenOperations);
    //     for (uint256 i = 0; i < types.length; i++) {
    //         assertEq(
    //             s_repTokens.balanceOf(distributor, i),
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     }
    // }
    // function testMint() public {
    //     batchCreateTokens(tokensProperties);
    //     ReputationTokensInternal.TokensOperations
    //         memory tokenOperations = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     mint(tokenOperations);
    //     for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
    //         assertEq(
    //             s_repTokens.balanceOf(DISTRIBUTOR, i),
    //             DEFAULT_MINT_AMOUNT
    //         );
    //         assertEq(
    //             s_repTokens.getDistributableBalance(DISTRIBUTOR, i),
    //             DEFAULT_MINT_AMOUNT
    //         );
    //         assertEq(s_repTokens.getTransferrableBalance(DISTRIBUTOR, i), 0);
    //     }
    // }
    // function testRevertIfMintingTooManyTokens() external {
    //     batchCreateTokens(tokensProperties);
    //     ReputationTokensInternal.TokensOperations
    //         memory mintOperations = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT + 1
    //         );
    //     vm.startPrank(MINTER);
    //     vm.expectRevert(
    //         IReputationTokensBaseInternal
    //             .ReputationTokens__AttemptingToMintTooManyTokens
    //             .selector
    //     );
    //     s_repTokens.mint(mintOperations);
    //     vm.stopPrank();
    // }
    // function testRevertIfMintingToNonDistributor() external {
    //     batchCreateTokens(tokensProperties);
    //     ReputationTokensInternal.TokensOperations
    //         memory tokenOperations = createTokenOperationsSequential(
    //             USER,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     vm.startPrank(MINTER);
    //     vm.expectRevert(
    //         IReputationTokensBaseInternal
    //             .ReputationTokens__AttemptingToMintToNonDistributor
    //             .selector
    //     );
    //     s_repTokens.mint(tokenOperations);
    //     vm.stopPrank();
    // }
    // function testMintBatch() external {
    //     address distributor2 = vm.addr(5);
    //     setUpRole(s_repTokens.DISTRIBUTOR_ROLE(), distributor2);
    //     batchCreateTokens(tokensProperties);
    //     address[] memory distributors = new address[](2);
    //     distributors[0] = DISTRIBUTOR;
    //     distributors[1] = distributor2;
    //     ReputationTokensInternal.TokensOperations
    //         memory mintOperations1 = createTokenOperationsSequential(
    //             DISTRIBUTOR,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     ReputationTokensInternal.TokensOperations
    //         memory mintOperations2 = createTokenOperationsSequential(
    //             distributor2,
    //             TOKEN_TYPES_TO_CREATE,
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     ReputationTokensInternal.TokensOperations[]
    //         memory batchMintOperations = new ReputationTokensInternal.TokensOperations[](
    //             distributors.length
    //         );
    //     batchMintOperations[0] = mintOperations1;
    //     batchMintOperations[1] = mintOperations2;
    //     vm.startPrank(MINTER);
    //     s_repTokens.mintBatch(batchMintOperations);
    //     vm.stopPrank();
    //     for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
    //         for (uint256 j = 0; j < distributors.length; j++) {
    //             assertEq(
    //                 s_repTokens.balanceOf(distributors[j], i),
    //                 DEFAULT_MINT_AMOUNT
    //             );
    //         }
    //     }
    // }
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
