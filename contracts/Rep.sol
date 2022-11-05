// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract REP is ERC20, AccessControl {
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

    address _multiSig;

    constructor(address multiSig, uint256 initialMultisigSupply)
        ERC20("RepToken", "Rep")
    {
        _multiSig = multiSig;
        _setupRole(MULTISIG_ROLE, multiSig);
        mint(multiSig, initialMultisigSupply);
    }

    function multiSigMintToSelf(uint256 numOfTokens)
        public
        onlyRole(MULTISIG_ROLE)
    {
        mint(msg.sender, numOfTokens);
    }

    //numOfTokens is whole number
    function mint(address addr, uint256 numOfTokens) internal {
        uint256 numOfTokensToMintWithDecimalPlaces = numOfTokens *
            10**decimals();

        _mint(addr, numOfTokensToMintWithDecimalPlaces);
    }

    //Leave in if tokens are soulbound for DAO members, but
    //still giving the capability for the multi-sig to reward tokens

    //The multi-sig has the ability to transfer tokens freely.
    //A token holder may only transfer tokens back to the multi-sig - impossible to transfer REP to any other address.
    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        if (msg.sender != _multiSig) {
            bool isPresent = false;
            for (uint256 i = 0; i < smartContractAllowList.length; i++) {
                if (msg.sender == smartContractAllowList[i]) {
                    isPresent = true;
                    break;
                }
            }

            //is authorized smart contract
            if (isPresent) {}
            //is DAO member
            else {
                require(
                    to == _multiSig,
                    "You can only send REP tokens back to the multi-sig!"
                );
            }
        }

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    address[] smartContractAllowList;

    function addToAllowList(address addr) public onlyRole(MULTISIG_ROLE) {
        require(
            isContract(addr),
            "The passed in address is not a smart contract!"
        );

        smartContractAllowList.push(addr);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
