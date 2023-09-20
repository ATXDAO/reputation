// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Custom ERC115 Storage
 * @author Jacob Homanics
 *
 * This smart contract library follows the Diamond Storage Pattern by hosting the state variables for Custom ERC1155.
 */
library ReputationTokensStorage {
    ///////////////////
    // State Variables
    ///////////////////

    //give the storage a unique identifier.
    bytes32 internal constant STORAGE_SLOT =
        keccak256("atxdao.contracts.storage.reputationtokens");

    ///////////////////
    // Types
    ///////////////////

    struct Layout {
        uint256 maxMintAmountPerTx;
        //A mapping to see if an address has minted any tokens
        mapping(address => bool) hasMinted;
        //Total number of created token types.
        uint256 totalTokenTypeCount;
        //Owner of the smart contract. Most likely used to limit creation of tokens.
        address owner;
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
