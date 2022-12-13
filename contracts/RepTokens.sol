// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract RepTokens is ERC1155, AccessControl {

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

    //EXTREME CONSIDERATION SHOULD BE MADE FOR WHICH ADDRESS(ES) ARE GRANTED THIS ROLE.
    //Addresses granted this role should be multisigs or smart contracts that have been proven to be trusted.
    //Addresses granted this role should only ever change the maxTokensPerDistribution if there is a fault
    //in how the socio-economic system is playing out in regards to the tokens, I.E. if too little tokens are being rewarded
    //or if too many are being handed out.
    bytes32 public constant MAX_TOKENS_PER_DISTRIBUTION_SETTER_ROLE = keccak256("MAX_TOKENS_PER_DISTRIBUTION_SETTER_ROLE");

    //id 0 = soulbound token
    //id 1 = transferable token

    //The admin role needs to be a multi-sig used by trusted members of the DAO.
    //The admin role is used to grant/revoke distributor and burner roles to addresses at will.
    constructor() ERC1155("") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        //either set here or after role is set up
        maxTokensPerDistribution = 15000;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {

        //if soulbound token, then revert transaction.
        if (id == 0) {
            require(true == false, "Cannot trade soulbound token!");
        }
        //If transferable token, then check to see if the recipient address has been granted the BURNER_ROLE.
        else if (id == 1) {
            require(hasRole(BURNER_ROLE, to), "Only a burner may succesfully be a recipient of a transferable token");
            super.safeTransferFrom(from, to, id, amount, data);
        }
        else {
            require(id < 2, "Please provide a valid token to transfer!"); 
        }
    }

    //maxTokensPerDistribution forces a hard lock on distributing tokens.
    //This prevents distributors from being bad actors or making accidents by distributing enough to
    //completely destroy the token economy.
    //It also prevents bad actors by forcing multiple transactions and multiple transaction fees - very
    //similar to how ethereum gas, itself, works. 
    uint256 maxTokensPerDistribution;

    function setMaxTokensPerDistribution(uint256 maxTokens) public onlyRole(MAX_TOKENS_PER_DISTRIBUTION_SETTER_ROLE) {
        maxTokensPerDistribution = maxTokens;
    }

    //The act of distributing is done only by an address (distributor) granted the DISTRIBUTOR_ROLE.
    //The distributor may call this function to send a provided amount of transferable and soulbound tokens to an address.
    function distribute(
        address to,
        uint256 amount,
        bytes memory data
    ) public {

        require(hasRole(DISTRIBUTOR_ROLE, _msgSender()), "Only a distributor may succesfully call this function!");
        require(amount <= maxTokensPerDistribution, "Cannot distribute that many tokens in one transaction!");
        //mints an amount of soulbound tokens to an address.
        super._mint(to, 0, amount, data);
        //mints an amount of transferable tokens to an address.
        super._mint(to, 1, amount, data);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    mapping(uint256 => address[]) ownersOfTokenTypes;

    function getOwnersOfTokenID(uint256 tokenID) public view returns(address[] memory) {
        return ownersOfTokenTypes[tokenID];
    }

    function getOwnersOfTokenIDLength(uint256 tokenID) public view returns(uint256) {
        return ownersOfTokenTypes[tokenID].length;
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

        super._afterTokenTransfer(operator, from,to, ids, amounts, data);
    }

    //@addrToCheck: Address to check during _afterTokenTransfer if it is already registered
    //as an owner of @tokenID.
    //@tokenID: the ID of the token selected.
    function addAddressAsOwnerOfTokenIDIfNotAlreadyPresent(address addrToCheck, uint256 tokenID) internal {

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

    function removeAddressAsOwnerOfTokenID(address addrToCheck, uint256 id) internal {

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
}