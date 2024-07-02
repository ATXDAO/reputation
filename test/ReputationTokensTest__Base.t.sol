// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";

import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensBaseTest__Base} from "./ReputationTokensBaseTest__Base.t.sol";

contract ReputationTokensTest__Base is ReputationTokensBaseTest__Base {
    ////////////////////////
    // Functions
    ////////////////////////
    constructor() {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;

        string[] memory uris;
        ReputationTokens.TokenType[] memory tokenTypes;

        s_repTokens = new ReputationTokens(
            ADMIN,
            admins,
            admins,
            tokenTypes,
            uris
        );
    }
}
