// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.18;

// import {
//     ERC1155Upgradeable,
//     ERC1155URIStorageUpgradeable
// } from
//     "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";

// import {OwnableUpgradeable} from
//     "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import {AccessControlUpgradeable} from
//     "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

// import {IReputationTokensErrors} from "./IReputationTokensErrors.sol";
// import {IReputationTokensEvents} from "./IReputationTokensEvents.sol";

// import {ReputationTokensBase} from "./ReputationTokensBase.sol";

// /**
//  * @title Reputation Tokens
//  * @author Jacob Homanics
//  */
// contract ReputationTokensUpgradeable is ReputationTokensBase {
//     ////////////////////////////////////////////////////////////////////////////
//     ////////////////////////////////////////////////////////////////////////////
//     // Functions
//     ////////////////////////////////////////////////////////////////////////////
//     ////////////////////////////////////////////////////////////////////////////
//     function initialize(address newOwner, address[] memory admins) external {
//         __Ownable_init(newOwner);
//         __ERC1155_init("");

//         for (uint256 i = 0; i < admins.length; i++) {
//             _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
//         }
//     }
// }
