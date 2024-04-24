// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
// import {ReputationTokens} from "../contracts/ReputationTokens.sol";

// import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

// contract ReputationTokens__AddAllowance is ReputationTokensTest__Base {
//     function setUp() public override {
//         super.setUp();

//         createToken(ReputationTokens.TokenType.Transferable);
//     }

//     ////////////////////////
//     // Tests
//     ////////////////////////

//     function testAddAllowance(
//         uint256 addrId,
//         uint256 allowanceToAdd
//     ) public onlyValidAddress(addrId) {
//         address addr = vm.addr(addrId);

//         ReputationTokens.Sequence memory mintSequence;
//         mintSequence.recipient = addr;
//         mintSequence.operations = new ReputationTokens.Operation[](1);
//         mintSequence.operations[0].id = 0;
//         mintSequence.operations[0].amount = allowanceToAdd;

//         vm.prank(ADMIN);
//         s_repTokens.addMintAllowance(mintSequence);

//         assertEq(allowanceToAdd, s_repTokens.getMintAllowance(addr, 0));
//     }

//     function testBatchAddAllowance(uint256[] memory ids)
//         public
//         onlyValidAddresses(ids)
//     {
//         ReputationTokens.Sequence[] memory mintSequences =
//             new ReputationTokens.Sequence[](ids.length);

//         for (uint256 i = 0; i < mintSequences.length; i++) {
//             ReputationTokens.Sequence memory mintSequence;
//             mintSequence.recipient = vm.addr(ids[i]);
//             mintSequence.operations = new ReputationTokens.Operation[](1);
//             mintSequence.operations[0].id = 0;
//             mintSequence.operations[0].amount = 500;
//             mintSequences[i] = mintSequence;
//         }

//         vm.prank(ADMIN);
//         s_repTokens.batchAddMintAllowances(mintSequences);
//     }
// }
