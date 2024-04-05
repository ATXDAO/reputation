// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Reputation Tokens Storage
 * @author Jacob Homanics
 *
 * This smart contract library follows the Diamond Storage Pattern by hosting the state variables for Reputation Tokens.
 */
library AddressToAddressMappingStorage {
    ///////////////////
    // State Variables
    ///////////////////

    //give the storage a unique identifier.
    bytes32 internal constant STORAGE_SLOT =
        keccak256("atxdao.contracts.storage.addresstoaddressmapping");

    ///////////////////
    // Types
    ///////////////////

    // struct Layout {
    //     mapping(address => address) destinationWallets;
    // }

    // ///////////////////
    // // Internal Functions
    // ///////////////////
    // function layout() internal pure returns (Layout storage l) {
    //     bytes32 slot = STORAGE_SLOT;
    //     assembly {
    //         l.slot := slot
    //     }
    // }
}
