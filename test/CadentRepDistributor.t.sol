// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockRepTokens} from "./Mocks/MockRepToken.sol";
import {CadentRepDistributor} from "../src/CadentRepDistributor.sol";
import {DeployCadentRepDistributor} from "../script/DeployCadentRepDistributor.s.sol";

contract CadentRepDistributorTest is Test {
    address public ADMIN = makeAddr("ADMIN");
    address public USER = makeAddr("USER");
    uint256 constant MAX_MINT_PER_TX = 100;
    uint256 constant AMOUNT_DISTRIBUTED_PER_CADENCE = 5;
    uint256 constant CADENCE_OF_1_DAY = 86400;
    uint256 constant CADENCE_OF_1_WEEK = 604800;

    uint256 constant AMOUNT_TO_SET_UP_DISTRIBUTOR_WITH = 100;

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
        s_cadentRepDistributor =
            s_deployCadentRepDistributor.run(address(s_repTokens), AMOUNT_DISTRIBUTED_PER_CADENCE, s_selectedCadence);

        vm.deal(USER, 1 ether);
    }

    function advanceSeconds(uint256 numOfSeconds) public {
        vm.warp(block.timestamp + numOfSeconds + 1);
        vm.roll(block.number + 1);
    }

    modifier setupDailyRepDistributorRole(address admin) {
        vm.startPrank(admin);
        s_repTokens.grantRole(s_repTokens.DISTRIBUTOR_ROLE(), address(s_cadentRepDistributor));
        vm.stopPrank();
        _;
    }

    modifier setupDailyRepDistributorWithTokens(address minter, uint256 amount) {
        vm.startPrank(minter);
        s_repTokens.mint(address(s_cadentRepDistributor), amount, "");
        vm.stopPrank();
        _;
    }

    function testGetRemainingTime()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN, AMOUNT_TO_SET_UP_DISTRIBUTOR_WITH)
    {
        vm.startPrank(USER);
        s_cadentRepDistributor.claim();
        vm.stopPrank();

        advanceSeconds(CADENCE_OF_1_WEEK + 1 seconds);

        int256 result = s_cadentRepDistributor.getRemainingTime(USER);
        assertEq(result, -2);
    }

    function testDailyRepDistributorGetsGrantedDistributorRole()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN, AMOUNT_TO_SET_UP_DISTRIBUTOR_WITH)
    {
        assertEq(s_repTokens.hasRole(s_repTokens.DISTRIBUTOR_ROLE(), address(s_cadentRepDistributor)), true);
    }

    function testUserCanDoFirstTimeClaim()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN, AMOUNT_TO_SET_UP_DISTRIBUTOR_WITH)
    {
        vm.startPrank(USER);
        s_cadentRepDistributor.claim();
        vm.stopPrank();

        assertEq(s_repTokens.balanceOf(USER, 0), AMOUNT_DISTRIBUTED_PER_CADENCE);
    }

    function testUserCanDoClaimAfterOneDayFromLastClaim()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN, AMOUNT_TO_SET_UP_DISTRIBUTOR_WITH)
    {
        testUserCanDoFirstTimeClaim();

        advanceSeconds(s_selectedCadence);

        vm.startPrank(USER);
        s_cadentRepDistributor.claim();
        vm.stopPrank();
    }

    function testUserCannotDoClaimImmediatelyAfterLastClaim()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN, AMOUNT_TO_SET_UP_DISTRIBUTOR_WITH)
    {
        testUserCanDoFirstTimeClaim();

        advanceSeconds(s_selectedCadence);

        vm.startPrank(USER);
        s_cadentRepDistributor.claim();

        vm.expectRevert(CadentRepDistributor.CadentRepDistributor__NOT_ENOUGH_TIME_PASSED.selector);
        s_cadentRepDistributor.claim();
        vm.stopPrank();
    }

    function testUserCannotDoClaimBeforeAnyClaim()
        public
        setupDailyRepDistributorRole(ADMIN)
        setupDailyRepDistributorWithTokens(ADMIN, AMOUNT_TO_SET_UP_DISTRIBUTOR_WITH)
    {
        testUserCanDoFirstTimeClaim();

        advanceSeconds(s_slightlyLessThanCadence);

        vm.startPrank(USER);
        vm.expectRevert(CadentRepDistributor.CadentRepDistributor__NOT_ENOUGH_TIME_PASSED.selector);
        s_cadentRepDistributor.claim();
        vm.stopPrank();
    }

    function testUserCannotClaimBecauseCadentRepDistributorHasNoTokens() public setupDailyRepDistributorRole(ADMIN) {
        vm.startPrank(USER);
        vm.expectRevert(CadentRepDistributor.CadentRepDistributor__NOT_ENOUGH_TOkENS_TO_DISTRIBUTE.selector);
        s_cadentRepDistributor.claim();
        vm.stopPrank();
    }

    function testGetAmountToDistributePerCadence() public {
        assertEq(s_cadentRepDistributor.getAmountToDistributePerCadence(), AMOUNT_DISTRIBUTED_PER_CADENCE);
    }

    function testGetCadence() public {
        assertEq(s_cadentRepDistributor.getCadence(), s_selectedCadence);
    }
}
