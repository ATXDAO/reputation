// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../contracts/ReputationTokensStandalone.sol";
import {IReputationTokensBaseInternal} from "../contracts/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../contracts/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../contracts/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__SafeTransferFrom is ReputationTokensTest__Base {
    uint256 constant DEFAULT_MAX_MINT_AMOUNT = 100;

    address user1;
    address transferRecipient;

    function setUp() public override {
        user1 = vm.addr(15);
        transferRecipient = vm.addr(17);

        super.setUp();
    }

    function createAndMintAndDistributTokenWithMaxMintAmountMoreThanZero(
        bool isSoulbound,
        bool isRedeemable
    ) public returns (uint256 tokenId) {
        tokenId = createToken(
            TokensPropertiesStorage.TokenProperties(
                TokensPropertiesStorage.TokenType(0),
                isSoulbound,
                isRedeemable,
                DEFAULT_MAX_MINT_AMOUNT
            )
        );

        ReputationTokensInternal.Sequence memory mintSequence;
        mintSequence.operations = new ReputationTokensInternal.Operation[](1);
        mintSequence.to = DISTRIBUTOR;

        mintSequence.operations[0].id = tokenId;
        mintSequence.operations[0].amount = DEFAULT_MAX_MINT_AMOUNT;

        mint(mintSequence);

        ReputationTokensInternal.Sequence memory distributeSequence;
        distributeSequence
            .operations = new ReputationTokensInternal.Operation[](1);
        distributeSequence.to = user1;

        distributeSequence.operations[0].id = tokenId;
        distributeSequence.operations[0].amount = DEFAULT_MAX_MINT_AMOUNT;

        distribute(distributeSequence);
    }

    function createAndMintAndDistributeSoulboundTokenWithMaxMintAmountMoreThanZero()
        internal
        returns (uint256 tokenId)
    {
        tokenId = createAndMintAndDistributTokenWithMaxMintAmountMoreThanZero(
            true,
            false
        );
    }

    function createAndMintAndDistributeRedeemableTokenWithMaxMintAmountMoreThanZero()
        internal
        returns (uint256 tokenId)
    {
        tokenId = createAndMintAndDistributTokenWithMaxMintAmountMoreThanZero(
            true,
            true
        );
    }

    function createAndMintAndDistributeDefaultTokenWithMaxMintAmountMoreThanZero()
        internal
        returns (uint256 tokenId)
    {
        tokenId = createAndMintAndDistributTokenWithMaxMintAmountMoreThanZero(
            false,
            false
        );
    }

    ////////////////////////
    // Tests
    ////////////////////////

    function testSafeTransferFrom() public {
        uint256 tokenId = createAndMintAndDistributeDefaultTokenWithMaxMintAmountMoreThanZero();

        vm.prank(user1);
        s_repTokens.safeTransferFrom(
            user1,
            transferRecipient,
            tokenId,
            DEFAULT_MAX_MINT_AMOUNT,
            ""
        );
    }

    function testSafeTransferFromBurn() public {
        uint256 tokenId = createAndMintAndDistributeRedeemableTokenWithMaxMintAmountMoreThanZero();

        vm.prank(user1);
        s_repTokens.safeTransferFrom(
            user1,
            BURNER,
            tokenId,
            DEFAULT_MAX_MINT_AMOUNT,
            ""
        );

        assertEq(
            s_repTokens.getBurnedBalance(BURNER, tokenId),
            DEFAULT_MAX_MINT_AMOUNT
        );
    }

    function testRevertSafeTransferFromSoulbound() public {
        uint256 tokenId = createAndMintAndDistributeSoulboundTokenWithMaxMintAmountMoreThanZero();

        vm.prank(user1);

        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__CannotTransferSoulboundToken
                .selector
        );

        s_repTokens.safeTransferFrom(
            user1,
            transferRecipient,
            tokenId,
            DEFAULT_MAX_MINT_AMOUNT,
            ""
        );
    }

    function testRevertIfTryingToTransferRedeemableToNonBurner() external {
        uint256 tokenId = createAndMintAndDistributeRedeemableTokenWithMaxMintAmountMoreThanZero();

        vm.prank(user1);

        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__CannotTransferRedeemableToNonBurner
                .selector
        );

        s_repTokens.safeTransferFrom(
            user1,
            transferRecipient,
            tokenId,
            DEFAULT_MAX_MINT_AMOUNT,
            ""
        );
    }

    function testRevertSafeTransferFromCantSendThatManyTransferrableTokens()
        external
    {
        uint256 tokenId = createAndMintAndDistributeDefaultTokenWithMaxMintAmountMoreThanZero();

        vm.prank(user1);

        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__CantSendThatManyTransferrableTokens
                .selector
        );
        s_repTokens.safeTransferFrom(
            DISTRIBUTOR,
            transferRecipient,
            tokenId,
            DEFAULT_MAX_MINT_AMOUNT + 1,
            ""
        );
    }
}
