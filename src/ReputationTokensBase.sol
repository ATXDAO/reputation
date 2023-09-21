// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC1155} from "@solidstate/contracts/interfaces/IERC1155.sol";
import {IERC165} from "@solidstate/contracts/interfaces/IERC165.sol";

import {ERC1155Base} from "@solidstate/contracts/token/ERC1155/base/ERC1155Base.sol";

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
contract ReputationTokensBase is ReputationTokensInternal, AccessControl {
    ///////////////////
    // Functions
    ///////////////////

    ///////////////////
    // External Functions
    ///////////////////

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

    function mintBatch(
        address[] memory to,
        uint256[] memory amount,
        bytes memory data
    ) external {
        _mintBatch(to, amount, data);
    }

    //from : distributor
    //to : address
    function distribute(
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) public onlyRole(DISTRIBUTOR_ROLE()) {
        _distribute(from, to, amount, data);
    }

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

    function setDestinationWallet(address destination) external {
        _setDestinationWallet(msg.sender, destination);
    }

    //from : address
    //to : burner
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
    //setApprovalForAll(TOKEN_MIGRATOR_ROLE, true)
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
}
