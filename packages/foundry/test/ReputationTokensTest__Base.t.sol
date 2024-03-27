// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../contracts/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from "../contracts/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from "../contracts/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from "../contracts/ReputationTokensInternal.sol";

contract ReputationTokensTest__Base is Test {
    ////////////////////////
    // State Variables
    ////////////////////////
    address ADMIN = makeAddr("ADMIN");
    address TOKEN_CREATOR = makeAddr("TOKEN_CREATOR");
    address TOKEN_UPDATER = makeAddr("TOKEN_UPDATER");
    address TOKEN_URI_SETTER = makeAddr("TOKEN_URI_SETTER");
    address MINTER = makeAddr("MINTER");
    address DISTRIBUTOR = makeAddr("DISTRIBUTOR");
    address BURNER = makeAddr("BURNER");
    address TOKEN_MIGRATOR = makeAddr("TOKEN_MIGRATOR");
    address DESTINATION_WALLET = makeAddr("DESTINATION_WALLET");

    ReputationTokensStandalone s_repTokens;

    ////////////////////////
    // Functions
    ////////////////////////

    function setUp() public virtual {
        setUpDeploy();
        setUpRoles();
    }

    function setUpDeploy() public {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;
        s_repTokens = new ReputationTokensStandalone(ADMIN, admins);
    }

    function setUpRoles() public {
        setUpRole(s_repTokens.TOKEN_CREATOR_ROLE(), TOKEN_CREATOR);
        setUpRole(s_repTokens.TOKEN_UPDATER_ROLE(), TOKEN_UPDATER);
        setUpRole(s_repTokens.TOKEN_URI_SETTER_ROLE(), TOKEN_URI_SETTER);
        setUpRole(s_repTokens.MINTER_ROLE(), MINTER);
        setUpRole(s_repTokens.DISTRIBUTOR_ROLE(), DISTRIBUTOR);
        setUpRole(s_repTokens.BURNER_ROLE(), BURNER);
        setUpRole(s_repTokens.TOKEN_MIGRATOR_ROLE(), TOKEN_MIGRATOR);
    }

    ////////////////////////
    // Helper Functions
    ////////////////////////
    function batchCreateTokens(
        TokensPropertiesStorage.TokenProperties[] memory tokenProperties
    ) public {
        vm.startPrank(TOKEN_CREATOR);
        s_repTokens.batchCreateTokens(tokenProperties);
        vm.stopPrank();
    }

    function createToken(
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) public returns (uint256) {
        vm.startPrank(TOKEN_CREATOR);
        uint256 tokenId = s_repTokens.createToken(tokenProperties);
        vm.stopPrank();
        return tokenId;
    }

    function batchUpdateTokensProperties(
        uint256[] memory ids,
        TokensPropertiesStorage.TokenProperties[] memory _tokensProperties
    ) public {
        vm.startPrank(TOKEN_UPDATER);
        s_repTokens.batchUpdateTokensProperties(ids, _tokensProperties);
        vm.stopPrank();
    }

    function updateToken(
        uint256 id,
        TokensPropertiesStorage.TokenProperties memory tokenProperties
    ) public {
        vm.startPrank(TOKEN_UPDATER);
        s_repTokens.updateTokenProperties(id, tokenProperties);
        vm.stopPrank();
    }

    function createTokenOperationsSequentialHalf(
        address to,
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
        uint256 divisibleAmount
    ) public pure returns (ReputationTokensInternal.TokensOperations memory) {
        ReputationTokensInternal.TokensOperations memory tokenOperations;
        tokenOperations
            .operations = new ReputationTokensInternal.TokenOperation[](
            tokensProperties.length
        );
        tokenOperations.to = to;

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            tokenOperations.operations[i].id = i;
            if (tokensProperties[i].maxMintAmountPerTx > 0) {
                tokenOperations.operations[i].amount =
                    tokensProperties[i].maxMintAmountPerTx /
                    divisibleAmount;
            } else {
                tokenOperations.operations[i].amount = 0;
            }
        }

        return tokenOperations;
    }

    function createTokenOperationsSequential(
        address to,
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties,
        uint256 amount
    ) public pure returns (ReputationTokensInternal.TokensOperations memory) {
        ReputationTokensInternal.TokensOperations memory tokenOperations;
        tokenOperations
            .operations = new ReputationTokensInternal.TokenOperation[](
            tokensProperties.length * amount
        );
        tokenOperations.to = to;

        for (uint256 j = 0; j < amount; j++) {
            for (uint256 i = 0; i < tokensProperties.length; i++) {
                tokenOperations.operations[i].id = i;
                tokenOperations.operations[i].amount = tokensProperties[i]
                    .maxMintAmountPerTx;
            }
        }

        return tokenOperations;
    }

    function createTokenOperationsSequential(
        address to,
        TokensPropertiesStorage.TokenProperties[] memory tokensProperties
    ) public pure returns (ReputationTokensInternal.TokensOperations memory) {
        ReputationTokensInternal.TokensOperations memory tokenOperations;
        tokenOperations
            .operations = new ReputationTokensInternal.TokenOperation[](
            tokensProperties.length
        );
        tokenOperations.to = to;

        for (uint256 i = 0; i < tokensProperties.length; i++) {
            tokenOperations.operations[i].id = i;
            tokenOperations.operations[i].amount = tokensProperties[i]
                .maxMintAmountPerTx;
        }

        return tokenOperations;
    }

    function createTokenOperationsSequential(
        address to,
        uint256 length,
        uint256 amount
    ) public pure returns (ReputationTokensInternal.TokensOperations memory) {
        ReputationTokensInternal.TokensOperations memory tokenOperations;
        tokenOperations
            .operations = new ReputationTokensInternal.TokenOperation[](length);
        tokenOperations.to = to;

        for (uint256 i = 0; i < length; i++) {
            tokenOperations.operations[i].id = i;
            tokenOperations.operations[i].amount = amount;
        }

        return tokenOperations;
    }

    function mint(
        ReputationTokensInternal.TokensOperations memory operations
    ) public {
        vm.startPrank(MINTER);
        s_repTokens.mint(operations);
        vm.stopPrank();
    }

    function batchMint(
        ReputationTokensInternal.TokensOperations[] memory operations
    ) public {
        vm.startPrank(MINTER);
        s_repTokens.batchMint(operations);
        vm.stopPrank();
    }

    function distribute(
        ReputationTokensInternal.TokensOperations memory tokenOps
    ) public {
        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distribute(DISTRIBUTOR, tokenOps, "");
        vm.stopPrank();
    }

    function setUpRole(bytes32 role, address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(role, addr);
        vm.stopPrank();
    }

    function setDestinationWallet(address target, address destination) public {
        vm.startPrank(target);
        s_repTokens.setDestinationWallet(destination);
        vm.stopPrank();
    }
}
