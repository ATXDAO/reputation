// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {
    ERC1155,
    ERC1155URIStorage
} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

import {ReputationTokensInternal} from "./ReputationTokensInternal.sol";
import {IReputationTokensErrors} from "./IReputationTokensErrors.sol";
import {Test, console} from "forge-std/Test.sol";

/**
 * @title Reputation Tokens Internal
 * @author Jacob Homanics
 *
 * Contains all of the internal functions for Repuation Tokens.
 *
 * @dev This contract follows the Diamond Storage Pattern where state variables are stored in libraries.
 *          This contract implements a library for Custom ERC1155 Storage management.
 *          This contract implements a library for Solid State's ERC 1155 Metadata Storage management.
 * @dev This contract inherits from SolidStateERC1155. Which is a smart contract that follows the Diamond Storage Pattern and
 *      allows for easy creation of ERC1155 compliant smart contracts.
 *      Source code and info found here: https://github.com/solidstate-network/solidstate-solidity
 * @dev This contract inherits from IReputationTokensErrors. Which contains the errors and events for Reputation Tokens.
 */
contract ReputationTokensInternal is
    ERC1155URIStorage,
    IReputationTokensErrors
{
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Types
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    enum TokenType {
        Default,
        Redeemable,
        Soulbound
    }

    struct TokenProperties {
        TokenType tokenType;
        uint256 maxMintAmountPerTx;
    }

    struct Operation {
        uint256 id;
        uint256 amount;
    }

    struct Sequence {
        address to;
        Operation[] operations;
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // State Variables
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TOKEN_CREATOR_ROLE = keccak256("TOKEN_CREATOR_ROLE");
    bytes32 public constant TOKEN_UPDATER_ROLE = keccak256("TOKEN_UPDATER_ROLE");
    bytes32 public constant TOKEN_URI_SETTER_ROLE =
        keccak256("TOKEN_URI_SETTER_ROLE");

    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant TOKEN_MIGRATOR_ROLE =
        keccak256("TOKEN_MIGRATOR_ROLE");

    mapping(address => address) s_destinationWallets;
    uint256 s_numOfTokens;
    mapping(address distributor => mapping(uint256 tokenId => uint256))
        s_distributableBalance;
    mapping(address burner => mapping(uint256 tokenId => uint256))
        s_burnedBalance;
    mapping(uint256 => TokenProperties) tokensProperties;

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // event Create(TokenProperties);
    // event Update(
    //     uint256 indexed id,
    //     TokensPropertiesStorage.TokenProperties indexed properties
    // );

    // event Mint(
    //     address indexed from, address indexed to, Operation[] indexed operations
    // );

    // event Distributed(
    //     address indexed from, address indexed to, Operation[] indexed operations
    // );

    // event DestinationWalletSet(
    //     address indexed coreAddress, address indexed destination
    // );

    // event OwnershipOfTokensMigrated(
    //     address indexed from, address indexed to, uint256 balance
    // );

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    constructor() ERC1155("") {}

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Internal Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function _createToken(TokenProperties memory tokenProperties)
        internal
        returns (uint256 tokenId)
    {
        uint256 newTokenId = s_numOfTokens;
        s_numOfTokens++;

        _updateTokenProperties(newTokenId, tokenProperties);

        // emit Create(tokenProperties);

        tokenId = newTokenId;
    }

    function _updateTokenProperties(
        uint256 id,
        TokenProperties memory tokenProperties
    ) internal {
        if (id >= s_numOfTokens) {
            revert ReputationTokens__CannotUpdateNonexistentTokenType();
        }

        tokensProperties[id].tokenType = tokenProperties.tokenType;

        tokensProperties[id].maxMintAmountPerTx =
            tokenProperties.maxMintAmountPerTx;

        // emit Update(id, tokenProperties);
    }

    /**
     * Checks and sets the destination wallet for an address if it is currently set to the zero address.
     * @param addr address who may get their destination wallet set
     */
    function initializeDestinationWallet(address addr) internal {
        if (s_destinationWallets[addr] == address(0)) {
            _setDestinationWallet(addr, addr);
        }
    }

    /**
     * Mints an amount of tokens to an address.
     * amount MUST BE lower than maxMintPerTx.
     * MAY set the receiver's destination wallet to itself if it is set to the zero address.
     * Mints Tokens 0 and 1 of amount to `to`.
     * @param sequence receiving address of tokens.
     * @param data N/A
     */
    function _mint(Sequence memory sequence, bytes memory data) internal {
        initializeDestinationWallet(sequence.to);

        for (uint256 i = 0; i < sequence.operations.length; i++) {
            if (
                sequence.operations[i].amount
                    > tokensProperties[sequence.operations[i].id].maxMintAmountPerTx
            ) revert ReputationTokens__MintAmountExceedsLimit();

            s_distributableBalance[sequence.to][sequence.operations[i].id] +=
                sequence.operations[i].amount;

            super._mint(
                sequence.to,
                sequence.operations[i].id,
                sequence.operations[i].amount,
                data
            );
            // emit Mint(msg.sender, sequence.to, sequence.operations);
        }
    }

    /**
     * Sets the target's destination wallet to an address
     * @param target The address who will get its destination wallet set
     * @param destination The address that will receive tokens on behalf of `target`
     */
    function _setDestinationWallet(
        address target,
        address destination
    ) internal {
        s_destinationWallets[target] = destination;
        // emit DestinationWalletSet(target, destination);
    }

    /**
     * Distributes an amount of tokens to an address
     * @param from A distributor who distributes tokens
     * @param sequence The recipient who will receive the tokens
     * @param data N/A
     */
    function _distribute(
        address from,
        Sequence memory sequence,
        bytes memory data
    ) internal {
        initializeDestinationWallet(sequence.to);

        for (uint256 i = 0; i < sequence.operations.length; i++) {
            s_distributableBalance[from][sequence.operations[i].id] -=
                sequence.operations[i].amount;

            // emit Distributed(
            //     from,
            //     AddressToAddressMappingStorage.layout().destinationWallets[sequence
            //         .to],
            //     sequence.operations
            // );

            super.safeTransferFrom(
                from,
                s_destinationWallets[sequence.to],
                sequence.operations[i].id,
                sequence.operations[i].amount,
                data
            );
        }
    }

    /**
     * Migrates all tokens to a new address only.
     * @param from The address who is migrating their tokens.
     * @param to The address who is receiving the migrated tokens.
     *
     * @notice setApprovalForAll(TOKEN_MIGRATOR_ROLE, true) needs to be called prior by the `from` address to succesfully migrate tokens.
     */
    function _migrateOwnershipOfTokens(address from, address to) internal {
        for (uint256 i = 0; i < s_numOfTokens; i++) {
            uint256 balanceOfFrom = balanceOf(from, i);
            // emit OwnershipOfTokensMigrated(from, to, balanceOfFrom);

            super.safeTransferFrom(from, to, i, balanceOfFrom, "");
        }
    }
}
