// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {ERC1155Base} from
    "@solidstate/contracts/token/ERC1155/base/ERC1155Base.sol";
import {SafeOwnable} from "@solidstate/contracts/access/ownable/SafeOwnable.sol";
import {AccessControl} from
    "@solidstate/contracts/access/access_control/AccessControl.sol";
import {AccessControlStorage} from
    "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

import {AddressToAddressMappingStorage} from
    "./storage/AddressToAddressMappingStorage.sol";
import {TokensPropertiesStorage} from "./storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "./ReputationTokensInternal.sol";

// TODO: Update Documentation (i.e. function parameters)

/**
 * @title Reputation Tokens Base
 * @author Jacob Homanics
 *
 * Implements the public and external interactions of Reputation Tokens.
 * Additionally defines specific roles and gates function interaction with those roles.
 *
 */
contract ReputationTokensBase is
    ReputationTokensInternal,
    AccessControl,
    SafeOwnable
{
    ///////////////////
    // State Variables
    ///////////////////

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TOKEN_CREATOR_ROLE = keccak256("TOKEN_CREATOR_ROLE");
    bytes32 public constant TOKEN_UPDATER_ROLE = keccak256("TOKEN_UPDATER_ROLE");
    bytes32 public constant TOKEN_URI_SETTER_ROLE =
        keccak256("TOKEN_URI_SETTER_ROLE");

    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant TOKEN_MIGRATOR_ROLE =
        keccak256("TOKEN_MIGRATOR_ROLE");

    ///////////////////
    // Functions
    ///////////////////

    ///////////////////
    // External Functions
    ///////////////////

    function mint(Sequence memory sequence)
        public
        // TokensOperations memory tokensOperations
        onlyRole(MINTER_ROLE)
    {
        if (!_hasRole(DISTRIBUTOR_ROLE, sequence.to)) {
            revert ReputationTokens__CanOnlyMintToDistributor();
        }

        _mint(sequence, "");
    }

    function batchMint(Sequence[] memory sequences)
        external
        onlyRole(MINTER_ROLE)
    {
        for (uint256 i = 0; i < sequences.length; i++) {
            mint(sequences[i]);
        }
    }

    function setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    ) external onlyRole(TOKEN_URI_SETTER_ROLE) {
        _setURI(tokenId, tokenURI);
    }

    /**
     * Distributes tokens to a user.
     * @param from The distributor who will be sending distributing tokens
     * @param sequence The recipient who will receive the distributed tokens
     * @param data N/A
     */
    function distribute(
        address from,
        Sequence memory sequence,
        bytes memory data
    ) public onlyRole(DISTRIBUTOR_ROLE) {
        _distribute(from, sequence, data);
    }

    /**
     * Distributes many tokens to many users.
     * @param from The distributor who will be sending distributing tokens
     * @param data N/A
     */
    function batchDistribute(
        address from,
        Sequence[] memory sequences,
        bytes memory data
    ) external onlyRole(DISTRIBUTOR_ROLE) {
        for (uint256 i = 0; i < sequences.length; i++) {
            distribute(from, sequences[i], data);
        }
    }

    /**
     * Sets the destination wallet for msg.sender
     * @param destination The address where tokens will go when msg.sender is sent tokens by a distributor
     */
    function setDestinationWallet(address destination) external {
        _setDestinationWallet(msg.sender, destination);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        if (tokensProperties[id].tokenType == TokenType.Soulbound) {
            revert ReputationTokens__CannotTransferSoulboundToken();
        }

        if (tokensProperties[id].tokenType == TokenType.Redeemable) {
            if (_hasRole(BURNER_ROLE, to)) {
                s_burnedBalance[to][id] += amount;
            } else {
                revert ReputationTokens__CannotTransferRedeemableToNonBurner();
            }
        }

        if (amount > getTransferrableBalance(from, id)) {
            revert ReputationTokens__CantSendThatManyTransferrableTokens();
        }

        super.safeTransferFrom(from, to, id, amount, data);
    }

    function createToken(TokenProperties memory tokenProperties)
        public
        onlyRole(TOKEN_CREATOR_ROLE)
        returns (uint256 tokenId)
    {
        tokenId = _createToken(tokenProperties);
    }

    function batchCreateTokens(TokenProperties[] memory tokensProperties)
        external
    {
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            createToken(tokensProperties[i]);
        }
    }

    function updateTokenProperties(
        uint256 id,
        TokenProperties memory tokenProperties
    ) public onlyRole(TOKEN_UPDATER_ROLE) {
        _updateTokenProperties(id, tokenProperties);
    }

    function batchUpdateTokensProperties(
        uint256[] memory ids,
        TokenProperties[] memory tokensProperties
    ) external {
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            _updateTokenProperties(ids[i], tokensProperties[i]);
        }
    }

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
        _migrateOwnershipOfTokens(from, to);
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External & Public View & Pure Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function getTransferrableBalance(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 transferrableBalance) {
        uint256 balance = balanceOf(addr, tokenId);
        transferrableBalance = balance - getDistributableBalance(addr, tokenId)
            - getBurnedBalance(addr, tokenId);
    }

    function getBurnedBalance(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 burnedBalance) {
        burnedBalance = s_burnedBalance[addr][tokenId];
    }

    function getDistributableBalance(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 distributableBalance) {
        distributableBalance = s_distributableBalance[addr][tokenId];
    }
}
