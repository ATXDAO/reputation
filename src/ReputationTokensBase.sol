// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {ERC1155Base} from "@solidstate/contracts/token/ERC1155/base/ERC1155Base.sol";
import {SafeOwnable} from "@solidstate/contracts/access/ownable/SafeOwnable.sol";
import {AccessControl} from "@solidstate/contracts/access/access_control/AccessControl.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

import {AddressToAddressMappingStorage} from "./storage/AddressToAddressMappingStorage.sol";
import {TokenTypesStorage} from "./storage/TokenTypesStorage.sol";
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
    bytes32 public constant TOKEN_TYPE_CREATOR_ROLE =
        keccak256("TOKEN_TYPE_CREATOR_ROLE");
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

    /**
     *
     * @param to The recipient address to be minted tokens to
     * @param data N/A
     */
    function mint(
        address to,
        TokenOperation[] memory tokens,
        bytes memory data
    ) external onlyRole(MINTER_ROLE) {
        if (!_hasRole(DISTRIBUTOR_ROLE, to)) {
            revert ReputationTokens__AttemptingToMintToNonDistributor();
        }

        _mint(to, tokens, data);
    }

    /**
     *
     * @param data N/A
     */
    function mintBatch(
        BatchTokenOperation[] memory batchMint,
        bytes memory data
    ) external {
        _mintBatch(batchMint, data);
    }

    /**
     * Distributes tokens to a user.
     * @param from The distributor who will be sending distributing tokens
     * @param to The recipient who will receive the distributed tokens
     * @param data N/A
     */
    function distribute(
        address from,
        address to,
        TokenOperation[] memory tokens,
        bytes memory data
    ) public onlyRole(DISTRIBUTOR_ROLE) {
        _distribute(from, to, tokens, data);
    }

    /**
     * Distributes many tokens to many users.
     * @param from The distributor who will be sending distributing tokens
     * @param data N/A
     */
    function distributeBatch(
        address from,
        BatchTokenOperation[] memory batchMint,
        bytes memory data
    ) external onlyRole(DISTRIBUTOR_ROLE) {
        _distributeBatch(from, batchMint, data);
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

        if (!TokenTypesStorage.layout().tokenTypes[id].isTradeable) {
            revert ReputationTokens__AttemptingToSendNonRedeemableTokens();
        }

        super.safeTransferFrom(from, to, id, amount, data);
        emit BurnedRedeemable(from, to, amount);
    }

    function batchCreateTokenTypes(
        TokenTypesStorage.TokenType[] memory tokenTypes
    ) external {
        for (uint256 i = 0; i < tokenTypes.length; i++) {
            createTokenType(tokenTypes[i]);
        }
    }

    function createTokenType(
        TokenTypesStorage.TokenType memory tokenType
    ) public onlyRole(TOKEN_TYPE_CREATOR_ROLE) {
        _createTokenType(tokenType);
    }

    //this needs to be called beforehand by address that wants to transfer its tokens:
    //

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

    function DEFAULT_ADMIN_ROLE() public pure returns (bytes32) {
        return AccessControlStorage.DEFAULT_ADMIN_ROLE;
    }

    function getDestinationWallet(
        address addr
    ) external view returns (address) {
        return AddressToAddressMappingStorage.layout().destinationWallets[addr];
    }

    function getMaxMintPerTx(uint256 index) external view returns (uint256) {
        return TokenTypesStorage.layout().tokenTypes[index].maxMintAmountPerTx;
    }

    function getNumOfTokenTypes() external view returns (uint256) {
        return TokenTypesStorage.layout().numOfTokenTypes;
    }
}
