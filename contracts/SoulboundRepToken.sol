// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SoulboundRepToken is ERC20 {
    
    constructor() ERC20("Soulbound Rep Token", "SRT") {

    }

    address _multisig;

    function setMultisig(address multisig) public {
        _multisig = multisig;
    }

    function getMultisig() public view returns(address) {
        return _multisig;
    }

    function mintToSender(uint256 amount) public {
        _mint(msg.sender, amount);
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        //If sender is not the DAO multi-sig, then they are a random person trying to transfer the token.
        if (msg.sender != _multisig) {
            //The token is soulbound to the sender so the transaction should revert and not allow transferring of tokens.
            require(true == false, "Only the multi-sig is able to transfer tokens!");           
        }

        _transfer(msg.sender, to, amount);
        return true;
    }
}