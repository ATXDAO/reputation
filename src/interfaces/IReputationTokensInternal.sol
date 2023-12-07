// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {TokensPropertiesStorage} from "../storage/TokensPropertiesStorage.sol";

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

    event Create(TokensPropertiesStorage.TokenProperties);
    event Update(
        uint256 indexed id,
        TokensPropertiesStorage.TokenProperties indexed properties
    );

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
