// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../src/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../src/ReputationTokensInternal.sol";
import {ReputationTokensTest__Base} from "./ReputationTokensTest__Base.t.sol";

contract ReputationTokens__Distribute is ReputationTokensTest__Base {
    ////////////////////////
    // Tests
    ////////////////////////

    function testDistribute(
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
        address user
    ) external {
        vm.assume(user != address(0));

        batchCreateTokens(tokensProperties);
        ReputationTokensInternal.TokensOperations
            memory tokenOperations = createTokenOperationsSequential(
                DISTRIBUTOR,
                tokensProperties
            );
        mint(tokenOperations);
        ReputationTokensInternal.TokensOperations
            memory distributeOperations = createTokenOperationsSequential(
                user,
                tokensProperties
            );

        uint256[] memory priorDistributableBalances = new uint256[](
            tokensProperties.length
        );

        uint256[] memory priorTransferrableBalances = new uint256[](
            tokensProperties.length
        );

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            priorDistributableBalances[i] = s_repTokens.getDistributableBalance(
                DISTRIBUTOR,
                i
            );

            priorTransferrableBalances[i] = s_repTokens.getTransferrableBalance(
                DISTRIBUTOR,
                i
            );
        }

        distribute(distributeOperations);
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            assertEq(s_repTokens.balanceOf(DISTRIBUTOR, i), 0);
            assertEq(
                s_repTokens.balanceOf(user, i),
                tokensProperties[i].maxMintAmountPerTx
            );
            assertEq(
                s_repTokens.getDistributableBalance(DISTRIBUTOR, i),
                priorDistributableBalances[i] -
                    tokensProperties[i].maxMintAmountPerTx
            );
        }
    }

    function testSetDestinationWallet(
        address user,
        address destinationWallet
    ) external {
        vm.assume(user != destinationWallet);
        vm.assume(user != address(0));
        setDestinationWallet(user, destinationWallet);
        assertEq(s_repTokens.getDestinationWallet(user), destinationWallet);
    }
}
