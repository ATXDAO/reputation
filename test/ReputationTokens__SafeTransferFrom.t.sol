// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
// import {ReputationTokens} from "../contracts/ReputationTokens.sol";

// import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

// contract ReputationTokens__SafeTransferFrom is ReputationTokensTest__Base {
//     uint256 constant DEFAULT_MAX_MINT_AMOUNT = 100;

//     address user1;
//     address transferRecipient;

//     function setUp() public override {
//         user1 = vm.addr(15);
//         transferRecipient = vm.addr(17);

//         super.setUp();
//     }

//     function createAndMintAndDistributTokenWithMaxMintAmountMoreThanZero(
//         ReputationTokens.TokenType tokenType
//     ) public returns (uint256 tokenId) {
//         tokenId = createToken(ReputationTokens.TokenType(tokenType));

//         ReputationTokens.Sequence memory mintSequence;
//         mintSequence.operations = new ReputationTokens.Operation[](1);
//         mintSequence.recipient = DISTRIBUTOR;

//         mintSequence.operations[0].id = tokenId;
//         mintSequence.operations[0].amount = DEFAULT_MAX_MINT_AMOUNT;

//         mint(mintSequence);
//     }

//     function createAndMintAndDistributeSoulboundTokenWithMaxMintAmountMoreThanZero(
//     ) internal returns (uint256 tokenId) {
//         tokenId = createAndMintAndDistributTokenWithMaxMintAmountMoreThanZero(
//             ReputationTokens.TokenType.Soulbound
//         );
//     }

//     function createAndMintAndDistributeRedeemableTokenWithMaxMintAmountMoreThanZero(
//     ) internal returns (uint256 tokenId) {
//         tokenId = createAndMintAndDistributTokenWithMaxMintAmountMoreThanZero(
//             ReputationTokens.TokenType.Redeemable
//         );
//     }

//     function createAndMintAndDistributeDefaultTokenWithMaxMintAmountMoreThanZero(
//     ) internal returns (uint256 tokenId) {
//         tokenId = createAndMintAndDistributTokenWithMaxMintAmountMoreThanZero(
//             ReputationTokens.TokenType.Transferable
//         );
//     }

//     ////////////////////////
//     // Tests
//     ////////////////////////

//     function testSafeTransferFrom() public {
//         uint256 tokenId =
//         createAndMintAndDistributeDefaultTokenWithMaxMintAmountMoreThanZero();

//         vm.prank(user1);
//         s_repTokens.safeTransferFrom(
//             user1, transferRecipient, tokenId, DEFAULT_MAX_MINT_AMOUNT, ""
//         );
//     }

//     function testSafeTransferFromBurn() public {
//         uint256 tokenId =
//         createAndMintAndDistributeRedeemableTokenWithMaxMintAmountMoreThanZero();

//         vm.prank(user1);
//         s_repTokens.safeTransferFrom(
//             user1, BURNER, tokenId, DEFAULT_MAX_MINT_AMOUNT, ""
//         );

//         assertEq(
//             s_repTokens.getBurnedBalance(BURNER, tokenId),
//             DEFAULT_MAX_MINT_AMOUNT
//         );
//     }

//     function testRevertSafeTransferFromSoulbound() public {
//         uint256 tokenId =
//         createAndMintAndDistributeSoulboundTokenWithMaxMintAmountMoreThanZero();

//         vm.prank(user1);

//         vm.expectRevert(
//             IReputationTokensErrors
//                 .ReputationTokens__CannotTransferSoulboundToken
//                 .selector
//         );

//         s_repTokens.safeTransferFrom(
//             user1, transferRecipient, tokenId, DEFAULT_MAX_MINT_AMOUNT, ""
//         );
//     }

//     function testRevertIfTryingToTransferRedeemableToNonBurner() external {
//         uint256 tokenId =
//         createAndMintAndDistributeRedeemableTokenWithMaxMintAmountMoreThanZero();

//         vm.prank(user1);

//         vm.expectRevert(
//             IReputationTokensErrors
//                 .ReputationTokens__CannotTransferRedeemableToNonBurner
//                 .selector
//         );

//         s_repTokens.safeTransferFrom(
//             user1, transferRecipient, tokenId, DEFAULT_MAX_MINT_AMOUNT, ""
//         );
//     }

//     function testRevertSafeTransferFromCantSendThatManyTransferrableTokens()
//         external
//     {
//         uint256 tokenId =
//         createAndMintAndDistributeDefaultTokenWithMaxMintAmountMoreThanZero();

//         vm.prank(user1);

//         vm.expectRevert(
//             IReputationTokensErrors
//                 .ReputationTokens__CantSendThatManyTransferrableTokens
//                 .selector
//         );
//         s_repTokens.safeTransferFrom(
//             DISTRIBUTOR,
//             transferRecipient,
//             tokenId,
//             DEFAULT_MAX_MINT_AMOUNT + 1,
//             ""
//         );
//     }
// }
