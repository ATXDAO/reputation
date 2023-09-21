// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokens} from "../script/DeployReputationTokens.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {ReputationTokensStorage} from "../src/ReputationTokensStorage.sol";

contract RepTokensTest is Test {
    address ADMIN = makeAddr("ADMIN");
    address MINTER = makeAddr("MINTER");
    address DISTRIBUTOR = makeAddr("DISTRIBUTOR");
    address DISTRIBUTOR2 = makeAddr("DISTRIBUTOR2");
    address BURNER = makeAddr("BURNER");
    address TOKEN_MIGRATOR = makeAddr("TOKEN_MIGRATOR");
    address USER = makeAddr("USER");
    address USER2 = makeAddr("USER2");
    address DESTINATION_WALLET = makeAddr("DESTINATION_WALLET");

    uint256 constant DEFAULT_MINT_AMOUNT = 50;
    uint256 constant MAX_MINT_PER_TX = 100;
    string constant BASE_URI =
        "ipfs://bafybeiaz55w6kf7ar2g5vzikfbft2qoexknstfouu524l7q3mliutns2u4/";

    ReputationTokensStandalone s_repTokens;

    modifier m_setUpBurner(address addr) {
        setUpBurner(addr);
        _;
    }

    function setUpBurner(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.BURNER_ROLE(), addr);
        vm.stopPrank();
    }

    modifier m_setUpMinter(address addr) {
        setUpMinter(addr);
        _;
    }

    function setUpMinter(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.MINTER_ROLE(), addr);
        vm.stopPrank();
    }

    modifier m_setUpTokenMigrator(address addr) {
        setUpTokenMigrator(addr);
        _;
    }

    function setUpTokenMigrator(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.TOKEN_MIGRATOR_ROLE(), addr);
        vm.stopPrank();
    }

    modifier m_setUpDistributor(address addr) {
        setUpDistributor(addr);
        _;
    }

    modifier m_setDestinationWallet(address target, address destination) {
        setDestinationWallet(target, destination);
        _;
    }

    function setDestinationWallet(address target, address destination) public {
        vm.startPrank(target);
        s_repTokens.setDestinationWallet(destination);
        vm.stopPrank();
    }

    modifier m_distribute(address to, uint256 amount) {
        distribute(to, amount);
        _;
    }

    function distribute(address to, uint256 amount) public {
        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distribute(DISTRIBUTOR, to, amount, "");
        vm.stopPrank();
    }

    modifier m_mint(address to, uint256 amount) {
        mint(to, amount);
        _;
    }

    function mint(address to, uint256 amount) public {
        vm.startPrank(MINTER);
        s_repTokens.mint(to, amount, "");
        vm.stopPrank();
    }

    function setUpDistributor(address addr) public {
        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.DISTRIBUTOR_ROLE(), addr);
        vm.stopPrank();
    }

    function setUp() public {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;
        DeployReputationTokens deployer = new DeployReputationTokens();
        s_repTokens = deployer.run(admins, MAX_MINT_PER_TX, BASE_URI);

        setUpMinter(MINTER);
        setUpDistributor(DISTRIBUTOR);
        setUpBurner(BURNER);
        setUpTokenMigrator(TOKEN_MIGRATOR);
    }

    function testURI() public {
        assertEq(s_repTokens.uri(0), string.concat(BASE_URI, "0"));
        assertEq(s_repTokens.uri(1), string.concat(BASE_URI, "1"));
    }

    function testMint() public m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT) {
        assertEq(s_repTokens.balanceOf(DISTRIBUTOR, 0), DEFAULT_MINT_AMOUNT);
        assertEq(s_repTokens.balanceOf(DISTRIBUTOR, 1), DEFAULT_MINT_AMOUNT);
    }

    function testRevertIfMintingTooManyTokens() public {
        uint256 mintAmount = 150;

        vm.startPrank(MINTER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToMintTooManyTokens
                .selector
        );
        s_repTokens.mint(DISTRIBUTOR, mintAmount, "");
        vm.stopPrank();
    }

    function testRevertIfMintingToNonDistributor() public {
        vm.startPrank(MINTER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToMintToNonDistributor
                .selector
        );

        s_repTokens.mint(USER, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();
    }

    function testMintBatch() public m_setUpDistributor(DISTRIBUTOR2) {
        address[] memory DISTRIBUTORS = new address[](2);
        DISTRIBUTORS[0] = DISTRIBUTOR;
        DISTRIBUTORS[1] = DISTRIBUTOR2;

        uint256[] memory MINT_AMOUNTS = new uint256[](2);
        MINT_AMOUNTS[0] = DEFAULT_MINT_AMOUNT;
        MINT_AMOUNTS[1] = DEFAULT_MINT_AMOUNT;

        vm.startPrank(MINTER);
        s_repTokens.mintBatch(DISTRIBUTORS, MINT_AMOUNTS, "");
        vm.stopPrank();

        assertEq(s_repTokens.balanceOf(DISTRIBUTOR, 0), MINT_AMOUNTS[0]);
        assertEq(s_repTokens.balanceOf(DISTRIBUTOR, 1), MINT_AMOUNTS[1]);

        assertEq(s_repTokens.balanceOf(DISTRIBUTOR2, 0), MINT_AMOUNTS[0]);
        assertEq(s_repTokens.balanceOf(DISTRIBUTOR2, 1), MINT_AMOUNTS[1]);
    }

    function testDistribute() public m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT) {
        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distribute(DISTRIBUTOR, USER, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();

        assertEq(s_repTokens.balanceOf(USER, 0), DEFAULT_MINT_AMOUNT);
        assertEq(s_repTokens.balanceOf(USER, 1), DEFAULT_MINT_AMOUNT);
    }

    function testDistributeBatch()
        public
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
    {
        address[] memory USERS = new address[](2);
        USERS[0] = USER;
        USERS[1] = USER2;

        uint256 mintAmount = DEFAULT_MINT_AMOUNT / 2;
        uint256[] memory MINT_AMOUNTS = new uint256[](2);
        MINT_AMOUNTS[0] = mintAmount;
        MINT_AMOUNTS[1] = mintAmount;

        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distributeBatch(DISTRIBUTOR, USERS, MINT_AMOUNTS, "");
        vm.stopPrank();

        assertEq(s_repTokens.balanceOf(USER, 0), mintAmount);
        assertEq(s_repTokens.balanceOf(USER, 1), mintAmount);

        assertEq(s_repTokens.balanceOf(USER2, 0), mintAmount);
        assertEq(s_repTokens.balanceOf(USER2, 1), mintAmount);
    }

    function testSetDestinationWalletAndDistribute()
        public
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
        m_setDestinationWallet(USER, DESTINATION_WALLET)
        m_distribute(USER, DEFAULT_MINT_AMOUNT)
    {
        assertEq(
            s_repTokens.balanceOf(s_repTokens.getDestinationWallet(USER), 0),
            DEFAULT_MINT_AMOUNT
        );
        assertEq(
            s_repTokens.balanceOf(s_repTokens.getDestinationWallet(USER), 1),
            DEFAULT_MINT_AMOUNT
        );
    }

    function testRedeem()
        public
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
        m_distribute(USER, DEFAULT_MINT_AMOUNT)
    {
        vm.startPrank(USER);
        s_repTokens.safeTransferFrom(USER, BURNER, 1, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();
    }

    function testRevertIfRedeemIsNotToken1()
        public
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
        public
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

    function testRevertIfRedeemIsBeingSentToABurner()
        public
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
        public
        m_mint(DISTRIBUTOR, DEFAULT_MINT_AMOUNT)
        m_distribute(USER, DEFAULT_MINT_AMOUNT)
    {
        vm.startPrank(USER);
        s_repTokens.setApprovalForAll(TOKEN_MIGRATOR, true);
        vm.stopPrank();

        vm.startPrank(TOKEN_MIGRATOR);
        s_repTokens.migrateOwnershipOfTokens(USER, USER2);
        vm.stopPrank();

        assertEq(s_repTokens.balanceOf(USER, 0), 0);
        assertEq(s_repTokens.balanceOf(USER, 1), 0);

        assertEq(s_repTokens.balanceOf(USER2, 0), DEFAULT_MINT_AMOUNT);
        assertEq(s_repTokens.balanceOf(USER2, 1), DEFAULT_MINT_AMOUNT);
    }
}
