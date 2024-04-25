// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @author Jacob Homanics
 */
interface IReputationTokensTypes {
    enum TokenType {
        Transferable,
        Soulbound,
        Redeemable
    }
}
