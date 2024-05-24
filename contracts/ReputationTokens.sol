// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {
    ERC1155,
    ERC1155URIStorage
} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
// import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable} from "@solidstate/contracts/access/ownable/Ownable.sol";
import {ERC1155Base} from
    "@solidstate/contracts/token/ERC1155/base/ERC1155Base.sol";
import {AccessControl} from
    "@solidstate/contracts/access/access_control/AccessControl.sol";
import {AccessControlStorage} from
    "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

import {IReputationTokensErrors} from "./IReputationTokensErrors.sol";
import {IReputationTokensEvents} from "./IReputationTokensEvents.sol";

import {ReputationTokensBase} from "./ReputationTokensBase.sol";
import {ERC1155Metadata} from
    "@solidstate/contracts/token/ERC1155/metadata/ERC1155Metadata.sol";

/**
 * @title Reputation Tokens
 * @author Jacob Homanics
 */
contract ReputationTokens is Ownable, AccessControl, ReputationTokensBase {
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    bytes32 public constant TOKEN_UPDATER_ROLE = keccak256("TOKEN_UPDATER_ROLE");
    bytes32 public constant TOKEN_URI_SETTER_ROLE =
        keccak256("TOKEN_URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TOKEN_MIGRATOR_ROLE =
        keccak256("TOKEN_MIGRATOR_ROLE");

    constructor(address newOwner, address[] memory admins) {
        _transferOwnership(newOwner);

        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(AccessControlStorage.DEFAULT_ADMIN_ROLE, admins[i]);
        }
    }

    /**
     * Updates a token's type.
     * @param id The id of the token.
     * @param tokenType The new type of the token.
     */
    function updateToken(
        uint256 id,
        TokenType tokenType
    ) public override onlyRole(TOKEN_UPDATER_ROLE) {
        super.updateToken(id, tokenType);
    }

    /**
     * Updates a batch of tokens' types.
     * @param ids The ids of the tokens.
     * @param tokenTypes The new type of the tokens.
     */
    function updateTokenBatch(
        uint256[] memory ids,
        TokenType[] memory tokenTypes
    ) public override onlyRole(TOKEN_UPDATER_ROLE) {
        super.updateTokenBatch(ids, tokenTypes);
    }

    /**
     * Mints a number of a specific token to an address.
     * @param to The address where the tokens are minted to.
     * @param id The id of the specific token to mint.
     * @param value The number of tokens to mint.
     * @param data N/A
     */
    function mint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public override onlyRole(MINTER_ROLE) {
        super.mint(to, id, value, data);
    }

    /**
     * Mints a number of many tokens to an address.
     * @param to The address where the tokens are minted to.
     * @param ids The ids of the tokens to mint.
     * @param values The number of tokens to mint per token.
     * @param data N/A
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override onlyRole(MINTER_ROLE) {
        super.mintBatch(to, ids, values, data);
    }

    /**
     *  A Token Migrator migrates an address' tokens to another address.
     * @param from The address where the tokens are transferred from.
     * @param to The address where the tokens are migrated to.
     * @param id The id of the tokens to migrate.
     * @param value The number of tokens to migrate.
     * @param data N/A
     *
     * @notice setApprovalForAll(TOKEN_MIGRATOR_ROLE, true) needs to be called prior by the `from` address to succesfully migrate tokens.
     */
    function migrate(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public override onlyRole(TOKEN_MIGRATOR_ROLE) {
        super.migrate(from, to, id, value, data);
    }

    /**
     *  A Token Migrator migrates an address' many tokens to another address.
     * @param from The address where the many tokens are transferred from.
     * @param to The address where the many tokens are migrated to.
     * @param ids The ids of the many tokens to migrate.
     * @param values The number of many tokens to migrate.
     * @param data N/A
     *
     * @notice setApprovalForAll(TOKEN_MIGRATOR_ROLE, true) needs to be called prior by the `from` address to succesfully migrate tokens.
     */
    function migrateBatch(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override onlyRole(TOKEN_MIGRATOR_ROLE) {
        super.migrateBatch(from, to, ids, values, data);
    }

    /**
     * Sets the tokenURI of a token.
     * @param tokenId token to update.
     * @param tokenURI the token's new URI.
     */
    function setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    ) public override onlyRole(TOKEN_URI_SETTER_ROLE) {
        super.setTokenURI(tokenId, tokenURI);
    }

    /**
     * Sets the tokenURIs of many tokens.
     * @param tokenIds tokens to update.
     * @param tokenURIs the tokens' new URIs.
     */
    function setBatchTokenURI(
        uint256[] memory tokenIds,
        string[] memory tokenURIs
    ) public override onlyRole(TOKEN_URI_SETTER_ROLE) {
        super.setBatchTokenURI(tokenIds, tokenURIs);
    }
}
