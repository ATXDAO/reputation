// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reputation Tokens Storage
 * @author Jacob Homanics
 *
 * This smart contract library follows the Diamond Storage Pattern by hosting the state variables for Reputation Tokens.
 */
library TokenTypesStorage {
    ///////////////////
    // State Variables
    ///////////////////

    //give the storage a unique identifier.
    bytes32 internal constant STORAGE_SLOT =
        keccak256("atxdao.contracts.storage.tokentypesstorage");

    ///////////////////
    // Types
    ///////////////////

    struct Layout {
        uint256 numOfTokenTypes;
        mapping(uint256 => TokenType) tokenTypes;
    }

    struct TokenType {
        bool isTradeable;
        uint256 maxMintAmountPerTx;
    }

    ///////////////////
    // Internal Functions
    ///////////////////
    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}
