// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IReputationTokensInternal} from "./interfaces/IReputationTokensInternal.sol";

/**
 * @title Interface for Reputation Tokens Internal
 * @author Jacob Homanics
 *
 * Hosts the error messages for Reputation Tokens Internal.
 * Additionally, inherits the proper events as well from Reputation Tokens Internal Interface.
 */

interface IReputationTokensBaseInternal is IReputationTokensInternal {
    ///////////////////
    // Errors
    ///////////////////
    error ReputationTokens__AttemptingToMintTooManyTokens();
    error ReputationTokens__AttemptingToMintToNonDistributor();
    error ReputationTokens__AttemptingToSendNonRedeemableTokens();
    error ReputationTokens__AttemptingToSendIllegalyAsDistributor();
    error ReputationTokens__AttemptingToSendToNonBurner();
}
