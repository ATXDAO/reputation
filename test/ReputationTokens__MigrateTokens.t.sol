// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__MigrateTokens is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    function testMigrationOfTokens() external {
        uint256 tokenId = createDefaultTokenWithAMintAmount();

        address user1 = vm.addr(15);
        address user2 = vm.addr(16);

        ReputationTokens.Sequence memory mintSequence;
        mintSequence.operations = new ReputationTokens.Operation[](1);
        mintSequence.recipient = DISTRIBUTOR;

        mintSequence.operations[0].id = tokenId;
        mintSequence.operations[0].amount = 100;

        mint(mintSequence);

        ReputationTokens.Sequence memory distributeSequence;
        distributeSequence.operations = new ReputationTokens.Operation[](1);
        distributeSequence.recipient = user1;

        distributeSequence.operations[0].id = tokenId;
        distributeSequence.operations[0].amount = 100;

        distribute(distributeSequence);

        vm.startPrank(user1);
        s_repTokens.setApprovalForAll(TOKEN_MIGRATOR, true);
        vm.stopPrank();
        vm.startPrank(TOKEN_MIGRATOR);
        s_repTokens.migrateOwnershipOfTokens(user1, user2);
        vm.stopPrank();

        assertEq(s_repTokens.balanceOf(user1, 0), 0);
        assertEq(s_repTokens.balanceOf(user2, 0), 100);
    }

    function testSetTokenURI(
        uint256 numOfTokens,
        string[] memory uris
    ) external {
        vm.assume(numOfTokens < uris.length);
        vm.startPrank(TOKEN_URI_SETTER);
        for (uint256 i = 0; i < numOfTokens; i++) {
            s_repTokens.setTokenURI(i, uris[i]);
        }
        vm.stopPrank();
        for (uint256 i = 0; i < numOfTokens; i++) {
            assertEq(s_repTokens.uri(i), uris[i]);
        }
    }

    function testGetMaxMintPerTx() external {
        uint256 tokenId = createDefaultTokenWithAMintAmount();

        assertEq(s_repTokens.getMaxMintPerTx(tokenId), 100);
    }
}
