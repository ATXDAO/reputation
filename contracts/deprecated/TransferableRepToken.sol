// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./RepTokensManager.sol";

contract TransferableRepToken is ERC20 {
    address repTokensManager;

    constructor() ERC20("Transferable Rep Token", "TRT") {}

    address _multisig;

    function setMultisig(address multisig) public {
        _multisig = multisig;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    //multi-sig - can send/receive from anywhere
    //regular peep - can send/receive to/from multi-sig
    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        // if (msg.sender != RepTokensManager(repTokensManager).getMultisig()) {
        //     require(to == _multisig, "Cannot send tokens to anywhere except multisig!");
        // }

        _transfer(msg.sender, to, amount);
        return true;
    }
}
