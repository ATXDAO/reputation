// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {TokenTypesStorage} from "../src/storage/TokenTypesStorage.sol";

contract RepTokensStandaloneTest is Test {
    ////////////////////////
    // State Variables
    ////////////////////////
    address ADMIN = makeAddr("ADMIN");
    address TOKEN_CREATOR = makeAddr("TOKEN_CREATOR");
    address MINTER = makeAddr("MINTER");
    address DISTRIBUTOR = makeAddr("DISTRIBUTOR");
    address DISTRIBUTOR2 = makeAddr("DISTRIBUTOR2");
    address BURNER = makeAddr("BURNER");
    address TOKEN_MIGRATOR = makeAddr("TOKEN_MIGRATOR");
    address USER = makeAddr("USER");
    address USER2 = makeAddr("USER2");
    address DESTINATION_WALLET = makeAddr("DESTINATION_WALLET");

    TokenTypesStorage.TokenType[] types;
    uint256 constant TOKEN_TYPES_TO_CREATE = 2;
    uint256 constant DEFAULT_MINT_AMOUNT = 50;
    string constant BASE_URI =
        "ipfs://bafybeiaz55w6kf7ar2g5vzikfbft2qoexknstfouu524l7q3mliutns2u4/";

    ReputationTokensStandalone s_repTokens;

    ////////////////////////
    // Modifiers
    ////////////////////////

    modifier m_distribute(address to, uint256 amount) {
        distribute(to, amount);
        _;
    }

    modifier m_mint(address to, uint256 amount) {
        mint(to, amount);
        _;
    }

    modifier m_setUpMinter(address addr) {
        setUpMinter(addr);
        _;
    }

    modifier m_setUpDistributor(address addr) {
        setUpDistributor(addr);
        _;
    }

    modifier m_setUpBurner(address addr) {
        setUpBurner(addr);
        _;
    }

    modifier m_setUpTokenMigrator(address addr) {
        setUpTokenMigrator(addr);
        _;
    }

    modifier m_setDestinationWallet(address target, address destination) {
        setDestinationWallet(target, destination);
        _;
    }

    modifier m_setupTokenCreator(address addr) {
        setupTokenCreator(addr);
        _;
    }

    modifier m_batchCreateTokenTypes(
        TokenTypesStorage.TokenType[] memory tokenTypes
    ) {
        batchCreateTokenTypes(tokenTypes);
        _;
    }

    modifier m_createTokenType(TokenTypesStorage.TokenType memory tokenType) {
        createTokenType(tokenType);
        _;
    }

    ////////////////////////
    // Functions
    ////////////////////////

    function setUp() public {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;
        DeployReputationTokensStandalone deployer = new DeployReputationTokensStandalone();
        s_repTokens = deployer.run(ADMIN, admins, BASE_URI);

        setupTokenCreator(TOKEN_CREATOR);
        setUpMinter(MINTER);
        setUpDistributor(DISTRIBUTOR);
        setUpBurner(BURNER);
        setUpTokenMigrator(TOKEN_MIGRATOR);

        TokenTypesStorage.TokenType memory t1 = TokenTypesStorage.TokenType(
            false,
            DEFAULT_MINT_AMOUNT
        );
        TokenTypesStorage.TokenType memory t2 = TokenTypesStorage.TokenType(
            true,
            DEFAULT_MINT_AMOUNT
        );

        types.push(t1);
        types.push(t2);

        // batchCreateTokenTypes(types);
    }

    ////////////////////////
    // Tests
    ////////////////////////

    function testURI() external {
        assertEq(s_repTokens.uri(0), string.concat(BASE_URI, "0"));
        assertEq(s_repTokens.uri(1), string.concat(BASE_URI, "1"));
    }

    function testDefaultAdminRole() external {
        assertEq(s_repTokens.DEFAULT_ADMIN_ROLE(), 0x00);
    }

    function testBatchCreateTokenTypes()
        external
        m_batchCreateTokenTypes(types)
    {
        assertEq(types.length, s_repTokens.getNumOfTokenTypes());
    }

    function testCreateTokenTypes() external m_createTokenType(types[0]) {
        assertEq(1, s_repTokens.getNumOfTokenTypes());
    }

    function testMint()
        public
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
    {
        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            assertEq(
                s_repTokens.balanceOf(DISTRIBUTOR, i),
                DEFAULT_MINT_AMOUNT
            );
        }
    }

    function testRevertIfMintingTooManyTokens()
        external
        m_batchCreateTokenTypes(types)
    {
        vm.startPrank(MINTER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToMintTooManyTokens
                .selector
        );
        s_repTokens.mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT + 1, "");
        vm.stopPrank();
    }

    function testRevertIfMintingToNonDistributor()
        external
        m_batchCreateTokenTypes(types)
    {
        vm.startPrank(MINTER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToMintToNonDistributor
                .selector
        );

        s_repTokens.mint(USER, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();
    }

    function testMintBatch()
        external
        m_setUpDistributor(DISTRIBUTOR2)
        m_batchCreateTokenTypes(types)
    {
        address[] memory DISTRIBUTORS = new address[](2);
        DISTRIBUTORS[0] = DISTRIBUTOR;
        DISTRIBUTORS[1] = DISTRIBUTOR2;

        uint256[] memory MINT_AMOUNTS = new uint256[](2);
        MINT_AMOUNTS[0] = DEFAULT_MINT_AMOUNT;
        MINT_AMOUNTS[1] = DEFAULT_MINT_AMOUNT;

        vm.startPrank(MINTER);
        s_repTokens.mintBatch(DISTRIBUTORS, MINT_AMOUNTS, "");
        vm.stopPrank();

        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            assertEq(s_repTokens.balanceOf(DISTRIBUTOR, i), MINT_AMOUNTS[i]);
        }
    }

    function testDistribute()
        external
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
    {
        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distribute(DISTRIBUTOR, USER, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();

        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            assertEq(s_repTokens.balanceOf(USER, i), DEFAULT_MINT_AMOUNT);
        }
    }

    function testDistributeBatch()
        external
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
    {
        address[] memory USERS = new address[](TOKEN_TYPES_TO_CREATE);
        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            USERS[i] = makeAddr(string.concat("USER", uint2str(i)));
        }

        uint256 mintAmount = DEFAULT_MINT_AMOUNT / TOKEN_TYPES_TO_CREATE;
        uint256[] memory MINT_AMOUNTS = new uint256[](TOKEN_TYPES_TO_CREATE);
        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            MINT_AMOUNTS[i] = mintAmount;
        }

        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distributeBatch(DISTRIBUTOR, USERS, MINT_AMOUNTS, "");
        vm.stopPrank();

        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            assertEq(s_repTokens.balanceOf(USERS[i], i), mintAmount);
        }
    }

    function testSetDestinationWalletAndDistribute()
        external
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
        m_setDestinationWallet(USER, DESTINATION_WALLET)
        m_distribute(USER, DEFAULT_MINT_AMOUNT)
    {
        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            assertEq(
                s_repTokens.balanceOf(
                    s_repTokens.getDestinationWallet(USER),
                    i
                ),
                DEFAULT_MINT_AMOUNT
            );
        }
    }

    function testRedeem()
        external
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
        m_distribute(USER, DEFAULT_MINT_AMOUNT)
    {
        vm.startPrank(USER);
        s_repTokens.safeTransferFrom(USER, BURNER, 1, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();
    }

    function testRevertIfRedeemIsTokenIsNotTradeable()
        external
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
        m_distribute(USER, DEFAULT_MINT_AMOUNT)
    {
        vm.startPrank(USER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToSendNonRedeemableTokens
                .selector
        );
        s_repTokens.safeTransferFrom(USER, BURNER, 0, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();
    }

    function testRevertIfRedeemIllegalyAsDistributor()
        external
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
    {
        vm.startPrank(DISTRIBUTOR);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToSendIllegalyAsDistributor
                .selector
        );
        s_repTokens.safeTransferFrom(
            DISTRIBUTOR,
            BURNER,
            1,
            DEFAULT_MINT_AMOUNT,
            ""
        );
        vm.stopPrank();
    }

    function testRevertIfRedeemIsNotBeingSentToABurner()
        external
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
        m_distribute(USER, DEFAULT_MINT_AMOUNT)
    {
        vm.startPrank(USER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToSendToNonBurner
                .selector
        );
        s_repTokens.safeTransferFrom(
            USER,
            DISTRIBUTOR,
            1,
            DEFAULT_MINT_AMOUNT,
            ""
        );
        vm.stopPrank();
    }

    function testMigrationOfTokens()
        external
        m_batchCreateTokenTypes(types)
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
        m_distribute(USER, DEFAULT_MINT_AMOUNT)
    {
        vm.startPrank(USER);
        s_repTokens.setApprovalForAll(TOKEN_MIGRATOR, true);
        vm.stopPrank();

        vm.startPrank(TOKEN_MIGRATOR);
        s_repTokens.migrateOwnershipOfTokens(USER, USER2);
        vm.stopPrank();

        for (uint256 i = 0; i < types.length; i++) {
            assertEq(s_repTokens.balanceOf(USER, i), 0);
            assertEq(s_repTokens.balanceOf(USER2, i), DEFAULT_MINT_AMOUNT);
        }
    }

    function testGetMaxMintPerTx() external m_batchCreateTokenTypes(types) {
        for (uint256 i = 0; i < types.length; i++) {
            assertEq(s_repTokens.getMaxMintPerTx(i), DEFAULT_MINT_AMOUNT);
        }
    }

    // ////////////////////////
    // // Helper Functions
    // ///////////////////////

    function batchCreateTokenTypes(
        TokenTypesStorage.TokenType[] memory tokenTypes
    ) public {
        vm.startPrank(TOKEN_CREATOR);
        s_repTokens.batchCreateTokenTypes(tokenTypes);
        vm.stopPrank();
    }

    function createTokenType(
        TokenTypesStorage.TokenType memory tokenType
    ) public {
        vm.startPrank(TOKEN_CREATOR);
        s_repTokens.createTokenType(tokenType);
        vm.stopPrank();
    }

    function mint(address to, uint256 amount) public {
        vm.startPrank(MINTER);
        s_repTokens.mint(to, amount, "");
        vm.stopPrank();
    }

    function distribute(address to, uint256 amount) public {
        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distribute(DISTRIBUTOR, to, amount, "");
        vm.stopPrank();
    }

    function setupTokenCreator(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.TOKEN_TYPE_CREATOR_ROLE(), addr);
        vm.stopPrank();
    }

    function setUpMinter(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.MINTER_ROLE(), addr);
        vm.stopPrank();
    }

    function setUpDistributor(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.DISTRIBUTOR_ROLE(), addr);
        vm.stopPrank();
    }

    function setUpBurner(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.BURNER_ROLE(), addr);
        vm.stopPrank();
    }

    function setUpTokenMigrator(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.TOKEN_MIGRATOR_ROLE(), addr);
        vm.stopPrank();
    }

    function setDestinationWallet(address target, address destination) public {
        vm.startPrank(target);
        s_repTokens.setDestinationWallet(destination);
        vm.stopPrank();
    }

    function uint2str(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
