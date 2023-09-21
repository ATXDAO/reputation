// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {console} from "forge-std/console.sol";

import {ReputationTokensBase} from "./ReputationTokensBase.sol";
import {SafeOwnable} from "@solidstate/contracts/access/ownable/SafeOwnable.sol";
import {Initializable} from "@solidstate/contracts/security/initializable/Initializable.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

/**
 * @title Reputation Tokens Initializable
 * @author Jacob Homanics
 *
 * Inherits the neccesary functionality to create a Reputation Tokens Smart Contract.
 * It is reccomended to be deployed through a factory or initialized through a Diamond (ERC-2535).
 *
 */
contract ReputationTokensInitializable is ReputationTokensBase, Initializable {
    ///////////////////
    // Functions
    ///////////////////

    ///////////////////
    // External Functions
    ///////////////////
    function initialize(
        address owner,
        address[] memory admins,
        uint256 maxMintAmountPerTx,
        string memory baseUri
    ) external initializer {
        _initialize(owner, admins, maxMintAmountPerTx, baseUri);
    }
}
