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

    function BURNER_ROLE() external view returns (bytes32);

    function TOKEN_MIGRATOR_ROLE() external view returns (bytes32);

    event Mint(
        address indexed minter,
        address indexed to,
        uint256 indexed amount
    );

    event DestinationWalletSet(address coreAddress, address destination);
    event Distributed(address from, address to, uint256 amount);

    event OwnershipOfTokensMigrated(
        address from,
        address to,
        uint256 lifetimeBalance,
        uint256 redeemableBalance
    );
    event BurnedRedeemable(address from, address to, uint256 amount);
}
