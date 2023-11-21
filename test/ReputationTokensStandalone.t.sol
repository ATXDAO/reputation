// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ReputationTokensStandalone} from "../src/ReputationTokensStandalone.sol";
import {DeployReputationTokensStandalone} from "../script/DeployReputationTokensStandalone.s.sol";
import {IReputationTokensBaseInternal} from "../src/IReputationTokensBaseInternal.sol";
import {TokenTypesStorage} from "../src/storage/TokenTypesStorage.sol";
import {ReputationTokensInternal} from "../src/ReputationTokensInternal.sol";

contract RepTokensStandaloneTest is Test {
    ////////////////////////
    // State Variables
    ////////////////////////
    address ADMIN = makeAddr("ADMIN");
    address TOKEN_TYPE_CREATOR = makeAddr("TOKEN_TYPE_CREATOR");
    address MINTER = makeAddr("MINTER");
    address DISTRIBUTOR = makeAddr("DISTRIBUTOR");
    address BURNER = makeAddr("BURNER");
    address TOKEN_MIGRATOR = makeAddr("TOKEN_MIGRATOR");
    address USER = makeAddr("USER");
    address USER2 = makeAddr("USER2");
    address DESTINATION_WALLET = makeAddr("DESTINATION_WALLET");

    TokenTypesStorage.TokenType[] tokenTypes;
    uint256 constant TOKEN_TYPES_TO_CREATE = 2;
    uint256 constant DEFAULT_MINT_AMOUNT = 20;
    string constant BASE_URI =
        "ipfs://bafybeiaz55w6kf7ar2g5vzikfbft2qoexknstfouu524l7q3mliutns2u4/";

    ReputationTokensStandalone s_repTokens;

    ////////////////////////
    // Functions
    ////////////////////////

    function setUp() public {
        setUpDeploy();
        setUpRoles();
        setUpTokenTypes();
    }

    function setUpDeploy() public {
        address[] memory admins = new address[](1);
        admins[0] = ADMIN;
        DeployReputationTokensStandalone deployer = new DeployReputationTokensStandalone();
        s_repTokens = deployer.run(ADMIN, admins, BASE_URI);
    }

    function setUpRoles() public {
        setUpRole(s_repTokens.TOKEN_TYPE_CREATOR_ROLE(), TOKEN_TYPE_CREATOR);
        setUpRole(s_repTokens.MINTER_ROLE(), MINTER);
        setUpRole(s_repTokens.DISTRIBUTOR_ROLE(), DISTRIBUTOR);
        setUpRole(s_repTokens.BURNER_ROLE(), BURNER);
        setUpRole(s_repTokens.TOKEN_MIGRATOR_ROLE(), TOKEN_MIGRATOR);
    }

    function setUpTokenTypes() public {
        TokenTypesStorage.TokenType memory t1 = TokenTypesStorage.TokenType(
            false,
            DEFAULT_MINT_AMOUNT
        );
        TokenTypesStorage.TokenType memory t2 = TokenTypesStorage.TokenType(
            true,
            DEFAULT_MINT_AMOUNT
        );

        tokenTypes.push(t1);
        tokenTypes.push(t2);
    }

    ////////////////////////
    // Tests
    ////////////////////////

    function testCreateTokenType(
        TokenTypesStorage.TokenType memory tokenType
    ) public {
        createTokenType(tokenType);
        assertEq(s_repTokens.getNumOfTokenTypes(), 1);
    }

    function testCreateTokenType() external {
        testCreateTokenType(tokenTypes[0]);
    }

    function testBatchCreateTokenTypes(
        TokenTypesStorage.TokenType[] memory types
    ) public {
        batchCreateTokenTypes(types);

        assertEq(types.length, s_repTokens.getNumOfTokenTypes());
    }

    function testBatchCreateTokenTypes() external {
        testBatchCreateTokenTypes(tokenTypes);
    }

    // function testMint(
    //     address minter,
    //     address distributor,
    //     TokenTypesStorage.TokenType[] memory types

    // ) public {
    //     vm.assume(minter != 0x0000000000000000000000000000000000000000);
    //     vm.assume(distributor != 0x0000000000000000000000000000000000000000);
    //     vm.assume(types.length > 0);

    //     for (uint256 i = 0; i < types.length; i++) {
    //         vm.assume(types[i].maxMintAmountPerTx > 0);
    //     }

    //     batchCreateTokenTypes(types);
    //     setUpRole(s_repTokens.DISTRIBUTOR_ROLE(), distributor);

    //     ReputationTokensInternal.TokenOperation[]
    //         memory tokenOperations = createTokenOperationsSequential(
    //             types.length,
    //             DEFAULT_MINT_AMOUNT
    //         );

    //     mint(minter, distributor, tokenOperations);

    //     for (uint256 i = 0; i < types.length; i++) {
    //         assertEq(
    //             s_repTokens.balanceOf(distributor, i),
    //             DEFAULT_MINT_AMOUNT
    //         );
    //     }
    // }

    function testMint() public {
        batchCreateTokenTypes(tokenTypes);

        ReputationTokensInternal.TokenOperation[]
            memory tokenOperations = createTokenOperationsSequential(
                TOKEN_TYPES_TO_CREATE,
                DEFAULT_MINT_AMOUNT
            );

        mint(MINTER, DISTRIBUTOR, tokenOperations);

        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            assertEq(
                s_repTokens.balanceOf(DISTRIBUTOR, i),
                DEFAULT_MINT_AMOUNT
            );
        }
    }

    function testRevertIfMintingTooManyTokens() external {
        batchCreateTokenTypes(tokenTypes);

        ReputationTokensInternal.TokenOperation[]
            memory tokenOperations = createTokenOperationsSequential(
                TOKEN_TYPES_TO_CREATE,
                DEFAULT_MINT_AMOUNT + 1
            );

        vm.startPrank(MINTER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToMintTooManyTokens
                .selector
        );

        s_repTokens.mint(DISTRIBUTOR, tokenOperations, "");
        vm.stopPrank();
    }

    function testRevertIfMintingToNonDistributor() external {
        batchCreateTokenTypes(tokenTypes);

        ReputationTokensInternal.TokenOperation[]
            memory tokenOperations = createTokenOperationsSequential(
                TOKEN_TYPES_TO_CREATE,
                DEFAULT_MINT_AMOUNT
            );

        vm.startPrank(MINTER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToMintToNonDistributor
                .selector
        );

        s_repTokens.mint(USER, tokenOperations, "");
        vm.stopPrank();
    }

    function testMintBatch() external {
        address distributor2 = vm.addr(5);
        setUpRole(s_repTokens.DISTRIBUTOR_ROLE(), distributor2);

        batchCreateTokenTypes(tokenTypes);

        address[] memory distributors = new address[](2);
        distributors[0] = DISTRIBUTOR;
        distributors[1] = distributor2;

        ReputationTokensInternal.TokenOperation[]
            memory tokenOperations = createTokenOperationsSequential(
                TOKEN_TYPES_TO_CREATE,
                DEFAULT_MINT_AMOUNT
            );

        ReputationTokensInternal.BatchTokenOperation[]
            memory batchMint = new ReputationTokensInternal.BatchTokenOperation[](
                distributors.length
            );

        for (uint256 i = 0; i < batchMint.length; i++) {
            batchMint[i].to = distributors[i];
            batchMint[i].tokens = tokenOperations;
        }

        vm.startPrank(MINTER);
        s_repTokens.mintBatch(batchMint, "");
        vm.stopPrank();

        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            for (uint256 j = 0; j < distributors.length; j++) {
                assertEq(
                    s_repTokens.balanceOf(distributors[j], i),
                    DEFAULT_MINT_AMOUNT
                );
            }
        }
    }

    function testDistribute() external {
        batchCreateTokenTypes(tokenTypes);

        uint256 numOfTokens = TOKEN_TYPES_TO_CREATE;
        address user = makeAddr("USER");

        ReputationTokensInternal.TokenOperation[]
            memory tokenOperations = createTokenOperationsSequential(
                numOfTokens,
                DEFAULT_MINT_AMOUNT
            );

        mint(MINTER, DISTRIBUTOR, tokenOperations);

        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distribute(DISTRIBUTOR, user, tokenOperations, "");
        vm.stopPrank();

        for (uint256 i = 0; i < numOfTokens; i++) {
            assertEq(s_repTokens.balanceOf(DISTRIBUTOR, i), 0);
            assertEq(s_repTokens.balanceOf(user, i), DEFAULT_MINT_AMOUNT);
        }
    }

    function testDistributeBatch() external {
        batchCreateTokenTypes(tokenTypes);

        ReputationTokensInternal.TokenOperation[]
            memory mintOps = createTokenOperationsSequential(
                TOKEN_TYPES_TO_CREATE,
                DEFAULT_MINT_AMOUNT
            );

        mint(MINTER, DISTRIBUTOR, mintOps);

        address[] memory users = generateUsers(5);

        ReputationTokensInternal.BatchTokenOperation[]
            memory batchOp = new ReputationTokensInternal.BatchTokenOperation[](
                users.length
            );

        ReputationTokensInternal.TokenOperation[]
            memory distributeOps = createTokenOperationsSequential(
                mintOps.length,
                DEFAULT_MINT_AMOUNT / users.length
            );

        for (uint256 i = 0; i < batchOp.length; i++) {
            batchOp[i].to = users[i];
            batchOp[i].tokens = distributeOps;
        }

        vm.startPrank(DISTRIBUTOR);
        s_repTokens.distributeBatch(DISTRIBUTOR, batchOp, "");
        vm.stopPrank();

        for (uint256 i = 0; i < TOKEN_TYPES_TO_CREATE; i++) {
            assertEq(s_repTokens.balanceOf(DISTRIBUTOR, i), 0);
            for (uint256 j = 0; j < batchOp.length; j++) {
                assertEq(
                    s_repTokens.balanceOf(batchOp[j].to, i),
                    DEFAULT_MINT_AMOUNT / users.length
                );
            }
        }
    }

    function testSetDestinationWalletAndDistribute() external {
        batchCreateTokenTypes(tokenTypes);

        uint256 numOfTokens = 1;

        ReputationTokensInternal.TokenOperation[]
            memory mintTokens = new ReputationTokensInternal.TokenOperation[](
                numOfTokens
            );
        mintTokens[0].id = 0;
        mintTokens[0].amount = DEFAULT_MINT_AMOUNT;
        mint(MINTER, DISTRIBUTOR, mintTokens);

        setDestinationWallet(USER, DESTINATION_WALLET);
        distribute(DISTRIBUTOR, USER, mintTokens);

        for (uint256 i = 0; i < numOfTokens; i++) {
            assertEq(
                s_repTokens.balanceOf(
                    s_repTokens.getDestinationWallet(USER),
                    i
                ),
                DEFAULT_MINT_AMOUNT
            );

            assertEq(
                s_repTokens.balanceOf(DESTINATION_WALLET, i),
                DEFAULT_MINT_AMOUNT
            );
        }
    }

    function testRedeem() external {
        batchCreateTokenTypes(tokenTypes);
        ReputationTokensInternal.TokenOperation[]
            memory mintTokens = new ReputationTokensInternal.TokenOperation[](
                tokenTypes.length
            );
        mintTokens[0].id = 0;
        mintTokens[0].amount = DEFAULT_MINT_AMOUNT;

        mintTokens[1].id = 1;
        mintTokens[1].amount = DEFAULT_MINT_AMOUNT;

        mint(MINTER, DISTRIBUTOR, mintTokens);
        distribute(DISTRIBUTOR, USER, mintTokens);

        vm.startPrank(USER);
        s_repTokens.safeTransferFrom(USER, BURNER, 1, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();
    }

    function testRevertIfRedeemIsTokenIsNotTradeable() external {
        batchCreateTokenTypes(tokenTypes);
        ReputationTokensInternal.TokenOperation[]
            memory mintTokens = new ReputationTokensInternal.TokenOperation[](
                1
            );
        mintTokens[0].id = 0;
        mintTokens[0].amount = DEFAULT_MINT_AMOUNT;
        mint(MINTER, DISTRIBUTOR, mintTokens);
        distribute(DISTRIBUTOR, USER, mintTokens);

        vm.startPrank(USER);
        vm.expectRevert(
            IReputationTokensBaseInternal
                .ReputationTokens__AttemptingToSendNonRedeemableTokens
                .selector
        );
        s_repTokens.safeTransferFrom(USER, BURNER, 0, DEFAULT_MINT_AMOUNT, "");
        vm.stopPrank();
    }

    function testRevertIfRedeemIllegalyAsDistributor() external {
        batchCreateTokenTypes(tokenTypes);
        ReputationTokensInternal.TokenOperation[]
            memory mintTokens = new ReputationTokensInternal.TokenOperation[](
                tokenTypes.length
            );
        mintTokens[0].id = 0;
        mintTokens[0].amount = DEFAULT_MINT_AMOUNT;
        mintTokens[1].id = 1;
        mintTokens[1].amount = DEFAULT_MINT_AMOUNT;

        mint(MINTER, DISTRIBUTOR, mintTokens);

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

    function testRevertIfRedeemIsNotBeingSentToABurner() external {
        batchCreateTokenTypes(tokenTypes);
        ReputationTokensInternal.TokenOperation[]
            memory mintTokens = new ReputationTokensInternal.TokenOperation[](
                tokenTypes.length
            );
        mintTokens[0].id = 0;
        mintTokens[0].amount = DEFAULT_MINT_AMOUNT;
        mintTokens[1].id = 1;
        mintTokens[1].amount = DEFAULT_MINT_AMOUNT;

        mint(MINTER, DISTRIBUTOR, mintTokens);
        distribute(DISTRIBUTOR, USER, mintTokens);

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

    function testMigrationOfTokens() external {
        batchCreateTokenTypes(tokenTypes);
        ReputationTokensInternal.TokenOperation[]
            memory mintTokens = new ReputationTokensInternal.TokenOperation[](
                tokenTypes.length
            );
        mintTokens[0].id = 0;
        mintTokens[0].amount = DEFAULT_MINT_AMOUNT;
        mintTokens[1].id = 1;
        mintTokens[1].amount = DEFAULT_MINT_AMOUNT;

        mint(MINTER, DISTRIBUTOR, mintTokens);
        distribute(DISTRIBUTOR, USER, mintTokens);

        vm.startPrank(USER);
        s_repTokens.setApprovalForAll(TOKEN_MIGRATOR, true);
        vm.stopPrank();

        vm.startPrank(TOKEN_MIGRATOR);
        s_repTokens.migrateOwnershipOfTokens(USER, USER2);
        vm.stopPrank();

        for (uint256 i = 0; i < tokenTypes.length; i++) {
            assertEq(s_repTokens.balanceOf(USER, i), 0);
            assertEq(s_repTokens.balanceOf(USER2, i), DEFAULT_MINT_AMOUNT);
        }
    }

    function testURI() external {
        assertEq(s_repTokens.uri(0), string.concat(BASE_URI, "0"));
        assertEq(s_repTokens.uri(1), string.concat(BASE_URI, "1"));
    }

    function testGetMaxMintPerTx() external {
        batchCreateTokenTypes(tokenTypes);

        for (uint256 i = 0; i < tokenTypes.length; i++) {
            assertEq(s_repTokens.getMaxMintPerTx(i), DEFAULT_MINT_AMOUNT);
        }
    }

    // ////////////////////////
    // // Helper Functions
    // ///////////////////////

    function batchCreateTokenTypes(
        TokenTypesStorage.TokenType[] memory types
    ) public {
        vm.startPrank(TOKEN_TYPE_CREATOR);
        s_repTokens.batchCreateTokenTypes(types);
        vm.stopPrank();
    }

    function createTokenType(
        TokenTypesStorage.TokenType memory tokenType
    ) public {
        vm.startPrank(TOKEN_TYPE_CREATOR);
        s_repTokens.createTokenType(tokenType);
        vm.stopPrank();
    }

    function createTokenOperationsSequential(
        uint256 length,
        uint256 amount
    ) public pure returns (ReputationTokensInternal.TokenOperation[] memory) {
        ReputationTokensInternal.TokenOperation[]
            memory tokenOperations = new ReputationTokensInternal.TokenOperation[](
                length
            );

        for (uint256 i = 0; i < length; i++) {
            tokenOperations[i].id = i;
            tokenOperations[i].amount = amount;
        }

        return tokenOperations;
    }

    function mint(
        address minter,
        address to,
        ReputationTokensInternal.TokenOperation[] memory mintTokens
    ) public {
        vm.startPrank(minter);
        s_repTokens.mint(to, mintTokens, "");
        vm.stopPrank();
    }

    function distribute(
        address distributor,
        address to,
        ReputationTokensInternal.TokenOperation[] memory tokenOps
    ) public {
        vm.startPrank(distributor);
        s_repTokens.distribute(distributor, to, tokenOps, "");
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

    function generateUsers(uint256 amount) public returns (address[] memory) {
        address[] memory users = new address[](amount);

        for (uint256 i = 0; i < users.length; i++) {
            users[i] = makeAddr(string.concat("USER", uint2str(i)));
        }

        return users;
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
