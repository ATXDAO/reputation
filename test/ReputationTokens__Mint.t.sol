// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__Mint is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////
    function testMint() public {
        uint256 tokenId = createDefaultTokenWithAMintAmount();

        ReputationTokens.Sequence memory sequence;
        sequence.operations = new ReputationTokens.Operation[](1);
        sequence.recipient = DISTRIBUTOR;

        sequence.operations[0].id = tokenId;
        sequence.operations[0].amount = 100;

        mint(sequence);

        assertEq(s_repTokens.balanceOf(DISTRIBUTOR, tokenId), 100);
        assertEq(s_repTokens.getDistributableBalance(DISTRIBUTOR, tokenId), 100);
        assertEq(s_repTokens.getTransferrableBalance(DISTRIBUTOR, tokenId), 0);
    }

    function testBatchMint(uint256 numToMint) public {
        vm.assume(numToMint < 1000);

        uint256 tokenId = createDefaultTokenWithAMintAmount();

        ReputationTokens.Sequence[] memory sequences =
            new ReputationTokens.Sequence[](numToMint);

        for (uint256 i = 0; i < sequences.length; i++) {
            sequences[i].recipient = DISTRIBUTOR;

            sequences[i].operations = new ReputationTokens.Operation[](1);
            sequences[i].operations[0].amount = 100;
            sequences[i].operations[0].id = tokenId;
        }

        batchMint(sequences);
    }

    function testRevertIfMintingTooManyTokens() external {
        uint256 tokenId = createDefaultTokenWithAMintAmount();

        ReputationTokens.Sequence memory sequence;
        sequence.operations = new ReputationTokens.Operation[](1);
        sequence.recipient = DISTRIBUTOR;

        sequence.operations[0].id = tokenId;
        sequence.operations[0].amount = 150;

        vm.expectRevert(
            IReputationTokensErrors
                .ReputationTokens__MintAmountExceedsLimit
                .selector
        );

        mint(sequence);
    }

    function testRevertIfMintingToNonDistributor(uint256 userId) external {
        vm.assume(userId > 0);
        vm.assume(
            userId
                <
                115792089237316195423570985008687907852837564279074904382605163141518161494337
        );

        address user = vm.addr(userId);

        uint256 tokenId = createDefaultTokenWithAMintAmount();

        ReputationTokens.Sequence memory sequence;
        sequence.operations = new ReputationTokens.Operation[](1);
        sequence.recipient = user;

        sequence.operations[0].id = tokenId;
        sequence.operations[0].amount = 100;

        vm.expectRevert(
            IReputationTokensErrors
                .ReputationTokens__CanOnlyMintToDistributor
                .selector
        );

        mint(sequence);
    }
}
