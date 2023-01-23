// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./SoulboundRepToken.sol";
import "./TransferableRepToken.sol";

contract RepTokenManager {
    address transferableRepToken;
    address soulboundRepToken;

    address _multisig;

    function setMultisig(address multisig) public {
        _multisig = multisig;
    }

    function getMultisig() public view returns (address) {
        return _multisig;
    }

    constructor() {}

    //multi-sig or another verified address/contract
    function mintTo(address addr, uint256 amount) public {
        require(
            _multisig == msg.sender,
            "Only multisig can mint new tokens to other addresses!"
        );

        TransferableRepToken(transferableRepToken).mint(addr, amount);
        SoulboundRepToken(soulboundRepToken).mint(addr, amount);
    }

    function transferToAddress(address addr, uint256 amount) public {
        IERC20(transferableRepToken).transfer(addr, amount);
        IERC20(soulboundRepToken).transfer(addr, amount);
    }

    function transferToSender(uint256 amount) public {
        transferToAddress(msg.sender, amount);
    }
}
