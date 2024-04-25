// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
// import {ReputationTokens} from "../contracts/ReputationTokens.sol";

// import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";
// import {IReputationTokensEvents} from "../contracts/IReputationTokensEvents.sol";

// contract ReputationTokens__Distribute is ReputationTokensTest__Base {
//     function setUp() public override {
//         super.setUp();
//     }

//     ////////////////////////
//     // Tests
//     ////////////////////////
//     function testDistribute(
//         uint256 addrId,
//         uint256 tokenId,
//         uint256 mintAmount
//     ) public onlyValidAddress(addrId) {
//         address distributor = vm.addr(addrId);

//         vm.expectEmit();
//         emit IReputationTokensEvents.Mint(
//             MINTER, distributor, tokenId, mintAmount
//         );

//         vm.prank(MINTER);
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

//     function testMintBatch(
//         uint256 toId,
//         uint256[] memory ids,
//         uint32[] memory values32
//     ) public onlyValidAddress(toId) {
//         uint256[] memory values = new uint256[](values32.length);

//         for (uint256 i = 0; i < values.length; i++) {
//             values[i] = values32[i];
//         }

//         (uint256[] memory cauterizedIds, uint256[] memory cauterizedValues) =
//             cauterizeLength(ids, values);

//         address to = vm.addr(toId);

//         vm.prank(MINTER);
//         s_repTokens.mintBatch(to, cauterizedIds, cauterizedValues, "");
//     }
// }
