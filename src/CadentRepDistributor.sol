// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IRepTokens} from "./IRepTokens.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract CadentRepDistributor is ERC1155Holder {
    error CadentRepDistributor__NOT_ENOUGH_TIME_PASSED();
    error CadentRepDistributor__NOT_ENOUGH_TOkENS_TO_DISTRIBUTE();

    IRepTokens s_rep;

    uint256 s_amountToDistributePerCadence;
    uint256 s_cadence;

    mapping(address => uint256) addressToLastClaimDate;

    event DistributedRep(address indexed recipient);

    constructor(address rep, uint256 amountDistributedPerCadence, uint256 cadenceCycle) {
        s_rep = IRepTokens(rep);
        s_amountToDistributePerCadence = amountDistributedPerCadence;
        s_cadence = cadenceCycle;
    }

    function claim() external {
        if (getRemainingTime(msg.sender) > 0) {
            revert CadentRepDistributor__NOT_ENOUGH_TIME_PASSED();
        }

        if (
            s_rep.balanceOf(address(this), 0) <= s_amountToDistributePerCadence
                || s_rep.balanceOf(address(this), 1) <= s_amountToDistributePerCadence
        ) {
            revert CadentRepDistributor__NOT_ENOUGH_TOkENS_TO_DISTRIBUTE();
        }

        s_rep.distribute(address(this), msg.sender, s_amountToDistributePerCadence, "");

        addressToLastClaimDate[msg.sender] = block.timestamp;
        emit DistributedRep(msg.sender);
    }

    function getRemainingTime(address addr) public view returns (int256) {
        int256 lastClaimTime = int256(addressToLastClaimDate[addr]);
        return lastClaimTime != 0 ? (lastClaimTime + int256(s_cadence) - int256(block.timestamp)) : int256(0);
    }

    function getAmountToDistributePerCadence() external view returns (uint256) {
        return s_amountToDistributePerCadence;
    }

    function getCadence() external view returns (uint256) {
        return s_cadence;
    }
}
