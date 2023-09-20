// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {RepTokens} from "../src/RepTokens.sol";
// import {DeployRepTokens} from "../script/DeployRepTokens.s.sol";

// contract RepTokensTest is Test {
//     address ADMIN = makeAddr("ADMIN");
//     address MINTER = makeAddr("MINTER");
//     address DISTRIBUTOR = makeAddr("DISTRIBUTOR");
//     address TOKEN_MIGRATOR = makeAddr("TOKEN_MIGRATOR");
//     address USER = makeAddr("USER");

//     uint256 constant MAX_MINT_PER_TX = 100;
//     string constant BASE_URI =
//         "ipfs://bafybeiaz55w6kf7ar2g5vzikfbft2qoexknstfouu524l7q3mliutns2u4/";

//     RepTokens s_repTokens;

//     function setUp() public {
//         address[] memory admins = new address[](1);
//         admins[0] = ADMIN;
//         DeployRepTokens deployer = new DeployRepTokens();
//         s_repTokens = deployer.run(admins, MAX_MINT_PER_TX, BASE_URI);
//     }

//     function testURI() public {
//         assertEq(s_repTokens.uri(0), string.concat(BASE_URI, "0"));
//         assertEq(s_repTokens.uri(1), string.concat(BASE_URI, "1"));
//     }

//     function testSuccesfullMint() public {
//         uint256 MINT_AMOUNT = 50;

//         vm.startPrank(ADMIN);
//         s_repTokens.grantRole(s_repTokens.MINTER_ROLE(), MINTER);
//         s_repTokens.grantRole(s_repTokens.DISTRIBUTOR_ROLE(), DISTRIBUTOR);
//         vm.stopPrank();

//         vm.startPrank(MINTER);
//         s_repTokens.mint(DISTRIBUTOR, MINT_AMOUNT, "");
//         vm.stopPrank();

//         assertEq(s_repTokens.balanceOf(DISTRIBUTOR, 0), MINT_AMOUNT);
//         assertEq(s_repTokens.balanceOf(DISTRIBUTOR, 1), MINT_AMOUNT);
//     }

//     function testRevertIfMintingTooManyTokens() public {
//         uint256 MINT_AMOUNT = 150;

//         vm.startPrank(ADMIN);
//         s_repTokens.grantRole(s_repTokens.MINTER_ROLE(), MINTER);
//         s_repTokens.grantRole(s_repTokens.DISTRIBUTOR_ROLE(), DISTRIBUTOR);
//         vm.stopPrank();

//         vm.startPrank(MINTER);
//         vm.expectRevert(RepTokens.AttemptingToMintTooManyTokens.selector);
//         s_repTokens.mint(DISTRIBUTOR, MINT_AMOUNT, "");
//         vm.stopPrank();
//     }

//     function testRevertIfMintingToNonDistributor() public {
//         uint256 MINT_AMOUNT = 50;

//         vm.startPrank(ADMIN);
//         s_repTokens.grantRole(s_repTokens.MINTER_ROLE(), MINTER);
//         vm.stopPrank();

//         vm.startPrank(MINTER);
//         vm.expectRevert(RepTokens.AttemptingToMintToNonDistributor.selector);

//         s_repTokens.mint(DISTRIBUTOR, MINT_AMOUNT, "");
//         vm.stopPrank();
//     }
// }
