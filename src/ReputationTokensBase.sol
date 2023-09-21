// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {ERC1155Base} from "@solidstate/contracts/token/ERC1155/base/ERC1155Base.sol";
import {SafeOwnable} from "@solidstate/contracts/access/ownable/SafeOwnable.sol";
import {AccessControl} from "@solidstate/contracts/access/access_control/AccessControl.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

import {ReputationTokensStorage} from "./ReputationTokensStorage.sol";
import {ReputationTokensInternal} from "./ReputationTokensInternal.sol";

/**
 * @title Reputation Tokens Base
 * @author Jacob Homanics
 *
 * Implements the public and external interactions of Reputation Tokens.
 *
 */
contract ReputationTokensBase is
    ReputationTokensInternal,
    AccessControl,
    SafeOwnable
{
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
     * @param maxMintAmountPerTx The max amount of tokens that can be minted per transaction
     * @param baseUri The base URI that will be used for the token's metadata
     */
    function _initialize(
        address ownerNominee,
        address[] memory admins,
        uint256 maxMintAmountPerTx,
        string memory baseUri
    ) internal {
        _transferOwnership(ownerNominee);

        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(AccessControlStorage.DEFAULT_ADMIN_ROLE, admins[i]);
        }

        super._initialize(maxMintAmountPerTx, baseUri);
    }

    ///////////////////
    // External Functions
    ///////////////////

    /**
     *
     * @param to The recipient address to be minted tokens to
     * @param amount The amount of tokens to mint to the recipient address
     * @param data N/A
     */
    function mint(
        address to,
        uint256 amount,
        bytes memory data
    ) external onlyRole(MINTER_ROLE()) {
        if (!_hasRole(DISTRIBUTOR_ROLE(), to)) {
            revert ReputationTokens__AttemptingToMintToNonDistributor();
        }

        _mint(to, amount, data);
    }

    /**
     *
     * @param to An array of recipient addresses to be sent tokens
     * @param amount An array of an amount of tokens associated with the array of recipient addresses which define the number of tokens to be minted
     * @param data N/A
     */
    function mintBatch(
        address[] memory to,
        uint256[] memory amount,
        bytes memory data
    ) external {
        _mintBatch(to, amount, data);
    }

    /**
     * Distributes tokens to a user.
     * @param from The distributor who will be sending distributing tokens
     * @param to The recipient who will receive the distributed tokens
     * @param amount The amount of tokens the recipient will receive
     * @param data N/A
     */
    function distribute(
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) public onlyRole(DISTRIBUTOR_ROLE()) {
        _distribute(from, to, amount, data);
    }

    /**
     * Distributes many tokens to many users.
     * @param from The distributor who will be sending distributing tokens
     * @param to An array of recipient addresses to receive a number of tokens.
     * @param amount An array of an amount of tokens associated with the array of recipient addresses which define the number of tokens to be distributed
     * @param data N/A
     */
    function distributeBatch(
        address from,
        address[] memory to,
        uint256[] memory amount,
        bytes memory data
    ) external {
        for (uint256 i = 0; i < to.length; i++) {
            distribute(from, to[i], amount[i], data);
        }
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
    ) public override(ERC1155Base, IERC1155) {
        if (id != 1) {
            revert ReputationTokens__AttemptingToSendNonRedeemableTokens();
        }

        if (_hasRole(DISTRIBUTOR_ROLE(), from)) {
            revert ReputationTokens__AttemptingToSendIllegalyAsDistributor();
        }

        if (!_hasRole(BURNER_ROLE(), to)) {
            revert ReputationTokens__AttemptingToSendToNonBurner();
        }

        super.safeTransferFrom(from, to, id, amount, data);
        emit BurnedRedeemable(from, to, amount);
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
    ) external onlyRole(TOKEN_MIGRATOR_ROLE()) {
        _migrateOwnershipOfTokens(from, to);
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External & Public View & Pure Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function MINTER_ROLE() public pure returns (bytes32) {
        return keccak256("MINTER_ROLE");
    }

    function DISTRIBUTOR_ROLE() public pure returns (bytes32) {
        return keccak256("DISTRIBUTOR_ROLE");
    }

    function BURNER_ROLE() public pure returns (bytes32) {
        return keccak256("BURNER_ROLE");
    }

    function TOKEN_MIGRATOR_ROLE() public pure returns (bytes32) {
        return keccak256("TOKEN_MIGRATOR_ROLE");
    }

    function getDestinationWallet(
        address addr
    ) external view returns (address) {
        return ReputationTokensStorage.layout().destinationWallets[addr];
    }

    function getMaxMintPerTx() external view returns (uint256) {
        return ReputationTokensStorage.layout().maxMintAmountPerTx;
    }
}
