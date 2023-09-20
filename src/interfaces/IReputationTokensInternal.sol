// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Custom ERC1155 Internal Interface
 * @author Jacob Homanics
 *
 * Interface hosting the events for Custom ERC1155.
 */
interface IReputationTokensInternal {
    function MINTER_ROLE() external view returns (bytes32);

    function DISTRIBUTOR_ROLE() external view returns (bytes32);

    event Mint(
        address indexed minter,
        address indexed to,
        uint256 indexed amount
    );
}
