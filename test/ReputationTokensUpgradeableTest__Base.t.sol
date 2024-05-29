// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";

import {ReputationTokensUpgradeable} from "../contracts/ReputationTokensUpgradeable.sol";

import {ReputationTokensBaseTest__Base} from "./ReputationTokensBaseTest__Base.t.sol";

contract ReputationTokensUpgradeableTest__Base is
    ReputationTokensBaseTest__Base
{
    ////////////////////////
    // Functions
    ////////////////////////
    constructor() {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;

        s_repTokens = new ReputationTokensUpgradeable();
        ReputationTokensUpgradeable(address(s_repTokens)).initialize(
            ADMIN,
            admins,
            admins
        );
    }
}
