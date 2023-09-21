// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IReputationTokensInternal} from "./interfaces/IReputationTokensInternal.sol";

/**
 * @title Interface for Custom ERC115 Internal
 * @author Jacob Homanics
 *
 * This smart contract hosts the error messages for Custom ERC1155 Internal and inherits the events as well.
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
