// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IReputationTokensErrors} from "../contracts/IReputationTokensErrors.sol";

import {ReputationTokens} from "../contracts/ReputationTokens.sol";

contract ReputationTokensTest__Base is Test {
    ////////////////////////
    // State Variables
    ////////////////////////
    address ADMIN = makeAddr("ADMIN");
    address TOKEN_CREATOR = makeAddr("TOKEN_CREATOR");
    address TOKEN_UPDATER = makeAddr("TOKEN_UPDATER");
    address TOKEN_URI_SETTER = makeAddr("TOKEN_URI_SETTER");
    address MINTER = makeAddr("MINTER");
    address BURNER = makeAddr("BURNER");
    address TOKEN_MIGRATOR = makeAddr("TOKEN_MIGRATOR");
    address DESTINATION_WALLET = makeAddr("DESTINATION_WALLET");

    address USER = makeAddr("USER");

    ReputationTokens s_repTokens;

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
        s_repTokens = new ReputationTokens(ADMIN, admins);
    }

    function setUpRoles() public {
        setUpRole(s_repTokens.TOKEN_CREATOR_ROLE(), TOKEN_CREATOR);
        setUpRole(s_repTokens.TOKEN_UPDATER_ROLE(), TOKEN_UPDATER);
        setUpRole(s_repTokens.TOKEN_URI_SETTER_ROLE(), TOKEN_URI_SETTER);
        setUpRole(s_repTokens.MINTER_ROLE(), MINTER);
        setUpRole(s_repTokens.TOKEN_MIGRATOR_ROLE(), TOKEN_MIGRATOR);
    }

    ////////////////////////
    // Helper Functions
    ////////////////////////
    // function batchCreateTokens(ReputationTokens.TokenType[] memory tokenType)
    //     public
    // {
    //     vm.startPrank(TOKEN_CREATOR);
    //     s_repTokens.batchCreateTokens(tokenType);
    //     vm.stopPrank();
    // }

    // function createToken(ReputationTokens.TokenType tokenType)
    //     public
    //     returns (uint256)
    // {
    //     vm.startPrank(TOKEN_CREATOR);
    //     uint256 tokenId = s_repTokens.createToken(tokenType);
    //     vm.stopPrank();
    //     return tokenId;
    // }

    // function createDefaultTokenWithAMintAmount() public returns (uint256) {
    //     return createToken(ReputationTokens.TokenType.Transferable);
    // }

    // function createDefaultToken() public returns (uint256) {
    //     return createToken(ReputationTokens.TokenType.Transferable);
    // }

    uint256 numOfTokenTypes = 3;

    function getNumTokenTypesMaxBound() public view returns (uint256) {
        return numOfTokenTypes - 1;
    }

    function cauterizeLength(
        uint256[] memory arr1,
        uint256[] memory arr2
    ) public pure returns (uint256[] memory, uint256[] memory) {
        if (arr1.length < arr2.length) {
            uint256 arrayLength = arr1.length;
            assembly {
                mstore(arr2, arrayLength)
            }
        } else {
            uint256 arrayLength = arr2.length;
            assembly {
                mstore(arr1, arrayLength)
            }
        }

        return (arr1, arr2);
    }

    modifier onlyValidAddress(uint256 id) {
        vm.assume(id > 0);
        vm.assume(
            id
                <
                115792089237316195423570985008687907852837564279074904382605163141518161494337
        );
        _;
    }

    modifier onlyValidAddresses(uint256[] memory ids) {
        for (uint256 i = 0; i < ids.length; i++) {
            vm.assume(ids[i] > 0);
            vm.assume(
                ids[i]
                    <
                    115792089237316195423570985008687907852837564279074904382605163141518161494337
            );
        }

        _;
    }

    function batchUpdateTokens(
        uint256[] memory ids,
        ReputationTokens.TokenType[] memory _tokensType
    ) public {
        vm.startPrank(TOKEN_UPDATER);
        s_repTokens.updateTokenBatch(ids, _tokensType);
        vm.stopPrank();
    }

    function updateToken(
        uint256 id,
        ReputationTokens.TokenType tokenTypes
    ) public {
        vm.startPrank(TOKEN_UPDATER);
        s_repTokens.updateToken(id, tokenTypes);
        vm.stopPrank();
    }

    function mint(ReputationTokens.Sequence memory sequence) public {
        vm.startPrank(MINTER);
        // s_repTokens.mint(sequence);
        vm.stopPrank();
    }

    function batchMint(ReputationTokens.Sequence[] memory sequences) public {
        vm.startPrank(MINTER);
        // s_repTokens.batchMint(sequences);
        vm.stopPrank();
    }

    function setUpRole(bytes32 role, address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(role, addr);
        vm.stopPrank();
    }
}
