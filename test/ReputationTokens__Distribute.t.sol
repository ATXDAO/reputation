// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__Distribute is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    function testDistribute(uint256 userId) public onlyValidAddress(userId) {
        address user = vm.addr(userId);

        uint256 tokenId = createDefaultTokenWithAMintAmount();

        ReputationTokens.Sequence memory mintSequence;
        mintSequence.operations = new ReputationTokens.Operation[](1);
        mintSequence.recipient = DISTRIBUTOR;

        mintSequence.operations[0].id = tokenId;
        mintSequence.operations[0].amount = 100;

        mint(mintSequence);

        ReputationTokens.Sequence memory distributeSequence;
        distributeSequence.operations = new ReputationTokens.Operation[](1);
        distributeSequence.recipient = user;

        distributeSequence.operations[0].id = tokenId;
        distributeSequence.operations[0].amount = 100;

        uint256 priorDistributableBalance =
            s_repTokens.getDistributableBalance(DISTRIBUTOR, 0);

        distribute(distributeSequence);

        assertEq(s_repTokens.balanceOf(DISTRIBUTOR, 0), 0);
        assertEq(s_repTokens.balanceOf(user, 0), 100);
        assertEq(
            s_repTokens.getDistributableBalance(DISTRIBUTOR, 0),
            priorDistributableBalance - 100
        );
        assertEq(s_repTokens.getTransferrableBalance(user, 0), 100);
    }

    function testDistributeBatch(uint256 numOfSequences) public {
        vm.assume(numOfSequences < 1000);

        address user = vm.addr(15);

        uint256 tokenId = createDefaultTokenWithAMintAmount();

        ReputationTokens.Sequence memory mintSequence;
        mintSequence.operations = new ReputationTokens.Operation[](1);
        mintSequence.recipient = DISTRIBUTOR;

        mintSequence.operations[0].id = tokenId;
        mintSequence.operations[0].amount = 100;

        mint(mintSequence);

        ReputationTokens.Sequence[] memory distributeSequences =
            new ReputationTokens.Sequence[](numOfSequences);

        for (uint256 i = 0; i < distributeSequences.length; i++) {
            distributeSequences[i].recipient = user;
            distributeSequences[i].operations =
                new ReputationTokens.Operation[](1);
            distributeSequences[i].operations[0].id = tokenId;
            distributeSequences[i].operations[0].amount = 100 / numOfSequences;
        }

        batchDistribute(distributeSequences);
    }

    function testSetDestinationWallet(
        uint256 userId,
        uint256 destinationWalletId
    ) external onlyValidAddress(userId) onlyValidAddress(destinationWalletId) {
        address user = vm.addr(userId);
        address destinationWallet = vm.addr(destinationWalletId);
        setDestinationWallet(user, destinationWallet);
        assertEq(s_repTokens.getDestinationWallet(user), destinationWallet);
    }
}
