// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {
    ERC1155,
    ERC1155URIStorage
} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IReputationTokensErrors} from "./IReputationTokensErrors.sol";
import {IReputationTokensEvents} from "./IReputationTokensEvents.sol";

/**
 * @title Reputation Tokens
 * @author Jacob Homanics
 */
contract ReputationTokens is
    ERC1155URIStorage,
    IReputationTokensErrors,
    IReputationTokensEvents,
    AccessControl,
    Ownable
{
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // State Variables
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    bytes32 public constant TOKEN_CREATOR_ROLE = keccak256("TOKEN_CREATOR_ROLE");
    bytes32 public constant TOKEN_UPDATER_ROLE = keccak256("TOKEN_UPDATER_ROLE");
    bytes32 public constant TOKEN_URI_SETTER_ROLE =
        keccak256("TOKEN_URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TOKEN_MIGRATOR_ROLE =
        keccak256("TOKEN_MIGRATOR_ROLE");

    mapping(uint256 id => TokenType) s_tokenType;

    mapping(uint256 tokenId => mapping(address distributor => uint256 balance))
        s_distributableBalanceOf;

    mapping(uint256 tokenId => mapping(address burner => uint256 balance))
        s_burnedBalanceOf;

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    constructor(
        address newOwner,
        address[] memory admins
    ) Ownable(newOwner) ERC1155("") {
        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Updates a token's type.
     * @param id The id of the token.
     * @param tokenType The new type of the token.
     */
    function updateToken(
        uint256 id,
        TokenType tokenType
    ) external onlyRole(TOKEN_UPDATER_ROLE) {
        _updateToken(id, tokenType);
        emit Update(id, tokenType);
    }

    /**
     * Updates a batch of tokens' types.
     * @param ids The ids of the tokens.
     * @param tokenTypes The new type of the tokens.
     */
    function updateTokenBatch(
        uint256[] memory ids,
        TokenType[] memory tokenTypes
    ) external onlyRole(TOKEN_UPDATER_ROLE) {
        _updateTokenBatch(ids, tokenTypes);
        emit UpdateBatch(ids, tokenTypes);
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
    ) external onlyRole(MINTER_ROLE) {
        _addToDistributionBalance(id, to, value);

        emit Mint(msg.sender, to, id, value);

        _mint(to, id, value, data);
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
    ) external onlyRole(MINTER_ROLE) {
        for (uint256 i = 0; i < ids.length; i++) {
            _addToDistributionBalance(ids[i], to, values[i]);
        }

        emit MintBatch(msg.sender, to, ids, values);

        _mintBatch(to, ids, values, data);
    }

    /**
     * Distributes a number of a specific token to an address.
     * @param from The address where the tokens are transferred from.
     * @param to The address where the tokens are distributed to.
     * @param id The id of the specific token to distribute.
     * @param value The number of tokens to distribute.
     * @param data N/A
     */
    function distribute(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) external {
        _removeFromDistributionBalance(id, from, value);

        emit Distribute(from, to, id, value);

        super.safeTransferFrom(from, to, id, value, data);
    }

    /**
     * Distributes a number of many tokens to an address.
     * @param from The address where the tokens are transferred from.
     * @param to The address where the tokens are distributed to.
     * @param ids The ids of the tokens to distribute.
     * @param values The number of tokens to distribute per token.
     * @param data N/A
     */
    function distributeBatch(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) external {
        for (uint256 i = 0; i < ids.length; i++) {
            _removeFromDistributionBalance(ids[i], from, values[i]);
        }

        super._safeBatchTransferFrom(from, to, ids, values, data);
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
    ) external onlyRole(TOKEN_MIGRATOR_ROLE) {
        emit Migrate(from, to, id, value);
        super.safeTransferFrom(from, to, id, value, data);
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
    ) external onlyRole(TOKEN_MIGRATOR_ROLE) {
        emit MigrateBatch(from, to, ids, values);
        super.safeBatchTransferFrom(from, to, ids, values, data);
    }

    /**
     * Sets the tokenURI of a token.
     * @param tokenId token to update.
     * @param tokenURI the token's new URI.
     */
    function setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    ) external onlyRole(TOKEN_URI_SETTER_ROLE) {
        _setURI(tokenId, tokenURI);
    }

    /**
     * Sets the tokenURIs of many tokens.
     * @param tokenIds tokens to update.
     * @param tokenURIs the tokens' new URIs.
     */
    function setBatchTokenURI(
        uint256[] memory tokenIds,
        string[] memory tokenURIs
    ) external onlyRole(TOKEN_URI_SETTER_ROLE) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _setURI(tokenIds[i], tokenURIs[i]);
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Public Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Transfers valid tokens to an address.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param id The id of the token to transfer.
     * @param value The amount of tokens to transfer.
     * @param data N/A
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public override {
        _validateTokenBeforeTransfer(from, to, id, value);

        super.safeTransferFrom(from, to, id, value, data);
    }

    /**
     * Transfers many valid tokens to an address.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param ids The ids of the tokens to transfer.
     * @param values The amounts of tokens to transfer.
     * @param data N/A
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override {
        for (uint256 i = 0; i < ids.length; i++) {
            _validateTokenBeforeTransfer(from, to, ids[i], values[i]);
        }

        super.safeBatchTransferFrom(from, to, ids, values, data);
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Internal Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Updates a token's type.
     * @param id The id of the token.
     * @param tokenType The new type of the token.
     */
    function _updateToken(uint256 id, TokenType tokenType) internal {
        s_tokenType[id] = tokenType;
    }

    /**
     * Updates many tokens' types.
     * @param ids The ids of the tokens.
     * @param tokenTypes The new types of the tokens.
     */
    function _updateTokenBatch(
        uint256[] memory ids,
        TokenType[] memory tokenTypes
    ) internal {
        for (uint256 i = 0; i < ids.length; i++) {
            _updateToken(ids[i], tokenTypes[i]);
        }
    }

    /**
     * Adds an amount of a distributable token to an address.
     * @param id the id of the token.
     * @param to the address to add distributable tokens to.
     * @param value the amount of distributable tokens to add to an address.
     */
    function _addToDistributionBalance(
        uint256 id,
        address to,
        uint256 value
    ) internal {
        s_distributableBalanceOf[id][to] += value;
    }

    /**
     * Removes an amount of a distributable token to an address.
     * @param id the id of the token.
     * @param from the address to remove distributable tokens from.
     * @param value the amount of distributable tokens to remove from an address.
     */
    function _removeFromDistributionBalance(
        uint256 id,
        address from,
        uint256 value
    ) internal {
        s_distributableBalanceOf[id][from] -= value;
    }

    /**
     * Validates a token for transfer based on several conditions.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param id The id of the token to transfer.
     * @param value The amount of tokens to transfer.
     *
     * @notice Also adds to the burned balance if token is Redeemable.
     */
    function _validateTokenBeforeTransfer(
        address from,
        address to,
        uint256 id,
        uint256 value
    ) internal {
        if (s_tokenType[id] == TokenType.Soulbound) {
            revert ReputationTokens__CannotTransferSoulboundToken();
        }

        if (value > honestBalanceOf(from, id)) {
            revert ReputationTokens__InsufficientBalance();
        }

        if (s_tokenType[id] == TokenType.Redeemable) {
            s_burnedBalanceOf[id][to] += value;
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External & Public View & Pure Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function honestBalanceOf(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 transferrableBalance) {
        uint256 balance = balanceOf(addr, tokenId);
        transferrableBalance = balance - burnedBalanceOf(addr, tokenId)
            - distributableBalanceOf(addr, tokenId);
    }

    function burnedBalanceOf(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 burnedBalance) {
        burnedBalance = s_burnedBalanceOf[tokenId][addr];
    }

    function distributableBalanceOf(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 distributableBalance) {
        distributableBalance = s_distributableBalanceOf[tokenId][addr];
    }

    function getTokenType(uint256 id) external view returns (TokenType) {
        return s_tokenType[id];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
