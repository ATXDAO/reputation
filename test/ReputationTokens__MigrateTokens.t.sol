// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../contracts/ReputationTokensStandalone.sol";
import {IReputationTokensBaseInternal} from "../contracts/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../contracts/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../contracts/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__MigrateTokens is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    function testMigrationOfTokens() external {
        uint256 tokenId = createToken(
            TokensPropertiesStorage.TokenProperties(
                TokensPropertiesStorage.TokenType(0),
                false,
                false,
                100
            )
        );

        address user1 = vm.addr(15);
        address user2 = vm.addr(16);

        ReputationTokensInternal.Sequence memory mintSequence;
        mintSequence.operations = new ReputationTokensInternal.Operation[](1);
        mintSequence.to = DISTRIBUTOR;

        mintSequence.operations[0].id = tokenId;
        mintSequence.operations[0].amount = 100;

        mint(mintSequence);

        ReputationTokensInternal.Sequence memory distributeSequence;
        distributeSequence
            .operations = new ReputationTokensInternal.Operation[](1);
        distributeSequence.to = user1;

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
        uint256 tokenId = createToken(
            TokensPropertiesStorage.TokenProperties(
                TokensPropertiesStorage.TokenType(0),
                false,
                false,
                100
            )
        );

        assertEq(s_repTokens.getMaxMintPerTx(tokenId), 100);
    }
}
