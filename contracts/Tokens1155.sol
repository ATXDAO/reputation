// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Tokens1155 is ERC1155, AccessControl {

    //LOOK INTO MAKING A FUNCTION THAT SHOWS ALL THE CURRENT OWNERS AND THEIR BALANCES

    //LOOK INTO A WAY OF ALLOWING AN ADDRESS TO MAKE A REQUEST TO TRANSFER ITS SOULBOUND TOKENS.
    //HELPFUL IN CASES OF A COMPROMISED WALLET OR CHANGING OF WALLET
    //CURRENTLY, THE THOUGHT IS THAT AN ADDRESS WILL MAKE A REQUEST TO TRANSFER ITS SOULBOUND TOKENS,
    //THEN THE ADMIN ROLE (A MULTISIG) NEEDS TO APPROVE THE REQUEST. THIS GIVES SEVERAL EYES ON THE REQUEST
    //AND EACH DECIDER FROM THE MULTISIG NEEDS TO ACT IN GOOD FAITH ON WHETHER THE REQUEST IS VALID (I.E. not filled with bad intent, harm, etc.)

    //EXTREME CONSIDERATION SHOULD BE MADE FOR WHICH ADDRESSES ARE GRANTED THIS ROLE.
    //Addresses granted this role should be multisigs or smart contracts that have been proven to be trusted.
    //Addresses granted this role have the ability to mint tokens to addresses on demand without limit.
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");

    //EXTREME CONSIDERATION SHOULD BE MADE FOR WHICH ADDRESSES ARE GRANTED THIS ROLE.
    //Addresses granted this role should be multisigs or smart contracts that have been proven to be trusted.
    //Addresses granted this role should only be trusted to ever receive a transferable token and never move it
    //or use it with ill intent.
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    //id 0 = soulbound token
    //id 1 = transferable token

    //The admin role needs to be a multi-sig used by trusted members of the DAO.
    //The admin role is used to grant/revoke distributor and burner roles to addresses at will.
    constructor(
        // address[] memory distributors, 
        // address[] memory burners
        )
        ERC1155("") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // for (uint256 i = 0; i < distributors.length; i++) {
        //     _setupRole(DISTRIBUTOR_ROLE, distributors[i]);
        // }
        // for (uint256 i = 0; i < burners.length; i++) {
        //     _setupRole(BURNER_ROLE, burners[i]);
        // }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {

        if (id == 0) {
            require(true == false, "Cannot trade soulbound token!");
        }
        else if (id == 1) {
            require(hasRole(BURNER_ROLE, to), "Can only transfer the transferable token to a qualified burner address!");
            super.safeTransferFrom(from, to, id, amount, data);
        }
        else {
            require(id < 2, "Please provide a valid token to transfer!"); 
        }
    }

    function distribute(
        address to,
        uint256 amount,
        bytes memory data
    ) public {

        require(hasRole(DISTRIBUTOR_ROLE, _msgSender()), "minter role required");
        super._mint(to, 0, amount, data);
        super._mint(to, 1, amount, data);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}