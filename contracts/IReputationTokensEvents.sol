// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IReputationTokensTypes} from "./IReputationTokensTypes.sol";

/**
 * @author Jacob Homanics
 */
interface IReputationTokensEvents is IReputationTokensTypes {
    ///////////////////
    // Events
    ///////////////////
    event Create(uint256 indexed tokenId);
    event Update(uint256 indexed tokenId, TokenType indexed tokenType);
    event UpdateBatch(uint256[] indexed tokenId, TokenType[] indexed tokenType);

    event Mint(
        address indexed from, address indexed to, uint256 tokenId, uint256 value
    );

    event MintBatch(
        address indexed from,
        address indexed to,
        uint256[] tokenIds,
        uint256[] values
    );

    event Distribute(
        address indexed from, address indexed to, uint256 tokenId, uint256 value
    );

    event DistributeBatch(
        address indexed from,
        address indexed to,
        uint256[] tokenId,
        uint256[] value
    );

    event Migrate(
        address indexed from, address indexed to, uint256 id, uint256 value
    );
    event MigrateBatch(
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
}
