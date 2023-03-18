// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IRepTokens.sol";

contract RepTokens is
    IRepTokens,
    AccessControl,
    Ownable,
    DefaultOperatorFilterer,
    ERC1155,
    Pausable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant SOULBOUND_TOKEN_TRANSFERER_ROLE = keccak256("SOULBOUND_TOKEN_TRANSFERER_ROLE");

    uint256 public maxMintAmountPerTx;
    mapping(uint256 => address[]) ownersOfTokenTypes;

    //id 0 = soulbound token
    //id 1 = transferable token
    constructor(
        address[] memory admins,
        uint256 _maxMintAmountPerTx
    )
        ERC1155(
            "ipfs://bafybeih3e3hyanol5zjsnyzxss72p3fosy6jsw46wr77e5rlstz5zapxru/{id}"
        )
    {
        for (uint256 i = 0; i < admins.length; i++) {
            _setupRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }

        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function uri(
        uint256 _tokenid
    ) public pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "ipfs://bafybeih3e3hyanol5zjsnyzxss72p3fosy6jsw46wr77e5rlstz5zapxru/",
                    Strings.toString(_tokenid)
                )
            );
    }

    function mint(
        address to,
        uint256 amount,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) whenNotPaused {
        require(
            amount <= maxMintAmountPerTx,
            "Cannot mint that many tokens in a single transaction!"
        );

        require(
            hasRole(DISTRIBUTOR_ROLE, to),
            "Minter can only mint tokens to distributors!"
        );

        //mints an amount of soulbound tokens to an address.
        super._mint(to, 0, amount, data);
        //mints an amount of transferable tokens to an address.
        super._mint(to, 1, amount, data);
    }

    function setMaxMintAmount(
        uint256 value
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxMintAmountPerTx = value;
    }

    //from : minter
    //to : distributor
    // function transferFromMinterToDistributor(
    //     address from,
    //     address to,
    //     uint256 amount,
    //     bytes memory data
    // ) public onlyRole(MINTER_ROLE) whenNotPaused {
    //     require(
    //         hasRole(DISTRIBUTOR_ROLE, to),
    //         "Minter can only send tokens to distributors!"
    //     );
    //     super.safeTransferFrom(from, to, 0, amount, data);
    //     super.safeTransferFrom(from, to, 1, amount, data);
    // }

    mapping (address=> address) walletToSecureWallet;

    //from : distributor
    //to : address
    function distribute(
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) public onlyRole(DISTRIBUTOR_ROLE) whenNotPaused {


        // address receivingWallet = 
        super.safeTransferFrom(from, to, 0, amount, data);
        super.safeTransferFrom(from, to, 1, amount, data);
    }

    //from : address
    //to : burner
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override(ERC1155, IERC1155) onlyAllowedOperator(from) {
        require(
            id == 1, 
            "Can only send a redeemable token!"
        );

        require(
            !hasRole(DISTRIBUTOR_ROLE, from),
            "Distributors can only send tokens in pairs through the transferFromDistributor function!"
        );

        require(
            !hasRole(BURNER_ROLE, from),
            "Burners cannot send tokens!"
        );
        
        require(
            hasRole(BURNER_ROLE, to),
            "Can only send Redeemable Tokens to burners!"
        );

        super.safeTransferFrom(from, to, id, amount, data);
    }

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        //loop through transferred token IDs
        for (uint i = 0; i < ids.length; i++) {
            //if the tokenID balance of the receiving address is greater than zero after the transfer, then check to see if the receiving
            //address needs to be added as an owner to the tokenID
            if (balanceOf(to, ids[i]) > 0) {
                addAddressAsOwnerOfTokenIDIfNotAlreadyPresent(to, ids[i]);
            }

            //address(0) cannot have a balance of tokens so check to see if it is the sender (usually from == address(0) in the case of minting)
            if (from != address(0)) {
                //if the tokenID balance of the sending address is less than zero after the transfer, then remove it from being an owner
                //of the tokenID
                if (balanceOf(from, ids[i]) <= 0) {
                    removeAddressAsOwnerOfTokenID(from, ids[i]);
                }
            }
        }

        super._afterTokenTransfer(operator, from, to, ids, amounts, data);
    }

    //this needs to be called beforehand by address that wants to transfer its soulbound tokens:
    //setApprovalForAll(SOULBOUND_TOKEN_TRANSFERER_ROLE, true)
    function fulfillTransferSoulboundTokensRequest(
        address from,
        address to
    ) public onlyRole(SOULBOUND_TOKEN_TRANSFERER_ROLE) {
        super.safeTransferFrom(from, to, 0, balanceOf(from, 0), "");
        super.safeTransferFrom(from, to, 1, balanceOf(from, 1), "");
    }

    //@addrToCheck: Address to check during _afterTokenTransfer if it is already registered
    //as an owner of @tokenID.
    //@tokenID: the ID of the token selected.
    function addAddressAsOwnerOfTokenIDIfNotAlreadyPresent(
        address addrToCheck,
        uint256 tokenID
    ) internal {
        //get all owners of a given tokenID.
        address[] storage owners = ownersOfTokenTypes[tokenID];

        bool isPresent = false;

        //loop through all token owners of selected tokenID.
        for (uint256 i = 0; i < owners.length; i++) {
            //if address of receiver is found within selected tokenID's owners.
            if (owners[i] == addrToCheck) {
                //the address of receiver is equal to a current owner of the selected tokenID.
                isPresent = true;
                //leave loop for performance
                break;
            }
        }

        //if address of receiver is not currently registered as an owner of selected tokenID, but it now
        //holds a positive balance of the selected tokenID
        if (!isPresent) {
            //register address of receiver as an an owner of selected tokenID
            owners.push(addrToCheck);
        }
    }

    function removeAddressAsOwnerOfTokenID(
        address addrToCheck,
        uint256 id
    ) internal {
        address[] storage owners = ownersOfTokenTypes[id];

        uint256 index;
        for (uint i = 0; i < owners.length - 1; i++) {
            if (owners[i] == addrToCheck) {
                index = i;
                break;
            }
        }

        for (uint i = index; i < owners.length - 1; i++) {
            owners[i] = owners[i + 1];
        }
        owners.pop();
    }

    function getOwnersOfTokenID(
        uint256 tokenID
    ) public view returns (address[] memory) {
        return ownersOfTokenTypes[tokenID];
    }

    function getOwnersOfTokenIDLength(
        uint256 tokenID
    ) public view returns (uint256) {
        return ownersOfTokenTypes[tokenID].length;
    }

    function togglePause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (paused()) {
            _unpause();
        } else {
            _pause();
        }
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC1155, IERC1155) onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }
    
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override(ERC1155, IERC1155) onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, IERC165, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function renounceRole(bytes32 role, address account) public virtual override(IAccessControl, AccessControl) {
        require(
            !hasRole(BURNER_ROLE, account),
            "Burners cannot renounce their own roles!"
        );

        super.renounceRole(role, account);
    }
}
