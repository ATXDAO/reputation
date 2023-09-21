// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ReputationTokensBase} from "./ReputationTokensBase.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

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
contract ReputationTokensStandalone is ReputationTokensBase {
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

        _initialize(maxMintAmountPerTx, baseUri);
    }
}
