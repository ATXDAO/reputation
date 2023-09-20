// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {IERC165} from "@solidstate/contracts/interfaces/IERC165.sol";

import {ERC1155MetadataStorage} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataStorage.sol";
import {ERC1155Metadata} from "@solidstate/contracts/token/ERC1155/metadata/ERC1155Metadata.sol";
import {IERC1155Metadata} from "@solidstate/contracts/token/ERC1155/metadata/IERC1155Metadata.sol";
import {AccessControl} from "@solidstate/contracts/access/access_control/AccessControl.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

import {ReputationTokensStorage} from "./ReputationTokensStorage.sol";
import {ReputationTokensInternal} from "./ReputationTokensInternal.sol";

import {console} from "forge-std/console.sol";

/**
 * @title Custom ERC115
 * @author Jacob Homanics
 *
 * This contract adheres to the requirements for Smart Contract Development Test using ZkSync L2 from Game7 DAO.
 * Through this smart contract:
 *      1. You can deploy it on its own or as a facet on a diamond.
 *      2. Users cannot mint more tokens after having already minted.
 *      3. The owner should not be able to create new tokens unless it's uri ends in the '.glb' extensions.
 * @notice This contract can act as a standalone ERC1155 collection or be used as a Diamond Facet with Diamonds.
 */
contract ReputationTokensStandalone is ReputationTokensInternal, AccessControl {
    ///////////////////
    // Functions
    ///////////////////

    constructor(
        address[] memory admins,
        uint256 maxMintAmountPerTx,
        string memory baseUri
    ) {
        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(AccessControlStorage.DEFAULT_ADMIN_ROLE, admins[i]);
        }

        ReputationTokensStorage
            .layout()
            .maxMintAmountPerTx = maxMintAmountPerTx;

        ERC1155MetadataStorage.layout().baseURI = baseUri;

        _setSupportsInterface(type(IERC165).interfaceId, true);
        _setSupportsInterface(type(IERC1155).interfaceId, true);
    }

    ///////////////////
    // External Functions
    ///////////////////

    function mint(
        address to,
        uint256 amount,
        bytes memory data
    ) external onlyRole(MINTER_ROLE()) {
        if (!_hasRole(DISTRIBUTOR_ROLE(), to)) {
            revert AttemptingToMintToNonDistributor();
        }

        _mint(to, amount, data);
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
}
