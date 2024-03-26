// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {SolidStateERC1155} from "@solidstate/contracts/token/ERC1155/SolidStateERC1155.sol";
import {ERC1155MetadataStorage} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataStorage.sol";
import {ERC1155Metadata} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155Metadata.sol";
import {IERC1155Metadata} from "@solidstate/contracts/token/ERC1155/metadata/IERC1155Metadata.sol";
import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {IERC165} from "@solidstate/contracts/interfaces/IERC165.sol";

import {ReputationTokensInternal} from "./ReputationTokensInternal.sol";
import {IReputationTokensBaseInternal} from "./IReputationTokensBaseInternal.sol";
import {AddressToAddressMappingStorage} from "./storage/AddressToAddressMappingStorage.sol";
import {TokensPropertiesStorage} from "./storage/TokensPropertiesStorage.sol";
import {Test, console} from "forge-std/Test.sol";

/**
 * @title Reputation Tokens Internal
 * @author Jacob Homanics
 *
 * Contains all of the internal functions for Repuation Tokens.
 *
 * @dev This contract follows the Diamond Storage Pattern where state variables are stored in libraries.
 *          This contract implements a library for Custom ERC1155 Storage management.
 *          This contract implements a library for Solid State's ERC 1155 Metadata Storage management.
 * @dev This contract inherits from SolidStateERC1155. Which is a smart contract that follows the Diamond Storage Pattern and
 *      allows for easy creation of ERC1155 compliant smart contracts.
 *      Source code and info found here: https://github.com/solidstate-network/solidstate-solidity
 * @dev This contract inherits from IReputationTokensBaseInternal. Which contains the errors and events for Reputation Tokens.
 */
abstract contract ReputationTokensInternal is
    SolidStateERC1155,
    IReputationTokensBaseInternal
{
    ///////////////////
    // Functions
    ///////////////////

    ///////////////////
    // Internal Functions
    ///////////////////

    function _initialize() internal {
        // ERC1155MetadataStorage.layout().baseURI = baseUri;

        _setSupportsInterface(type(IERC165).interfaceId, true);
        _setSupportsInterface(type(IERC1155).interfaceId, true);
    }

    function _createToken(
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) internal {
        uint256 tokenId = TokensPropertiesStorage.layout().numOfTokens;
        TokensPropertiesStorage.layout().numOfTokens++;

        _updateTokenProperties(tokenId, tokenProperties);

        emit Create(tokenProperties);
    }

    function _updateTokenProperties(
        uint256 id,
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) internal {
        if (id >= TokensPropertiesStorage.layout().numOfTokens) {
            revert ReputationTokens__CannotUpdateNonexistentTokenType();
        }

        TokensPropertiesStorage
            .layout()
            .tokensProperties[id]
            .isRedeemable = tokenProperties.isRedeemable;

        TokensPropertiesStorage
            .layout()
            .tokensProperties[id]
            .isSoulbound = tokenProperties.isSoulbound;

        TokensPropertiesStorage
            .layout()
            .tokensProperties[id]
            .maxMintAmountPerTx = tokenProperties.maxMintAmountPerTx;

        emit Update(id, tokenProperties);
    }

    /**
     * Checks and sets the destination wallet for an address if it is currently set to the zero address.
     * @param addr address who may get their destination wallet set
     */
    function initializeDestinationWallet(address addr) internal {
        if (
            AddressToAddressMappingStorage.layout().destinationWallets[addr] ==
            address(0)
        ) {
            _setDestinationWallet(addr, addr);
        }
    }

    /**
     * Mints an amount of tokens to an address.
     * amount MUST BE lower than maxMintPerTx.
     * MAY set the receiver's destination wallet to itself if it is set to the zero address.
     * Mints Tokens 0 and 1 of amount to `to`.
     * @param tokensOperations receiving address of tokens.
     * @param data N/A
     */
    function _mint(
        TokensOperations memory tokensOperations,
        bytes memory data
    ) internal {
        initializeDestinationWallet(tokensOperations.to);

        for (uint256 i = 0; i < tokensOperations.operations.length; i++) {
            if (
                tokensOperations.operations[i].amount >
                TokensPropertiesStorage
                    .layout()
                    .tokensProperties[tokensOperations.operations[i].id]
                    .maxMintAmountPerTx
            ) revert ReputationTokens__MintAmountExceedsLimit();

            TokensPropertiesStorage.layout().s_distributableBalance[
                tokensOperations.to
            ][tokensOperations.operations[i].id] += tokensOperations
                .operations[i]
                .amount;

            super._mint(
                tokensOperations.to,
                tokensOperations.operations[i].id,
                tokensOperations.operations[i].amount,
                data
            );
            emit Mint(
                msg.sender,
                tokensOperations.to,
                tokensOperations.operations
            );
        }
    }

    /**
     * Sets the target's destination wallet to an address
     * @param target The address who will get its destination wallet set
     * @param destination The address that will receive tokens on behalf of `target`
     */
    function _setDestinationWallet(
        address target,
        address destination
    ) internal {
        AddressToAddressMappingStorage.layout().destinationWallets[
                target
            ] = destination;
        emit DestinationWalletSet(target, destination);
    }

    /**
     * Distributes an amount of tokens to an address
     * @param from A distributor who distributes tokens
     * @param tokensOperations The recipient who will receive the tokens
     * @param data N/A
     */
    function _distribute(
        address from,
        TokensOperations memory tokensOperations,
        bytes memory data
    ) internal {
        initializeDestinationWallet(tokensOperations.to);

        for (uint256 i = 0; i < tokensOperations.operations.length; i++) {
            TokensPropertiesStorage.layout().s_distributableBalance[from][
                    tokensOperations.operations[i].id
                ] -= tokensOperations.operations[i].amount;

            super.safeTransferFrom(
                from,
                AddressToAddressMappingStorage.layout().destinationWallets[
                    tokensOperations.to
                ],
                tokensOperations.operations[i].id,
                tokensOperations.operations[i].amount,
                data
            );
        }

        emit Distributed(
            from,
            AddressToAddressMappingStorage.layout().destinationWallets[
                tokensOperations.to
            ],
            tokensOperations.operations
        );
    }

    function _distributeBatch(
        address from,
        TokensOperations[] memory tokensOperations,
        bytes memory data
    ) internal {
        for (uint256 i = 0; i < tokensOperations.length; i++) {
            _distribute(from, tokensOperations[i], data);
        }
    }

    /**
     * Migrates all tokens to a new address only.
     * @param from The address who is migrating their tokens.
     * @param to The address who is receiving the migrated tokens.
     *
     * @notice setApprovalForAll(TOKEN_MIGRATOR_ROLE, true) needs to be called prior by the `from` address to succesfully migrate tokens.
     */
    function _migrateOwnershipOfTokens(address from, address to) internal {
        uint256 lifetimeBalance = balanceOf(from, 0);
        uint256 redeemableBalance = balanceOf(from, 1);

        super.safeTransferFrom(from, to, 0, lifetimeBalance, "");
        super.safeTransferFrom(from, to, 1, redeemableBalance, "");
        emit OwnershipOfTokensMigrated(
            from,
            to,
            lifetimeBalance,
            redeemableBalance
        );
    }
}
