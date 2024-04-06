// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {
    ERC1155,
    ERC1155URIStorage
} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

import {IReputationTokensErrors} from "./IReputationTokensErrors.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

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
contract ReputationTokens is
    ERC1155URIStorage,
    IReputationTokensErrors,
    AccessControl,
    Ownable
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
    mapping(uint256 => TokenProperties) s_tokensProperties;

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    event Create(uint256 indexed tokenId);
    event Update(uint256 indexed tokenId);

    event Mint(
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 amount
    );

    event Distributed(
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 amount
    );

    event DestinationWalletSet(
        address indexed coreAddress, address indexed destination
    );

    event OwnershipOfTokensMigrated(
        address indexed from, address indexed to, uint256 balance
    );

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    constructor(
        address owner,
        address[] memory admins
    ) Ownable(owner) ERC1155("") {
        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    function batchCreateTokens(TokenProperties[] memory tokensProperties)
        external
    {
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            createToken(tokensProperties[i]);
        }
    }

    function batchUpdateTokensProperties(
        uint256[] memory ids,
        TokenProperties[] memory tokensProperties
    ) external {
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            _updateTokenProperties(ids[i], tokensProperties[i]);
        }
    }

    function batchMint(Sequence[] memory sequences)
        external
        onlyRole(MINTER_ROLE)
    {
        for (uint256 i = 0; i < sequences.length; i++) {
            mint(sequences[i]);
        }
    }

    /**
     * Distributes many tokens to many users.
     * @param from The distributor who will be sending distributing tokens
     * @param data N/A
     */
    function batchDistribute(
        address from,
        Sequence[] memory sequences,
        bytes memory data
    ) external onlyRole(DISTRIBUTOR_ROLE) {
        for (uint256 i = 0; i < sequences.length; i++) {
            distribute(from, sequences[i], data);
        }
    }

    /**
     * Migrates all tokens to a new address only by authorized accounts.
     * @param from The address who is migrating their tokens.
     * @param to The address who is receiving the migrated tokens.
     *
     * @notice setApprovalForAll(TOKEN_MIGRATOR_ROLE, true) needs to be called prior by the `from` address to succesfully migrate tokens.
     */
    function migrateOwnershipOfTokens(
        address from,
        address to
    ) external onlyRole(TOKEN_MIGRATOR_ROLE) {
        _migrateOwnershipOfTokens(from, to);
    }

    /**
     * Sets the destination wallet for msg.sender
     * @param destination The address where tokens will go when msg.sender is sent tokens by a distributor
     */
    function setDestinationWallet(address destination) external {
        _setDestinationWallet(msg.sender, destination);
    }

    function setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    ) external onlyRole(TOKEN_URI_SETTER_ROLE) {
        _setURI(tokenId, tokenURI);
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Public Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function createToken(TokenProperties memory tokenProperties)
        public
        onlyRole(TOKEN_CREATOR_ROLE)
        returns (uint256 tokenId)
    {
        tokenId = _createToken(tokenProperties);
    }

    function updateTokenProperties(
        uint256 id,
        TokenProperties memory tokenProperties
    ) public onlyRole(TOKEN_UPDATER_ROLE) {
        _updateTokenProperties(id, tokenProperties);
    }

    function mint(Sequence memory sequence) public onlyRole(MINTER_ROLE) {
        if (!hasRole(DISTRIBUTOR_ROLE, sequence.to)) {
            revert ReputationTokens__CanOnlyMintToDistributor();
        }

        _mint(sequence, "");
    }

    /**
     * Distributes tokens to a user.
     * @param from The distributor who will be sending distributing tokens
     * @param sequence The recipient who will receive the distributed tokens
     * @param data N/A
     */
    function distribute(
        address from,
        Sequence memory sequence,
        bytes memory data
    ) public onlyRole(DISTRIBUTOR_ROLE) {
        _distribute(from, sequence, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        if (s_tokensProperties[id].tokenType == TokenType.Soulbound) {
            revert ReputationTokens__CannotTransferSoulboundToken();
        }

        if (s_tokensProperties[id].tokenType == TokenType.Redeemable) {
            if (hasRole(BURNER_ROLE, to)) {
                s_burnedBalance[to][id] += amount;
            } else {
                revert ReputationTokens__CannotTransferRedeemableToNonBurner();
            }
        }

        if (amount > getTransferrableBalance(from, id)) {
            revert ReputationTokens__CantSendThatManyTransferrableTokens();
        }

        super.safeTransferFrom(from, to, id, amount, data);
    }

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

        emit Create(tokenId);

        tokenId = newTokenId;
    }

    function _updateTokenProperties(
        uint256 id,
        TokenProperties memory tokenProperties
    ) internal {
        if (id >= s_numOfTokens) {
            revert ReputationTokens__CannotUpdateNonexistentTokenType();
        }

        s_tokensProperties[id].tokenType = tokenProperties.tokenType;

        s_tokensProperties[id].maxMintAmountPerTx =
            tokenProperties.maxMintAmountPerTx;

        emit Update(id);
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
                    > s_tokensProperties[sequence.operations[i].id]
                        .maxMintAmountPerTx
            ) revert ReputationTokens__MintAmountExceedsLimit();

            s_distributableBalance[sequence.to][sequence.operations[i].id] +=
                sequence.operations[i].amount;

            super._mint(
                sequence.to,
                sequence.operations[i].id,
                sequence.operations[i].amount,
                data
            );

            emit Mint(
                msg.sender,
                sequence.to,
                sequence.operations[i].id,
                sequence.operations[i].amount
            );
        }
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

            emit Distributed(
                from,
                s_destinationWallets[sequence.to],
                sequence.operations[i].id,
                sequence.operations[i].amount
            );

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
     * Sets the target's destination wallet to an address
     * @param target The address who will get its destination wallet set
     * @param destination The address that will receive tokens on behalf of `target`
     */
    function _setDestinationWallet(
        address target,
        address destination
    ) internal {
        s_destinationWallets[target] = destination;
        emit DestinationWalletSet(target, destination);
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
            emit OwnershipOfTokensMigrated(from, to, balanceOfFrom);

            super.safeTransferFrom(from, to, i, balanceOfFrom, "");
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External & Public View & Pure Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    function getTransferrableBalance(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 transferrableBalance) {
        uint256 balance = balanceOf(addr, tokenId);
        transferrableBalance = balance - getDistributableBalance(addr, tokenId)
            - getBurnedBalance(addr, tokenId);
    }

    function getBurnedBalance(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 burnedBalance) {
        burnedBalance = s_burnedBalance[addr][tokenId];
    }

    function getDistributableBalance(
        address addr,
        uint256 tokenId
    ) public view returns (uint256 distributableBalance) {
        distributableBalance = s_distributableBalance[addr][tokenId];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getDestinationWallet(address addr)
        external
        view
        returns (address)
    {
        return s_destinationWallets[addr];
    }

    function getMaxMintPerTx(uint256 index) external view returns (uint256) {
        return s_tokensProperties[index].maxMintAmountPerTx;
    }

    function getNumOfTokenTypes() external view returns (uint256) {
        return s_numOfTokens;
    }

    function getTokenProperties(uint256 id)
        external
        view
        returns (TokenProperties memory)
    {
        return s_tokensProperties[id];
    }
}
