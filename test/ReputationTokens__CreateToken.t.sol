// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";

// import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
// import {ReputationTokens} from "../contracts/ReputationTokens.sol";

// import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

// contract ReputationTokens__CreateToken is ReputationTokensTest__Base {
//     ////////////////////////
//     // Tests
//     ////////////////////////
//     function testCreateToken(uint256 tokenTypeId) public {
//         tokenTypeId = bound(tokenTypeId, 0, 2);

//         ReputationTokens.TokenType tokenType =
//             ReputationTokens.TokenType(tokenTypeId);

//         uint256 tokenId = createToken(tokenType);

//         ReputationTokens.TokenType createdTokenType =
//             s_repTokens.getTokenType(tokenId);

//         assertEq(uint8(createdTokenType), tokenTypeId);
//     }

//     function testBatchCreateTokens(uint256 numToCreate) public {
//         vm.assume(numToCreate < 1000);

//         ReputationTokens.TokenType[] memory tokensType =
//             new ReputationTokens.TokenType[](numToCreate);

//         for (uint256 i = 0; i < numToCreate; i++) {
//             tokensType[i] = ReputationTokens.TokenType.Transferable;
//         }
//         batchCreateTokens(tokensType);

//         assertEq(tokensType.length, s_repTokens.getNumOfTokenTypes());
//     }
// }
