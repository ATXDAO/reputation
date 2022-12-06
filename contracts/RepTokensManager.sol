// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RepTokenManager {

    address transferableRepToken;
    address soulboundRepToken;

    constructor() {

    }

    function mintToSender(uint256 amount) public {
        IERC20(transferableRepToken).transfer(msg.sender, amount);
        IERC20(soulboundRepToken).transfer(msg.sender, amount);
    }
}