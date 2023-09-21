// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Reputation Tokens Internal Interface
 * @author Jacob Homanics
 *
 * Hosts the events for Reputation Tokens.
 */
interface IReputationTokensInternal {
    event Mint(
        address indexed minter,
        address indexed to,
        uint256 indexed amount
    );
    event Distributed(address indexed from, address indexed to, uint256 amount);
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
