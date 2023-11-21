// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title Reputation Tokens Internal Interface
 * @author Jacob Homanics
 *
 * Hosts the events for Reputation Tokens.
 */
interface IReputationTokensInternal {
    ///////////////////
    // Types
    ///////////////////
    struct TokenOperation {
        uint256 id;
        uint256 amount;
    }

    struct BatchTokenOperation {
        address to;
        TokenOperation[] tokens;
    }

    event Mint(
        address indexed from,
        address indexed to,
        TokenOperation[] indexed tokens
    );

    event Distributed(
        address indexed from,
        address indexed to,
        TokenOperation[] indexed tokens
    );

    event DestinationWalletSet(
        address indexed coreAddress,
        address indexed destination
    );
    event BurnedRedeemable(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event OwnershipOfTokensMigrated(
        address indexed from,
        address indexed to,
        uint256 lifetimeBalance,
        uint256 redeemableBalance
    );
}
