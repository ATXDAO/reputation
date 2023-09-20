// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {SolidStateERC1155} from "@solidstate/contracts/token/ERC1155/SolidStateERC1155.sol";
import {ERC1155MetadataStorage} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataStorage.sol";
import {ERC1155Metadata} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155Metadata.sol";
import {IERC1155Metadata} from "@solidstate/contracts/token/ERC1155/metadata/IERC1155Metadata.sol";

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
    // Types
    ///////////////////
    ///////////////////
    // Functions
    ///////////////////
    ///////////////////
    // Internal Functions
    ///////////////////

    // bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");

    function _mint(address to, uint256 amount, bytes memory data) internal {
        if (amount >= ReputationTokensStorage.layout().maxMintAmountPerTx) {
            revert AttemptingToMintTooManyTokens();
        }

        //mints an amount of lifetime tokens to an address.
        super._mint(to, 0, amount, data);
        //mints an amount of transferable tokens to an address.
        super._mint(to, 1, amount, data);

        emit Mint(msg.sender, to, amount);
    }

    function mintBatch(
        address[] memory to,
        uint256[] memory amount,
        bytes memory data
    ) internal {
        for (uint256 i = 0; i < to.length; i++) {
            _mint(to[i], amount[i], data);
        }
    }
}
