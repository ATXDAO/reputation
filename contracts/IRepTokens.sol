// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

interface IRepTokens is IAccessControl, IERC1155
{
    function MINTER_ROLE() external view returns(bytes32);
    function DISTRIBUTOR_ROLE() external view returns(bytes32);
    function BURNER_ROLE() external view returns(bytes32);
    function SOULBOUND_TOKEN_TRANSFERER_ROLE() external view returns(bytes32);

    function mint(
        address to,
        uint256 amount,
        bytes memory data
    ) external;

    function setMaxMintAmount(
        uint256 value
    ) external;

    //from : distributor
    //to : address
    function distribute(
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) external;

    //this needs to be called beforehand by address that wants to transfer its soulbound tokens:
    //setApprovalForAll(SOULBOUND_TOKEN_TRANSFERER_ROLE, true)
    function fulfillTransferSoulboundTokensRequest(
        address from,
        address to
    ) external;


    function getOwnersOfTokenID(
        uint256 tokenID
    ) external view returns (address[] memory);

    function getOwnersOfTokenIDLength(
        uint256 tokenID
    ) external view returns (uint256);

    function togglePause() external;
}
