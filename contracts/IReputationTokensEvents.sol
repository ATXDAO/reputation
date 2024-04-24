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
    enum TokenType {
        Transferable,
        Soulbound,
        Redeemable
    }

    ///////////////////
    // Errors
    ///////////////////
    event Create(uint256 indexed tokenId);
    event Update(uint256 indexed tokenId, TokenType indexed tokenType);
    event UpdateBatch(uint256[] indexed tokenId, TokenType[] indexed tokenType);

    event Mint(
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 values
    );

    event MintBatch(
        address indexed from,
        address indexed to,
        uint256[] tokenIds,
        uint256[] values
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
