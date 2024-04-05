// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {ReputationTokensStandalone} from "../contracts/ReputationTokensStandalone.sol";
// import {IReputationTokensBaseInternal} from "../contracts/IReputationTokensBaseInternal.sol";
// import {TokensPropertiesStorage} from "../contracts/storage/TokensPropertiesStorage.sol";
// import {ReputationTokensInternal} from "../contracts/ReputationTokensInternal.sol";
// import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

// contract ReputationTokens__Distribute is ReputationTokensTest__Base {
//     ////////////////////////
//     // Tests
//     ////////////////////////

//     function testDistribute(uint256 fromId) public onlyValidAddress(fromId) {
//         address user = vm.addr(fromId);

//         createToken(
//             TokensPropertiesStorage.TokenProperties(
//                 TokensPropertiesStorage.TokenType(0),
//                 false,
//                 false,
//                 100
//             )
//         );

//         ReputationTokensInternal.TokensOperations memory mintOperations;
//         mintOperations
//             .operations = new ReputationTokensInternal.TokenOperation[](1);
//         mintOperations.to = DISTRIBUTOR;

//         mintOperations.operations[0].id = 0;
//         mintOperations.operations[0].amount = 100;

//         mint(mintOperations);

//         ReputationTokensInternal.TokensOperations memory distributeOperations;
//         distributeOperations
//             .operations = new ReputationTokensInternal.TokenOperation[](1);
//         distributeOperations.to = user;

//         distributeOperations.operations[0].id = 0;
//         distributeOperations.operations[0].amount = 100;

//         uint256 priorDistributableBalance = s_repTokens.getDistributableBalance(
//             DISTRIBUTOR,
//             0
//         );

//         distribute(distributeOperations);

//         assertEq(s_repTokens.balanceOf(DISTRIBUTOR, 0), 0);
//         assertEq(s_repTokens.balanceOf(user, 0), 100);
//         assertEq(
//             s_repTokens.getDistributableBalance(DISTRIBUTOR, 0),
//             priorDistributableBalance - 100
//         );
//         assertEq(s_repTokens.getTransferrableBalance(user, 0), 100);
//     }

//     function testSetDestinationWallet(
//         uint256 userId,
//         uint256 destinationWalletId
//     ) external onlyValidAddress(userId) onlyValidAddress(destinationWalletId) {
//         address user = vm.addr(userId);
//         address destinationWallet = vm.addr(destinationWalletId);
//         setDestinationWallet(user, destinationWallet);
//         assertEq(s_repTokens.getDestinationWallet(user), destinationWallet);
//     }
// }
