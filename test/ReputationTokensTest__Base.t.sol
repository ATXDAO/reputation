// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from
    "../contracts/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from
    "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from
    "../contracts/IReputationTokensBaseInternal.sol";
import {TokensPropertiesStorage} from
    "../contracts/storage/TokensPropertiesStorage.sol";
import {ReputationTokensInternal} from
    "../contracts/ReputationTokensInternal.sol";

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

    function createDefaultTokenWithAMintAmount() public returns (uint256) {
        return createToken(
            TokensPropertiesStorage.TokenProperties(
                TokensPropertiesStorage.TokenType.Default, 100
            )
        );
    }

    function createDefaultToken() public returns (uint256) {
        return createToken(
            TokensPropertiesStorage.TokenProperties(
                TokensPropertiesStorage.TokenType.Default, 0
            )
        );
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

    function mint(ReputationTokensInternal.Sequence memory sequence) public {
        vm.startPrank(MINTER);
        s_repTokens.mint(sequence);
        vm.stopPrank();
    }

    function batchMint(ReputationTokensInternal.Sequence[] memory sequences)
        public
    {
        vm.startPrank(MINTER);
        s_repTokens.batchMint(sequences);
        vm.stopPrank();
    }

    function distribute(ReputationTokensInternal.Sequence memory sequence)
        public
    {
        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distribute(DISTRIBUTOR, sequence, "");
        vm.stopPrank();
    }

    function batchDistribute(
        ReputationTokensInternal.Sequence[] memory sequences
    ) public {
        vm.startPrank(DISTRIBUTOR);
        s_repTokens.batchDistribute(DISTRIBUTOR, sequences, "");
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
