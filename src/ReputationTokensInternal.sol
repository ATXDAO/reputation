// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {SolidStateERC1155} from "@solidstate/contracts/token/ERC1155/SolidStateERC1155.sol";
import {ERC1155MetadataStorage} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataStorage.sol";
import {ERC1155Metadata} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155Metadata.sol";
import {IERC1155Metadata} from "@solidstate/contracts/token/ERC1155/metadata/IERC1155Metadata.sol";
import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {IERC165} from "@solidstate/contracts/interfaces/IERC165.sol";

import {ReputationTokensInternal} from "./ReputationTokensInternal.sol";
import {IReputationTokensBaseInternal} from "./IReputationTokensBaseInternal.sol";
import {ReputationTokensStorage} from "./ReputationTokensStorage.sol";

/**
 * @title Custom ERC115 Internal
 * @author Jacob Homanics
 *
 * This contract contains all of the internal functions for Custom ERC1155.
 *
 * @dev This contract implements a library for string management. It was pulled from: https://github.com/Arachnid/solidity-stringutils
 * @dev This contract follows the Diamond Storage Pattern where state variables are stored in libraries.
 *          This contract implements a library for Custom ERC1155 Storage management.
 *          This contract implements a library for Solid State's ERC 1155 Metadata Storage management.
 * @dev This contract inherits from SolidStateERC1155. Which is a smart contract that follows the Diamond Storage Pattern and
 *      allows for easy creation of ERC1155 compliant smart contracts.
 *      Source code and info found here: https://github.com/solidstate-network/solidstate-solidity
 * @dev This contract inherits from ICustomERC1155Internal. Which contains the errors of the smart contract.
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

    function _initialize(
        uint256 maxMintAmountPerTx,
        string memory baseUri
    ) internal {
        ReputationTokensStorage
            .layout()
            .maxMintAmountPerTx = maxMintAmountPerTx;

        ERC1155MetadataStorage.layout().baseURI = baseUri;

        _setSupportsInterface(type(IERC165).interfaceId, true);
        _setSupportsInterface(type(IERC1155).interfaceId, true);
    }

    function maybeInitializeDestinationWallet(address addr) internal {
        if (
            ReputationTokensStorage.layout().destinationWallets[addr] ==
            address(0)
        ) {
            _setDestinationWallet(addr, addr);
        }
    }

    function _mint(address to, uint256 amount, bytes memory data) internal {
        if (amount >= ReputationTokensStorage.layout().maxMintAmountPerTx) {
            revert ReputationTokens__AttemptingToMintTooManyTokens();
        }

        maybeInitializeDestinationWallet(to);

        //mints an amount of lifetime tokens to an address.
        super._mint(to, 0, amount, data);
        //mints an amount of transferable tokens to an address.
        super._mint(to, 1, amount, data);

        emit Mint(msg.sender, to, amount);
    }

    function _mintBatch(
        address[] memory to,
        uint256[] memory amount,
        bytes memory data
    ) internal {
        for (uint256 i = 0; i < to.length; i++) {
            _mint(to[i], amount[i], data);
        }
    }

    function _setDestinationWallet(
        address target,
        address destination
    ) internal {
        ReputationTokensStorage.layout().destinationWallets[
            target
        ] = destination;
        emit DestinationWalletSet(target, destination);
    }

    //from : distributor
    //to : address
    function _distribute(
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) internal {
        maybeInitializeDestinationWallet(to);

        super.safeTransferFrom(
            from,
            ReputationTokensStorage.layout().destinationWallets[to],
            0,
            amount,
            data
        );
        super.safeTransferFrom(
            from,
            ReputationTokensStorage.layout().destinationWallets[to],
            1,
            amount,
            data
        );
        emit Distributed(
            from,
            ReputationTokensStorage.layout().destinationWallets[to],
            amount
        );
    }

    //this needs to be called beforehand by address that wants to transfer its lifetime tokens:
    //setApprovalForAll(TOKEN_MIGRATOR_ROLE, true)
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
