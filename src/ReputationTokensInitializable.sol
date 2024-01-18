// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {console} from "forge-std/console.sol";

import {ReputationTokensBase} from "./ReputationTokensBase.sol";
import {SafeOwnable} from "@solidstate/contracts/access/ownable/SafeOwnable.sol";
import {Initializable} from "@solidstate/contracts/security/initializable/Initializable.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";
import {TokensPropertiesStorage} from "./storage/TokensPropertiesStorage.sol";
import {AddressToAddressMappingStorage} from "./storage/AddressToAddressMappingStorage.sol";

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
        address ownerNominee,
        address[] memory admins
    ) external initializer {
        _initialize(ownerNominee, admins);
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External & Public View & Pure Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function getDestinationWallet(
        address addr
    ) external view returns (address) {
        return AddressToAddressMappingStorage.layout().destinationWallets[addr];
    }

    function getMaxMintPerTx(uint256 index) external view returns (uint256) {
        return
            TokensPropertiesStorage
                .layout()
                .tokensProperties[index]
                .maxMintAmountPerTx;
    }

    function getNumOfTokenTypes() external view returns (uint256) {
        return TokensPropertiesStorage.layout().numOfTokens;
    }

    function getTokenProperties(
        uint256 id
    ) external view returns (TokensPropertiesStorage.TokenProperties memory) {
        return TokensPropertiesStorage.layout().tokensProperties[id];
    }
}
