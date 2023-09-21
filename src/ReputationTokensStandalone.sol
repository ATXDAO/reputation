// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ReputationTokensBase} from "./ReputationTokensBase.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

/**
 * @title Reputation Tokens Standalone
 * @author Jacob Homanics
 *
 * This contract inherits the neccesary functionality to create a Reputation Tokens Smart Contract.
 * It is reccomended to deploy this smart contract through regular means where you are sure that the constructor is getting called.
 *
 */
contract ReputationTokensStandalone is ReputationTokensBase {
    ///////////////////
    // Functions
    ///////////////////

    constructor(
        address owner,
        address[] memory admins,
        uint256 maxMintAmountPerTx,
        string memory baseUri
    ) {
        _initialize(owner, admins, maxMintAmountPerTx, baseUri);
    }
}
