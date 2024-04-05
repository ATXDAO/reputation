// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ReputationTokensBase} from "./ReputationTokensBase.sol";
import {TokensPropertiesStorage} from "./storage/TokensPropertiesStorage.sol";
import {AddressToAddressMappingStorage} from
    "./storage/AddressToAddressMappingStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

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
        address[] memory admins
    ) Ownable(ownerNominee) {
        _transferOwnership(ownerNominee);

        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External & Public View & Pure Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function getDestinationWallet(address addr)
        external
        view
        returns (address)
    {
        return destinationWallets[addr];
    }

    function getMaxMintPerTx(uint256 index) external view returns (uint256) {
        return tokensProperties[index].maxMintAmountPerTx;
    }

    function getNumOfTokenTypes() external view returns (uint256) {
        return numOfTokens;
    }

    function getTokenProperties(uint256 id)
        external
        view
        returns (TokenProperties memory)
    {
        return tokensProperties[id];
    }
}
