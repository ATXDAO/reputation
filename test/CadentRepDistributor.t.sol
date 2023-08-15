// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockRepTokens} from "./Mocks/MockRepToken.sol";
import {CadentRepDistributor} from "../src/CadentRepDistributor.sol";
import {DeployCadentRepDistributor} from "../script/DeployCadentRepDistributor.s.sol";

contract CadentRepDistributorTest is Test {
    error CadentRepDistributor__NOT_ENOUGH_TIME_PASSED();
    error CadentRepDistributor__NO_TOkENS_TO_DISTRIBUTE();

    address public ADMIN = makeAddr("ADMIN");
    uint256 constant MAX_MINT_PER_TX = 100;
    uint256 constant AMOUNT_DISTRIBUTED_PER_CADENCE = 5;
    uint256 constant CADENCE_OF_1_DAY = 86400;
    uint256 constant CADENCE_OF_1_WEEK = 604800;

    uint256 s_selectedCadence;
    uint256 s_slightlyLessThanCadence;

    MockRepTokens s_repTokens;
    CadentRepDistributor s_cadentRepDistributor;

    DeployCadentRepDistributor s_deployCadentRepDistributor;

    function setUp() public {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;

        s_repTokens = new MockRepTokens(admins, MAX_MINT_PER_TX);

        vm.startPrank(ADMIN);
        s_repTokens.grantRole(s_repTokens.MINTER_ROLE(), ADMIN);
        s_repTokens.grantRole(s_repTokens.DISTRIBUTOR_ROLE(), ADMIN);
        vm.stopPrank();

        s_selectedCadence = CADENCE_OF_1_WEEK;
        s_slightlyLessThanCadence = s_selectedCadence - 2;

        s_deployCadentRepDistributor = new DeployCadentRepDistributor();
        s_cadentRepDistributor = s_deployCadentRepDistributor.run(
            address(s_repTokens),
            AMOUNT_DISTRIBUTED_PER_CADENCE,
            s_selectedCadence
        );
    }

    function advanceSeconds(uint256 numOfSeconds) public {
        vm.warp(block.timestamp + numOfSeconds + 1);
        vm.roll(block.number + 1);
    }

    function dealNewAccount(
        string memory accountName
    ) public returns (address) {
        address user = makeAddr(accountName);
        vm.deal(user, 1 ether);
        return user;
    }

    modifier setupDailyRepDistributorRole(address admin) {
        vm.startPrank(admin);
        s_repTokens.grantRole(
            s_repTokens.DISTRIBUTOR_ROLE(),
            address(s_cadentRepDistributor)
        );
        vm.stopPrank();
        _;
    }

    modifier setupDailyRepDistributorWithTokens(address minter) {
        vm.startPrank(minter);
        s_repTokens.mint(address(s_cadentRepDistributor), 100, "");
        vm.stopPrank();
        _;
    }

    function testGetRemainingTime()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN)
    {
        address user = dealNewAccount("user");

        vm.startPrank(user);
        s_cadentRepDistributor.claim();
        vm.stopPrank();

        advanceSeconds(CADENCE_OF_1_WEEK + 1 seconds);

        int result = s_cadentRepDistributor.getRemainingTime(user);
        assertEq(result, -2);
    }

    function testDailyRepDistributorGetsGrantedDistributorRole()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN)
    {
        assertEq(
            s_repTokens.hasRole(
                s_repTokens.DISTRIBUTOR_ROLE(),
                address(s_cadentRepDistributor)
            ),
            true
        );
    }

    function testUserCanDoFirstTimeClaim()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN)
    {
        address user = dealNewAccount("user");

        vm.startPrank(user);
        s_cadentRepDistributor.claim();
        vm.stopPrank();

        assertEq(
            s_repTokens.balanceOf(user, 0),
            AMOUNT_DISTRIBUTED_PER_CADENCE
        );
    }

    function testUserCanDoClaimAfterOneDayFromLastClaim()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN)
    {
        testUserCanDoFirstTimeClaim();

        address user = dealNewAccount("user");

        advanceSeconds(s_selectedCadence);

        vm.startPrank(user);
        s_cadentRepDistributor.claim();
        vm.stopPrank();
    }

    function testUserCannotDoClaimImmediatelyAfterLastClaim()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN)
    {
        testUserCanDoFirstTimeClaim();

        address user = dealNewAccount("user");

        advanceSeconds(s_selectedCadence);

        vm.startPrank(user);
        s_cadentRepDistributor.claim();

        vm.expectRevert(CadentRepDistributor__NOT_ENOUGH_TIME_PASSED.selector);
        s_cadentRepDistributor.claim();
        vm.stopPrank();
    }

    function testUserCannotDoClaimBeforeAnyClaim()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN)
    {
        testUserCanDoFirstTimeClaim();

        address user = dealNewAccount("user");

        advanceSeconds(s_slightlyLessThanCadence);

        vm.startPrank(user);
        vm.expectRevert(CadentRepDistributor__NOT_ENOUGH_TIME_PASSED.selector);
        s_cadentRepDistributor.claim();
        vm.stopPrank();
    }

    function testUserCannotClaimBecauseCadentRepDistributorHasNoTokens()
        public
        setupDailyRepDistributorRole(ADMIN)
    {
        address user = dealNewAccount("user");

        vm.startPrank(user);
        vm.expectRevert(CadentRepDistributor__NO_TOkENS_TO_DISTRIBUTE.selector);
        s_cadentRepDistributor.claim();
        vm.stopPrank();
    }
}
