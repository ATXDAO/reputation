// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {
    ERC1155,
    ERC1155URIStorage
} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

import {IReputationTokensErrors} from "./IReputationTokensErrors.sol";
import {IReputationTokensEvents} from "./IReputationTokensEvents.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Test, console} from "forge-std/Test.sol";

/**
 * @title Reputation Token
 * @author Jacob Homanics
 *
 * Contains all of the functions for Repuation Tokens.
 *
 * @dev This contract inherits from IReputationTokensErrors. Which contains the errors and events for Reputation Tokens.
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

    mapping(
        uint256 tokenId => mapping(address distributor => uint256 allowance)
    ) s_distributableBalanceOf;

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
     * Updates an existing token's type.
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

    function updateTokenBatch(
        uint256[] memory ids,
        TokenType[] memory tokenTypes
    ) external onlyRole(TOKEN_UPDATER_ROLE) {
        _updateTokenBatch(ids, tokenTypes);
        emit UpdateBatch(ids, tokenTypes);
    }

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
     * Migrates all tokens to a new address only by authorized accounts.
     * @param from The address who is migrating their tokens.
     * @param to The address who is receiving the migrated tokens.
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
     * Sets the tokenURI for a given token type.
     * @param tokenId token to update URI for.
     * @param tokenURI updated tokenURI.
     */
    function setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    ) external onlyRole(TOKEN_URI_SETTER_ROLE) {
        _setURI(tokenId, tokenURI);
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Public Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public override {
        _validateToken(from, to, id, value);

        super.safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override {
        for (uint256 i = 0; i < ids.length; i++) {
            _validateToken(from, to, ids[i], values[i]);
        }

        super.safeBatchTransferFrom(from, to, ids, values, data);
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Internal Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Updates an existing token's type.
     * @param id The id of the token.
     * @param tokenType The new type of the token.
     */
    function _updateToken(uint256 id, TokenType tokenType) internal {
        s_tokenType[id] = tokenType;
    }

    function _updateTokenBatch(
        uint256[] memory ids,
        TokenType[] memory tokenTypes
    ) internal {
        for (uint256 i = 0; i < ids.length; i++) {
            _updateToken(ids[i], tokenTypes[i]);
        }
    }

    function _addToDistributionBalance(
        uint256 id,
        address to,
        uint256 value
    ) internal {
        s_distributableBalanceOf[id][to] += value;
    }

    function _removeFromDistributionBalance(
        uint256 id,
        address from,
        uint256 value
    ) internal {
        s_distributableBalanceOf[id][from] -= value;
    }

    function _validateToken(
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
