// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {ReputationTokensStandalone} from "../contracts/ReputationTokensStandalone.sol";
// import {IReputationTokensBaseInternal} from "../contracts/IReputationTokensBaseInternal.sol";
// import {TokensPropertiesStorage} from "../contracts/storage/TokensPropertiesStorage.sol";
// import {ReputationTokensInternal} from "../contracts/ReputationTokensInternal.sol";
// import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

// contract ReputationTokens__SafeTransferFrom is ReputationTokensTest__Base {
//     ////////////////////////
//     // Tests
//     ////////////////////////

//     function testSafeTransferFromAsUser(
//         TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
//         address user,
//         address recipient
//     ) external {
//         vm.assume(user != address(0));
//         vm.assume(recipient != address(0));

//         batchCreateTokens(tokensProperties);
//         ReputationTokensInternal.TokensOperations
//             memory tokenOperations = createTokenOperationsSequential(
//                 DISTRIBUTOR,
//                 tokensProperties
//             );
//         mint(tokenOperations);
//         ReputationTokensInternal.TokensOperations
//             memory distributeOperations = createTokenOperationsSequential(
//                 user,
//                 tokensProperties
//             );

//         distribute(distributeOperations);

//         for (uint256 i = 0; i < tokensProperties.length; i++) {
//             if (!tokensProperties[i].isSoulbound) {
//                 vm.prank(user);
//                 s_repTokens.safeTransferFrom(
//                     user,
//                     recipient,
//                     i,
//                     tokensProperties[i].maxMintAmountPerTx,
//                     ""
//                 );
//             }
//         }
//     }

//     function testSafeTransferFromBurnAsUser(
//         TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
//         address user
//     ) external {
//         vm.assume(user != address(0));

//         batchCreateTokens(tokensProperties);
//         ReputationTokensInternal.TokensOperations
//             memory tokenOperations = createTokenOperationsSequential(
//                 DISTRIBUTOR,
//                 tokensProperties
//             );
//         mint(tokenOperations);
//         ReputationTokensInternal.TokensOperations
//             memory distributeOperations = createTokenOperationsSequential(
//                 user,
//                 tokensProperties
//             );

//         distribute(distributeOperations);

//         for (uint256 i = 0; i < distributeOperations.operations.length; i++) {
//             TokensPropertiesStorage.TokenProperties
//                 memory tokenProperties = s_repTokens.getTokenProperties(i);
//             if (tokenProperties.isSoulbound) {
//                 if (tokenProperties.isRedeemable) {
//                     vm.prank(user);
//                     s_repTokens.safeTransferFrom(
//                         user,
//                         BURNER,
//                         i,
//                         distributeOperations.operations[i].amount,
//                         ""
//                     );

//                     assertEq(
//                         s_repTokens.getBurnedBalance(BURNER, i),
//                         distributeOperations.operations[i].amount
//                     );
//                 }
//             }
//         }
//     }

//     function testRevertIfTryingToSendSoulboundToken(
//         TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
//         address user,
//         address recipient
//     ) external {
//         vm.assume(user != address(0));
//         vm.assume(recipient != address(0));

//         batchCreateTokens(tokensProperties);
//         ReputationTokensInternal.TokensOperations
//             memory tokenOperations = createTokenOperationsSequential(
//                 DISTRIBUTOR,
//                 tokensProperties
//             );
//         mint(tokenOperations);
//         ReputationTokensInternal.TokensOperations
//             memory distributeOperations = createTokenOperationsSequential(
//                 user,
//                 tokensProperties
//             );

//         distribute(distributeOperations);

//         for (uint256 i = 0; i < distributeOperations.operations.length; i++) {
//             TokensPropertiesStorage.TokenProperties
//                 memory tokenProperties = s_repTokens.getTokenProperties(i);

//             if (tokenProperties.isSoulbound && !tokenProperties.isRedeemable) {
//                 vm.prank(user);

//                 vm.expectRevert(
//                     IReputationTokensBaseInternal
//                         .ReputationTokens__CannotTransferSoulboundToken
//                         .selector
//                 );

//                 s_repTokens.safeTransferFrom(
//                     user,
//                     recipient,
//                     i,
//                     distributeOperations.operations[i].amount,
//                     ""
//                 );
//             }
//         }
//     }

//     function testRevertIfTryingToTransferRedeemableToNonBurner(
//         TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
//         address user,
//         address recipient
//     ) external {
//         vm.assume(user != address(0));
//         vm.assume(recipient != address(0));

//         batchCreateTokens(tokensProperties);
//         ReputationTokensInternal.TokensOperations
//             memory tokenOperations = createTokenOperationsSequential(
//                 DISTRIBUTOR,
//                 tokensProperties
//             );
//         mint(tokenOperations);
//         ReputationTokensInternal.TokensOperations
//             memory distributeOperations = createTokenOperationsSequential(
//                 user,
//                 tokensProperties
//             );

//         distribute(distributeOperations);

//         for (uint256 i = 0; i < distributeOperations.operations.length; i++) {
//             TokensPropertiesStorage.TokenProperties
//                 memory tokenProperties = s_repTokens.getTokenProperties(i);

//             if (tokenProperties.isSoulbound && tokenProperties.isRedeemable) {
//                 vm.prank(user);

//                 vm.expectRevert(
//                     IReputationTokensBaseInternal
//                         .ReputationTokens__CannotTransferRedeemableToNonBurner
//                         .selector
//                 );

//                 s_repTokens.safeTransferFrom(
//                     user,
//                     recipient,
//                     i,
//                     distributeOperations.operations[i].amount,
//                     ""
//                 );
//             }
//         }
//     }

//     function testRevertSafeTransferFromCantSendThatManyTransferrableTokensAsDistributor(
//         TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
//         address user,
//         address recipient
//     ) external {
//         vm.assume(user != address(0));
//         vm.assume(recipient != address(0));

//         uint256 divisbleAmount = 2;
//         for (uint256 i = 0; i < tokensProperties.length; i++) {
//             vm.assume(
//                 tokensProperties[i].maxMintAmountPerTx % divisbleAmount == 0
//             );

//             vm.assume(tokensProperties[i].maxMintAmountPerTx != 0);
//         }

//         batchCreateTokens(tokensProperties);
//         ReputationTokensInternal.TokensOperations
//             memory tokenOperations = createTokenOperationsSequential(
//                 DISTRIBUTOR,
//                 tokensProperties
//             );
//         mint(tokenOperations);
//         ReputationTokensInternal.TokensOperations
//             memory distributeOperations = createTokenOperationsSequentialHalf(
//                 DISTRIBUTOR,
//                 tokensProperties,
//                 divisbleAmount
//             );

//         distribute(distributeOperations);

//         for (uint256 i = 0; i < tokensProperties.length; i++) {
//             if (!tokensProperties[i].isSoulbound) {
//                 vm.prank(DISTRIBUTOR);

//                 vm.expectRevert(
//                     IReputationTokensBaseInternal
//                         .ReputationTokens__CantSendThatManyTransferrableTokens
//                         .selector
//                 );
//                 s_repTokens.safeTransferFrom(
//                     DISTRIBUTOR,
//                     recipient,
//                     i,
//                     tokensProperties[i].maxMintAmountPerTx,
//                     ""
//                 );
//             }
//         }
//     }

//     function testSafeTransferFromDistributableBalancesChecks(
//         TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
//         address recipient
//     ) external {
//         vm.assume(recipient != address(0));

//         uint256 divisbleAmount = 2;
//         for (uint256 i = 0; i < tokensProperties.length; i++) {
//             vm.assume(
//                 tokensProperties[i].maxMintAmountPerTx % divisbleAmount == 0
//             );
//         }

//         batchCreateTokens(tokensProperties);
//         ReputationTokensInternal.TokensOperations
//             memory tokenOperations = createTokenOperationsSequential(
//                 DISTRIBUTOR,
//                 tokensProperties
//             );
//         mint(tokenOperations);

//         ReputationTokensInternal.TokensOperations
//             memory distributeOperations = createTokenOperationsSequentialHalf(
//                 DISTRIBUTOR,
//                 tokensProperties,
//                 divisbleAmount
//             );

//         uint256[] memory originalDistributableBalances = new uint256[](
//             distributeOperations.operations.length
//         );

//         for (uint256 i = 0; i < distributeOperations.operations.length; i++) {
//             originalDistributableBalances[i] = s_repTokens
//                 .getDistributableBalance(DISTRIBUTOR, i);
//         }

//         distribute(distributeOperations);

//         for (uint256 i = 0; i < distributeOperations.operations.length; i++) {
//             assertEq(
//                 s_repTokens.getDistributableBalance(DISTRIBUTOR, i),
//                 originalDistributableBalances[i] -
//                     distributeOperations.operations[i].amount
//             );
//         }

//         for (uint256 i = 0; i < tokensProperties.length; i++) {
//             if (!tokensProperties[i].isSoulbound) {
//                 uint256 originalTransferrableAmount = s_repTokens
//                     .getTransferrableBalance(DISTRIBUTOR, i);

//                 vm.prank(DISTRIBUTOR);
//                 s_repTokens.safeTransferFrom(
//                     DISTRIBUTOR,
//                     recipient,
//                     i,
//                     distributeOperations.operations[i].amount,
//                     ""
//                 );

//                 assertEq(
//                     s_repTokens.getTransferrableBalance(DISTRIBUTOR, i),
//                     originalTransferrableAmount -
//                         distributeOperations.operations[i].amount
//                 );
//             }
//         }
//     }
// }
