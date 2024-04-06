// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Interface for Reputation Tokens Internal
 * @author Jacob Homanics
 *
 * Hosts the error messages for Reputation Tokens Internal.
 * Additionally, inherits the proper events as well from Reputation Tokens Internal Interface.
 */
interface IReputationTokensEvents {
    ///////////////////
    // Errors
    ///////////////////
    event Create(uint256 indexed tokenId);
    event Update(uint256 indexed tokenId);

    event Mint(
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 amount
    );

    event Distributed(
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 amount
    );

    event DestinationWalletSet(
        address indexed coreAddress, address indexed destination
    );

    event OwnershipOfTokensMigrated(
        address indexed from, address indexed to, uint256 balance
    );
}
