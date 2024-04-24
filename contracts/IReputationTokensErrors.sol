// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Interface for Reputation Tokens Internal
 * @author Jacob Homanics
 *
 * Hosts the error messages for Reputation Tokens Internal.
 * Additionally, inherits the proper events as well from Reputation Tokens Internal Interface.
 */
interface IReputationTokensErrors {
    ///////////////////
    // Errors
    ///////////////////
    error ReputationTokens__CannotUpdateNonexistentTokenType();
    error ReputationTokens__MintAmountExceedsLimit();
    error ReputationTokens__CanOnlyMintToDistributor();
    error ReputationTokens__CantSendThatManyTransferrableTokens();
    error ReputationTokens__CannotTransferRedeemableToNonBurner();
    error ReputationTokens__AttemptingToUpdateNonexistentToken();
    error ReputationTokens__CannotTransferSoulboundToken();
    error ReputationTokens__CannotSetAllowanceForNonMinter();
}
