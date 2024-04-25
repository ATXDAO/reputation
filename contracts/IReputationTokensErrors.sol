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
    error ReputationTokens__InsufficientBalance();
    error ReputationTokens__CannotTransferSoulboundToken();
}
