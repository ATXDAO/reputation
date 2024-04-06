// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {
    ERC1155,
    ERC1155URIStorage
} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

import {IReputationTokensErrors} from "./IReputationTokensErrors.sol";
import {IReputationTokensEvents} from "./IReputationTokensEvents.sol";
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
    IReputationTokensEvents,
    AccessControl,
    Ownable
{
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // Types
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    enum TokenType {
        Transferable,
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
        address recipient;
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

    /**
     * Creates many new token types.
     * @param tokensProperties The array of properties to set to each new token type created.
     */
    function batchCreateTokens(TokenProperties[] memory tokensProperties)
        external
        onlyRole(TOKEN_CREATOR_ROLE)
    {
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            createToken(tokensProperties[i]);
        }
    }

    /**
     * Updates many token types' properties.
     * @param ids the IDs of the tokens to update properties for.
     * @param tokensProperties The properties to set for the supplied tokens.
     */
    function batchUpdateTokensProperties(
        uint256[] memory ids,
        TokenProperties[] memory tokensProperties
    ) external onlyRole(TOKEN_UPDATER_ROLE) {
        for (uint256 i = 0; i < tokensProperties.length; i++) {
            _updateTokenProperties(ids[i], tokensProperties[i]);
        }
    }

    /**
     * Given many sequences, mints many operations of tokens to the recipients.
     * @param sequences Contains the recipients and tokens operations to mint tokens to.
     */
    function batchMint(Sequence[] memory sequences)
        external
        onlyRole(MINTER_ROLE)
    {
        for (uint256 i = 0; i < sequences.length; i++) {
            mint(sequences[i]);
        }
    }

    /**
     * Distributes many tokens to a user.
     * @param from The distributor who will be sending distributing tokens.
     * @param sequences Contains the recipients and tokens operations to distribute tokens.
     */
    function batchDistribute(
        address from,
        Sequence[] memory sequences
    ) external onlyRole(DISTRIBUTOR_ROLE) {
        for (uint256 i = 0; i < sequences.length; i++) {
            distribute(from, sequences[i]);
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
        for (uint256 i = 0; i < s_numOfTokens; i++) {
            uint256 balanceOfFrom = balanceOf(from, i);
            emit OwnershipOfTokensMigrated(from, to, balanceOfFrom);

            super.safeTransferFrom(from, to, i, balanceOfFrom, "");
        }
    }

    /**
     * Sets the destination wallet for msg.sender
     * @param destination The address where tokens will go when msg.sender is sent tokens by a distributor
     */
    function setDestinationWallet(address destination) external {
        _setDestinationWallet(msg.sender, destination);
    }

    /**
     * Sets the tokenURI for a given token type.
     * @param tokenId token to update URI for.
     * @param tokenURI updated tokenURI.
     */
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

    /**
     * Creates a new token type with custom properties.
     * @param tokenProperties properties to assign to the new token type.
     */
    function createToken(TokenProperties memory tokenProperties)
        public
        onlyRole(TOKEN_CREATOR_ROLE)
        returns (uint256 tokenId)
    {
        uint256 newTokenId = s_numOfTokens;
        s_numOfTokens++;

        _updateTokenProperties(newTokenId, tokenProperties);

        emit Create(tokenId);

        tokenId = newTokenId;
    }

    /**
     * Updates an existing token's properties.
     * @param id The id of the token.
     * @param tokenProperties The new properties of the token.
     */
    function updateTokenProperties(
        uint256 id,
        TokenProperties memory tokenProperties
    ) public onlyRole(TOKEN_UPDATER_ROLE) {
        _updateTokenProperties(id, tokenProperties);
    }

    /**
     * Given a sequence, mints an operation of tokens to the recipient.
     * @dev recipient must have DISTRIBUTOR_ROLE.
     * @param sequence Contains the recipient and token operations to mint tokens.
     */
    function mint(Sequence memory sequence) public onlyRole(MINTER_ROLE) {
        if (!hasRole(DISTRIBUTOR_ROLE, sequence.recipient)) {
            revert ReputationTokens__CanOnlyMintToDistributor();
        }

        for (uint256 i = 0; i < sequence.operations.length; i++) {
            if (
                sequence.operations[i].amount
                    > s_tokensProperties[sequence.operations[i].id]
                        .maxMintAmountPerTx
            ) revert ReputationTokens__MintAmountExceedsLimit();
        }

        _initializeDestinationWallet(sequence.recipient);

        for (uint256 i = 0; i < sequence.operations.length; i++) {
            s_distributableBalance[sequence.recipient][sequence.operations[i].id]
            += sequence.operations[i].amount;

            super._mint(
                sequence.recipient,
                sequence.operations[i].id,
                sequence.operations[i].amount,
                ""
            );

            emit Mint(
                msg.sender,
                sequence.recipient,
                sequence.operations[i].id,
                sequence.operations[i].amount
            );
        }
    }

    /**
     * Distributes tokens to a user.
     * @param from The distributor who will be sending distributing tokens.
     * @param sequence Contains the recipient and token operations to distribute tokens.
     */
    function distribute(
        address from,
        Sequence memory sequence
    ) public onlyRole(DISTRIBUTOR_ROLE) {
        _initializeDestinationWallet(sequence.recipient);

        for (uint256 i = 0; i < sequence.operations.length; i++) {
            s_distributableBalance[from][sequence.operations[i].id] -=
                sequence.operations[i].amount;

            emit Distributed(
                from,
                s_destinationWallets[sequence.recipient],
                sequence.operations[i].id,
                sequence.operations[i].amount
            );

            super.safeTransferFrom(
                from,
                s_destinationWallets[sequence.recipient],
                sequence.operations[i].id,
                sequence.operations[i].amount,
                ""
            );
        }
    }

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`.
     *
     * WARNING: This function can potentially allow a reentrancy attack when transferring tokens
     * to an untrusted contract, when invoking {onERC1155Received} on the receiver.
     * Ensure to follow the checks-effects-interactions pattern and consider employing
     * reentrancy guards when interacting with untrusted contracts.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     *
     *
     * ReputationTokens:
     *
     *
     * CANNOT transfer Soulbound tokens
     * CAN transfer Redeemable tokens ONLY TO accounts with the BURNER_ROLE.
     * amount MUST be greater than transferable balance
     * CAN transfer Transferable tokens.
     */
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

    /**
     * Updates an existing token's properties.
     * @param id The id of the token.
     * @param tokenProperties The new properties of the token.
     */
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
     * Sets the destination wallet for the provided address if the destination is currently unset.
     * @param addr address who may get their destination wallet set
     */
    function _initializeDestinationWallet(address addr) internal {
        if (s_destinationWallets[addr] == address(0)) {
            _setDestinationWallet(addr, addr);
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
