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

    address[] allTransferableOwners;
    address[] allSoulboundOwners;

    function getSoulboundOwners() public view returns(address[] memory) {
        return allSoulboundOwners;
    }

    function getSoulboundOwnersLegth() public view returns(uint256) {
        return allSoulboundOwners.length;
    }

    function getTransferableOwners() public view returns(address[] memory) {
        return allTransferableOwners;
    }
    
    function getTransferableOwnersLength() public view returns(uint256) {
        return allTransferableOwners.length;
    }

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {

        //loop through token IDs
        for (uint i = 0; i < ids.length; i++) {

            //if soulbound token
            if (ids[i] == 0) {
                //if receiving address currently owns soulbound tokens
                if (balanceOf(to,ids[i]) > 0)
                {
                    bool isPresent = false;
                    //loop through all soulbound token owners
                    for (uint256 j = 0; j < allSoulboundOwners.length; j++) {
                        //if address of receiver is equal to a current owner of soulbound tokens
                        if (allSoulboundOwners[j] == to) {
                            //the address of receiver is equal to a current owner of soulbound tokens
                            isPresent = true;
                            //leave loop for performance
                            break;
                        }
                    }

                    //if address of receiver is not currently recorded as an owner of soulbounds tokens, , but it now owns
                    //soulbound tokens
                    if (!isPresent) {
                        //record address of receiver as an an owner of soulbounds tokens
                        allSoulboundOwners.push(to);
                    }
                }
            }

            //if transferable token
            if (ids[i] == 1) {

                //address(0) mints tokens, thus no recorded entries for its balance exist.
                if (from != address(0)) {
                    //if sending address currently owns no transferable tokens, remove it from being 
                    //recognized as an owner of a transferable token.
                    if (balanceOf(from, ids[i]) <= 0) {
                        removeTransferableRights(from);
                    }
                }

                
                //if receiving address currently owns transferable tokens
                if (balanceOf(to,ids[i]) > 0) {

                    //run a for loop to check if "to" is already present in the transferable tokens owners array.
                    bool isPresent = false;
                    //loop through all transferable token owners
                    for (uint256 j = 0; j < allTransferableOwners.length; j++) {
                        //if address of receiver is equal to a current owner of transferable tokens
                        if (allTransferableOwners[j] == to) {
                            //the address of receiver is equal to a current owner of transferable tokens
                            isPresent = true;
                            //leave loop for performance
                            break;
                        }
                    }

                    //if address of receiver is not currently recorded as an owner of transferable tokens, but it now owns
                    //transferable tokens
                    if (!isPresent) {
                        //record address of receiver as an an owner of transferable tokens
                        allTransferableOwners.push(to);
                    }
                }
            }
        }

        // //loop through transferred token IDs
        // for (uint i = 0; i < ids.length; i++) {
        //     //if soulbound token
        //     if (ids[i] == 0) {
        //         //if "to" address currently owns soulbound tokens 
        //         if (balanceOf(to,ids[i]) > 0)
        //         {
        //             //run a for loop to check if "to" is already present in the soulbound owners array.
        //             bool isPresent = false;
        //             //loop through soulbound owners
        //             for (uint256 j = 0; j < allSoulboundOwners.length; j++) {
        //                 //if soulbound owners index is equal to "to"
        //                 if (allSoulboundOwners[j] == to) {
        //                     //The address already owns a balance of soulbound tokens,
        //                     //therefore no need to add it to the soulbound tokens array
        //                     isPresent = true;
        //                 }
        //             }

        //             //if "to" is not present in soulbound owners array
        //             if (!isPresent) {
        //                 //add "to" to soulbound owners array
        //                 allSoulboundOwners.push(to);
        //             }
        //         }
        //     }
        //     //if transferable token
        //     else if (ids[i] == 1) {
        //         //if transferable token balance of "to" address is greater than 0
        //         if (balanceOf(to,ids[i]) > 0) {

        //             //run a for loop to check if "to" is already present in the transferable tokens owners array.
        //             bool isPresent = false;
        //             //loop through transferable tokens owners
        //             for (uint256 j = 0; j < allTransferableOwners.length; j++) {
        //                 //if transferable tokens index is equal to "to"
        //                 if (allTransferableOwners[j] == to) {
        //                     //The address already owns a balance of transferable tokens,
        //                     //therefore no need to add it to the transferable tokens array
        //                     isPresent = true;
        //                 }
        //             }

        //             //if "to" is not present in transferable tokens owners array
        //             if (!isPresent) {
        //                 //add "to" to transferable tokens owners array
        //                 allTransferableOwners.push(to);
        //             }
        //         }
        //     }
        // }

        super._afterTokenTransfer(operator, from,to, ids, amounts, data);
    }

    function removeTransferableRights(address addr) internal {

        uint256 index;
        for (uint i = 0; i < allTransferableOwners.length - 1; i++) {
            if (allTransferableOwners[i] == addr) {
                index = i;
                break;
            }
        }

        for (uint i = index; i < allTransferableOwners.length - 1; i++) {
            allTransferableOwners[i] = allTransferableOwners[i + 1];
        }
        allTransferableOwners.pop();
    }
}