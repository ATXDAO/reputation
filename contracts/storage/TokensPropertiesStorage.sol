// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Reputation Tokens Storage
 * @author Jacob Homanics
 *
 * This smart contract library follows the Diamond Storage Pattern by hosting the state variables for Reputation Tokens.
 */
library TokensPropertiesStorage {
    ///////////////////
    // State Variables
    ///////////////////

    //give the storage a unique identifier.
    bytes32 internal constant STORAGE_SLOT =
        keccak256("atxdao.contracts.storage.tokenspropertiesstorage");

    ///////////////////
    // Types
    ///////////////////

    struct Layout {
        uint256 numOfTokens;
        mapping(address distributor => mapping(uint256 tokenId => uint256)) s_distributableBalance;
        mapping(address burner => mapping(uint256 tokenId => uint256)) s_burnedBalance;
        mapping(uint256 => TokenProperties) tokensProperties;
    }

    enum TokenType {
        Default,
        Redeemable,
        Soulbound
    }

    struct TokenProperties {
        TokenType tokenType;
        // bool isSoulbound;
        // bool isRedeemable;
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
