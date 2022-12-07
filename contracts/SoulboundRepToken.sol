// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./RepTokensManager.sol";

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

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        require(true == false, "This token is not tradeable!");           

        _transfer(msg.sender, to, amount);
        return true;
    }
}