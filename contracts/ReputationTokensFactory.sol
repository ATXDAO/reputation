// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import {ReputationTokensUpgradeable} from "./ReputationTokensUpgradeable.sol";

contract ReputationTokensFactory is AccessControl {
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");

    address public s_implementation;

    uint256 public contractInstanceCount;
    mapping(uint256 => ReputationTokensUpgradeable) public instances;

    event CreatedNewInstance(address indexed creator, address indexed instance);

    constructor(address[] memory _admins, address implementation) {
        for (uint256 i = 0; i < _admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, _admins[i]);
        }

        if (implementation != address(0)) {
            s_implementation = implementation;
        }
    }

    function createNewInstance(
        address owner,
        address[] memory admins,
        address[] memory tokenUpdaters
    ) external returns (address instanceAddress) {
        address clone = Clones.clone(address(s_implementation));

        ReputationTokensUpgradeable instance = ReputationTokensUpgradeable(
            clone
        );

        instance.initialize(owner, admins, tokenUpdaters);

        instances[contractInstanceCount] = instance;
        contractInstanceCount++;

        emit CreatedNewInstance(msg.sender, address(instance));

        instanceAddress = address(instance);
    }

    function setImplementation(address implementation) external {
        if (implementation != address(0)) {
            s_implementation = implementation;
        }
    }
}
