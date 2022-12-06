// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TransferableRepToken is ERC20 {
    constructor() ERC20("Transferable Rep Token", "TRT") {

    }

    address _multisig;

    function setMultisig(address multisig) public {
        _multisig = multisig;
    }

    function mintToSender(uint256 amount) public {
        _mint(msg.sender, amount);
    }
    
    //multi-sig - can send/receive from anywhere
    //regular peep - can send/receive to/from multi-sig
    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {

        if (msg.sender != _multisig) {
            require(to == _multisig, "Cannot send tokens to anywhere except multisig!");
        }
        
        _transfer(msg.sender, to, amount);
        return true;
    }
}