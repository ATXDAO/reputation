// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../contracts/ReputationTokensStandalone.sol";
import {IReputationTokensBaseInternal} from "../contracts/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../contracts/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../contracts/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__Mint is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////
    function testMint() public {
        uint256 tokenId = createToken(
            TokensPropertiesStorage.TokenProperties(
                TokensPropertiesStorage.TokenType(0),
                false,
                false,
                100
            )
        );

        ReputationTokensInternal.TokensOperations memory tokenOperations;
        tokenOperations
            .operations = new ReputationTokensInternal.TokenOperation[](1);
        tokenOperations.to = DISTRIBUTOR;

        tokenOperations.operations[0].id = tokenId;
        tokenOperations.operations[0].amount = 100;

        mint(tokenOperations);

        assertEq(s_repTokens.balanceOf(DISTRIBUTOR, tokenId), 100);
        assertEq(
            s_repTokens.getDistributableBalance(DISTRIBUTOR, tokenId),
            100
        );
        assertEq(s_repTokens.getTransferrableBalance(DISTRIBUTOR, tokenId), 0);
    }

    function testRevertIfMintingTooManyTokens() external {
        uint256 tokenId = createToken(
            TokensPropertiesStorage.TokenProperties(
                TokensPropertiesStorage.TokenType(0),
                false,
                false,
                100
            )
        );

        ReputationTokensInternal.TokensOperations memory tokenOperations;
        tokenOperations
            .operations = new ReputationTokensInternal.TokenOperation[](1);
        tokenOperations.to = DISTRIBUTOR;

        tokenOperations.operations[0].id = tokenId;
        tokenOperations.operations[0].amount = 150;

        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__MintAmountExceedsLimit
                .selector
        );

        mint(tokenOperations);
    }

    function testRevertIfMintingToNonDistributor(uint256 userId) external {
        vm.assume(userId > 0);
        vm.assume(
            userId <
                115792089237316195423570985008687907852837564279074904382605163141518161494337
        );

        address user = vm.addr(userId);

        uint256 tokenId = createToken(
            TokensPropertiesStorage.TokenProperties(
                TokensPropertiesStorage.TokenType(0),
                false,
                false,
                100
            )
        );

        ReputationTokensInternal.TokensOperations memory tokenOperations;
        tokenOperations
            .operations = new ReputationTokensInternal.TokenOperation[](1);
        tokenOperations.to = user;

        tokenOperations.operations[0].id = tokenId;
        tokenOperations.operations[0].amount = 100;

        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__CanOnlyMintToDistributor
                .selector
        );

        mint(tokenOperations);
    }
}
