// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @author Jacob Homanics
 */
interface IReputationTokensErrors {
    ///////////////////
    // Errors
    ///////////////////
    error ReputationTokens__InsufficientBalance();
    error ReputationTokens__CannotTransferSoulboundToken();
}
