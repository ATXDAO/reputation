// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {ERC1155Base} from "@solidstate/contracts/token/ERC1155/base/ERC1155Base.sol";
import {SafeOwnable} from "@solidstate/contracts/access/ownable/SafeOwnable.sol";
import {AccessControl} from "@solidstate/contracts/access/access_control/AccessControl.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

import {AddressToAddressMappingStorage} from "./storage/AddressToAddressMappingStorage.sol";
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
    bytes32 public constant TOKEN_CREATOR_ROLE =
        keccak256("TOKEN_CREATOR_ROLE");
    bytes32 public constant TOKEN_UPDATER_ROLE =
        keccak256("TOKEN_UPDATER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant TOKEN_MIGRATOR_ROLE =
        keccak256("TOKEN_MIGRATOR_ROLE");

    ///////////////////
    // Functions
    ///////////////////

    ///////////////////
    // Internal Functions
    ///////////////////

    /**
     * Used to initialize the Reputation Tokens System
     * @param ownerNominee The nominee that will be set to own the smart contract
     * @param admins The admins who can grant/revoke roles and do other administrative functionality
     * @param baseUri The base URI that will be used for the token's metadata
     */
    function _initialize(
        address ownerNominee,
        address[] memory admins,
        string memory baseUri
    ) internal {
        _transferOwnership(ownerNominee);

        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(AccessControlStorage.DEFAULT_ADMIN_ROLE, admins[i]);
        }

        super._initialize(baseUri);
    }

    ///////////////////
    // External Functions
    ///////////////////

    function mint(
        TokensOperations memory tokensOperations
    ) external onlyRole(MINTER_ROLE) {
        if (!_hasRole(DISTRIBUTOR_ROLE, tokensOperations.to)) {
            revert ReputationTokens__AttemptingToMintToNonDistributor();
        }

        _mint(tokensOperations, "");
    }

    function mintBatch(TokensOperations[] memory tokensOperations) external {
        _mintBatch(tokensOperations, "");
    }

    /**
     * Distributes tokens to a user.
     * @param from The distributor who will be sending distributing tokens
     * @param tokensOperations The recipient who will receive the distributed tokens
     * @param data N/A
     */
    function distribute(
        address from,
        TokensOperations memory tokensOperations,
        bytes memory data
    ) public onlyRole(DISTRIBUTOR_ROLE) {
        _distribute(from, tokensOperations, data);
    }

    /**
     * Distributes many tokens to many users.
     * @param from The distributor who will be sending distributing tokens
     * @param data N/A
     */
    function distributeBatch(
        address from,
        TokensOperations[] memory tokensOperations,
        bytes memory data
    ) external onlyRole(DISTRIBUTOR_ROLE) {
        _distributeBatch(from, tokensOperations, data);
    }

    /**
     * Sets the destination wallet for msg.sender
     * @param destination The address where tokens will go when msg.sender is sent tokens by a distributor
     */
    function setDestinationWallet(address destination) external {
        _setDestinationWallet(msg.sender, destination);
    }

    /**
     * A customization of the default safeTransferFrom function.
     * The caller
     * CAN ONLY send tokens with an ID of 1.
     * MUST NOT be a distributor.
     * MUST be sending tokens to an address with the BURNER_ROLE.
     * @param from address who is sending tokens.
     * @param to address who is receiving tokens.
     * @param id tokenId
     * @param amount amount of tokens to send to the recipient.
     * @param data N/A
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override(ERC1155Base, IERC1155) nonReentrant {
        if (_hasRole(DISTRIBUTOR_ROLE, from)) {
            revert ReputationTokens__AttemptingToSendIllegalyAsDistributor();
        }

        if (!_hasRole(BURNER_ROLE, to)) {
            revert ReputationTokens__AttemptingToSendToNonBurner();
        }

        if (
            !TokensPropertiesStorage.layout().tokensProperties[id].isTradeable
        ) {
            revert ReputationTokens__AttemptingToSendNonRedeemableTokens();
        }

        super.safeTransferFrom(from, to, id, amount, data);
        emit BurnedRedeemable(from, to, amount);
    }

    function createToken(
        TokensPropertiesStorage.TokenProperties memory tokenProperty
    ) public onlyRole(TOKEN_CREATOR_ROLE) {
        _createToken(tokenProperty);
    }

    function batchCreateTokens(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    ) external {
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            createToken(tokensProperties[i]);
        }
    }

    function updateToken(
        uint256 id,
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) public onlyRole(TOKEN_UPDATER_ROLE) {
        if (id >= TokensPropertiesStorage.layout().numOfTokens)
            revert ReputationTokens__AttemptingToUpdateNonexistentToken();

        _updateToken(id, tokenProperties);
    }

    function batchUpdateTokens(
        uint256[] memory ids,
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    ) external {
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            updateToken(ids[i], tokensProperties[i]);
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
}
