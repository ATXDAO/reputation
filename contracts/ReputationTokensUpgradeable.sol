// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Ownable} from "@solidstate/contracts/access/ownable/Ownable.sol";

import {AccessControlStorage} from
    "@solidstate/contracts/access/access_control/AccessControlStorage.sol";

import {IReputationTokensErrors} from "./IReputationTokensErrors.sol";
import {IReputationTokensEvents} from "./IReputationTokensEvents.sol";

import {ReputationTokensBase} from "./ReputationTokensBase.sol";

import {Initializable} from
    "@solidstate/contracts/security/initializable/Initializable.sol";

/**
 * @title Reputation Tokens
 * @author Jacob Homanics
 */
contract ReputationTokensUpgradeable is
    Ownable,
    ReputationTokensBase,
    Initializable
{
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    function initialize(
        address newOwner,
        address[] memory admins
    ) external initializer {
        _transferOwnership(newOwner);

        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(AccessControlStorage.DEFAULT_ADMIN_ROLE, admins[i]);
        }
    }
}
