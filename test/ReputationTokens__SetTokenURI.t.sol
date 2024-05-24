// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";
import {ReputationTokens} from "../contracts/ReputationTokens.sol";

import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__SetTokenURI is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    function testSetTokenURI(string memory uri) external {
        vm.prank(TOKEN_URI_SETTER);
        s_repTokens.setTokenURI(0, uri);
        assertEq(s_repTokens.uri(0), uri);
    }
}
