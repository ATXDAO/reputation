// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
// import {ReputationTokens} from "../contracts/ReputationTokens.sol";

// import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

// contract ReputationTokens__Mint is ReputationTokensTest__Base {
//     address minter;

//     uint256 NUM_OF_TOKEN_TYPES = 100000;

//     function setUp() public override {
//         super.setUp();

//         for (uint256 i = 0; i < type(uint256).max; i++) {
//             createToken(ReputationTokens.TokenType.Transferable);
//         }

//         // createToken(ReputationTokens.TokenType.Transferable);

//         // minter = makeAddr("Minter");

//         // ReputationTokens.Sequence memory mintSequence;
//         // mintSequence.operations = new ReputationTokens.Operation[](1);
//         // mintSequence.recipient = minter;

//         // mintSequence.operations[0].id = tokenId;
//         // mintSequence.operations[0].amount = type(uint256).max;
//         // vm.prank(ADMIN);
//         // s_repTokens.addMintAllowance(mintSequence);
//     }

//     ////////////////////////
//     // Tests
//     ////////////////////////
//     function testMint(
//         uint256 addrId,
//         uint256 tokenId,
//         uint256 mintAmount
//     ) public onlyValidAddress(addrId) {
//         // uint256 tokenId = createToken(ReputationTokens.TokenType.Transferable);

//         address distributor = vm.addr(addrId);

//         vm.prank(ADMIN);
//         s_repTokens.mint(distributor, tokenId, mintAmount, "");

//         assertEq(s_repTokens.balanceOf(distributor, tokenId), mintAmount);
//         assertEq(
//             s_repTokens.distributableBalanceOf(distributor, tokenId), mintAmount
//         );
//         assertEq(
//             s_repTokens.honestBalanceOf(distributor, tokenId),
//             s_repTokens.balanceOf(distributor, tokenId) - mintAmount
//         );
//     }

//     function testBatchMint(
//         uint256 addrId,
//         uint256[] memory idsAndValues
//     ) public onlyValidAddress(addrId) {
//         bool isCopy = false;

//         for (uint256 i = 0; i < idsAndValues.length; i++) {
//             for (uint256 j = 0; j < idsAndValues.length; j++) {
//                 if (i != j) {
//                     if (idsAndValues[i] == idsAndValues[j]) {
//                         isCopy = true;
//                         break;
//                     }
//                 }
//             }
//         }
//         vm.assume(!isCopy);

//         address distributor = vm.addr(addrId);

//         vm.prank(ADMIN);
//         s_repTokens.mintBatch(distributor, idsAndValues, idsAndValues, "");

//         // vm.assume(numToMint < 1000);

//         // uint256 tokenId = createDefaultTokenWithAMintAmount();

//         // ReputationTokens.Sequence[] memory sequences =
//         //     new ReputationTokens.Sequence[](numToMint);

//         // for (uint256 i = 0; i < sequences.length; i++) {
//         //     sequences[i].recipient = DISTRIBUTOR;

//         //     sequences[i].operations = new ReputationTokens.Operation[](1);
//         //     sequences[i].operations[0].amount = 100;
//         //     sequences[i].operations[0].id = tokenId;
//         // }

//         // batchMint(sequences);
//     }

//     // function testRevertIfMintingTooManyTokens() external {
//     //     uint256 tokenId = createDefaultTokenWithAMintAmount();

//     //     ReputationTokens.Sequence memory sequence;
//     //     sequence.operations = new ReputationTokens.Operation[](1);
//     //     sequence.recipient = DISTRIBUTOR;

//     //     sequence.operations[0].id = tokenId;
//     //     sequence.operations[0].amount = 150;

//     //     vm.expectRevert(
//     //         IReputationTokensErrors
//     //             .ReputationTokens__MintAmountExceedsLimit
//     //             .selector
//     //     );

//     //     mint(sequence);
//     // }

//     // function testRevertIfMintingToNonDistributor(uint256 userId) external {
//     //     vm.assume(userId > 0);
//     //     vm.assume(
//     //         userId
//     //             <
//     //             115792089237316195423570985008687907852837564279074904382605163141518161494337
//     //     );

//     //     address user = vm.addr(userId);

//     //     uint256 tokenId = createDefaultTokenWithAMintAmount();

//     //     ReputationTokens.Sequence memory sequence;
//     //     sequence.operations = new ReputationTokens.Operation[](1);
//     //     sequence.recipient = user;

//     //     sequence.operations[0].id = tokenId;
//     //     sequence.operations[0].amount = 100;

//     //     vm.expectRevert(
//     //         IReputationTokensErrors
//     //             .ReputationTokens__CanOnlyMintToDistributor
//     //             .selector
//     //     );

//     //     mint(sequence);
//     // }
// }
