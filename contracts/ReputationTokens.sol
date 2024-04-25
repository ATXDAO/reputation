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

// Max Mint Amount moved to per minter basis?
// Rejoin minter and distributor.
// Admin would re-up max mint supply for minters.
contract ReputationTokens is
    ERC1155URIStorage,
    IReputationTokensErrors,
    IReputationTokensEvents,
    AccessControl,
    Ownable
{
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Types
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    struct Operation {
        uint256 id;
        uint256 amount;
    }

    struct Sequence {
        address recipient;
        Operation[] operations;
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // State Variables
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    // bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TOKEN_CREATOR_ROLE = keccak256("TOKEN_CREATOR_ROLE");
    bytes32 public constant TOKEN_UPDATER_ROLE = keccak256("TOKEN_UPDATER_ROLE");
    bytes32 public constant TOKEN_URI_SETTER_ROLE =
        keccak256("TOKEN_URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TOKEN_MIGRATOR_ROLE =
        keccak256("TOKEN_MIGRATOR_ROLE");

    // bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    // bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 s_numOfTokens;
    mapping(uint256 id => TokenType) s_tokenType;

    // mapping(address distributor => mapping(uint256 tokenId => uint256))
    //     s_distributableBalance;

    // mapping(uint256 tokenId => mapping(address minter => uint256 allowance))
    //     mintAllowance;

    mapping(
        uint256 tokenId => mapping(address distributor => uint256 allowance)
    ) s_distributableBalanceOf;

    mapping(uint256 tokenId => mapping(address burner => uint256 balance))
        s_burnedBalanceOf;

    // mapping(address => address) s_destinationWallets;

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
     * Creates many new token types.
     * @param tokenTypes The array of types to set to each new token type created.
     */
    // function batchCreateTokens(TokenType[] memory tokenTypes)
    //     external
    //     onlyRole(TOKEN_CREATOR_ROLE)
    // {
    //     uint256 startId = s_numOfTokens;
    //     s_numOfTokens += tokenTypes.length;

    //     for (uint256 i = startId; i < s_numOfTokens; i++) {
    //         _createToken(tokenTypes[i], i);
    //     }
    // }

    /**
     * Updates many token types.
     * @param ids the IDs of the tokens to update type for.
     * @param tokenTypes The types to set for the supplied tokens.
     */
    // function batchUpdateTokens(
    //     uint256[] memory ids,
    //     TokenType[] memory tokenTypes
    // ) external onlyRole(TOKEN_UPDATER_ROLE) {
    //     for (uint256 i = 0; i < tokenTypes.length; i++) {
    //         _updateToken(ids[i], tokenTypes[i]);
    //     }
    // }

    /**
     * Given many sequences, adds to the minting allowance of many minters.
     * @param sequences Contains the recipients and operations to add allowances to for token Ids.
     */
    // function batchAddMintAllowances(Sequence[] memory sequences)
    //     external
    //     onlyRole(DEFAULT_ADMIN_ROLE)
    // {
    //     for (uint256 i = 0; i < sequences.length; i++) {
    //         addMintAllowance(sequences[i]);
    //     }
    // }

    /**
     * Given many sequences, mints many operations of tokens to the recipients.
     * @param sequences Contains the recipients and tokens operations to mint tokens to.
     */
    // function batchMint(Sequence[] memory sequences)
    //     external
    //     onlyRole(DEFAULT_ADMIN_ROLE)
    // {
    //     for (uint256 i = 0; i < sequences.length; i++) {
    //         mint(sequences[i]);
    //     }
    // }

    // function safeBatchTransferFrom(
    //     address from,
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory values,
    //     bytes memory data
    // ) public virtual {
    //     address sender = _msgSender();
    //     if (from != sender && !isApprovedForAll(from, sender)) {
    //         revert ERC1155MissingApprovalForAll(sender, from);
    //     }
    //     _safeBatchTransferFrom(from, to, ids, values, data);
    // }

    /**
     * Migrates all tokens to a new address only by authorized accounts.
     * @param from The address who is migrating their tokens.
     * @param to The address who is receiving the migrated tokens.
     *
     * @notice setApprovalForAll(TOKEN_MIGRATOR_ROLE, true) needs to be called prior by the `from` address to succesfully migrate tokens.
     */
    function migrateOwnershipOfTokens(
        address from,
        address to
    ) external onlyRole(TOKEN_MIGRATOR_ROLE) {
        for (uint256 i = 0; i < s_numOfTokens; i++) {
            uint256 balanceOfFrom = balanceOf(from, i);
            emit OwnershipOfTokensMigrated(from, to, balanceOfFrom);
        }

        for (uint256 i = 0; i < s_numOfTokens; i++) {
            uint256 balanceOfFrom = balanceOf(from, i);
            super.safeTransferFrom(from, to, i, balanceOfFrom, "");
        }
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

    // function createTokenBatch(TokenType[] memory tokenType)
    //     public
    //     onlyRole(TOKEN_CREATOR_ROLE)
    //     returns (uint256 tokenId)
    // {
    //     uint256 newTokenId = s_numOfTokens;
    //     s_numOfTokens++;

    //     return _createToken(tokenType, newTokenId);
    // }

    /**
     * Creates a new token type with a specified token type.
     * @param tokenType token type to assign to the new token type.
     */
    // function createToken(TokenType tokenType)
    //     public
    //     onlyRole(TOKEN_CREATOR_ROLE)
    //     returns (uint256 tokenId)
    // {
    //     uint256 newTokenId = s_numOfTokens;
    //     s_numOfTokens++;

    //     return _createToken(tokenType, newTokenId);
    // }

    // function _createToken(
    //     TokenType tokenType,
    //     uint256 id
    // ) public returns (uint256 tokenId) {
    //     _updateToken(id, tokenType);

    //     emit Create(tokenId);

    //     tokenId = id;
    // }

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155Received} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     *
     *
     * ReputationTokens:
     *
     *
     * CANNOT transfer Soulbound tokens
     * CAN transfer Redeemable tokens ONLY TO accounts with the BURNER_ROLE.
     * amount MUST be greater than transferable balance
     * CAN transfer Transferable tokens.
     */
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

    // function getMintAllowance(
    //     address target,
    //     uint256 tokenId
    // ) external view returns (uint256 amount) {
    //     amount = mintAllowance[target][tokenId];
    // }

    // function getDestinationWallet(address addr)
    //     external
    //     view
    //     returns (address)
    // {
    //     return s_destinationWallets[addr];
    // }

    function getNumOfTokenTypes() external view returns (uint256) {
        return s_numOfTokens;
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
