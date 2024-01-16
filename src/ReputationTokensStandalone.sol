// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ReputationTokensBase} from "./ReputationTokensBase.sol";
import {AccessControlStorage} from "@solidstate/contracts/access/access_control/AccessControlStorage.sol";
import {TokensPropertiesStorage} from "./storage/TokensPropertiesStorage.sol";
import {AddressToAddressMappingStorage} from "./storage/AddressToAddressMappingStorage.sol";

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
        address ownerNominee,
        address[] memory admins,
        string memory baseUri
    ) {
        _initialize(ownerNominee, admins, baseUri);
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
